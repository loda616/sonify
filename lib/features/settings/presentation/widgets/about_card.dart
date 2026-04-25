import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/themes/theme_config.dart';
import '../../../../l10n/app_localizations.dart';

class AboutCard extends StatelessWidget {
  final bool isDarkMode;

  const AboutCard({
    super.key,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Card(
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
    );
  }
}
