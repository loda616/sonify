import '../repositories/tts_repository.dart';

class GetAvailableVoices {
  final TtsRepository repository;
  GetAvailableVoices(this.repository);

  Future<List<String>> call() {
    return repository.getAvailableVoices();
  }
}
