import 'package:sonify/core/models/audio_file.dart';
import 'package:sonify/services/audio_storage_service.dart';
import '../../domain/repositories/saved_audios_repository.dart';

class SavedAudiosRepositoryImpl implements SavedAudiosRepository {
  final AudioStorageService storageService;
  SavedAudiosRepositoryImpl({required this.storageService});

  @override
  Future<List<AudioFile>> getSavedAudios() => storageService.getSavedAudios();

  @override
  Future<bool> saveAudio(String audioPath, String title) =>
      storageService.saveAudio(audioPath, title);

  @override
  Future<bool> deleteAudio(String id) => storageService.deleteAudio(id);
}
