import 'package:flutter_test/flutter_test.dart';
import 'package:sonify/core/models/audio_file.dart';
import 'package:sonify/features/saved_audios/domain/repositories/saved_audios_repository.dart';
import 'package:sonify/features/saved_audios/domain/usecases/save_audio.dart';

class MockSavedAudiosRepository implements SavedAudiosRepository {
  bool getSavedAudiosCalled = false;
  bool saveAudioCalled = false;
  bool deleteAudioCalled = false;

  String? saveAudioPathArg;
  String? saveAudioTitleArg;

  bool saveAudioResult = true;
  Exception? saveAudioException;

  @override
  Future<List<AudioFile>> getSavedAudios() async {
    getSavedAudiosCalled = true;
    return [];
  }

  @override
  Future<bool> saveAudio(String audioPath, String title) async {
    saveAudioCalled = true;
    saveAudioPathArg = audioPath;
    saveAudioTitleArg = title;

    if (saveAudioException != null) {
      throw saveAudioException!;
    }

    return saveAudioResult;
  }

  @override
  Future<bool> deleteAudio(String id) async {
    deleteAudioCalled = true;
    return true;
  }
}

void main() {
  late SaveAudio usecase;
  late MockSavedAudiosRepository mockRepository;

  setUp(() {
    mockRepository = MockSavedAudiosRepository();
    usecase = SaveAudio(mockRepository);
  });

  group('SaveAudio UseCase', () {
    const tAudioPath = 'path/to/audio.mp3';
    const tTitle = 'Test Audio Title';

    test('should call saveAudio on the repository with correct parameters and return true when successful', () async {
      // arrange
      mockRepository.saveAudioResult = true;

      // act
      final result = await usecase(tAudioPath, tTitle);

      // assert
      expect(result, isTrue);
      expect(mockRepository.saveAudioCalled, isTrue);
      expect(mockRepository.saveAudioPathArg, equals(tAudioPath));
      expect(mockRepository.saveAudioTitleArg, equals(tTitle));
    });

    test('should return false when the repository saveAudio returns false', () async {
      // arrange
      mockRepository.saveAudioResult = false;

      // act
      final result = await usecase(tAudioPath, tTitle);

      // assert
      expect(result, isFalse);
      expect(mockRepository.saveAudioCalled, isTrue);
      expect(mockRepository.saveAudioPathArg, equals(tAudioPath));
      expect(mockRepository.saveAudioTitleArg, equals(tTitle));
    });

    test('should throw an exception when the repository saveAudio throws', () async {
      // arrange
      mockRepository.saveAudioException = Exception('Failed to save audio');

      // act
      final call = usecase(tAudioPath, tTitle);

      // assert
      expect(() => call, throwsException);
      // Ensure that saveAudio is actually called before the exception stops execution
      // Note: Because it throws immediately, we check it after catching or allowing the framework to catch it.
      // But we can check it in a try-catch to be sure:
      try {
        await usecase(tAudioPath, tTitle);
      } catch (_) {}
      expect(mockRepository.saveAudioCalled, isTrue);
      expect(mockRepository.saveAudioPathArg, equals(tAudioPath));
      expect(mockRepository.saveAudioTitleArg, equals(tTitle));
    });
  });
}
