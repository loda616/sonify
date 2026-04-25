import '../repositories/theme_repository.dart';

class GetTheme {
  final ThemeRepository repository;
  GetTheme(this.repository);

  Future<bool> call() => repository.getIsDarkMode();
}
