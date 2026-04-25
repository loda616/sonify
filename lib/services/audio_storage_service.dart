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

  // ──── In-memory cache ────
  static List<AudioFile>? _cachedAudios;
  static DateTime? _lastCacheTime;
  static const Duration _cacheMaxAge = Duration(minutes: 5);

  /// Check if cache is still valid
  bool get _isCacheValid {
    if (_cachedAudios == null || _lastCacheTime == null) return false;
    return DateTime.now().difference(_lastCacheTime!) < _cacheMaxAge;
  }

  /// Invalidate the cache (call after save/delete/rename)
  void invalidateCache() {
    _cachedAudios = null;
    _lastCacheTime = null;
  }

  /// Save an audio file to persistent storage with metadata
  Future<bool> saveAudio(String audioPath, String title) async {
    try {
      final sourceFile = File(audioPath);
      if (!await sourceFile.exists()) {
        throw AudioNotFoundException('Source file not found: $audioPath');
      }

      final audioDir = await _getAudioDirectory();
      final id = const Uuid().v4();

      final ext =
          p.extension(audioPath).isNotEmpty ? p.extension(audioPath) : '.wav';
      final fileName = '$id$ext';
      final destinationPath = p.join(audioDir.path, fileName);

      await sourceFile.copy(destinationPath);

      final metadataFile = File(p.join(audioDir.path, '$id.json'));
      final now = DateTime.now();
      final audioFile = AudioFile(
        id: id,
        title: title,
        filePath: destinationPath,
        createdAt: DateFormat('yyyy-MM-dd HH:mm:ss').format(now),
      );
      await metadataFile.writeAsString(jsonEncode(audioFile.toJson()));

      invalidateCache();
      return true;
    } catch (e) {
      debugPrint('Error saving audio: $e');
      return false;
    }
  }

  /// Get all saved audio files, sorted newest first.
  /// Uses in-memory cache for fast subsequent loads.
  Future<List<AudioFile>> getSavedAudios({bool forceRefresh = false}) async {
    // Return cached data if valid
    if (!forceRefresh && _isCacheValid) {
      debugPrint('Returning cached audios (${_cachedAudios!.length} files)');
      return _cachedAudios!;
    }

    try {
      final audioDir = await _getAudioDirectory();
      if (!await audioDir.exists()) {
        _cachedAudios = [];
        _lastCacheTime = DateTime.now();
        return [];
      }

      // List all files at once
      final files = await audioDir.list().toList();
      final metadataFiles =
          files
              .whereType<File>()
              .where((f) => p.extension(f.path) == '.json')
              .toList();

      if (metadataFiles.isEmpty) {
        _cachedAudios = [];
        _lastCacheTime = DateTime.now();
        return [];
      }

      // Parse all metadata files in PARALLEL (major performance improvement)
      final parsed = await Future.wait(
        metadataFiles.map((file) async {
          try {
            final content = await file.readAsString();
            final audioFile = AudioFile.fromJson(jsonDecode(content));
            // Verify file exists during parse, skip if not
            if (await File(audioFile.filePath).exists()) {
              return audioFile;
            }
            return null;
          } catch (e) {
            debugPrint('Error parsing metadata: $e');
            return null;
          }
        }),
      );

      // Filter out nulls and sort
      final audioFiles = parsed.whereType<AudioFile>().toList();
      audioFiles.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Update cache
      _cachedAudios = audioFiles;
      _lastCacheTime = DateTime.now();

      debugPrint('Loaded ${audioFiles.length} audios (cached)');
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

      for (final ext in ['.wav', '.mp3']) {
        final audioFile = File(p.join(audioDir.path, '$id$ext'));
        if (await audioFile.exists()) await audioFile.delete();
      }

      final metadataFile = File(p.join(audioDir.path, '$id.json'));
      if (await metadataFile.exists()) await metadataFile.delete();

      invalidateCache();
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
      invalidateCache();
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
      if (audioFiles.isEmpty) {
        throw const StorageException('No audio files to export');
      }

      final now = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final exportDir = await _getExportDirectory('sonify_export_$now');

      for (final audioFile in audioFiles) {
        final sourceFile = File(audioFile.filePath);
        if (await sourceFile.exists()) {
          final safeName = p.basename(
            audioFile.title.replaceAll(RegExp(r'[^\w\s-]'), '').trim(),
          );
          final ext = p.extension(audioFile.filePath);
          final targetFile = File(
            p.join(
              exportDir.path,
              '${safeName}_${audioFile.id.substring(0, 8)}$ext',
            ),
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

  /// Rename a saved audio file's title in its metadata
  Future<bool> renameAudio(String id, String newTitle) async {
    try {
      final audioDir = await _getAudioDirectory();
      final metadataFile = File(p.join(audioDir.path, '$id.json'));
      if (!await metadataFile.exists()) return false;
      final content = await metadataFile.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      json['title'] = newTitle;
      await metadataFile.writeAsString(jsonEncode(json));
      invalidateCache();
      return true;
    } catch (e) {
      debugPrint('Error renaming audio: $e');
      return false;
    }
  }

  /// Share an audio file via the system share sheet
  Future<void> shareAudio(String audioPath, String title) async {
    final file = XFile(audioPath);
    await Share.shareXFiles([file], text: 'Shared from Sonify: $title');
  }

  /// Delete temporary audio files older than 24 hours
  Future<void> cleanupTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = await tempDir.list().toList();
      final now = DateTime.now();

      for (final entity in files) {
        if (entity is File && entity.path.contains('sonify_')) {
          final stat = await entity.stat();
          if (now.difference(stat.modified).inHours > 24) {
            await entity.delete();
          }
        }
      }
    } catch (e) {
      debugPrint('Cleanup error: $e');
    }
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
      baseDir =
          (await getExternalStorageDirectory()) ??
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
