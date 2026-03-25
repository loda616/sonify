import 'package:sonify/core/models/audio_file.dart';

abstract class SavedAudiosRepository {
  Future<List<AudioFile>> getSavedAudios();
  Future<bool> saveAudio(String audioPath, String title);
  Future<bool> deleteAudio(String id);
}
