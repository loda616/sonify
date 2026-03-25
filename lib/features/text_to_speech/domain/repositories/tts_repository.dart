import '../entities/speech_options.dart';

abstract class TtsRepository {
  /// Generate speech audio from text. Returns file path to WAV.
  Future<String> generateSpeech(SpeechOptions options);

  /// Get list of available voice names
  Future<List<String>> getAvailableVoices();

  /// Initialize the TTS engine (load model)
  Future<void> initialize();

  /// Whether the engine is ready to generate
  bool get isInitialized;

  /// Number of available speaker IDs
  int get numSpeakers;
}
