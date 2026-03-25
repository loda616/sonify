import 'package:sonify/core/models/audio_file.dart';
import '../repositories/saved_audios_repository.dart';

class GetSavedAudios {
  final SavedAudiosRepository repository;
  GetSavedAudios(this.repository);

  Future<List<AudioFile>> call() => repository.getSavedAudios();
}
