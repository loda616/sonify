import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:sonify/core/models/audio_file.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:share_plus/share_plus.dart';

class TTSService {
  static const String _audioDirectoryName = 'sonify_audio';
  static TTSService? _instance;
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  // Singleton pattern
  factory TTSService() {
    _instance ??= TTSService._internal();
    return _instance!;
  }

  TTSService._internal();

  Future<void> _initialize() async {
    if (_isInitialized) return;

    try {
      // Set up TTS settings
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(1.0);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      // Get available voices
      final voices = await _flutterTts.getVoices;
      debugPrint('Available voices: $voices');

      _isInitialized = true;
      debugPrint('TTS service initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize TTS service: $e');
      rethrow;
    }
  }

  Future<String> generateSpeech(
      String text, {
        String voice = 'Default',
        double pitch = 1.0,
        double speed = 1.0,
      }) async {
    await _initialize();

    try {
      // Create a temporary file to store the generated audio
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(path.join(tempDir.path, '${const Uuid().v4()}.mp3'));

      // Set voice parameters
      await _flutterTts.setPitch(pitch);
      await _flutterTts.setSpeechRate(speed);

      // If not default, try to set the voice
      if (voice != 'Default') {
        try {
          // Get available voices
          final voices = await _flutterTts.getVoices;
          final selectedVoice = (voices as List<dynamic>).firstWhere(
                (v) => v['name'].toString().contains(voice),
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
          // Continue with default voice
        }
      }

      // Generate speech to file if platform supports it
      bool canSaveToFile = false;
      if (Platform.isAndroid || Platform.isIOS) {
        canSaveToFile = true;
      }

      if (canSaveToFile) {
        // On supported platforms, save directly to file
        await _flutterTts.synthesizeToFile(text, tempFile.path);
      } else {
        // On other platforms, use the speak method and simulate file creation
        // This is just a placeholder - the file won't actually contain audio data
        await _flutterTts.speak(text);
        await tempFile.create();
      }

      return tempFile.path;
    } catch (e) {
      debugPrint('Error generating speech: $e');
      rethrow;
    }
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

      await metadataFile.writeAsString(metadata.toString());

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
          // In a real app, use a proper JSON parser
          final id = _extractValue(content, 'id');
          final title = _extractValue(content, 'title');
          final filePath = _extractValue(content, 'filePath');
          final createdAt = _extractValue(content, 'createdAt');

          final audioFile = File(filePath);
          if (await audioFile.exists()) {
            audioFiles.add(
              AudioFile(
                id: id,
                title: title,
                filePath: filePath,
                createdAt: createdAt,
              ),
            );
          }
        } catch (e) {
          debugPrint('Error parsing metadata file: $e');
          // Continue to the next file
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

  // Simple helper to extract values from a stringified JSON
  // In a real app, use a proper JSON parser
  String _extractValue(String jsonString, String key) {
    final regex = RegExp('$key: (.*?)(,|})', multiLine: true);
    final match = regex.firstMatch(jsonString);
    return match?.group(1)?.trim() ?? '';
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
          final fileName = '${audioFile.title.replaceAll(' ', '_')}_${path.basename(audioFile.filePath)}';
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
      final exportDir = Directory(path.join(documentsDir.path, 'Exports', dirName));

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

  // Stop any ongoing speech
  Future<void> stop() async {
    await _flutterTts.stop();
  }
}