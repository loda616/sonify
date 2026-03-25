import 'package:sonify/core/models/audio_file.dart';

class SavedAudioModel extends AudioFile {
  SavedAudioModel({
    required super.id,
    required super.title,
    required super.filePath,
    required super.createdAt,
  });

  factory SavedAudioModel.fromAudioFile(AudioFile file) {
    return SavedAudioModel(
      id: file.id,
      title: file.title,
      filePath: file.filePath,
      createdAt: file.createdAt,
    );
  }
}
