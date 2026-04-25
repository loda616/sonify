import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sonify/features/theme/presentation/providers/theme_provider.dart';

void main() {
  group('ThemeProvider', () {
    test('starts with isDarkMode false if prefs has no value', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = ThemeProvider();

      // Wait for async load to finish
      await Future.delayed(Duration.zero);

      expect(provider.isDarkMode, false);
    });

    test('starts with isDarkMode true if prefs has isDarkMode=true', () async {
      SharedPreferences.setMockInitialValues({'isDarkMode': true});
      final provider = ThemeProvider();

      // Wait for async load to finish
      await Future.delayed(Duration.zero);

      expect(provider.isDarkMode, true);
    });

    test('starts with isDarkMode false if prefs has isDarkMode=false', () async {
      SharedPreferences.setMockInitialValues({'isDarkMode': false});
      final provider = ThemeProvider();

      // Wait for async load to finish
      await Future.delayed(Duration.zero);

      expect(provider.isDarkMode, false);
    });

    test('toggleTheme changes isDarkMode from false to true and updates prefs', () async {
      SharedPreferences.setMockInitialValues({'isDarkMode': false});
      final provider = ThemeProvider();

      // Wait for async load to finish
      await Future.delayed(Duration.zero);

      // Track notifyListeners calls
      var notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      await provider.toggleTheme();

      expect(provider.isDarkMode, true);
      expect(notifyCount, 1);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('isDarkMode'), true);
    });

    test('toggleTheme changes isDarkMode from true to false and updates prefs', () async {
      SharedPreferences.setMockInitialValues({'isDarkMode': true});
      final provider = ThemeProvider();

      // Wait for async load to finish
      await Future.delayed(Duration.zero);

      // Track notifyListeners calls
      var notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      await provider.toggleTheme();

      expect(provider.isDarkMode, false);
      expect(notifyCount, 1);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('isDarkMode'), false);
    });
  });
}
