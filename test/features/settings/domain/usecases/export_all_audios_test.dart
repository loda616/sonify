import 'package:flutter_test/flutter_test.dart';
import 'package:sonify/features/settings/domain/repositories/settings_repository.dart';
import 'package:sonify/features/settings/domain/usecases/export_all_audios.dart';

class MockSettingsRepository implements SettingsRepository {
  String? exportPath;
  Object? error;
  int exportCallCount = 0;

  @override
  Future<bool> clearAllSavedAudios() async {
    return true;
  }

  @override
  Future<String> exportAllAudios() async {
    exportCallCount++;
    if (error != null) {
      throw error!;
    }
    return exportPath ?? 'default/path';
  }
}

void main() {
  late ExportAllAudios useCase;
  late MockSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockSettingsRepository();
    useCase = ExportAllAudios(mockRepository);
  });

  test('should call exportAllAudios from repository and return the path', () async {
    // arrange
    const tPath = 'exported/audios.zip';
    mockRepository.exportPath = tPath;

    // act
    final result = await useCase();

    // assert
    expect(result, tPath);
    expect(mockRepository.exportCallCount, 1);
  });

  test('should propagate exception from repository', () async {
    // arrange
    final tException = Exception('Failed to export');
    mockRepository.error = tException;

    // act & assert
    expect(() => useCase(), throwsA(tException));
    expect(mockRepository.exportCallCount, 1);
  });
}
