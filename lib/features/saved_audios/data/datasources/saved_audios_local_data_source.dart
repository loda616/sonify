import 'package:sonify/core/models/audio_file.dart';
import 'package:sonify/services/audio_storage_service.dart';

abstract class SavedAudiosLocalDataSource {
  Future<List<AudioFile>> getSavedAudios();
  Future<bool> saveAudio(String audioPath, String title);
  Future<bool> deleteAudio(String id);
}

class SavedAudiosLocalDataSourceImpl implements SavedAudiosLocalDataSource {
  final AudioStorageService storageService;
  SavedAudiosLocalDataSourceImpl({required this.storageService});

  @override
  Future<List<AudioFile>> getSavedAudios() => storageService.getSavedAudios();

  @override
  Future<bool> saveAudio(String audioPath, String title) =>
      storageService.saveAudio(audioPath, title);

  @override
  Future<bool> deleteAudio(String id) => storageService.deleteAudio(id);
}
