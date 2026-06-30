import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:sonify/core/models/audio_file.dart';
import 'package:share_plus/share_plus.dart';

class TTSService {
  static const String _audioDirectoryName = 'sonify_audio';
  static TTSService? _instance;
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isInitializing = false;

  factory TTSService() {
    _instance ??= TTSService._internal();
    return _instance!;
  }

  TTSService._internal();

  Future<void> _initialize() async {
    if (_isInitialized) return;
    if (_isInitializing) {
      while (_isInitializing) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      return;
    }
    _isInitializing = true;

    try {
      await _flutterTts.setSpeechRate(1.0);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      try {
        await _flutterTts.setLanguage("en-US");
      } catch (_) {
        try {
          await _flutterTts.setLanguage("en");
        } catch (_) {}
      }

      try {
        final voices = await _flutterTts.getVoices;
        debugPrint('Available voices: $voices');
      } catch (e) {
        debugPrint('Could not query voices: $e');
      }

      _isInitialized = true;
      debugPrint('TTS service initialized successfully');
      
      // Clean up old temporary audio files asynchronously
      cleanupTempFiles();
    } catch (e) {
      debugPrint('Failed to initialize TTS service: $e');
      rethrow;
    } finally {
      _isInitializing = false;
    }
  }

  static const MethodChannel _captureChannel =
      MethodChannel('com.example.sonify/tts_capture');

  Future<String> generateSpeech(
    String text, {
    String voice = 'Default',
    double pitch = 1.0,
    double speed = 1.0,
  }) async {
    await _initialize();

    final Directory appDir;
    if (Platform.isAndroid) {
      appDir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    } else {
      appDir = await getApplicationDocumentsDirectory();
    }
    final outputDir = Directory(path.join(appDir.path, _audioDirectoryName));
    if (!await outputDir.exists()) {
      await outputDir.create(recursive: true);
    }
    final outputFile = File(
      path.join(outputDir.path, '${const Uuid().v4()}.wav'),
    );

    try {
      await _flutterTts.setPitch(pitch);
      await _flutterTts.setSpeechRate(speed);

      try {
        await _flutterTts.setLanguage("en-US");
      } catch (_) {
        try {
          await _flutterTts.setLanguage("en");
        } catch (_) {}
      }

      if (voice != 'Default') {
        try {
          final voices = await _flutterTts.getVoices;
          final selectedVoice = (voices as List<dynamic>).firstWhere(
                (v) => v['name'].toString() == voice,
            orElse: () => null,
          );
          if (selectedVoice != null) {
            await _flutterTts.setVoice({
              "name": selectedVoice['name'],
              "locale": selectedVoice['locale'],
            });
          }
        } catch (e) {
          debugPrint('Error setting voice: $e');
        }
      }

      bool canSaveToFile = false;
      if (Platform.isAndroid || Platform.isIOS) {
        canSaveToFile = true;
      }

      if (!canSaveToFile) {
        throw UnsupportedError(
          'Audio file generation is not supported on this platform.',
        );
      }

      // Attempt 1: synthesizeToFile
      for (int attempt = 0; attempt < 3; attempt++) {
        try {
          await _flutterTts.speak(" ");
          await Future.delayed(const Duration(milliseconds: 200));
        } catch (_) {}

        final completer = Completer<void>();
        _flutterTts.setCompletionHandler(() {
          if (!completer.isCompleted) completer.complete();
        });

        await _flutterTts.synthesizeToFile(text, outputFile.path, true);
        await completer.future.timeout(
          const Duration(seconds: 10),
          onTimeout: () {},
        );
        await Future.delayed(const Duration(milliseconds: 200));

        if (await outputFile.exists() && await outputFile.length() > 0) {
          return outputFile.path;
        }
        debugPrint('synthesizeToFile attempt ${attempt + 1} failed, retrying...');
      }

      // Attempt 2: capture speaker output via MethodChannel
      try {
        debugPrint('Falling back to playback capture...');
        await _flutterTts.stop();

        final pcmFile = File(
          path.join(outputDir.path, '${const Uuid().v4()}.pcm'),
        );
        await _captureChannel.invokeMethod('startCapture', {'path': pcmFile.path});

        final speakCompleter = Completer<void>();
        _flutterTts.setCompletionHandler(() {
          if (!speakCompleter.isCompleted) speakCompleter.complete();
        });

        await _flutterTts.speak(text);

        await speakCompleter.future.timeout(
          const Duration(seconds: 30),
          onTimeout: () {},
        );
        await Future.delayed(const Duration(milliseconds: 300));

        await _captureChannel.invokeMethod('stopCapture');

        if (await pcmFile.exists() && await pcmFile.length() > 0) {
          // Wrap raw PCM with WAV header
          await _writeWavHeader(pcmFile, outputFile);
          if (await outputFile.exists() && await outputFile.length() > 44) {
            await pcmFile.delete();
            return outputFile.path;
          }
        }
      } catch (e) {
        debugPrint('Playback capture failed: $e');
      }

      throw Exception('TTS engine did not produce audio output');
    } catch (e) {
      debugPrint('Error generating speech: $e');
      rethrow;
    }
  }

