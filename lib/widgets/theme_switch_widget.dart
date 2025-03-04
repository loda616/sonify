// lib/widgets/theme_switch_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sonify/models/theme_provider.dart';
import 'package:sonify/utils/theme_config.dart';

class ThemeSwitchWidget extends StatelessWidget {
  const ThemeSwitchWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return GestureDetector(
      onTap: () {
        themeProvider.toggleTheme();
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDarkMode ? const Color(0xFF252525) : Colors.white,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isDarkMode
              ? Icon(
            Icons.light_mode,
            key: const ValueKey('light'),
            color: darkAccentColor,
          )
              : Icon(
            Icons.dark_mode,
            key: const ValueKey('dark'),
            color: lightPrimaryColor,
          ),
        ),
      ),
    );
  }
}