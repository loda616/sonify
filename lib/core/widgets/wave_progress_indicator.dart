import 'dart:math' as math;
import 'package:flutter/material.dart';

class WaveProgressIndicator extends StatefulWidget {
  final double width;
  final double height;
  final Color baseColor;

  const WaveProgressIndicator({
    super.key,
    this.width = 180.0,
    this.height = 40.0,
    this.baseColor = const Color(0xFF00D8FF),
  });

  @override
  State<WaveProgressIndicator> createState() => _WaveProgressIndicatorState();
}

class _WaveProgressIndicatorState extends State<WaveProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _WavePainter(
              animationValue: _controller.value,
              baseColor: widget.baseColor,
            ),
          );
        },
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double animationValue;
  final Color baseColor;

  _WavePainter({
    required this.animationValue,
    required this.baseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final yCenter = size.height / 2;

    // Draw three overlapping waves with different phases, amplitudes, and speeds
    // Wave 1: The primary wave
    _drawSingleWave(
      canvas: canvas,
      size: size,
      yCenter: yCenter,
      waveColor: baseColor.withValues(alpha: 0.9),
      wavelengthFactor: 0.65,
      amplitudeFactor: 0.4,
      speedFactor: 1.0,
      phaseOffset: 0.0,
      strokeWidth: 2.5,
    );

    // Wave 2: Secondary wave, offset and moving in opposite direction
    _drawSingleWave(
      canvas: canvas,
      size: size,
      yCenter: yCenter,
      waveColor: baseColor.withValues(alpha: 0.5),
      wavelengthFactor: 0.45,
      amplitudeFactor: 0.25,
      speedFactor: -1.2,
      phaseOffset: math.pi / 3.0,
      strokeWidth: 1.8,
    );

    // Wave 3: Background wave, slower and wider
    _drawSingleWave(
      canvas: canvas,
      size: size,
      yCenter: yCenter,
      waveColor: baseColor.withValues(alpha: 0.25),
      wavelengthFactor: 0.85,
      amplitudeFactor: 0.15,
      speedFactor: 0.6,
      phaseOffset: math.pi * 2.0 / 3.0,
      strokeWidth: 1.2,
    );
  }

  void _drawSingleWave({
    required Canvas canvas,
    required Size size,
    required double yCenter,
    required Color waveColor,
    required double wavelengthFactor,
    required double amplitudeFactor,
    required double speedFactor,
    required double phaseOffset,
    required double strokeWidth,
  }) {
    final paint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final wavelength = size.width * wavelengthFactor;
    final maxAmplitude = size.height * amplitudeFactor;
    final phase = (animationValue * 2.0 * math.pi * speedFactor) + phaseOffset;

    for (double x = 0.0; x <= size.width; x += 1.0) {
      // Smoothly fade amplitude to 0 at the left and right edges using a sine window
      final edgeFade = math.sin(math.pi * x / size.width);
      
      // Compute the y position using a sine function
      final y = yCenter +
          (maxAmplitude * edgeFade * math.sin((2.0 * math.pi * x / wavelength) - phase));

      if (x == 0.0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.baseColor != baseColor;
  }
}
