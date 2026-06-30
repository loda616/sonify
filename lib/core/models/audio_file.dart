class AudioFile {
  final String id;
  final String title;
  final String filePath;
  final String createdAt;

  AudioFile({
    required this.id,
    required this.title,
    required this.filePath,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'filePath': filePath,
    'createdAt': createdAt,
  };

  factory AudioFile.fromJson(Map<String, dynamic> json) => AudioFile(
    id: json['id'] as String,
    title: json['title'] as String,
    filePath: json['filePath'] as String,
    createdAt: json['createdAt'] as String,
  );
}
