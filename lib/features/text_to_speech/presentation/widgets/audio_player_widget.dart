import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:sonify/features/theme/presentation/providers/theme_provider.dart';
import 'package:sonify/core/themes/theme_config.dart';
import 'package:sonify/l10n/app_localizations.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioPath;
  final Function? onSave;

  const AudioPlayerWidget({
    super.key,
    required this.audioPath,
    this.onSave,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = true;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  // Store stream subscriptions so they can be cancelled on dispose
  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void didUpdateWidget(AudioPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audioPath != widget.audioPath) {
      _disposePlayer();
      _initializePlayer();
    }
  }

  @override
  void dispose() {
    _disposePlayer();
    super.dispose();
  }

  void _disposePlayer() {
    // Cancel all stream subscriptions BEFORE disposing the player
    // to prevent callbacks firing on a disposed player
    _playerStateSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playerStateSub = null;
    _positionSub = null;
    _durationSub = null;
    _audioPlayer.dispose();
  }

  Future<void> _initializePlayer() async {
    _audioPlayer = AudioPlayer();

    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _position = Duration.zero;
          _duration = Duration.zero;
        });
      }

      // Check if file exists
      final file = File(widget.audioPath);
      if (!await file.exists()) {
        throw Exception('Audio file not found');
      }

      // Set audio source
      await _audioPlayer.setFilePath(widget.audioPath);

      // Get initial duration (may be null for some codecs)
      final duration = _audioPlayer.duration;
      if (mounted && duration != null) {
        setState(() => _duration = duration);
      }

      // Listen for duration updates — some codecs report duration
      // asynchronously after playback starts
      _durationSub = _audioPlayer.durationStream.listen((duration) {
        if (mounted && duration != null && duration > Duration.zero) {
          setState(() => _duration = duration);
        }
      });

      // Listen to player state changes
      _playerStateSub = _audioPlayer.playerStateStream.listen((state) {
        if (!mounted) return;
        setState(() {
          _isPlaying = state.playing;
          if (state.processingState == ProcessingState.completed) {
            _isPlaying = false;
            _position = _duration;
          }
        });
      });

      // Listen to position changes
      _positionSub = _audioPlayer.positionStream.listen((position) {
        if (mounted) {
          setState(() => _position = position);
        }
      });
    } catch (e) {
      debugPrint('Error initializing audio player: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> _togglePlayback() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
    } catch (e) {
      debugPrint('Playback toggle error: $e');
    }
    if (mounted) setState(() => _isPlaying = _audioPlayer.playing);
  }

  Future<void> _seekTo(double position) async {
    final newPosition = Duration(milliseconds: (position * _duration.inMilliseconds).round());
    await _audioPlayer.seek(newPosition);
    if (mounted) {
      setState(() {
        _position = newPosition;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final accentColor = isDarkMode ? darkAccentColor : lightAccentColor;
    final primaryColor = isDarkMode ? darkPrimaryColor : lightPrimaryColor;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDuration(_position),
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            Text(
              _formatDuration(_duration),
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Play/Pause button
            InkWell(
              onTap: _isLoading ? null : _togglePlayback,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor,
                ),
                child: _isLoading
                    ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Seek bar
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                  activeTrackColor: accentColor,
                  inactiveTrackColor: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                  thumbColor: accentColor,
                  overlayColor: accentColor.withValues(alpha: 0.2),
                ),
                child: Slider(
                  value: (_position.inMilliseconds / (_duration.inMilliseconds == 0 ? 1 : _duration.inMilliseconds)).clamp(0.0, 1.0),
                  onChanged: _isLoading ? null : _seekTo,
                ),
              ),
            ),
            // Save button (if provided)
            if (widget.onSave != null) ...[
              const SizedBox(width: 12),
              InkWell(
                onTap: () => widget.onSave!(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.save,
                        color: isDarkMode ? Colors.black : Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppLocalizations.of(context)!.playerSave,
                        style: TextStyle(
                          color: isDarkMode ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}