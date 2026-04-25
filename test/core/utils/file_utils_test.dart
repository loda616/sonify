import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sonify/core/utils/file_utils.dart';
import 'package:path/path.dart' as p;

class FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  final String appDocsPath;
  final String tempPath;

  FakePathProviderPlatform({required this.appDocsPath, required this.tempPath});

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return appDocsPath;
  }

  @override
  Future<String?> getTemporaryPath() async {
    return tempPath;
  }
}

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('file_utils_test');
    PathProviderPlatform.instance = FakePathProviderPlatform(
      appDocsPath: p.join(tempDir.path, 'app_docs'),
      tempPath: p.join(tempDir.path, 'temp'),
    );
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('FileUtils', () {
    test('getAudioDirectory creates and returns the correct directory', () async {
      final audioDir = await FileUtils.getAudioDirectory();

      expect(audioDir.path, p.join(tempDir.path, 'app_docs', FileUtils.audioDirectoryName));
      expect(await audioDir.exists(), isTrue);
    });

    test('getTempAudioDirectory returns the correct temporary directory', () async {
      final audioDir = await FileUtils.getTempAudioDirectory();

      expect(audioDir.path, p.join(tempDir.path, 'temp'));
    });

    test('fileExists returns true when file exists', () async {
      final file = File(p.join(tempDir.path, 'test_file.txt'));
      await file.writeAsString('test content');

      expect(await FileUtils.fileExists(file.path), isTrue);
    });

    test('fileExists returns false when file does not exist', () async {
      final path = p.join(tempDir.path, 'non_existent_file.txt');

      expect(await FileUtils.fileExists(path), isFalse);
    });

    test('getFileSize returns correct size when file exists', () async {
      final file = File(p.join(tempDir.path, 'test_size_file.txt'));
      await file.writeAsString('12345'); // 5 bytes

      expect(await FileUtils.getFileSize(file.path), 5);
    });

    test('getFileSize returns 0 when file does not exist', () async {
      final path = p.join(tempDir.path, 'non_existent_file.txt');

      expect(await FileUtils.getFileSize(path), 0);
    });

    test('formatFileSize formats correctly', () {
      expect(FileUtils.formatFileSize(500), '500 B');
      expect(FileUtils.formatFileSize(1024), '1.0 KB');
      expect(FileUtils.formatFileSize(1536), '1.5 KB'); // 1.5 * 1024
      expect(FileUtils.formatFileSize(1024 * 1024), '1.0 MB');
      expect(FileUtils.formatFileSize((2.5 * 1024 * 1024).toInt()), '2.5 MB');
    });

    test('deleteFileSafely deletes an existing file', () async {
      final file = File(p.join(tempDir.path, 'test_delete_file.txt'));
      await file.writeAsString('test content');

      expect(await file.exists(), isTrue);

      await FileUtils.deleteFileSafely(file.path);

      expect(await file.exists(), isFalse);
    });

    test('deleteFileSafely does not throw when file does not exist', () async {
      final path = p.join(tempDir.path, 'non_existent_file.txt');

      // Should not throw an exception
      await expectLater(FileUtils.deleteFileSafely(path), completes);
    });
  });
}
