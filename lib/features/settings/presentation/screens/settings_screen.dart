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
import '../widgets/theme_settings_card.dart';
import '../widgets/voice_settings_card.dart';
import '../widgets/storage_settings_card.dart';
import '../widgets/about_card.dart';

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

            const ThemeSettingsCard(),
            const SizedBox(height: 16),

            VoiceSettingsCard(
              defaultSpeed: _defaultSpeed,
              onSpeedChanged: (v) async {
                setState(() => _defaultSpeed = v);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setDouble(AppConstants.storageKeyDefaultSpeed, v);
              },
              onDiscoverVoices: () {
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

            const SizedBox(height: 16),

            StorageSettingsCard(
              isClearing: _isClearing,
              isExporting: _isExporting,
              onClearAll: () async {
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
              onExportAll: () async {
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

            const SizedBox(height: 16),

            AboutCard(isDarkMode: isDarkMode),
          ],
        ),
      ),
    );
  }
}
