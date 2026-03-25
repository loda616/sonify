import 'package:sonify/services/tts_engine.dart';

/// Wraps the TTS engine for the data layer
abstract class TtsLocalDataSource {
  Future<void> initialize();
  Future<String> generateSpeech(String text, {int speakerId, double speed});
  Future<List<String>> getAvailableVoices();
  bool get isInitialized;
  int get numSpeakers;
}

class TtsLocalDataSourceImpl implements TtsLocalDataSource {
  final TtsEngine engine;
  TtsLocalDataSourceImpl({required this.engine});

  @override
  Future<void> initialize() => engine.initialize();

  @override
  Future<String> generateSpeech(
    String text, {
    int speakerId = 0,
    double speed = 1.0,
  }) =>
      engine.generateSpeech(text, speakerId: speakerId, speed: speed);

  @override
  Future<List<String>> getAvailableVoices() async {
    await engine.initialize();
    final count = engine.numSpeakers;
    if (count <= 1) return ['Default'];
    return ['Default', ...List.generate(count, (i) => 'Speaker ${i + 1}')];
  }

  @override
  bool get isInitialized => engine.isInitialized;

  @override
  int get numSpeakers => engine.numSpeakers;
}