  Future<void> _writeWavHeader(File pcmFile, File wavFile) async {
    final data = await pcmFile.readAsBytes();
    final dataSize = data.length;
    final fileSize = 36 + dataSize;

    final header = ByteData(44);
    header.setUint8(0, 0x52); // R
    header.setUint8(1, 0x49); // I
    header.setUint8(2, 0x46); // F
    header.setUint8(3, 0x46); // F
    header.setUint32(4, fileSize, Endian.little);
    header.setUint8(8, 0x57);  // W
    header.setUint8(9, 0x41);  // A
    header.setUint8(10, 0x56); // V
    header.setUint8(11, 0x45); // E
    header.setUint8(12, 0x66); // f
    header.setUint8(13, 0x6D); // m
    header.setUint8(14, 0x74); // t
    header.setUint8(15, 0x20); // (space)
    header.setUint32(16, 16, Endian.little);   // subchunk1 size
    header.setUint16(20, 1, Endian.little);    // PCM
    header.setUint16(22, 1, Endian.little);    // mono
    header.setUint32(24, 44100, Endian.little); // sample rate
    header.setUint32(28, 88200, Endian.little); // byte rate
    header.setUint16(32, 2, Endian.little);    // block align
    header.setUint16(34, 16, Endian.little);   // bits per sample
    header.setUint8(36, 0x64); // d
    header.setUint8(37, 0x61); // a
    header.setUint8(38, 0x74); // t
    header.setUint8(39, 0x61); // a
    header.setUint32(40, dataSize, Endian.little);

    final wavData = Uint8List(44 + dataSize);
    wavData.setRange(0, 44, header.buffer.asUint8List());
    wavData.setRange(44, 44 + dataSize, data);

    await wavFile.writeAsBytes(wavData);
  }

  Future<List<String>> getAvailableVoices() async {
    await _initialize();
    try {
      final voices = await _flutterTts.getVoices;
      if (voices is List<dynamic>) {
        return voices
            .map((voice) => voice['name'].toString())
            .toSet() // Remove duplicates
            .toList();
      }
      return ['Default', 'Male', 'Female'];
    } catch (e) {
      debugPrint('Error getting voices: $e');
      return ['Default', 'Male', 'Female'];
    }
  }

