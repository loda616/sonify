import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/presentation/providers/theme_provider.dart';
import '../../../../l10n/app_localizations.dart';

class ThemeSettingsCard extends StatelessWidget {
  const ThemeSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
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
    );
  }
}
