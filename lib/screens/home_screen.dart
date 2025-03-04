import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sonify/screens/saved_audios_screen.dart';
import 'package:sonify/screens/settings_screen.dart';
import 'package:sonify/screens/text_to_speech_screen.dart';

import '../models/theme_provider.dart';
import '../widgets/theme_switch_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const TextToSpeechScreen(),
    const SavedAudiosScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sonify',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          const ThemeSwitchWidget(),
          SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        selectedItemColor: isDarkMode ? theme.colorScheme.secondary : theme.colorScheme.primary,
        unselectedItemColor: isDarkMode ? const Color(0xFF8E8E8E) : Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.record_voice_over),
            label: 'Text to Speech',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: 'Saved Audio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}