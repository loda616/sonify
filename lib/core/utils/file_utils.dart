import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class FileUtils {
  static const String audioDirectoryName = 'sonify_audio';

  /// Get the directory where saved audio files are stored
  static Future<Directory> getAudioDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final audioDir = Directory(p.join(appDir.path, audioDirectoryName));
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    return audioDir;
  }

  /// Get a temporary directory for in-progress audio
  static Future<Directory> getTempAudioDirectory() async {
    return await getTemporaryDirectory();
  }

  /// Check if a file exists at the given path
  static Future<bool> fileExists(String path) async {
    return await File(path).exists();
  }

  /// Get file size in bytes
  static Future<int> getFileSize(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  /// Format file size for display (e.g., "1.2 MB")
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Delete a file safely (no error if missing)
  static Future<void> deleteFileSafely(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
