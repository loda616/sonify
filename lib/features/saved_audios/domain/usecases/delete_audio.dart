import '../repositories/saved_audios_repository.dart';

class DeleteAudio {
  final SavedAudiosRepository repository;
  DeleteAudio(this.repository);

  Future<bool> call(String id) => repository.deleteAudio(id);
}
