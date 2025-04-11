import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/themes/theme_config.dart';
import '../../../theme/presentation/providers/theme_provider.dart';

class AboutCard extends StatelessWidget {
  const AboutCard({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final theme = Theme.of(context);
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About',
          style: theme.textTheme.titleMedium,
        ),
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
    );
  }
}
