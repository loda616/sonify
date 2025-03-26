import 'package:flutter/material.dart';

// Light Theme Colors
const Color lightPrimaryColor = Color(0xFF1E3A8A); // Deep Blue
const Color lightBackgroundColor = Color(0xFFF5F5F5); // Soft Off-White
const Color lightTextColor = Color(0xFF333333); // Dark Gray
const Color lightAccentColor = Color(0xFF00A896); // Vibrant Teal

// Dark Theme Colors
const Color darkPrimaryColor = Color(0xFF4F46E5); // Neon Blue
const Color darkBackgroundColor = Color(0xFF121212); // Deep Black
const Color darkTextColor = Color(0xFFE0E0E0); // Light Gray
const Color darkAccentColor = Color(0xFF00E5FF); // Electric Cyan

ThemeData getLightTheme() {
  return ThemeData(
    primaryColor: lightPrimaryColor,
    scaffoldBackgroundColor: lightBackgroundColor,
    colorScheme: const ColorScheme.light(
      primary: lightPrimaryColor,
      secondary: lightAccentColor,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: lightTextColor, fontFamily: 'Inter'),
      bodyMedium: TextStyle(color: lightTextColor, fontFamily: 'Inter'),
      titleLarge: TextStyle(
        color: lightTextColor,
        fontFamily: 'Inter',
        fontWeight: FontWeight.bold,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: lightPrimaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightPrimaryColor,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.bold,
        ),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: lightAccentColor, width: 2),
      ),
    ),
  );
}

ThemeData getDarkTheme() {
  return ThemeData(
    primaryColor: darkPrimaryColor,
    scaffoldBackgroundColor: darkBackgroundColor,
    colorScheme: const ColorScheme.dark(
      primary: darkPrimaryColor,
      secondary: darkAccentColor,
      background: darkBackgroundColor,
      surface: Color(0xFF1E1E1E),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: darkTextColor, fontFamily: 'Manrope'),
      bodyMedium: TextStyle(color: darkTextColor, fontFamily: 'Manrope'),
      titleLarge: TextStyle(
        color: darkTextColor,
        fontFamily: 'Manrope',
        fontWeight: FontWeight.bold,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackgroundColor,
      foregroundColor: darkTextColor,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkPrimaryColor,
        foregroundColor: darkTextColor,
        textStyle: const TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.bold,
        ),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    cardTheme: CardTheme(
      color: const Color(0xFF1E1E1E),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: darkAccentColor, width: 2),
      ),
      hintStyle: const TextStyle(color: Color(0xFF8E8E8E)),
    ),
  );
}
