# Phase 2: TTS Engine Integration

**Goal:** Replace `flutter_tts` with Piper via `sherpa_onnx`. Audio generation should work end-to-end: text in, natural-sounding WAV out, playable and saveable.

**Prerequisite:** Phase 1 complete (architecture, DI, error handling in place).

---

## Step 2.1: Download & Bundle Piper Model

### Download the model

```bash
# From your project root
mkdir -p assets/tts-model

# Download the recommended Piper model
# Option A: Single speaker, best quality (lessac-medium, ~61MB)
cd assets/tts-model
wget https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/vits-piper-en_US-lessac-medium.tar.bz2
tar xf vits-piper-en_US-lessac-medium.tar.bz2
rm vits-piper-en_US-lessac-medium.tar.bz2

# OR Option B: Multi-speaker, 904 voices (libritts_r-medium, ~75MB)
# wget https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/vits-piper-en_US-libritts_r-medium.tar.bz2
# tar xf vits-piper-en_US-libritts_r-medium.tar.bz2
```

### Resulting structure

```
assets/tts-model/vits-piper-en_US-lessac-medium/
├── en_US-lessac-medium.onnx       # ~61 MB — the neural network
├── en_US-lessac-medium.onnx.json  # Model metadata
├── tokens.txt                      # Token vocabulary
└── espeak-ng-data/                 # Phonemizer data (~15 MB)
    ├── en_dict
    ├── phondata
    ├── phondata-extra
    ├── phonindex
    ├── phontab
    ├── intonations
    └── ... (many small files)
```

### Generate asset list for Flutter

sherpa-onnx needs EVERY file listed in pubspec.yaml assets. Use their script or create one:

```python
#!/usr/bin/env python3
# generate_asset_list.py — run from project root
import os

asset_dir = "assets/tts-model"
entries = set()

for root, dirs, files in os.walk(asset_dir):
    for f in files:
        rel = os.path.relpath(os.path.join(root, f), ".").replace("\\", "/")
        # Add the directory containing this file
        dir_path = os.path.dirname(rel) + "/"
        entries.add(dir_path)

for e in sorted(entries):
    print(f"    - {e}")
```

### Update pubspec.yaml assets section

```yaml
flutter:
  assets:
    - assets/images/
    - assets/tts-model/vits-piper-en_US-lessac-medium/
    - assets/tts-model/vits-piper-en_US-lessac-medium/espeak-ng-data/
    # If espeak-ng-data has subdirectories, list them too:
    # - assets/tts-model/vits-piper-en_US-lessac-medium/espeak-ng-data/en_dict/

  uses-material-design: true
```

---

## Step 2.2: Implement TTS Engine

### `lib/services/tts_engine.dart`

This is the core class — the single point of contact with sherpa-onnx:

