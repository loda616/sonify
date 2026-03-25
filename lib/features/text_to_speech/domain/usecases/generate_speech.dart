import '../entities/speech_options.dart';
import '../repositories/tts_repository.dart';

class GenerateSpeech {
  final TtsRepository repository;
  GenerateSpeech(this.repository);

  /// Returns the file path of the generated WAV audio
  Future<String> call(SpeechOptions options) {
    return repository.generateSpeech(options);
  }
}
