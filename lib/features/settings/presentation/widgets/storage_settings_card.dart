import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

class StorageSettingsCard extends StatelessWidget {
  final bool isClearing;
  final bool isExporting;
  final VoidCallback onClearAll;
  final VoidCallback onExportAll;

  const StorageSettingsCard({
    super.key,
    required this.isClearing,
    required this.isExporting,
    required this.onClearAll,
    required this.onExportAll,
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
              trailing: isClearing
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
                  : const Icon(Icons.delete_forever),
              onTap: isClearing ? null : onClearAll,
            ),

            ListTile(
              title: Text(
                l10n.settingsExportAll,
                style: theme.textTheme.bodyLarge,
              ),
              subtitle: Text(
                l10n.settingsExportAllDesc,
              ),
              trailing: isExporting
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
                  : const Icon(Icons.file_download),
              onTap: isExporting ? null : onExportAll,
            ),
          ],
        ),
      ),
    );
  }
}
