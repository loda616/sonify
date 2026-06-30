import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../theme/presentation/providers/theme_provider.dart';
import '../../../../services/tts_service.dart';
import '../widgets/audio_player_widget.dart';

class TextToSpeechScreen extends StatefulWidget {
  const TextToSpeechScreen({super.key});

  @override
  State<TextToSpeechScreen> createState() => _TextToSpeechScreenState();
}

class _TextToSpeechScreenState extends State<TextToSpeechScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isGenerating = false;
  String? _generatedAudioPath;
  final TTSService _ttsService = TTSService();
  double _pitch = 1.0;
  double _speed = 1.0;
  String _selectedVoice = 'Default';
  List<String> _availableVoices = ['Default'];

  @override
  void initState() {
    super.initState();
    _loadVoices();
  }

  Future<void> _loadVoices() async {
    try {
      final voices = await _ttsService.getAvailableVoices();
      if (mounted) {
        setState(() {
          _availableVoices = ['Default', ...voices];
        });
      }
    } catch (_) {}
  }

  String _getFriendlyVoiceName(String rawName) {
    if (rawName == 'Default') return AppLocalizations.of(context)!.voiceDefault;

    // iOS formatting: com.apple.ttsbundle.Samantha-compact
    if (rawName.startsWith('com.apple.ttsbundle.')) {
      final cleanName = rawName
          .replaceFirst('com.apple.ttsbundle.', '')
          .replaceFirst('-compact', '')
          .replaceFirst('-premium', '');
      return '$cleanName (Siri)';
    }

    // Android/General formatting: en-us-x-sfg-local or ar-xa-x-ard-local
    final parts = rawName.split('-');
    if (parts.length >= 2) {
      final langCode = parts[0];
      final countryCode = parts[1];
      final locale = '${langCode.toLowerCase()}-${countryCode.toLowerCase()}';
      
      String langName = '';
      switch (locale) {
        case 'en-us': langName = 'US English'; break;
        case 'en-gb': langName = 'UK English'; break;
        case 'en-in': langName = 'Indian English'; break;
        case 'en-au': langName = 'Australian English'; break;
        case 'ar-eg': langName = 'Arabic (Egypt)'; break;
        case 'ar-sa': langName = 'Arabic (Saudi)'; break;
        case 'ar-ae': langName = 'Arabic (UAE)'; break;
        case 'ar-xa': langName = 'Arabic (Standard)'; break;
        case 'fr-fr': langName = 'French'; break;
        case 'es-es': langName = 'Spanish'; break;
        case 'de-de': langName = 'German'; break;
        case 'it-it': langName = 'Italian'; break;
        case 'ja-jp': langName = 'Japanese'; break;
        default:
          langName = '${langCode.toUpperCase()}-${countryCode.toUpperCase()}';
      }

      if (parts.length >= 4 && parts[2] == 'x') {
        final variant = parts[3];
        // Map common Google TTS variants
        final googleVoiceMap = {
          'sfg': 'Female (Soft)',
          'tpf': 'Female (Clear)',
          'iol': 'Male (Deep)',
          'hnd': 'Female (Expressive)',
          'rgf': 'Male (Standard)',
          'kdf': 'Female (Professional)',
          'lfd': 'Male (Friendly)',
          'bdf': 'Male (Classic)',
          'gpf': 'Female (Smooth)',
          'ntk': 'Female (Elegant)',
          'ard': 'Male (Standard)',
          'ara': 'Female (Soft)',
          'arb': 'Female (Standard)',
          'arc': 'Male (Soft)',
        };

        final desc = googleVoiceMap[variant.toLowerCase()] ?? 'Variant ${variant.toUpperCase()}';
        return '$langName - $desc';
      }
      
      return '$langName ($rawName)';
    }

    return rawName;
  }

  void _showVoiceSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _VoiceSelectorSheet(
          availableVoices: _availableVoices,
          selectedVoice: _selectedVoice,
          pitch: _pitch,
          speed: _speed,
          ttsService: _ttsService,
          friendlyNameMapper: _getFriendlyVoiceName,
          onVoiceSelected: (voice) {
            setState(() {
              _selectedVoice = voice;
            });
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _generateSpeech() async {
    if (_textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.ttsEnterTextError),
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _generatedAudioPath = null;
    });

    try {
      final audioPath = await _ttsService.generateSpeech(
        _textController.text,
        voice: _selectedVoice,
        pitch: _pitch,
        speed: _speed,
      );

      if (!mounted) return;
      setState(() {
        _generatedAudioPath = audioPath;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.ttsError(e.toString())),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.ttsTitle,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            
            // Text Input Container with Paste, Clear, and Character Counter
            Container(
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _textController,
                    maxLines: 6,
                    style: theme.textTheme.bodyMedium,
                    onChanged: (text) {
                      setState(() {}); // Rebuild to update character count and clear button visibility
                    },
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.ttsHintText,
                      contentPadding: const EdgeInsets.all(16),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.15),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () async {
                                final data = await Clipboard.getData(Clipboard.kTextPlain);
                                if (data?.text != null) {
                                  _textController.text = data!.text!;
                                  setState(() {});
                                }
                              },
                              icon: const Icon(Icons.paste, size: 16),
                              label: const Text('Paste', style: TextStyle(fontSize: 12)),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                            if (_textController.text.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: () {
                                  _textController.clear();
                                  setState(() {});
                                },
                                icon: const Icon(Icons.clear, size: 16, color: Colors.redAccent),
                                label: const Text('Clear', style: TextStyle(fontSize: 12, color: Colors.redAccent)),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          '${_textController.text.length} characters',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Voice selection button
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _showVoiceSelector(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.record_voice_over_rounded,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.ttsVoiceLabel,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _getFriendlyVoiceName(_selectedVoice),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Pitch control card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.ttsPitchLabel,
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _pitch.toStringAsFixed(1),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _pitch,
                      min: 0.5,
                      max: 2.0,
                      divisions: 30,
                      label: _pitch.toStringAsFixed(1),
                      onChanged: (value) {
                        setState(() {
                          _pitch = value;
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Low (0.5)', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                          Text('Normal (1.0)', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                          Text('High (2.0)', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Speed control card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.ttsSpeedLabel,
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _speed.toStringAsFixed(1),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _speed,
                      min: 0.5,
                      max: 2.0,
                      divisions: 30,
                      label: _speed.toStringAsFixed(1),
                      onChanged: (value) {
                        setState(() {
                          _speed = value;
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Slow (0.5)', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                          Text('Normal (1.0)', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                          Text('Fast (2.0)', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Generate button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isGenerating ? null : _generateSpeech,
                child: _isGenerating
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const WaveformLoader(),
                          const SizedBox(width: 16),
                          Text(
                            AppLocalizations.of(context)!.ttsGeneratingBtn,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 16),
                          const WaveformLoader(),
                        ],
                      )
                    : Text(AppLocalizations.of(context)!.ttsGenerateBtn),
              ),
            ),
            const SizedBox(height: 20),

            // Audio player
            if (_generatedAudioPath != null)
              Container(
                margin: const EdgeInsets.only(top: 20, bottom: 20),
                child: AudioPlayerWidget(
                  audioPath: _generatedAudioPath!,
                  onSave: () async {
                    // Save the generated audio
                    final title = _textController.text.length > 30
                        ? _textController.text.substring(0, 30)
                        : _textController.text;
                    if (_textController.text.length > 30) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context)!.ttsTitleTruncated,
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                    final messenger = ScaffoldMessenger.of(context);
                    final success = await _ttsService.saveAudio(
                      _generatedAudioPath!,
                      title,
                    );

                    if (!mounted) return;
                    if (success) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context)!.ttsSaveSuccess,
                          ),
                        ),
                      );
                    } else {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context)!.ttsSaveFailed,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            const SizedBox(
              height: 40,
            ), // Add some padding at the bottom for better scrolling
          ],
        ),
      ),
    );
  }
}

