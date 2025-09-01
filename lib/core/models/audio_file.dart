import 'dart:convert';

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

  // Factory constructor to create an instance from a map (JSON)
  factory AudioFile.fromJson(Map<String, dynamic> json) {
    return AudioFile(
      id: json['id'],
      title: json['title'],
      filePath: json['filePath'],
      createdAt: json['createdAt'],
    );
  }

  // Method to convert an instance to a map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'filePath': filePath,
      'createdAt': createdAt,
    };
  }
}