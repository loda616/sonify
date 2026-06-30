import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Light Theme Colors
const Color lightPrimaryColor = Color(0xFF1E3A8A); // Deep Blue
const Color lightBackgroundColor = Color(0xFFF8FAFC); // Clean Slate White
const Color lightTextColor = Color(0xFF1E293B); // Slate 800
const Color lightAccentColor = Color(0xFF0D9488); // Vibrant Teal
const Color lightCardColor = Colors.white;

// Dark Theme Colors
const Color darkPrimaryColor = Color(0xFF6366F1); // Modern Indigo
const Color darkBackgroundColor = Color(0xFF0F172A); // Slate 900 (Deep Space Blue-Black)
const Color darkTextColor = Color(0xFFF1F5F9); // Light Slate Gray
const Color darkAccentColor = Color(0xFF06B6D4); // Electric Cyan
const Color darkCardColor = Color(0xFF1E293B); // Slate 800 Card

ThemeData getLightTheme() {
  return ThemeData(
    useMaterial3: true,
    primaryColor: lightPrimaryColor,
    scaffoldBackgroundColor: lightBackgroundColor,
    colorScheme: const ColorScheme.light(
      primary: lightPrimaryColor,
      secondary: lightAccentColor,
      surface: lightCardColor,
      onSurface: lightTextColor,
    ),
    textTheme: GoogleFonts.interTextTheme(const TextTheme(
      bodyLarge: TextStyle(color: lightTextColor, fontSize: 16),
      bodyMedium: TextStyle(color: lightTextColor, fontSize: 14),
      titleLarge: TextStyle(
        color: lightTextColor,
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
      titleMedium: TextStyle(
        color: lightTextColor,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
    )),
    appBarTheme: const AppBarTheme(
      backgroundColor: lightBackgroundColor,
      foregroundColor: lightTextColor,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightPrimaryColor,
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
    ),
    cardTheme: CardThemeData(
      color: lightCardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.1), width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.15), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.15), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: lightAccentColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
  );
}

ThemeData getDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    primaryColor: darkPrimaryColor,
    scaffoldBackgroundColor: darkBackgroundColor,
    colorScheme: const ColorScheme.dark(
      primary: darkPrimaryColor,
      secondary: darkAccentColor,
      surface: darkCardColor,
      onSurface: darkTextColor,
    ),
    textTheme: GoogleFonts.manropeTextTheme(const TextTheme(
      bodyLarge: TextStyle(color: darkTextColor, fontSize: 16),
      bodyMedium: TextStyle(color: darkTextColor, fontSize: 14),
      titleLarge: TextStyle(
        color: darkTextColor,
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
      titleMedium: TextStyle(
        color: darkTextColor,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
    )),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackgroundColor,
      foregroundColor: darkTextColor,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkPrimaryColor,
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.manrope(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
    ),
    cardTheme: CardThemeData(
      color: darkCardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E293B),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: darkAccentColor, width: 2),
      ),
      hintStyle: const TextStyle(color: Color(0xFF64748B)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
  );
}
