import 'package:sonify/services/audio_storage_service.dart';

abstract class SettingsLocalDataSource {
  Future<bool> clearAllSavedAudios();
  Future<String> exportAllAudios();
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final AudioStorageService storageService;
  SettingsLocalDataSourceImpl({required this.storageService});

  @override
  Future<bool> clearAllSavedAudios() => storageService.clearAllSavedAudios();

  @override
  Future<String> exportAllAudios() => storageService.exportAllAudios();
}
