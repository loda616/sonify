import 'dart:math';
import 'package:flutter/material.dart';

class SoundWaveAnimation extends StatefulWidget {
  final bool isAnimating;
  final Color color;
  final int barCount;
  final double height;

  const SoundWaveAnimation({
    super.key,
    required this.isAnimating,
    this.color = const Color(0xFF00A896),
    this.barCount = 5,
    this.height = 40,
  });

  @override
  State<SoundWaveAnimation> createState() => _SoundWaveAnimationState();
}

class _SoundWaveAnimationState extends State<SoundWaveAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _controllers = List.generate(widget.barCount, (i) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 300 + _random.nextInt(400)),
      );
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.2, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    if (widget.isAnimating) _startAnimations();
  }

  void _startAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 80), () {
        if (mounted && widget.isAnimating) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  void _stopAnimations() {
    for (final controller in _controllers) {
      controller.stop();
      controller.animateTo(0.2,
          duration: const Duration(milliseconds: 300));
    }
  }

  @override
  void didUpdateWidget(SoundWaveAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating && !oldWidget.isAnimating) {
      _startAnimations();
    } else if (!widget.isAnimating && oldWidget.isAnimating) {
      _stopAnimations();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(widget.barCount, (i) {
          return AnimatedBuilder(
            animation: _animations[i],
            builder: (context, child) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 4,
                height: widget.height * _animations[i].value,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
