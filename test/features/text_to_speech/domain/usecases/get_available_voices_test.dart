import 'package:flutter_test/flutter_test.dart';
import 'package:sonify/features/text_to_speech/domain/entities/speech_options.dart';
import 'package:sonify/features/text_to_speech/domain/repositories/tts_repository.dart';
import 'package:sonify/features/text_to_speech/domain/usecases/get_available_voices.dart';

class MockTtsRepository implements TtsRepository {
  List<String> mockVoices = [];
  bool shouldThrow = false;
  Exception? exceptionToThrow;

  @override
  Future<List<String>> getAvailableVoices() async {
    if (shouldThrow) {
      throw exceptionToThrow ?? Exception('Mock exception');
    }
    return mockVoices;
  }

  @override
  Future<String> generateSpeech(SpeechOptions options) {
    throw UnimplementedError();
  }

  @override
  Future<void> initialize() {
    throw UnimplementedError();
  }

  @override
  bool get isInitialized => throw UnimplementedError();

  @override
  int get numSpeakers => throw UnimplementedError();
}

void main() {
  late GetAvailableVoices usecase;
  late MockTtsRepository mockRepository;

  setUp(() {
    mockRepository = MockTtsRepository();
    usecase = GetAvailableVoices(mockRepository);
  });

  test('should return list of voices when repository returns successfully', () async {
    // arrange
    final expectedVoices = ['en_US-ryan-medium', 'ar_JO-kareem-medium'];
    mockRepository.mockVoices = expectedVoices;

    // act
    final result = await usecase();

    // assert
    expect(result, equals(expectedVoices));
  });

  test('should return empty list when repository returns empty list', () async {
    // arrange
    mockRepository.mockVoices = [];

    // act
    final result = await usecase();

    // assert
    expect(result, isEmpty);
  });

  test('should throw exception when repository throws exception', () async {
    // arrange
    mockRepository.shouldThrow = true;
    final exception = Exception('Failed to get voices');
    mockRepository.exceptionToThrow = exception;

    // act & assert
    expect(() => usecase(), throwsA(equals(exception)));
  });
}
