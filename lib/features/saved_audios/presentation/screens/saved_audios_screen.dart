import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/models/audio_file.dart';
import '../../../theme/presentation/providers/theme_provider.dart';
import '../../../../services/tts_service.dart';
import '../../../../services/sfx_service.dart';
import '../../../../core/themes/theme_config.dart';
import '../../../text_to_speech/presentation/widgets/audio_player_widget.dart';

enum SavedAudioSortOption {
  dateNewest,
  dateOldest,
  titleAZ,
  titleZA,
}

class SavedAudiosScreen extends StatefulWidget {
  const SavedAudiosScreen({super.key});

  @override
  State<SavedAudiosScreen> createState() => _SavedAudiosScreenState();
}

class _SavedAudiosScreenState extends State<SavedAudiosScreen> {
  final TTSService _ttsService = TTSService();
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<AudioPlayerWidgetState> _playerKey = GlobalKey();
  
  List<AudioFile> _audioFiles = [];
  final Map<String, String> _fileSizes = {};
  bool _isLoading = true;
  AudioFile? _selectedAudio;
  String _searchQuery = '';
  Timer? _searchDebounce;
  SavedAudioSortOption _sortOption = SavedAudioSortOption.dateNewest;
  bool _isAudioPlaying = false;

  @override
  void initState() {
    super.initState();
    _loadAudioFiles();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAudioFiles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final files = await _ttsService.getSavedAudios();
      if (!mounted) return;
      setState(() {
        _audioFiles = files;
      });
      _loadAudioSizes();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.savedLoadError(e.toString()),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadAudioSizes() async {
    for (final file in _audioFiles) {
      try {
        final f = File(file.filePath);
        if (await f.exists()) {
          final bytes = await f.length();
          final kb = bytes / 1024;
          if (mounted) {
            setState(() {
              _fileSizes[file.id] = '${kb.toStringAsFixed(1)} KB';
            });
          }
        }
      } catch (_) {}
    }
  }

  Future<bool> _deleteAudioFile(AudioFile audioFile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.savedDeleteConfirmTitle),
            content: Text(
              AppLocalizations.of(
                context,
              )!.savedDeleteConfirmContent(audioFile.title),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(AppLocalizations.of(context)!.savedCancelBtn),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(AppLocalizations.of(context)!.savedDeleteBtn),
              ),
            ],
          ),
    );
    return confirmed ?? false;
  }

  Future<void> _clearAllAudios() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Saved Sounds'),
        content: const Text('Are you sure you want to permanently delete all saved sounds? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.savedCancelBtn),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      SfxService().playDelete();
      setState(() {
        _isLoading = true;
      });

      final success = await _ttsService.clearAllSavedAudios();

      if (mounted) {
        setState(() {
          _selectedAudio = null;
          _isAudioPlaying = false;
          _audioFiles = [];
          _fileSizes.clear();
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'All sounds deleted successfully.' : 'Failed to delete some sounds.'),
          ),
        );
      }
    }
  }

  Future<void> _renameAudioFile(AudioFile audioFile) async {
    final controller = TextEditingController(text: audioFile.title);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Audio File'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'New Title',
            hintText: 'Enter new title...',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.savedCancelBtn),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Rename'),
          ),
        ],
      ),
    );

    if (confirmed == true && controller.text.trim().isNotEmpty) {
      final newTitle = controller.text.trim();
      if (newTitle == audioFile.title) return;

      SfxService().playClick();
      final success = await _ttsService.renameAudio(audioFile.id, newTitle);
      if (success && mounted) {
        setState(() {
          final index = _audioFiles.indexWhere((file) => file.id == audioFile.id);
          if (index != -1) {
            _audioFiles[index] = AudioFile(
              id: audioFile.id,
              title: newTitle,
              filePath: audioFile.filePath,
              createdAt: audioFile.createdAt,
            );
          }
          if (_selectedAudio?.id == audioFile.id) {
            _selectedAudio = _audioFiles[index];
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Audio renamed successfully.')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to rename audio.')),
        );
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _searchQuery = query;
        });
      }
    });
  }

  Widget _highlightSearchText(BuildContext context, String text, String query) {
    if (query.isEmpty) {
      return Text(
        text,
        style: Theme.of(context).textTheme.titleMedium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final matches = query.toLowerCase();
    final textLower = text.toLowerCase();

    final List<TextSpan> spans = [];
    int start = 0;
    int index = textLower.indexOf(matches);

    final isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    final highlightColor = isDarkMode ? darkAccentColor : lightAccentColor;
    final defaultColor = Theme.of(context).textTheme.titleMedium?.color;

    while (index != -1) {
      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
        ));
      }
      spans.add(TextSpan(
        text: text.substring(index, index + matches.length),
        style: TextStyle(
          color: highlightColor,
          fontWeight: FontWeight.bold,
        ),
      ));
      start = index + matches.length;
      index = textLower.indexOf(matches, start);
    }

    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
      ));
    }

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: defaultColor,
        ),
        children: spans,
      ),
    );
  }

  void _showOptionsSheet(AudioFile audioFile) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final sizeStr = _fileSizes[audioFile.id] ?? 'Calculating...';

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              audioFile.title,
                              style: Theme.of(context).textTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Created: ${audioFile.createdAt}  •  Size: $sizeStr',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.share_outlined),
                  title: const Text('Share Audio'),
                  onTap: () async {
                    Navigator.pop(context);
                    try {
                      await _ttsService.shareAudio(audioFile.filePath, audioFile.title);
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error sharing: $e')),
                        );
                      }
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Rename File'),
                  onTap: () {
                    Navigator.pop(context);
                    _renameAudioFile(audioFile);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  title: const Text('Delete Sound', style: TextStyle(color: Colors.redAccent)),
                  onTap: () async {
                    Navigator.pop(context);
                    final confirmed = await _deleteAudioFile(audioFile);
                    if (confirmed && mounted) {
                      SfxService().playDelete();
                      setState(() {
                        _audioFiles.removeWhere((file) => file.id == audioFile.id);
                        if (_selectedAudio?.id == audioFile.id) {
                          _selectedAudio = null;
                        }
                      });
                      await _ttsService.deleteAudio(audioFile.id);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final theme = Theme.of(context);

    final filteredFiles = _audioFiles.where((file) {
      return file.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    switch (_sortOption) {
      case SavedAudioSortOption.dateNewest:
        filteredFiles.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SavedAudioSortOption.dateOldest:
        filteredFiles.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SavedAudioSortOption.titleAZ:
        filteredFiles.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case SavedAudioSortOption.titleZA:
        filteredFiles.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
        break;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.savedTitle,
                style: theme.textTheme.titleLarge,
              ),
              Row(
                children: [
                  if (_audioFiles.isNotEmpty) ...[
                    PopupMenuButton<SavedAudioSortOption>(
                      icon: const Icon(Icons.sort),
                      tooltip: 'Sort Saved Sounds',
                      onSelected: (option) {
                        SfxService().playClick();
                        setState(() {
                          _sortOption = option;
                        });
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: SavedAudioSortOption.dateNewest,
                          child: Row(
                            children: [
                              Icon(Icons.date_range),
                              SizedBox(width: 8),
                              Text('Date (Newest First)'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: SavedAudioSortOption.dateOldest,
                          child: Row(
                            children: [
                              Icon(Icons.date_range_outlined),
                              SizedBox(width: 8),
                              Text('Date (Oldest First)'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: SavedAudioSortOption.titleAZ,
                          child: Row(
                            children: [
                              Icon(Icons.sort_by_alpha),
                              SizedBox(width: 8),
                              Text('Title (A-Z)'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: SavedAudioSortOption.titleZA,
                          child: Row(
                            children: [
                              Icon(Icons.sort_by_alpha_outlined),
                              SizedBox(width: 8),
                              Text('Title (Z-A)'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
                      onPressed: _clearAllAudios,
                      tooltip: 'Delete All Sounds',
                    ),
                  ],
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadAudioFiles,
                    tooltip: AppLocalizations.of(context)!.savedRefreshTooltip,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search Bar
          if (_audioFiles.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search saved files...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                            setState(() {});
                          },
                        )
                      : null,
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0, left: 4.0),
                child: Text(
                  'Showing ${filteredFiles.length} of ${_audioFiles.length} sounds',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                ),
              )
            else
              const SizedBox(height: 8),
          ],

          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_audioFiles.isEmpty)
            Expanded(
              child: Center(
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
                        AppLocalizations.of(context)!.savedEmptyTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isDarkMode ? Colors.white38 : Colors.black38,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)!.savedEmptySubtitle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDarkMode ? Colors.white38 : Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (filteredFiles.isEmpty)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: isDarkMode ? Colors.white38 : Colors.black26,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No matching files found',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isDarkMode ? Colors.white38 : Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredFiles.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final audioFile = filteredFiles[index];
                        final isSelected = _selectedAudio?.id == audioFile.id;
                        final sizeStr = _fileSizes[audioFile.id] ?? 'Calculating...';

                        return Dismissible(
                          key: Key(audioFile.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.redAccent,
                                  Colors.redAccent.withValues(alpha: 0.8),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.delete, color: Colors.white),
                              ],
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            return await _deleteAudioFile(audioFile);
                          },
                          onDismissed: (direction) async {
                            final deletedFile = audioFile;
                            SfxService().playDelete();
                            setState(() {
                              _audioFiles.removeWhere((file) => file.id == deletedFile.id);
                              if (_selectedAudio?.id == deletedFile.id) {
                                _selectedAudio = null;
                                _isAudioPlaying = false;
                              }
                            });

                            final success = await _ttsService.deleteAudio(deletedFile.id);
                            if (!mounted) return;
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppLocalizations.of(context)!.savedDeleteSuccess,
                                  ),
                                ),
                              );
                            } else {
                              _loadAudioFiles();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppLocalizations.of(context)!.savedDeleteFailed,
                                  ),
                                ),
                              );
                            }
                          },
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: isSelected
                                  ? BorderSide(
                                      color: isDarkMode
                                          ? darkAccentColor
                                          : lightAccentColor,
                                      width: 2,
                                    )
                                  : BorderSide(
                                      color: Colors.grey.withValues(alpha: isDarkMode ? 0.05 : 0.1),
                                      width: 1,
                                    ),
                            ),
                            color: isSelected
                                ? (isDarkMode
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFFF1F5F9))
                                : null,
                            child: ListTile(
                              title: _highlightSearchText(context, audioFile.title, _searchQuery),
                              subtitle: Text(
                                '${AppLocalizations.of(context)!.savedCreatedPrefix(audioFile.createdAt)}  •  $sizeStr',
                                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                              ),
                              leading: GestureDetector(
                                onTap: () {
                                  if (isSelected) {
                                    _playerKey.currentState?.togglePlayback();
                                  } else {
                                    setState(() {
                                      _selectedAudio = audioFile;
                                      _isAudioPlaying = false;
                                    });
                                  }
                                },
                                child: CircleAvatar(
                                  backgroundColor: isSelected
                                      ? (isDarkMode ? darkAccentColor : lightAccentColor)
                                      : (isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                                  child: isSelected && _isAudioPlaying
                                      ? MusicVisualizer(
                                          color: isDarkMode ? Colors.black : Colors.white,
                                        )
                                      : Icon(
                                          isSelected ? Icons.play_arrow : Icons.music_note,
                                          color: isSelected
                                              ? (isDarkMode ? Colors.black : Colors.white)
                                              : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                                        ),
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.more_vert),
                                onPressed: () => _showOptionsSheet(audioFile),
                                tooltip: 'Options',
                              ),
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedAudio = null;
                                    _isAudioPlaying = false;
                                  } else {
                                    _selectedAudio = audioFile;
                                    _isAudioPlaying = false;
                                  }
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  if (_selectedAudio != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.15),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.05),
                            blurRadius: 15,
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
                              const Icon(Icons.headphones, color: Colors.grey, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _selectedAudio!.title,
                                  style: theme.textTheme.titleMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          AudioPlayerWidget(
                            key: _playerKey,
                            audioPath: _selectedAudio!.filePath,
                            onSave: null,
                            onPlayingChanged: (isPlaying) {
                              setState(() {
                                _isAudioPlaying = isPlaying;
                              });
                            },
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

class MusicVisualizer extends StatefulWidget {
  final Color color;
  const MusicVisualizer({super.key, required this.color});

  @override
  State<MusicVisualizer> createState() => _MusicVisualizerState();
}

class _MusicVisualizerState extends State<MusicVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            final double animValue = math.sin((_controller.value * 2 * math.pi) + (index * 1.5)) * 0.5 + 0.5;
            final double height = 4.0 + (animValue * 12.0);
            return Container(
              width: 3,
              height: height,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(1.5),
              ),
            );
          }),
        );
      },
    );
  }
}
