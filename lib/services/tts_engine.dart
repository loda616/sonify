import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa_onnx;
import 'package:uuid/uuid.dart';
import 'package:sonify/core/errors/exceptions.dart';

class TtsEngine {
  sherpa_onnx.OfflineTts? _tts;
  bool _isInitialized = false;
  bool _assetsCopied = false;

  /// Lock to prevent concurrent initialization — replaces busy-wait polling
  Completer<void>? _initLock;

  // ──── Cached paths for faster subsequent initializations ────
  static String? _cachedModelPath;
  static String? _cachedTokensPath;
  static String? _cachedDataDir;

  // ──── Cached asset manifest ────
  static AssetManifest? _cachedAssetManifest;
  static final Map<String, List<String>> _cachedModelAssets = {};

  // ──── Model Configuration ────
  static const String _tokensFile = 'tokens.txt';
  static const String _espeakDataDir = 'espeak-ng-data';
  static const String _assetPrefix = 'assets/tts-model';
  static const String _sharedEspeakPath = 'assets/espeak-ng-data';

  String _currentModelDir = 'vits-piper-en_US-lessac-medium';
  bool _isCurrentModelBundled = true;

  bool get isInitialized => _isInitialized;
  int get numSpeakers => _tts?.numSpeakers ?? 0;

  /// Changes the active model. If isBundled is true, expects it in assets/.
  /// Otherwise expects it in downloaded_models directory.
  Future<void> setModel(String directoryName, {required bool isBundled}) async {
    if (_currentModelDir == directoryName &&
        _isCurrentModelBundled == isBundled &&
        _isInitialized) {
      return;
    }
    _currentModelDir = directoryName;
    _isCurrentModelBundled = isBundled;
    _assetsCopied = false;
    // Clear cached paths when model changes
    _cachedModelPath = null;
    _cachedTokensPath = null;
    _cachedDataDir = null;
    dispose();
    await initialize();
  }

