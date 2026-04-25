import '../repositories/settings_repository.dart';

class ClearAllSavedAudios {
  final SettingsRepository repository;
  ClearAllSavedAudios(this.repository);

  Future<bool> call() => repository.clearAllSavedAudios();
}