  Future<bool> saveAudio(String audioPath, String title) async {
    try {
      final sourceFile = File(audioPath);
      if (!await sourceFile.exists()) {
        return false;
      }

      // Create directory for saved audio files if it doesn't exist
      final appDir = await getApplicationDocumentsDirectory();
      final audioDir = Directory(path.join(appDir.path, _audioDirectoryName));
      if (!await audioDir.exists()) {
        await audioDir.create(recursive: true);
      }

      // Generate a unique ID for the audio file
      final id = const Uuid().v4();
      final fileName = '$id.mp3';
      final destinationPath = path.join(audioDir.path, fileName);

      // Copy the file
      await sourceFile.copy(destinationPath);

      // Create a metadata file to store information about the audio
      final metadataFile = File(path.join(audioDir.path, '$id.json'));
      final now = DateTime.now();
      final metadata = {
        'id': id,
        'title': title,
        'filePath': destinationPath,
        'createdAt': DateFormat('yyyy-MM-dd HH:mm:ss').format(now),
      };

      await metadataFile.writeAsString(jsonEncode(metadata));

      return true;
    } catch (e) {
      debugPrint('Error saving audio: $e');
      return false;
    }
  }

  Future<List<AudioFile>> getSavedAudios() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final audioDir = Directory(path.join(appDir.path, _audioDirectoryName));

      if (!await audioDir.exists()) {
        return [];
      }

      final List<AudioFile> audioFiles = [];
      final List<FileSystemEntity> files = await audioDir.list().toList();

      // Filter for json metadata files
      final metadataFiles = files.whereType<File>().where(
        (file) => path.extension(file.path) == '.json',
      );

      for (final file in metadataFiles) {
        try {
          final content = await file.readAsString();
          final json = jsonDecode(content) as Map<String, dynamic>;
          final audioFile = AudioFile.fromJson(json);
          final audioFileOnDisk = File(audioFile.filePath);
          if (await audioFileOnDisk.exists()) {
            audioFiles.add(audioFile);
          }
        } catch (e) {
          debugPrint('Error parsing metadata file: $e');
        }
      }