```dart
import 'dart:io';
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
  bool _isInitializing = false;
  bool _assetsCopied = false;

  // ──── Model Configuration ────
  // Change these to switch models
  static const String _modelDir = 'vits-piper-en_US-lessac-medium';
  static const String _modelFile = 'en_US-lessac-medium.onnx';
  static const String _tokensFile = 'tokens.txt';
  static const String _espeakDataDir = 'espeak-ng-data';
  static const String _assetPrefix = 'assets/tts-model';

  bool get isInitialized => _isInitialized;
  int get numSpeakers => _tts?.numSpeakers ?? 0;

  /// Initialize the engine. Safe to call multiple times.
  /// First call copies model assets to disk (~3-10 sec on first launch).
  Future<void> initialize() async {
    if (_isInitialized) return;
    if (_isInitializing) {
      // Wait for in-progress initialization
      while (_isInitializing) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return;
    }

    _isInitializing = true;
    try {
      // Step 1: Copy model assets from Flutter bundle to local disk
      if (!_assetsCopied) {
        await _copyModelAssets();
        _assetsCopied = true;
      }

      // Step 2: Initialize sherpa-onnx native bindings
      sherpa_onnx.initBindings();

      // Step 3: Build file paths
      final appDir = await getApplicationSupportDirectory();
      final modelPath = p.join(appDir.path, _modelDir, _modelFile);
      final tokensPath = p.join(appDir.path, _modelDir, _tokensFile);
      final dataDir = p.join(appDir.path, _modelDir, _espeakDataDir);

      // Verify files exist
      if (!await File(modelPath).exists()) {
        throw ModelNotFoundException(
          'Model file not found at: $modelPath',
        );
      }

      // Step 4: Configure Piper VITS model
      final vits = sherpa_onnx.OfflineTtsVitsModelConfig(
        model: modelPath,
        tokens: tokensPath,
        dataDir: dataDir,
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

      // Step 5: Create TTS engine
      _tts = sherpa_onnx.OfflineTts(config);
      _isInitialized = true;

      debugPrint('TTS Engine ready: ${_tts!.numSpeakers} speaker(s)');
    } catch (e) {
      debugPrint('TTS Engine init failed: $e');
      if (e is SonifyException) rethrow;
      throw TtsInitializationException('$e');
    } finally {
      _isInitializing = false;
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
      // Configure generation parameters
      final genConfig = sherpa_onnx.OfflineTtsGenerationConfig(
        sid: speakerId,
        speed: speed,
        silenceScale: 0.2,
      );

      // Generate audio (this is the CPU-intensive part)
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
  Future<void> _copyModelAssets() async {
    final assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final allAssets = assetManifest.listAssets();
    final modelAssets = allAssets
        .where((a) => a.startsWith('$_assetPrefix/$_modelDir/'))
        .toList();

    if (modelAssets.isEmpty) {
      throw const ModelNotFoundException(
        'No model assets found. Did you download the Piper model?',
      );
    }

    final appDir = await getApplicationSupportDirectory();
    int copiedCount = 0;

    for (final assetPath in modelAssets) {
      // Strip "assets/tts-model/" prefix to get relative path
      final relativePath = assetPath.substring('$_assetPrefix/'.length);
      final targetPath = p.join(appDir.path, relativePath);
      final targetFile = File(targetPath);

      // Skip if already exists with same size
      final data = await rootBundle.load(assetPath);
      if (await targetFile.exists() &&
          targetFile.lengthSync() == data.lengthInBytes) {
        continue;
      }

      // Copy to disk
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      await targetFile.create(recursive: true);
      await targetFile.writeAsBytes(bytes);
      copiedCount++;
    }

    debugPrint('Copied $copiedCount/${ modelAssets.length} model files');
  }

  /// Release resources
  void dispose() {
    _tts?.free();
    _tts = null;
    _isInitialized = false;
  }
}
```

---

## Step 2.3: Extract Audio Storage Service

Move all file management logic out of the old `TTSService` into its own class.

### `lib/services/audio_storage_service.dart`

