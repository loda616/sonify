import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/constants.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../services/tts_service.dart';

class VoiceSettingsCard extends StatelessWidget {
  final double defaultSpeed;
  final ValueChanged<double> onSpeedChanged;
  final VoidCallback onDiscoverVoices;

  const VoiceSettingsCard({
    super.key,
    required this.defaultSpeed,
    required this.onSpeedChanged,
    required this.onDiscoverVoices,
  });

  @override
  Widget build(BuildContext context) {
    final ttsService = Provider.of<TTSService>(context);
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
            Text(l10n.settingsVoice, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.settingsDefaultSpeed, style: theme.textTheme.bodyLarge),
              subtitle: Text('${defaultSpeed.toStringAsFixed(1)}x'),
              trailing: SizedBox(
                width: 150,
                child: Slider(
                  value: defaultSpeed,
                  min: AppConstants.minSpeed,
                  max: AppConstants.maxSpeed,
                  divisions: 25,
                  label: '${defaultSpeed.toStringAsFixed(1)}x',
                  onChanged: onSpeedChanged,
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
              onTap: onDiscoverVoices,
            ),
          ],
        ),
      ),
    );
  }
}
