import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';
import 'package:sonify/l10n/app_localizations.dart';
import 'package:sonify/features/theme/presentation/providers/theme_provider.dart';
import 'package:sonify/core/themes/theme_config.dart';
import 'package:sonify/core/widgets/audio_waveform_seek_bar.dart';
import 'package:sonify/services/tts_service.dart';
import 'package:sonify/services/sfx_service.dart';
import 'package:audioplayers/audioplayers.dart' as ap;

class AudioPlayerWidget extends StatefulWidget {
  final String audioPath;
  final Function? onSave;
  final ValueChanged<bool>? onPlayingChanged;

  const AudioPlayerWidget({
    super.key,
    required this.audioPath,
    this.onSave,
    this.onPlayingChanged,
  });

  @override
  State<AudioPlayerWidget> createState() => AudioPlayerWidgetState();
}

class AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  late ap.AudioPlayer _ambientPlayer;
  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<Duration?>? _positionSub;
  StreamSubscription<bool>? _playingSub;
  StreamSubscription<Duration?>? _durationSub;
  bool _isPlaying = false;
  bool _isLoading = true;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  final TTSService _ttsService = TTSService();

  // Ambient soundscape variables
  String _selectedAmbient = 'none'; // 'none', 'drone', 'brown', 'white'
  double _ambientVolume = 0.3; // Default user-facing volume is 30% (mapped to max 40% internally)
  bool _isAmbientInitialized = false;
  String? _loadedAmbientPath;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void didUpdateWidget(AudioPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audioPath != widget.audioPath) {
      _loadAudioSource(widget.audioPath);
    }
  }

  @override
  void dispose() {
    _disposePlayer();
    super.dispose();
  }

  void _disposePlayer() {
    _playerStateSub?.cancel();
    _positionSub?.cancel();
    _playingSub?.cancel();
    _durationSub?.cancel();
    _audioPlayer.dispose();
    _ambientPlayer.dispose();
    _isAmbientInitialized = false;
  }

  Future<void> _loadAudioSource(String path) async {
    try {
      setState(() {
        _isLoading = true;
        _position = Duration.zero;
      });

      final file = File(path);
      if (!await file.exists()) {
        throw Exception('Audio file not found');
      }

      // Load using AudioSource.file with MediaItem tag to enable background media controls
      final filename = path.split(Platform.pathSeparator).last;
      await _audioPlayer.setAudioSource(
        AudioSource.file(
          path,
          tag: MediaItem(
            id: path,
            album: "Sonify Readings",
            title: filename,
            artist: "Sonify Reader",
          ),
        ),
      );

      final duration = _audioPlayer.duration;
      setState(() {
        _duration = duration ?? Duration.zero;
      });
    } catch (e) {
      debugPrint('Error loading audio source: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _initializePlayer() async {
    _audioPlayer = AudioPlayer();
    _ambientPlayer = ap.AudioPlayer();
    _isAmbientInitialized = true;
    _loadedAmbientPath = null;

    _durationSub = _audioPlayer.durationStream.listen((d) {
      if (mounted && d != null) {
        setState(() {
          _duration = d;
        });
      }
    });

    _playerStateSub = _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          _position = _duration;
        });
      }
    });

    _playingSub = _audioPlayer.playingStream.listen((playing) {
      if (mounted) {
        setState(() {
          _isPlaying = playing;
        });
        _updateAmbientPlayback();
        if (widget.onPlayingChanged != null) {
          widget.onPlayingChanged!(playing);
        }
      }
    });

    _positionSub = _audioPlayer.positionStream.listen((position) {
      _position = position;
    });

    await _loadAudioSource(widget.audioPath);
  }

  Future<void> _updateAmbientPlayback() async {
    if (!_isAmbientInitialized) return;

    if (_isPlaying && _selectedAmbient != 'none') {
      try {
        String assetPath;
        if (_selectedAmbient == 'drone') {
          assetPath = 'assets/sounds/ambient_drone.wav';
        } else if (_selectedAmbient == 'brown') {
          assetPath = 'assets/sounds/brown_noise.wav';
        } else {
          assetPath = 'assets/sounds/white_noise.wav';
        }

        // Set volume (user volume mapped to max 40% of standard output to stay soft)
        await _ambientPlayer.setVolume(_ambientVolume * 0.40);
        await _ambientPlayer.setReleaseMode(ap.ReleaseMode.loop);

        if (_loadedAmbientPath != assetPath) {
          _loadedAmbientPath = assetPath;
          final relativePath = assetPath.replaceFirst('assets/', '');
          await _ambientPlayer.play(ap.AssetSource(relativePath));
        } else {
          if (_ambientPlayer.state != ap.PlayerState.playing) {
            await _ambientPlayer.resume();
          }
        }
      } catch (e) {
        debugPrint('Error playing ambient sound: $e');
      }
    } else {
      if (_ambientPlayer.state == ap.PlayerState.playing) {
        await _ambientPlayer.pause();
      }
    }
  }

  Future<void> _changeAmbientSound(String newValue) async {
    SfxService().playClick();
    setState(() {
      _selectedAmbient = newValue;
    });

    if (newValue == 'none') {
      if (_ambientPlayer.state == ap.PlayerState.playing) {
        await _ambientPlayer.pause();
      }
    } else {
      await _updateAmbientPlayback();
    }
  }

  Future<void> _changeAmbientVolume(double newVolume) async {
    setState(() {
      _ambientVolume = newVolume;
    });
    if (_isAmbientInitialized) {
      await _ambientPlayer.setVolume(newVolume * 0.40);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> togglePlayback() async {
    await _togglePlayback();
  }

  Future<void> _togglePlayback() async {
    SfxService().playClick();
    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
    } else {
      if (_position >= _duration) {
        await _audioPlayer.seek(Duration.zero);
      }
      await _audioPlayer.play();
    }
  }

  Future<void> _seekTo(double position) async {
    final newPosition = Duration(
      milliseconds: (position * _duration.inMilliseconds).round(),
    );
    await _audioPlayer.seek(newPosition);
    setState(() {
      _position = newPosition;
    });
  }

  Future<void> _skipForward() async {
    SfxService().playClick();
    final newPosition = _position + const Duration(seconds: 10);
    if (newPosition < _duration) {
      await _audioPlayer.seek(newPosition);
    } else {
      await _audioPlayer.seek(_duration);
    }
  }

  Future<void> _skipBackward() async {
    SfxService().playClick();
    final newPosition = _position - const Duration(seconds: 10);
    if (newPosition > Duration.zero) {
      await _audioPlayer.seek(newPosition);
    } else {
      await _audioPlayer.seek(Duration.zero);
    }
  }

  Widget _buildAmbientControls(
    BuildContext context,
    bool isDarkMode,
    ThemeData theme,
    Color accentColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.music_note_outlined,
              size: 16,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              'Ambient Background Mixer',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _ambientChip('Off', 'none', Icons.music_off_outlined, accentColor),
              const SizedBox(width: 8),
              _ambientChip('Drone', 'drone', Icons.spa_outlined, accentColor),
              const SizedBox(width: 8),
              _ambientChip('Brown Noise', 'brown', Icons.water_outlined, accentColor),
              const SizedBox(width: 8),
              _ambientChip('White Noise', 'white', Icons.waves_outlined, accentColor),
            ],
          ),
        ),
        if (_selectedAmbient != 'none') ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.volume_mute,
                size: 16,
                color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 12,
                    ),
                    activeTrackColor: accentColor,
                    inactiveTrackColor: isDarkMode
                        ? const Color(0xFF334155)
                        : Colors.grey[200],
                    thumbColor: accentColor,
                    overlayColor: accentColor.withValues(alpha: 0.1),
                  ),
                  child: Slider(
                    value: _ambientVolume,
                    min: 0.0,
                    max: 1.0,
                    onChanged: _isLoading ? null : _changeAmbientVolume,
                  ),
                ),
              ),
              Icon(
                Icons.volume_up,
                size: 16,
                color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 32,
                child: Text(
                  '${(_ambientVolume * 100).round()}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _ambientChip(
    String label,
    String value,
    IconData icon,
    Color accentColor,
  ) {
    final isSelected = _selectedAmbient == value;
    final isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    
    return ChoiceChip(
      iconTheme: IconThemeData(
        color: isSelected
            ? Colors.white
            : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
        size: 16,
      ),
      avatar: Icon(icon),
      label: Text(label),
      selected: isSelected,
      onSelected: _isLoading
          ? null
          : (selected) {
              if (selected) {
                _changeAmbientSound(value);
              }
            },
      selectedColor: accentColor,
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
      labelStyle: TextStyle(
        color: isSelected
            ? Colors.white
            : (isDarkMode ? Colors.grey[300] : Colors.grey[700]),
        fontSize: 12,
      ),
      checkmarkColor: Colors.white,
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final accentColor = isDarkMode ? darkAccentColor : lightAccentColor;
    final primaryColor = isDarkMode ? darkPrimaryColor : lightPrimaryColor;
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Waveform Seek bar and Time Labels
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: StreamBuilder<Duration>(
                stream: _audioPlayer.positionStream,
                initialData: _position,
                builder: (context, snapshot) {
                  final currentPosition = snapshot.data ?? Duration.zero;
                  return Column(
                    children: [
                      RepaintBoundary(
                        child: AudioWaveformSeekBar(
                          position: currentPosition,
                          duration: _duration,
                          isPlaying: _isPlaying,
                          onSeek: _isLoading ? null : _seekTo,
                          activeColor: accentColor,
                          inactiveColor: isDarkMode
                              ? const Color(0xFF334155)
                              : Colors.grey[300]!,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(currentPosition),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                          Text(
                            _formatDuration(_duration),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            // Controls Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Save button
                widget.onSave != null
                    ? IconButton.filledTonal(
                        onPressed: () => widget.onSave!(),
                        icon: const Icon(Icons.save),
                        tooltip: AppLocalizations.of(context)!.audioSaveBtn,
                      )
                    : const SizedBox(width: 48),

                // Main Playback Controls
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: _isLoading ? null : _skipBackward,
                      icon: const Icon(Icons.replay_10, size: 28),
                      tooltip: 'Rewind 10s',
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _isLoading ? null : _togglePlayback,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor,
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: _isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 32,
                              ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _isLoading ? null : _skipForward,
                      icon: const Icon(Icons.forward_10, size: 28),
                      tooltip: 'Forward 10s',
                    ),
                  ],
                ),

                // Share Button (always available)
                IconButton.filledTonal(
                  onPressed: () async {
                    try {
                      await _ttsService.shareAudio(
                        widget.audioPath,
                        'Speech Output',
                      );
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error sharing audio: $e'),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.share),
                  tooltip: 'Share Audio',
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 12),
            _buildAmbientControls(context, isDarkMode, theme, accentColor),
          ],
        ),
      ),
    );
  }
}