      // Sort by creation date (newest first)
      audioFiles.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return audioFiles;
    } catch (e) {
      debugPrint('Error getting saved audios: $e');
      return [];
    }
  }

  Future<bool> deleteAudio(String id) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final audioDir = Directory(path.join(appDir.path, _audioDirectoryName));

      if (!await audioDir.exists()) {
        return false;
      }

      // Delete the audio file
      final audioFile = File(path.join(audioDir.path, '$id.mp3'));
      if (await audioFile.exists()) {
        await audioFile.delete();
      }

      // Delete the metadata file
      final metadataFile = File(path.join(audioDir.path, '$id.json'));
      if (await metadataFile.exists()) {
        await metadataFile.delete();
      }

      return true;
    } catch (e) {
      debugPrint('Error deleting audio: $e');
      return false;
    }
  }

  Future<bool> renameAudio(String id, String newTitle) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final audioDir = Directory(path.join(appDir.path, _audioDirectoryName));

      if (!await audioDir.exists()) {
        return false;
      }

      final metadataFile = File(path.join(audioDir.path, '$id.json'));
      if (await metadataFile.exists()) {
        final content = await metadataFile.readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        json['title'] = newTitle;
        await metadataFile.writeAsString(jsonEncode(json));
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error renaming audio: $e');
      return false;
    }
  }


  Future<bool> clearAllSavedAudios() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final audioDir = Directory(path.join(appDir.path, _audioDirectoryName));

      if (!await audioDir.exists()) {
        return true; // Nothing to delete
      }

      await audioDir.delete(recursive: true);

      return true;
    } catch (e) {
      debugPrint('Error clearing all saved audios: $e');
      return false;
    }
  }

  Future<String> exportAllAudios() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final audioDir = Directory(path.join(appDir.path, _audioDirectoryName));

      if (!await audioDir.exists()) {
        throw Exception('No audio files to export');
      }

      // Create a directory for exported files
      final now = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final exportDirName = 'sonify_export_$now';

      // Android / iOS handle external storage differently
      final exportDir = await _getExportDirectory(exportDirName);

      // Get all audio files
      final audioFiles = await getSavedAudios();

      // Copy each file to the export directory
      for (final audioFile in audioFiles) {
        final sourceFile = File(audioFile.filePath);
        if (await sourceFile.exists()) {
          final fileName =
              '${audioFile.title.replaceAll(' ', '_')}_${path.basename(audioFile.filePath)}';
          final targetFile = File(path.join(exportDir.path, fileName));
          await sourceFile.copy(targetFile.path);
        }
      }

      // Return the export directory path
      return exportDir.path;
    } catch (e) {
      debugPrint('Error exporting audio files: $e');
      rethrow;
    }
  }

  Future<Directory> _getExportDirectory(String dirName) async {
    if (Platform.isAndroid) {
      // On Android, we'd typically export to Download directory
      // For simplicity, we're using external storage directory
      final externalDir = await getExternalStorageDirectory();
      if (externalDir == null) {
        throw Exception('Could not access external storage');
      }

      final exportDir = Directory(path.join(externalDir.path, dirName));
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }

      return exportDir;
    } else if (Platform.isIOS) {
      // On iOS, we typically use the Documents directory
      final documentsDir = await getApplicationDocumentsDirectory();
      final exportDir = Directory(
        path.join(documentsDir.path, 'Exports', dirName),
      );

      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }

      return exportDir;
    } else {
      // Fallback for other platforms
      final tempDir = await getTemporaryDirectory();
      final exportDir = Directory(path.join(tempDir.path, dirName));

      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }

      return exportDir;
    }
  }

  Future<void> shareAudio(String audioPath, String title) async {
    try {
      final file = XFile(audioPath);
      await Share.shareXFiles([file], text: 'Sharing audio: $title');
    } catch (e) {
      debugPrint('Error sharing audio: $e');
      rethrow;
    }
  }

  Future<void> playPreview(String voice, {double pitch = 1.0, double speed = 1.0}) async {
    try {
      await stop();
      await _flutterTts.setPitch(pitch);
      await _flutterTts.setSpeechRate(speed);

      if (voice != 'Default') {
        final voices = await _flutterTts.getVoices;
        final selectedVoice = (voices as List<dynamic>).firstWhere(
          (v) => v['name'].toString() == voice,
          orElse: () => null,
        );
        if (selectedVoice != null) {
          await _flutterTts.setVoice({
            "name": selectedVoice['name'],
            "locale": selectedVoice['locale'],
          });
        }
      } else {
        await _flutterTts.setLanguage("en-US");
      }

      await _flutterTts.speak("This is a voice preview.");
    } catch (e) {
      debugPrint('Error playing preview: $e');
    }
  }

  // Stop any ongoing speech
  Future<void> stop() async {
    await _flutterTts.stop();
  }

  /// Delete temporary WAV and PCM audio files older than 24 hours to save storage.
  Future<void> cleanupTempFiles() async {
    try {
      final List<Directory> checkDirs = [];
      
      // Get application documents directory
      try {
        final docsDir = await getApplicationDocumentsDirectory();
        checkDirs.add(Directory(path.join(docsDir.path, _audioDirectoryName)));
      } catch (_) {}

      // Get external storage directory for Android
      if (Platform.isAndroid) {
        try {
          final extDir = await getExternalStorageDirectory();
          if (extDir != null) {
            checkDirs.add(Directory(path.join(extDir.path, _audioDirectoryName)));
          }
        } catch (_) {}
      }

      final now = DateTime.now();
      int deletedCount = 0;

      for (final dir in checkDirs) {
        if (await dir.exists()) {
          final List<FileSystemEntity> entities = await dir.list().toList();
          for (final entity in entities) {
            if (entity is File) {
              final ext = path.extension(entity.path).toLowerCase();
              if (ext == '.wav' || ext == '.pcm') {
                final stat = await entity.stat();
                if (now.difference(stat.modified).inHours > 24) {
                  await entity.delete();
                  deletedCount++;
                }
              }
            }
          }
        }
      }
      
      if (deletedCount > 0) {
        debugPrint('Cleaned up $deletedCount temporary audio file(s).');
      }
    } catch (e) {
      debugPrint('Error cleaning up temp files: $e');
    }
  }
}