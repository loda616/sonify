import 'dart:math' as math;
import 'package:flutter/material.dart';

class AudioWaveformSeekBar extends StatefulWidget {
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final ValueChanged<double>? onSeek;
  final Color activeColor;
  final Color inactiveColor;
  final double height;

  const AudioWaveformSeekBar({
    super.key,
    required this.position,
    required this.duration,
    required this.isPlaying,
    required this.onSeek,
    required this.activeColor,
    required this.inactiveColor,
    this.height = 48.0,
  });

  @override
  State<AudioWaveformSeekBar> createState() => _AudioWaveformSeekBarState();
}

class _AudioWaveformSeekBarState extends State<AudioWaveformSeekBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.isPlaying) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AudioWaveformSeekBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleSeek(Offset localPosition, double width) {
    if (widget.onSeek == null || width <= 0) return;
    final progress = (localPosition.dx / width).clamp(0.0, 1.0);
    widget.onSeek!(progress);
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.duration.inMilliseconds == 0
        ? 0.0
        : (widget.position.inMilliseconds / widget.duration.inMilliseconds).clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          onTapDown: (details) => _handleSeek(details.localPosition, width),
          onHorizontalDragUpdate: (details) => _handleSeek(details.localPosition, width),
          child: SizedBox(
            width: width,
            height: widget.height,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return RepaintBoundary(
                  child: CustomPaint(
                    painter: _WaveformSeekBarPainter(
                      progress: progress,
                      isPlaying: widget.isPlaying,
                      animationValue: _animationController.value,
                      activeColor: widget.activeColor,
                      inactiveColor: widget.inactiveColor,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _WaveformSeekBarPainter extends CustomPainter {
  final double progress;
  final bool isPlaying;
  final double animationValue;
  final Color activeColor;
  final Color inactiveColor;

  _WaveformSeekBarPainter({
    required this.progress,
    required this.isPlaying,
    required this.animationValue,
    required this.activeColor,
    required this.inactiveColor,
  });

  // A deterministic set of waveform height percentages (0.1 to 1.0)
  // Designed to represent a natural audio/voice wave shape.
  static final List<double> _waveformHeights = _generateWaveformHeights(42);

  static List<double> _generateWaveformHeights(int count) {
    final list = <double>[];
    for (int i = 0; i < count; i++) {
      final t = i / (count - 1);
      
      // Base envelope is a bell curve: starts small, rises in middle, falls at end
      final envelope = math.sin(t * math.pi);
      
      // Add natural harmonics to make it look like speech waves
      final harmonic1 = math.sin(t * 12.0) * 0.22;
      final harmonic2 = math.cos(t * 24.0) * 0.12;
      final noise = math.sin(t * 48.0) * 0.05;
      
      double height = (envelope * 0.75 + harmonic1 + harmonic2 + noise + 0.15).clamp(0.12, 1.0);
      list.add(height);
    }
    return list;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final barCount = _waveformHeights.length;
    
    // Spacing between the bars
    const spacing = 3.0;
    final totalSpacing = spacing * (barCount - 1);
    
    // Width of each individual bar
    final barWidth = (size.width - totalSpacing) / barCount;
    if (barWidth <= 0) return;

    for (int i = 0; i < barCount; i++) {
      final barProgress = i / (barCount - 1);
      final isBarActive = barProgress <= progress;

      double heightFactor = _waveformHeights[i];

      // Add a subtle wave animation when audio is playing
      if (isPlaying) {
        // Animate heights based on animation value and position in the wave
        final phase = (animationValue * 2.0 * math.pi) + (i * 0.3);
        // Limit amplitude changes so it is dynamic but not chaotic
        final animationOffset = math.sin(phase) * 0.12;
        heightFactor = (heightFactor + animationOffset).clamp(0.12, 1.0);
      }

      final barHeight = size.height * heightFactor;
      final x = i * (barWidth + spacing);
      final y = (size.height - barHeight) / 2; // Vertically center the wave

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        Radius.circular(barWidth / 2),
      );

      final paint = Paint()
        ..color = isBarActive ? activeColor : inactiveColor
        ..style = PaintingStyle.fill;

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformSeekBarPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isPlaying != isPlaying ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.inactiveColor != inactiveColor;
  }
}