class WaveformLoader extends StatefulWidget {
  const WaveformLoader({super.key});

  @override
  State<WaveformLoader> createState() => _WaveformLoaderState();
}

class _WaveformLoaderState extends State<WaveformLoader> with SingleTickerProviderStateMixin {
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final double value = (index - 2).abs() * 0.2;
            final double animationValue = (_controller.value + value) % 1.0;
            final double height = 4 + (16 * (0.5 - (animationValue - 0.5).abs()));

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              width: 3.0,
              height: height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(1.5),
              ),
            );
          },
        );
      }),
    );
  }
}

class _VoiceSelectorSheet extends StatefulWidget {
  final List<String> availableVoices;
  final String selectedVoice;
  final double pitch;
  final double speed;
  final TTSService ttsService;
  final String Function(String) friendlyNameMapper;
  final ValueChanged<String> onVoiceSelected;

  const _VoiceSelectorSheet({
    required this.availableVoices,
    required this.selectedVoice,
    required this.pitch,
    required this.speed,
    required this.ttsService,
    required this.friendlyNameMapper,
    required this.onVoiceSelected,
  });

  @override
  State<_VoiceSelectorSheet> createState() => _VoiceSelectorSheetState();
}

class _VoiceSelectorSheetState extends State<_VoiceSelectorSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _previewingVoice;

  @override
  void dispose() {
    _searchController.dispose();
    widget.ttsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final filteredVoices = widget.availableVoices.where((voice) {
      final friendlyName = widget.friendlyNameMapper(voice).toLowerCase();
      return friendlyName.contains(_searchQuery.toLowerCase()) ||
          voice.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[600] : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Voice',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search voices...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Voice List
          Expanded(
            child: filteredVoices.isEmpty
                ? Center(
                    child: Text(
                      'No voices found',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 24.0),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredVoices.length,
                    itemBuilder: (context, index) {
                      final voice = filteredVoices[index];
                      final isSelected = voice == widget.selectedVoice;
                      final friendlyName = widget.friendlyNameMapper(voice);
                      final isPreviewing = _previewingVoice == voice;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isSelected
                                ? theme.colorScheme.secondary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        color: isSelected
                            ? (isDarkMode
                                ? theme.colorScheme.secondary.withValues(alpha: 0.1)
                                : theme.colorScheme.secondary.withValues(alpha: 0.05))
                            : (isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                          leading: CircleAvatar(
                            backgroundColor: isSelected
                                ? theme.colorScheme.secondary
                                : (isDarkMode ? Colors.grey[700] : Colors.grey[200]),
                            child: Icon(
                              Icons.record_voice_over_rounded,
                              color: isSelected ? Colors.black : (isDarkMode ? Colors.grey[300] : Colors.grey[600]),
                              size: 20,
                            ),
                          ),
                          title: Text(
                            friendlyName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            voice == 'Default' ? 'System default voice' : voice,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[500],
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Preview button
                              IconButton(
                                icon: Icon(
                                  isPreviewing
                                      ? Icons.stop_circle_rounded
                                      : Icons.play_circle_fill_rounded,
                                  color: isPreviewing
                                      ? Colors.redAccent
                                      : theme.colorScheme.secondary,
                                  size: 28,
                                ),
                                onPressed: () async {
                                  if (isPreviewing) {
                                    await widget.ttsService.stop();
                                    setState(() {
                                      _previewingVoice = null;
                                    });
                                  } else {
                                    setState(() {
                                      _previewingVoice = voice;
                                    });
                                    await widget.ttsService.playPreview(
                                      voice,
                                      pitch: widget.pitch,
                                      speed: widget.speed,
                                    );
                                  }
                                },
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: theme.colorScheme.secondary,
                                ),
                              ],
                            ],
                          ),
                          onTap: () {
                            widget.onVoiceSelected(voice);
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
