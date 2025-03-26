import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme/presentation/providers/theme_provider.dart';
import '../../../../services/tts_service.dart';
import '../../../../core/themes/theme_config.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TTSService _ttsService = TTSService();
  bool _isClearing = false;
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 24),

            // Theme Settings
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Appearance',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: Text(
                        'Dark Mode',
                        style: theme.textTheme.bodyLarge,
                      ),
                      subtitle: Text(
                        isDarkMode ? 'Using dark theme' : 'Using light theme',
                        style: theme.textTheme.bodySmall,
                      ),
                      value: isDarkMode,
                      onChanged: (_) {
                        themeProvider.toggleTheme();
                      },
                      secondary: Icon(
                        isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        color: isDarkMode ? theme.colorScheme.secondary : theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Storage Settings
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Storage',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(
                        'Clear All Saved Audio',
                        style: theme.textTheme.bodyLarge,
                      ),
                      subtitle: const Text(
                        'Delete all saved audio files',
                      ),
                      trailing: _isClearing
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                          : const Icon(Icons.delete_forever),
                      onTap: _isClearing
                          ? null
                          : () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm Deletion'),
                            content: const Text(
                              'Are you sure you want to delete all saved audio files? This action cannot be undone.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Delete All'),
                              ),
                            ],
                          ),
                        );

                        if (confirmed ?? false) {
                          setState(() {
                            _isClearing = true;
                          });

                          try {
                            await _ttsService.clearAllSavedAudios();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('All audio files have been deleted'),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: ${e.toString()}'),
                              ),
                            );
                          } finally {
                            setState(() {
                              _isClearing = false;
                            });
                          }
                        }
                      },
                    ),

                    ListTile(
                      title: Text(
                        'Export All Audio Files',
                        style: theme.textTheme.bodyLarge,
                      ),
                      subtitle: const Text(
                        'Export all audio files to device storage',
                      ),
                      trailing: _isExporting
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                          : const Icon(Icons.file_download),
                      onTap: _isExporting
                          ? null
                          : () async {
                        setState(() {
                          _isExporting = true;
                        });

                        try {
                          final exportPath = await _ttsService.exportAllAudios();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Audio files exported to: $exportPath'),
                              duration: const Duration(seconds: 5),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${e.toString()}'),
                            ),
                          );
                        } finally {
                          setState(() {
                            _isExporting = false;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // About section
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(
                        'Sonify',
                        style: theme.textTheme.bodyLarge,
                      ),
                      subtitle: const Text('Version 1.0.0'),
                      trailing: const Icon(Icons.info_outline),
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'Sonify',
                          applicationVersion: '1.0.0',
                          applicationIcon: Icon(
                            Icons.record_voice_over,
                            color: isDarkMode ? darkAccentColor : lightPrimaryColor,
                            size: 36,
                          ),
                          children: [
                            const Text(
                              'Sonify is a text-to-speech application that uses a local AI model to generate high-quality speech from text.',
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}