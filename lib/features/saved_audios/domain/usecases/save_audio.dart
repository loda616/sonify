import '../repositories/saved_audios_repository.dart';

class SaveAudio {
  final SavedAudiosRepository repository;
  SaveAudio(this.repository);

  Future<bool> call(String audioPath, String title) =>
      repository.saveAudio(audioPath, title);
}
