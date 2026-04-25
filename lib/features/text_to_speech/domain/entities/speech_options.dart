class SpeechOptions {
  final String text;
  final int speakerId;
  final double speed;

  const SpeechOptions({
    required this.text,
    this.speakerId = 0,
    this.speed = 1.0,
  });

  SpeechOptions copyWith({String? text, int? speakerId, double? speed}) {
    return SpeechOptions(
      text: text ?? this.text,
      speakerId: speakerId ?? this.speakerId,
      speed: speed ?? this.speed,
    );
  }
}
