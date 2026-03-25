import '../datasources/theme_local_data_source.dart';
import '../../domain/repositories/theme_repository.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  final ThemeLocalDataSource dataSource;
  ThemeRepositoryImpl({required this.dataSource});

  @override
  Future<bool> getIsDarkMode() => dataSource.getIsDarkMode();

  @override
  Future<void> setIsDarkMode(bool isDarkMode) =>
      dataSource.setIsDarkMode(isDarkMode);
}