```dart
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sonify/core/models/audio_file.dart';
import 'package:sonify/core/errors/exceptions.dart';

class AudioStorageService {
  static const String _audioDirectoryName = 'sonify_audio';

  /// Save an audio file to persistent storage with metadata
  Future<bool> saveAudio(String audioPath, String title) async {
    try {
      final sourceFile = File(audioPath);
      if (!await sourceFile.exists()) {
        throw AudioNotFoundException('Source file not found: $audioPath');
      }

      final audioDir = await _getAudioDirectory();
      final id = const Uuid().v4();

      // Detect extension from source file
      final ext = p.extension(audioPath).isNotEmpty
          ? p.extension(audioPath)
          : '.wav';
      final fileName = '$id$ext';
      final destinationPath = p.join(audioDir.path, fileName);

      // Copy the audio file
      await sourceFile.copy(destinationPath);

      // Save metadata
      final metadataFile = File(p.join(audioDir.path, '$id.json'));
      final now = DateTime.now();
      final audioFile = AudioFile(
        id: id,
        title: title,
        filePath: destinationPath,
        createdAt: DateFormat('yyyy-MM-dd HH:mm:ss').format(now),
      );
      await metadataFile.writeAsString(jsonEncode(audioFile.toJson()));

      return true;
    } catch (e) {
      debugPrint('Error saving audio: $e');
      return false;
    }
  }

  /// Get all saved audio files, sorted newest first
  Future<List<AudioFile>> getSavedAudios() async {
    try {
      final audioDir = await _getAudioDirectory();
      if (!await audioDir.exists()) return [];

      final List<AudioFile> audioFiles = [];
      final files = await audioDir.list().toList();
      final metadataFiles = files
          .whereType<File>()
          .where((f) => p.extension(f.path) == '.json');

      for (final file in metadataFiles) {
        try {
          final content = await file.readAsString();
          final audioFile = AudioFile.fromJson(jsonDecode(content));
          if (await File(audioFile.filePath).exists()) {
            audioFiles.add(audioFile);
          }
        } catch (e) {
          debugPrint('Error parsing metadata: $e');
        }
      }

      audioFiles.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return audioFiles;
    } catch (e) {
      debugPrint('Error getting saved audios: $e');
      return [];
    }
  }

  /// Delete a saved audio file and its metadata
  Future<bool> deleteAudio(String id) async {
    try {
      final audioDir = await _getAudioDirectory();

      // Try common extensions
      for (final ext in ['.wav', '.mp3']) {
        final audioFile = File(p.join(audioDir.path, '$id$ext'));
        if (await audioFile.exists()) await audioFile.delete();
      }

      final metadataFile = File(p.join(audioDir.path, '$id.json'));
      if (await metadataFile.exists()) await metadataFile.delete();

      return true;
    } catch (e) {
      debugPrint('Error deleting audio: $e');
      return false;
    }
  }

  /// Delete ALL saved audio files
  Future<bool> clearAllSavedAudios() async {
    try {
      final audioDir = await _getAudioDirectory();
      if (await audioDir.exists()) {
        await audioDir.delete(recursive: true);
      }
      return true;
    } catch (e) {
      debugPrint('Error clearing audios: $e');
      return false;
    }
  }

  /// Export all audio files to a user-accessible directory
  Future<String> exportAllAudios() async {
    try {
      final audioFiles = await getSavedAudios();
      if (audioFiles.isEmpty) throw const StorageException('No audio files');

      final now = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final exportDir = await _getExportDirectory('sonify_export_$now');

      for (final audioFile in audioFiles) {
        final sourceFile = File(audioFile.filePath);
        if (await sourceFile.exists()) {
          final safeName = audioFile.title.replaceAll(RegExp(r'[^\w\s-]'), '');
          final ext = p.extension(audioFile.filePath);
          final targetFile = File(
            p.join(exportDir.path, '${safeName}_${audioFile.id.substring(0, 8)}$ext'),
          );
          await sourceFile.copy(targetFile.path);
        }
      }

      return exportDir.path;
    } catch (e) {
      debugPrint('Error exporting: $e');
      rethrow;
    }
  }

  /// Share an audio file via the system share sheet
  Future<void> shareAudio(String audioPath, String title) async {
    final file = XFile(audioPath);
    await Share.shareXFiles([file], text: 'Shared from Sonify: $title');
  }

  // ─── Private helpers ───

  Future<Directory> _getAudioDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final audioDir = Directory(p.join(appDir.path, _audioDirectoryName));
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    return audioDir;
  }

  Future<Directory> _getExportDirectory(String dirName) async {
    Directory baseDir;
    if (Platform.isAndroid) {
      baseDir = (await getExternalStorageDirectory()) ??
          await getApplicationDocumentsDirectory();
    } else {
      baseDir = await getApplicationDocumentsDirectory();
    }

    final exportDir = Directory(
      p.join(baseDir.path, Platform.isIOS ? 'Exports' : '', dirName),
    );
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    return exportDir;
  }
}
```

---

## Step 2.4: Rewrite TTSService as Facade

### `lib/services/tts_service.dart`

