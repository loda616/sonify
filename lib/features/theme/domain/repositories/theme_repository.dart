abstract class ThemeRepository {
  Future<bool> getIsDarkMode();
  Future<void> setIsDarkMode(bool isDarkMode);
}
