import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sonify/screens/home_screen.dart';
import 'package:sonify/utils/theme_config.dart';
import 'models/theme_provider.dart';


void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Sonify',
          debugShowCheckedModeBanner: false,
          theme: getLightTheme(),
          darkTheme: getDarkTheme(),
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const HomeScreen(),
        );
      },
    );
  }
}