```dart
import 'package:sonify/core/models/audio_file.dart';
import 'package:sonify/services/tts_engine.dart';
import 'package:sonify/services/audio_storage_service.dart';

/// Facade that combines TTS generation and audio storage.
/// Keeps backward compatibility with existing presentation code.
class TTSService {
  final TtsEngine engine;
  final AudioStorageService storage;

  TTSService({required this.engine, required this.storage});

  Future<String> generateSpeech(
    String text, {
    String voice = 'Default',
    double pitch = 1.0, // Ignored — kept for API compat during migration
    double speed = 1.0,
  }) async {
    int speakerId = 0;
    if (voice != 'Default') {
      // Parse "Speaker 3" → 2 (0-indexed)
      final match = RegExp(r'Speaker (\d+)').firstMatch(voice);
      if (match != null) {
        speakerId = (int.tryParse(match.group(1)!) ?? 1) - 1;
      }
    }

    return engine.generateSpeech(text, speakerId: speakerId, speed: speed);
  }

  Future<List<String>> getAvailableVoices() async {
    await engine.initialize();
    final count = engine.numSpeakers;
    if (count <= 1) return ['Default'];
    return ['Default', ...List.generate(count, (i) => 'Speaker ${i + 1}')];
  }

  Future<bool> saveAudio(String path, String title) =>
      storage.saveAudio(path, title);
  Future<List<AudioFile>> getSavedAudios() => storage.getSavedAudios();
  Future<bool> deleteAudio(String id) => storage.deleteAudio(id);
  Future<bool> clearAllSavedAudios() => storage.clearAllSavedAudios();
  Future<String> exportAllAudios() => storage.exportAllAudios();
  Future<void> shareAudio(String path, String title) =>
      storage.shareAudio(path, title);
  Future<void> stop() async {} // No-op for Piper (synchronous generation)
}
```

---

## Step 2.5: Update Constants

### `lib/core/constants/constants.dart`

```dart
class AppConstants {
  // App Info
  static const String appName = 'Sonify';
  static const String appVersion = '1.0.0';

  // TTS Defaults
  static const double defaultSpeed = 1.0;
  static const String defaultVoice = 'Default';
  static const int defaultSpeakerId = 0;

  // Speed limits (pitch removed — Piper doesn't support pitch control)
  static const double minSpeed = 0.5;
  static const double maxSpeed = 3.0; // sherpa-onnx supports up to 3.0

  // Text limits
  static const int maxTextLength = 5000;
  static const int maxTextLengthForInstantGeneration = 200;

  // Storage Keys
  static const String storageKeyTheme = 'theme_mode';
  static const String storageKeyDefaultVoice = 'default_voice';
  static const String storageKeyDefaultSpeed = 'default_speed';

  // Model Info
  static const String modelId = 'vits-piper-en_US-lessac-medium';
  static const String modelDisplayName = 'Piper Lessac (English)';
  static const String engineVersion = 'sherpa-onnx';
}
```

---

## Step 2.6: Android Configuration

### `android/app/build.gradle.kts`

```kotlin
android {
    namespace = "com.sonifyapp.sonify"  // Change from com.example.sonify
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.sonifyapp.sonify"
        minSdk = 24  // Required by sherpa-onnx (was flutter.minSdkVersion)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
    // ... rest stays the same
}
```

---

## Step 2.7: Verify End-to-End Audio Pipeline

After all the above, verify this flow works:

```
1. App launches → splash screen
2. Navigate to TTS tab
3. Type "Hello, welcome to Sonify"
4. Tap "Generate Speech"
5. Wait 1-3 seconds
6. Audio plays automatically via just_audio
7. Tap "Save" → appears in Saved Audio tab
8. Navigate to Saved Audio tab → tap to play
9. Share → system share sheet opens with WAV file
```

**Audio format notes:**
- Output is WAV (PCM, 22050 Hz, mono, 16-bit) — changed from MP3
- `just_audio` supports WAV natively — no changes needed in `AudioPlayerWidget`
- File sizes are larger than MP3 (~10x), but quality is lossless
- Future enhancement: add WAV→MP3 conversion for smaller saved files

---

## Phase 2 Definition of Done

- [ ] `flutter_tts` fully removed from pubspec.yaml
- [ ] `sherpa_onnx` added and working
- [ ] Piper model files bundled in assets
- [ ] TtsEngine initializes and generates audio on Android
- [ ] TtsEngine initializes and generates audio on iOS
- [ ] Generated WAV files play correctly in AudioPlayerWidget
- [ ] Save/load/delete audio works with new WAV format
- [ ] Export and share work with WAV files
- [ ] No crashes when generating with empty text
- [ ] No crashes when engine hasn't initialized yet
- [ ] Works in airplane mode (fully offline)
