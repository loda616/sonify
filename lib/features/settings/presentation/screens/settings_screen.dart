import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../theme/presentation/providers/theme_provider.dart';
import '../../../../services/tts_service.dart';
import '../../../../core/themes/theme_config.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../l10n/app_localizations.dart';
import 'model_manager_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TTSService _ttsService;
  bool _isClearing = false;
  bool _isExporting = false;
  double _defaultSpeed = AppConstants.defaultSpeed;

  @override
  void initState() {
    super.initState();
    _ttsService = sl<TTSService>();
    _loadDefaultSpeed();
  }

  Future<void> _loadDefaultSpeed() async {
    final prefs = await SharedPreferences.getInstance();
    final speed = prefs.getDouble(AppConstants.storageKeyDefaultSpeed);
    if (speed != null && mounted) {
      setState(() => _defaultSpeed = speed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final ttsService = Provider.of<TTSService>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.settingsTitle,
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
                      l10n.settingsAppearance,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: Text(
                        l10n.settingsDarkMode,
                        style: theme.textTheme.bodyLarge,
                      ),
                      subtitle: Text(
                        isDarkMode ? l10n.settingsDarkTheme : l10n.settingsLightTheme,
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

            // Voice/TTS Settings
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.settingsVoice, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.settingsDefaultSpeed, style: theme.textTheme.bodyLarge),
                      subtitle: Text('${_defaultSpeed.toStringAsFixed(1)}x'),
                      trailing: SizedBox(
                        width: 150,
                        child: Slider(
                          value: _defaultSpeed,
                          min: AppConstants.minSpeed,
                          max: AppConstants.maxSpeed,
                          divisions: 25,
                          label: '${_defaultSpeed.toStringAsFixed(1)}x',
                          onChanged: (v) async {
                            setState(() => _defaultSpeed = v);
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setDouble(AppConstants.storageKeyDefaultSpeed, v);
                          },
                        ),
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.settingsTtsEngine),
                      subtitle: Text('${ttsService.activeModel.name} (${ttsService.activeModel.language})'),
                      trailing: const Icon(Icons.offline_bolt, color: Colors.green),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.settingsDiscoverVoices),
                      subtitle: Text(l10n.settingsDiscoverVoicesDesc),
                      trailing: const Icon(Icons.language, color: Colors.blue),
                      onTap: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => const ModelManagerScreen(),
                            transitionsBuilder: (_, animation, __, child) {
                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(1.0, 0.0),
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutCubic,
                                )),
                                child: child,
                              );
                            },
                            transitionDuration: const Duration(milliseconds: 300),
                          ),
                        );
                      },
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
                      l10n.settingsStorage,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(
                        l10n.settingsClearAll,
                        style: theme.textTheme.bodyLarge,
                      ),
                      subtitle: Text(
                        l10n.settingsClearAllDesc,
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
                            title: Text(l10n.settingsClearConfirmTitle),
                            content: Text(
                              l10n.settingsClearConfirmMessage,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: Text(l10n.genericCancel),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: Text(l10n.genericDeleteAll),
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
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.settingsClearSuccess),
                              ),
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.genericErrorPrefix(e.toString())),
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
                        l10n.settingsExportAll,
                        style: theme.textTheme.bodyLarge,
                      ),
                      subtitle: Text(
                        l10n.settingsExportAllDesc,
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
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.settingsExportSuccess(exportPath)),
                              duration: const Duration(seconds: 5),
                            ),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.genericErrorPrefix(e.toString())),
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
                      l10n.settingsAbout,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text('Sonify', style: theme.textTheme.bodyLarge),
                      subtitle: Text('v${AppConstants.appVersion} — Powered by ${AppConstants.engineVersion}'),
                      trailing: const Icon(Icons.info_outline),
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: AppConstants.appName,
                          applicationVersion: AppConstants.appVersion,
                          applicationLegalese: '© 2026 Khalid',
                          applicationIcon: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/images/sonify-logo.png',
                              width: 48,
                              height: 48,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.record_voice_over,
                                color: isDarkMode ? darkAccentColor : lightPrimaryColor,
                                size: 36,
                              ),
                            ),
                          ),
                          children: [
                            const SizedBox(height: 16),
                            Text(
                              l10n.settingsAboutDescription,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.settingsAboutTechInfo,
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
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