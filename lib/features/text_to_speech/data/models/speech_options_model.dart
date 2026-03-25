import '../../domain/entities/speech_options.dart';

class SpeechOptionsModel extends SpeechOptions {
  const SpeechOptionsModel({
    required super.text,
    super.speakerId = 0,
    super.speed = 1.0,
  });

  factory SpeechOptionsModel.fromEntity(SpeechOptions entity) {
    return SpeechOptionsModel(
      text: entity.text,
      speakerId: entity.speakerId,
      speed: entity.speed,
    );
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'speakerId': speakerId,
        'speed': speed,
      };
}
