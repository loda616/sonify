import '../repositories/settings_repository.dart';

class ExportAllAudios {
  final SettingsRepository repository;
  ExportAllAudios(this.repository);

  Future<String> call() => repository.exportAllAudios();
}