  /// Initialize the engine. Safe to call multiple times.
  /// First call copies model assets to disk (~3-10 sec on first launch).
  Future<void> initialize() async {
    if (_isInitialized) return;

    // If another initialization is in progress, wait for it instead of busy-polling
    if (_initLock != null) {
      await _initLock!.future;
      return;
    }

    _initLock = Completer<void>();
    try {
      // Use cached paths if available for faster re-initialization
      if (_cachedModelPath != null &&
          _cachedTokensPath != null &&
          _cachedDataDir != null) {
        debugPrint('Using cached paths for model: $_currentModelDir');
      } else {
        // Step 1 & 3: Resolve Paths and Copy Assets if bundled
        String modelRootPath;
        if (_isCurrentModelBundled) {
          if (!_assetsCopied) {
            await _copyModelAssets(_currentModelDir);
            _assetsCopied = true;
          }
          final appDir = await getApplicationSupportDirectory();
          modelRootPath = p.join(appDir.path, _currentModelDir);
        } else {
          final appDir = await getApplicationSupportDirectory();
          modelRootPath = p.join(
            appDir.path,
            'downloaded_models',
            _currentModelDir,
          );
        }

        // Step 2: Initialize sherpa-onnx native bindings
        sherpa_onnx.initBindings();

        // Find the .onnx file by scanning the directory (async to avoid blocking)
        final modelDir = Directory(modelRootPath);
        if (!await modelDir.exists()) {
          throw ModelNotFoundException(
            'Model directory not found at: $modelRootPath',
          );
        }
        // Use async list to avoid blocking on large directories
        final allFiles = await modelDir.list(recursive: true).toList();
        final onnxFiles =
            allFiles
                .whereType<File>()
                .where((f) => f.path.endsWith('.onnx'))
                .toList();
        if (onnxFiles.isEmpty) {
          throw ModelNotFoundException(
            'No .onnx model file found in: $modelRootPath',
          );
        }
        final modelPath = onnxFiles.first.path;
        final modelFileDir = Directory(p.dirname(modelPath));

        // Resolve tokens.txt — prefer exact name, then common alternatives
        String tokensPath = p.join(modelFileDir.path, _tokensFile);
        if (!await File(tokensPath).exists()) {
          const preferredNames = ['tokens.txt', 'lexicon.txt', 'bpe.vocab'];
          final dirFiles = await modelFileDir.list().toList();
          final txtFiles =
              dirFiles
                  .whereType<File>()
                  .where(
                    (f) => f.path.endsWith('.txt') || f.path.endsWith('.vocab'),
                  )
                  .toList();
          File? bestMatch;
          for (final name in preferredNames) {
            bestMatch = txtFiles.cast<File?>().firstWhere(
              (f) => f != null && p.basename(f.path).toLowerCase() == name,
              orElse: () => null,
            );
            if (bestMatch != null) break;
          }
          bestMatch ??= txtFiles.isNotEmpty ? txtFiles.first : null;
          if (bestMatch != null) {
            tokensPath = bestMatch.path;
          }
        }

        // Resolve espeak-ng-data — check shared location first, then model dir, then model root
        String dataDir = p.join(modelRootPath, _espeakDataDir);
        if (!await Directory(dataDir).exists()) {
          dataDir = p.join(modelFileDir.path, _espeakDataDir);
        }
        if (!await Directory(dataDir).exists()) {
          // Use shared espeak-ng-data from assets (copied once, used by all models)
          final appDir = await getApplicationSupportDirectory();
          final sharedEspeakDir = p.join(appDir.path, 'espeak-ng-data');
          if (await Directory(sharedEspeakDir).exists()) {
            dataDir = sharedEspeakDir;
          } else {
            debugPrint('WARNING: espeak-ng-data not found. TTS may fail.');
          }
        }

        // Cache resolved paths for faster subsequent initializations
        _cachedModelPath = modelPath;
        _cachedTokensPath = tokensPath;
        _cachedDataDir = dataDir;
      }

      // Step 4: Configure Piper VITS model using cached paths
      final vits = sherpa_onnx.OfflineTtsVitsModelConfig(
        model: _cachedModelPath!,
        tokens: _cachedTokensPath!,
        dataDir: _cachedDataDir!,
        lexicon: '',
      );

      final modelConfig = sherpa_onnx.OfflineTtsModelConfig(
        vits: vits,
        kokoro: sherpa_onnx.OfflineTtsKokoroModelConfig(),
        numThreads: 2,
        debug: false,
        provider: 'cpu',
      );

      final config = sherpa_onnx.OfflineTtsConfig(
        model: modelConfig,
        maxNumSenetences: 2,
      );

      // Step 5: Create TTS engine — retry on model corruption
      try {
        _tts = sherpa_onnx.OfflineTts(config);
      } catch (e) {
        if (_isCurrentModelBundled) {
          debugPrint('Model load failed, attempting re-copy: $e');
          _assetsCopied = false;
          await _copyModelAssets(_currentModelDir);
          _tts = sherpa_onnx.OfflineTts(config);
        } else {
          rethrow;
        }
      }

      // Only mark as initialized if _tts was actually created
      if (_tts != null) {
        _isInitialized = true;
        debugPrint('TTS Engine ready: ${_tts!.numSpeakers} speaker(s)');
      } else {
        throw const TtsInitializationException('Engine creation returned null');
      }
    } catch (e) {
      _isInitialized = false;
      debugPrint('TTS Engine init failed: $e');
      if (e is SonifyException) rethrow;
      throw TtsInitializationException('$e');
    } finally {
      _initLock?.complete();
      _initLock = null;
    }
  }

  /// Generate speech audio from text.
  /// Returns the file path of the generated WAV file.
  Future<String> generateSpeech(
    String text, {
    int speakerId = 0,
    double speed = 1.0,
  }) async {
    await initialize();

    if (_tts == null) {
      throw const TtsInitializationException('Engine not available');
    }

    if (text.trim().isEmpty) {
      throw const TtsGenerationException('Text cannot be empty');
    }

    try {
      // Clamp speaker ID to valid range
      final int validSpeakerId = speakerId.clamp(
        0,
        max<int>(0, numSpeakers - 1),
      );
      final genConfig = sherpa_onnx.OfflineTtsGenerationConfig(
        sid: validSpeakerId,
        speed: speed,
        silenceScale: 0.2,
      );

      // Generate audio (CPU-intensive)
      final audio = _tts!.generateWithConfig(
        text: text.trim(),
        config: genConfig,
      );

      if (audio.samples.isEmpty) {
        throw const TtsGenerationException('No audio generated');
      }

      // Save to temporary WAV file
      final tempDir = await getTemporaryDirectory();
      final outputPath = p.join(
        tempDir.path,
        'sonify_${const Uuid().v4()}.wav',
      );

      final ok = sherpa_onnx.writeWave(
        filename: outputPath,
        samples: audio.samples,
        sampleRate: audio.sampleRate,
      );

      if (!ok) {
        throw const TtsGenerationException('Failed to write WAV file');
      }

      debugPrint(
        'Generated ${audio.samples.length / audio.sampleRate}s audio → $outputPath',
      );

      return outputPath;
    } catch (e) {
      if (e is SonifyException) rethrow;
      throw TtsGenerationException('Generation failed: $e');
    }
  }

