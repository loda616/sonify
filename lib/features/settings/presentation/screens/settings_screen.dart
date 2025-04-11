import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sonify/features/settings/presentation/widgets/about_card.dart';
import 'package:sonify/features/settings/presentation/widgets/storage_card.dart';

import '../../../theme/presentation/providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeProvider>(context);
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
            //Storage
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: StorageCard(),
              ),
            ),
            const SizedBox(height: 16),
            //About
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: AboutCard()
              ),
            ),
          ],
        ),
      ),
    );
  }
}