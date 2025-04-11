import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../services/tts_service.dart';
import '../../../theme/presentation/providers/theme_provider.dart';

class StorageCard extends StatefulWidget {
  const StorageCard({super.key});

  @override
  State<StorageCard> createState() => _StorageCardState();
}

class _StorageCardState extends State<StorageCard> {
  final TTSService _ttsService = TTSService();
  bool _isClearing = false;
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Storage',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        ListTile(
          title: Text(
            'Clear All Saved Audio',
            style: theme.textTheme.bodyLarge,
          ),
          subtitle: const Text(
            'Delete all saved audio files',
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
                title: const Text('Confirm Deletion'),
                content: const Text(
                  'Are you sure you want to delete all saved audio files? This action cannot be undone.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Delete All'),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All audio files have been deleted'),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
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
            'Export All Audio Files',
            style: theme.textTheme.bodyLarge,
          ),
          subtitle: const Text(
            'Export all audio files to device storage',
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Audio files exported to: $exportPath'),
                  duration: const Duration(seconds: 5),
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${e.toString()}'),
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
    );
  }
}
