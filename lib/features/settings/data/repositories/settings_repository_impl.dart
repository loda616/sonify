import 'package:sonify/services/audio_storage_service.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final AudioStorageService storageService;
  SettingsRepositoryImpl({required this.storageService});

  @override
  Future<bool> clearAllSavedAudios() => storageService.clearAllSavedAudios();

  @override
  Future<String> exportAllAudios() => storageService.exportAllAudios();
}