  /// Copy model assets from Flutter bundle to app support directory.
  /// Skips files that already exist with the correct size.
  /// Uses cached asset manifest for improved performance.
  /// Also copies shared espeak-ng-data if not already present.
  Future<void> _copyModelAssets(String modelFolder) async {
    // Cache asset manifest to avoid reloading on each copy operation
    _cachedAssetManifest ??= await AssetManifest.loadFromAssetBundle(
      rootBundle,
    );

    // Cache filtered asset list per model folder
    _cachedModelAssets.putIfAbsent(modelFolder, () {
      final allAssets = _cachedAssetManifest!.listAssets();
      return allAssets
          .where((a) => a.startsWith('$_assetPrefix/$modelFolder/'))
          .toList();
    });

    final modelAssets = _cachedModelAssets[modelFolder]!;

    if (modelAssets.isEmpty) {
      throw ModelNotFoundException(
        'No model assets found for $modelFolder in bundle.',
      );
    }

    final appDir = await getApplicationSupportDirectory();
    int copiedCount = 0;
    int skippedCount = 0;

    // Copy shared espeak-ng-data if not already present
    final sharedEspeakDir = Directory(p.join(appDir.path, 'espeak-ng-data'));
    if (!await sharedEspeakDir.exists()) {
      await _copySharedEspeakData(appDir.path);
    }

    // Process files in parallel for faster copying
    final futures = <Future>[];
    for (final assetPath in modelAssets) {
      futures.add(
        _copySingleAsset(assetPath, appDir.path).then((copied) {
          if (copied) {
            copiedCount++;
          } else {
            skippedCount++;
          }
        }),
      );
    }
    await Future.wait(futures);

    debugPrint(
      'Copied $copiedCount/${modelAssets.length} model files ($skippedCount skipped)',
    );
  }

  /// Copy shared espeak-ng-data to app support directory (once for all models).
  Future<void> _copySharedEspeakData(String appDirPath) async {
    _cachedAssetManifest ??= await AssetManifest.loadFromAssetBundle(
      rootBundle,
    );

    final allAssets = _cachedAssetManifest!.listAssets();
    final espeakAssets =
        allAssets.where((a) => a.startsWith('$_sharedEspeakPath/')).toList();

    if (espeakAssets.isEmpty) {
      debugPrint('WARNING: Shared espeak-ng-data not found in assets');
      return;
    }

    final futures = <Future>[];
    for (final assetPath in espeakAssets) {
      final relativePath = assetPath.substring('assets/'.length);
      final targetPath = p.join(appDirPath, relativePath);
      final targetFile = File(targetPath);

      futures.add(
        rootBundle.load(assetPath).then((data) async {
          if (await targetFile.exists() &&
              targetFile.lengthSync() == data.lengthInBytes) {
            return;
          }
          final bytes = data.buffer.asUint8List();
          await targetFile.create(recursive: true);
          await targetFile.writeAsBytes(bytes);
        }),
      );
    }
    await Future.wait(futures);
    debugPrint('Copied shared espeak-ng-data (${espeakAssets.length} files)');
  }

  /// Copy a single asset file, returning true if copied, false if skipped.
  Future<bool> _copySingleAsset(String assetPath, String appDirPath) async {
    final relativePath = assetPath.substring('$_assetPrefix/'.length);
    final targetPath = p.join(appDirPath, relativePath);
    final targetFile = File(targetPath);

    final data = await rootBundle.load(assetPath);

    // Skip if already exists with same size
    if (await targetFile.exists() &&
        targetFile.lengthSync() == data.lengthInBytes) {
      return false;
    }

    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    await targetFile.create(recursive: true);
    await targetFile.writeAsBytes(bytes);
    return true;
  }

  /// Release resources
  void dispose() {
    _tts?.free();
    _tts = null;
    _isInitialized = false;
  }
}
