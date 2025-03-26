import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/audio_file.dart';
import '../../../theme/presentation/providers/theme_provider.dart';
import '../../../../services/tts_service.dart';
import '../../../../core/themes/theme_config.dart';
import '../../../text_to_speech/presentaiont/widgets/audio_player_widget.dart';


class SavedAudiosScreen extends StatefulWidget {
  const SavedAudiosScreen({Key? key}) : super(key: key);

  @override
  State<SavedAudiosScreen> createState() => _SavedAudiosScreenState();
}

class _SavedAudiosScreenState extends State<SavedAudiosScreen> {
  final TTSService _ttsService = TTSService();
  List<AudioFile> _audioFiles = [];
  bool _isLoading = true;
  AudioFile? _selectedAudio;

  @override
  void initState() {
    super.initState();
    _loadAudioFiles();
  }

  Future<void> _loadAudioFiles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final files = await _ttsService.getSavedAudios();
      setState(() {
        _audioFiles = files;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading audio files: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteAudioFile(AudioFile audioFile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "${audioFile.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      try {
        final success = await _ttsService.deleteAudio(audioFile.id);
        if (success) {
          setState(() {
            _audioFiles.removeWhere((file) => file.id == audioFile.id);
            if (_selectedAudio?.id == audioFile.id) {
              _selectedAudio = null;
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Audio deleted successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete audio')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting audio: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Saved Audio Files',
                style: theme.textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadAudioFiles,
                tooltip: 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (_audioFiles.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.music_off,
                      size: 64,
                      color: isDarkMode ? Colors.white38 : Colors.black26,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No saved audio files yet',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isDarkMode ? Colors.white38 : Colors.black38,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Convert text to speech and save audio files to see them here',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDarkMode ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _audioFiles.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final audioFile = _audioFiles[index];
                        final isSelected = _selectedAudio?.id == audioFile.id;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: isSelected
                                ? BorderSide(
                              color: isDarkMode ? darkAccentColor : lightAccentColor,
                              width: 2,
                            )
                                : BorderSide.none,
                          ),
                          color: isSelected
                              ? (isDarkMode ? const Color(0xFF252525) : const Color(0xFFF0F0F0))
                              : null,
                          child: ListTile(
                            title: Text(
                              audioFile.title,
                              style: theme.textTheme.titleMedium,
                            ),
                            subtitle: Text(
                              'Created: ${audioFile.createdAt}',
                              style: theme.textTheme.bodySmall,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: isDarkMode ? darkPrimaryColor : lightPrimaryColor,
                              child: const Icon(
                                Icons.music_note,
                                color: Colors.white,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteAudioFile(audioFile),
                            ),
                            onTap: () {
                              setState(() {
                                _selectedAudio = isSelected ? null : audioFile;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  if (_selectedAudio != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedAudio!.title,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          AudioPlayerWidget(
                            audioPath: _selectedAudio!.filePath,
                            onSave: null, // Already saved
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}