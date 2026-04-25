import 'package:sonify/core/errors/exceptions.dart';
import 'package:sonify/services/tts_engine.dart';
import '../../domain/entities/speech_options.dart';
import '../../domain/repositories/tts_repository.dart';

class TtsRepositoryImpl implements TtsRepository {
  final TtsEngine engine;
  TtsRepositoryImpl({required this.engine});

  @override
  Future<String> generateSpeech(SpeechOptions options) async {
    try {
      return await engine.generateSpeech(
        options.text,
        speakerId: options.speakerId,
        speed: options.speed,
      );
    } catch (e) {
      throw TtsGenerationException('Failed to generate speech: $e');
    }
  }

  @override
  Future<List<String>> getAvailableVoices() async {
    await initialize();
    final count = engine.numSpeakers;
    if (count <= 1) return ['Default'];
    return ['Default', ...List.generate(count, (i) => 'Speaker ${i + 1}')];
  }

  @override
  Future<void> initialize() async {
    try {
      await engine.initialize();
    } catch (e) {
      throw TtsInitializationException('Failed to initialize TTS: $e');
    }
  }

  @override
  bool get isInitialized => engine.isInitialized;

  @override
  int get numSpeakers => engine.numSpeakers;
}
