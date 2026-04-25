import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/audio_file.dart';
import '../../../theme/presentation/providers/theme_provider.dart';
import '../../../../services/tts_service.dart';
import '../../../../core/themes/theme_config.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../text_to_speech/presentation/widgets/audio_player_widget.dart';

class SavedAudiosScreen extends StatefulWidget {
  const SavedAudiosScreen({super.key});

  @override
  State<SavedAudiosScreen> createState() => _SavedAudiosScreenState();
}

class _SavedAudiosScreenState extends State<SavedAudiosScreen> {
  late final TTSService _ttsService;
  List<AudioFile> _audioFiles = [];
  bool _isLoading = true;
  AudioFile? _selectedAudio;

  // Search & sort
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _sortAlphabetical = false;

  // ⚡ Bolt Optimization: Cache filtered and sorted list to prevent
  // O(N log N) sorting and O(N) string manipulation on every build/re-render.
  List<AudioFile> _cachedFilteredAudios = [];

  void _updateFilteredAudios() {
    var list =
        _audioFiles
            .where(
              (f) => f.title.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList();
    if (_sortAlphabetical) {
      list.sort(
        (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      );
    }
    _cachedFilteredAudios = list;
  }

  @override
  void initState() {
    super.initState();
    _ttsService = sl<TTSService>();
    _loadAudioFiles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAudioFiles() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
    });

    try {
      final files = await _ttsService.getSavedAudios();
      if (mounted) {
        setState(() {
          _audioFiles = files;
          _updateFilteredAudios();
        });
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('${l10n.savedLoadError}: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _copyToClipboard(AudioFile audioFile) {
    Clipboard.setData(ClipboardData(text: audioFile.title));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.savedCopied),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _shareAudioFile(AudioFile audioFile) async {
    final l10n = AppLocalizations.of(context)!;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final exists = await File(audioFile.filePath).exists();
      if (!exists) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(l10n.savedFileNotFound)),
        );
        return;
      }
      await _ttsService.shareAudio(audioFile.filePath, audioFile.title);
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(l10n.savedShareFailed)),
      );
    }
  }

  Future<void> _renameAudioFile(AudioFile audioFile) async {
    final l10n = AppLocalizations.of(context)!;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final controller = TextEditingController(text: audioFile.title);

    final newTitle = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.savedRenameTitle),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(hintText: l10n.savedRenameHint),
              onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.genericCancel),
              ),
              TextButton(
                onPressed:
                    () => Navigator.of(context).pop(controller.text.trim()),
                child: Text(l10n.genericSave),
              ),
            ],
          ),
    );

    controller.dispose();

    if (newTitle == null || newTitle.isEmpty || newTitle == audioFile.title)
      return;

    final success = await _ttsService.renameAudio(audioFile.id, newTitle);
    if (success) {
      setState(() {
        final index = _audioFiles.indexWhere((f) => f.id == audioFile.id);
        if (index != -1) {
          _audioFiles[index] = AudioFile(
            id: audioFile.id,
            title: newTitle,
            filePath: audioFile.filePath,
            createdAt: audioFile.createdAt,
          );
          if (_selectedAudio?.id == audioFile.id) {
            _selectedAudio = _audioFiles[index];
          }
          _updateFilteredAudios();
        }
      });
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(l10n.savedRenamed)),
      );
    } else {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(l10n.savedRenameFailed)),
      );
    }
  }

  Future<void> _deleteAudioFile(AudioFile audioFile) async {
    final l10n = AppLocalizations.of(context)!;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.savedDeleteConfirmTitle),
            content: Text(l10n.savedDeleteConfirmMessage(audioFile.title)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.genericCancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.genericDelete),
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
            _updateFilteredAudios();
          });
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text(l10n.savedDeleted)),
          );
        } else {
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text(l10n.savedDeleteFailed)),
          );
        }
      } catch (e) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('${l10n.savedDeleteError}: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final displayList = _cachedFilteredAudios;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.savedTitle, style: theme.textTheme.titleLarge),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_isLoading && _audioFiles.isNotEmpty)
                    IconButton(
                      icon: Icon(
                        _sortAlphabetical
                            ? Icons.sort_by_alpha
                            : Icons.access_time,
                      ),
                      tooltip:
                          _sortAlphabetical
                              ? l10n.savedSortByDate
                              : l10n.savedSortByName,
                      onPressed:
                          () => setState(() {
                            _sortAlphabetical = !_sortAlphabetical;
                            _updateFilteredAudios();
                          }),
                    ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadAudioFiles,
                    tooltip: l10n.savedRefresh,
                  ),
                ],
              ),
            ],
          ),

          // Search bar (only when there are enough items)
          if (!_isLoading && _audioFiles.length > 3) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.savedSearchHint,
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                              _updateFilteredAudios();
                            });
                          },
                        )
                        : null,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                  ),
                ),
              ),
              onChanged:
                  (v) => setState(() {
                    _searchQuery = v;
                    _updateFilteredAudios();
                  }),
            ),
          ],

          const SizedBox(height: 16),

          if (_isLoading)
            Expanded(
              child: Shimmer.fromColors(
                baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                highlightColor:
                    isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 5,
                  itemBuilder:
                      (_, __) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                ),
              ),
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
                      l10n.savedEmpty,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isDarkMode ? Colors.white38 : Colors.black38,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.savedEmptyHint,
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
                      itemCount: displayList.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final audioFile = displayList[index];
                        final isSelected = _selectedAudio?.id == audioFile.id;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side:
                                isSelected
                                    ? BorderSide(
                                      color:
                                          isDarkMode
                                              ? darkAccentColor
                                              : lightAccentColor,
                                      width: 2,
                                    )
                                    : BorderSide.none,
                          ),
                          color:
                              isSelected
                                  ? (isDarkMode
                                      ? const Color(0xFF252525)
                                      : const Color(0xFFF0F0F0))
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
                              backgroundColor:
                                  isDarkMode
                                      ? darkPrimaryColor
                                      : lightPrimaryColor,
                              child: const Icon(
                                Icons.music_note,
                                color: Colors.white,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.share_rounded),
                                  tooltip: l10n.savedShare,
                                  onPressed: () => _shareAudioFile(audioFile),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  tooltip: l10n.genericDelete,
                                  onPressed: () => _deleteAudioFile(audioFile),
                                ),
                              ],
                            ),
                            onLongPress: () => _copyToClipboard(audioFile),
                            onTap: () async {
                              if (!isSelected) {
                                final scaffoldMessenger = ScaffoldMessenger.of(
                                  context,
                                );
                                final exists =
                                    await File(audioFile.filePath).exists();
                                if (!exists) {
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.savedFileNotFound),
                                    ),
                                  );
                                  return;
                                }
                              }
                              if (mounted) {
                                setState(() {
                                  _selectedAudio =
                                      isSelected ? null : audioFile;
                                });
                              }
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
                        color:
                            isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _selectedAudio!.title,
                                  style: theme.textTheme.titleMedium,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.edit_rounded,
                                  color:
                                      isDarkMode
                                          ? darkAccentColor
                                          : lightAccentColor,
                                  size: 20,
                                ),
                                tooltip: l10n.savedRename,
                                onPressed:
                                    () => _renameAudioFile(_selectedAudio!),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.copy_rounded,
                                  color:
                                      isDarkMode
                                          ? darkAccentColor
                                          : lightAccentColor,
                                  size: 20,
                                ),
                                tooltip: l10n.savedCopied,
                                onPressed:
                                    () => _copyToClipboard(_selectedAudio!),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.share_rounded,
                                  color:
                                      isDarkMode
                                          ? darkAccentColor
                                          : lightAccentColor,
                                  size: 20,
                                ),
                                tooltip: l10n.savedShare,
                                onPressed:
                                    () => _shareAudioFile(_selectedAudio!),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
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
