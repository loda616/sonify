import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../theme/presentation/providers/theme_provider.dart';
import '../../../../services/tts_service.dart';
import '../../../../core/themes/theme_config.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TTSService _ttsService = TTSService();
  bool _isClearing = false;

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
              AppLocalizations.of(context)!.settingsTitle,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 24),

            // Theme Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.settingsAppearanceSection,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: Text(
                        AppLocalizations.of(context)!.settingsDarkModeLabel,
                        style: theme.textTheme.bodyLarge,
                      ),
                      subtitle: Text(
                        isDarkMode
                            ? AppLocalizations.of(context)!.settingsDarkModeOn
                            : AppLocalizations.of(context)!.settingsDarkModeOff,
                        style: theme.textTheme.bodySmall,
                      ),
                      value: isDarkMode,
                      onChanged: (_) {
                        themeProvider.toggleTheme();
                      },
                      secondary: Icon(
                        isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        color:
                            isDarkMode
                                ? theme.colorScheme.secondary
                                : theme.colorScheme.primary,
                      ),
                    ),
                    const Divider(height: 24),
                    ListTile(
                      leading: Icon(
                        Icons.language,
                        color: isDarkMode
                            ? theme.colorScheme.secondary
                            : theme.colorScheme.primary,
                      ),
                      title: Text(
                        AppLocalizations.of(context)!.settingsLanguageLabel,
                        style: theme.textTheme.bodyLarge,
                      ),
                      trailing: DropdownButton<String>(
                        value: themeProvider.locale.languageCode,
                        underline: const SizedBox(),
                        borderRadius: BorderRadius.circular(12),
                        items: const [
                          DropdownMenuItem(
                            value: 'en',
                            child: Text('English'),
                          ),
                          DropdownMenuItem(
                            value: 'ar',
                            child: Text('العربية (Arabic)'),
                          ),
                        ],
                        onChanged: (langCode) {
                          if (langCode != null) {
                            themeProvider.setLocale(Locale(langCode));
                          }
                        },
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
                      AppLocalizations.of(context)!.settingsStorageSection,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(
                        AppLocalizations.of(context)!.settingsClearAllTitle,
                        style: theme.textTheme.bodyLarge,
                      ),
                      subtitle: Text(
                        AppLocalizations.of(context)!.settingsClearAllSubtitle,
                      ),
                      trailing:
                          _isClearing
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(Icons.delete_forever),
                      onTap:
                          _isClearing
                              ? null
                              : () async {
                                final messenger = ScaffoldMessenger.of(context);
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder:
                                      (ctx) => AlertDialog(
                                        title: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.settingsClearConfirmTitle,
                                        ),
                                        content: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.settingsClearConfirmContent,
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.of(
                                                  ctx,
                                                ).pop(false),
                                            child: Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.settingsClearCancelBtn,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed:
                                                () =>
                                                    Navigator.of(ctx).pop(true),
                                            child: Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.settingsClearDeleteAllBtn,
                                            ),
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
                                    if (mounted) {
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            AppLocalizations.of(
                                              context,
                                            )!.settingsClearSuccess,
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            AppLocalizations.of(
                                              context,
                                            )!.settingsError(e.toString()),
                                          ),
                                        ),
                                      );
                                    }
                                  } finally {
                                    if (mounted) {
                                      setState(() {
                                        _isClearing = false;
                                      });
                                    }
                                  }
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
                      AppLocalizations.of(context)!.settingsAboutSection,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(
                        AppLocalizations.of(context)!.settingsAboutAppName,
                        style: theme.textTheme.bodyLarge,
                      ),
                      subtitle: Text(
                        AppLocalizations.of(
                          context,
                        )!.settingsAboutVersion('1.0.0'),
                      ),
                      trailing: const Icon(Icons.info_outline),
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName:
                              AppLocalizations.of(
                                context,
                              )!.settingsAboutAppName,
                          applicationVersion: '1.0.0',
                          applicationIcon: Icon(
                            Icons.record_voice_over,
                            color:
                                isDarkMode
                                    ? darkAccentColor
                                    : lightPrimaryColor,
                            size: 36,
                          ),
                          children: [
                            Text(
                              AppLocalizations.of(
                                context,
                              )!.settingsAboutDescription,
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
