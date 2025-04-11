import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/presentation/providers/theme_provider.dart';

class ThemeCard extends StatelessWidget {
  const ThemeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final theme = Theme.of(context);
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
                color: isDarkMode
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
