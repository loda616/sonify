abstract class SettingsRepository {
  Future<bool> clearAllSavedAudios();
  Future<String> exportAllAudios();
}
