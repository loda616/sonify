class RemoteModel {
  final String id;
  final String language;
  final String name;
  final String quality;
  final String filename;
  final String downloadUrl;
  final bool isCustom;
  final bool isBundled;

  const RemoteModel({
    required this.id,
    required this.language,
    required this.name,
    required this.quality,
    required this.filename,
    required this.downloadUrl,
    this.isCustom = false,
    this.isBundled = false,
  });

  /// The local directory name this model unzips to.
  String get directoryName => filename.replaceAll('.tar.bz2', '');

  Map<String, dynamic> toJson() => {
    'id': id,
    'language': language,
    'name': name,
    'quality': quality,
    'filename': filename,
    'downloadUrl': downloadUrl,
    'isCustom': isCustom,
    'isBundled': isBundled,
  };

  factory RemoteModel.fromJson(Map<String, dynamic> json) => RemoteModel(
    id: json['id'] as String,
    language: json['language'] as String,
    name: json['name'] as String,
    quality: json['quality'] as String,
    filename: json['filename'] as String,
    downloadUrl: json['downloadUrl'] as String,
    isCustom: json['isCustom'] as bool? ?? false,
    isBundled: json['isBundled'] as bool? ?? false,
  );
}
