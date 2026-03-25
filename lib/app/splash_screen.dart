import 'package:flutter/material.dart';

import 'package:sonify/core/di/service_locator.dart';
import 'package:sonify/l10n/app_localizations.dart';
import 'package:sonify/services/tts_engine.dart';
import 'home_screen.dart';

enum _SplashStatus { loading, preparing, ready, failed }

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;
  _SplashStatus _status = _SplashStatus.loading;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      setState(() => _status = _SplashStatus.preparing);
      final engine = sl<TtsEngine>();
      await engine.initialize();

      setState(() => _status = _SplashStatus.ready);
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    } catch (e) {
      debugPrint('App initialization failed: $e');
      if (mounted) {
        _animationController.stop();
        setState(() {
          _status = _SplashStatus.failed;
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _resolveStatusText(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return '';
    switch (_status) {
      case _SplashStatus.loading:
        return l10n.splashLoading;
      case _SplashStatus.preparing:
        return l10n.splashPreparing;
      case _SplashStatus.ready:
        return l10n.splashReady;
      case _SplashStatus.failed:
        return l10n.splashFailed;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF1A3684);

    return Scaffold(
      backgroundColor: bgColor,
      body: GestureDetector(
        onTap: _hasError
            ? () {
                setState(() => _hasError = false);
                _animationController.forward(from: 0.0);
                _initializeApp();
              }
            : null,
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeInAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(36),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 24,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(36),
                          child: Image.asset(
                            'assets/images/sonify-logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Progress or error icon
                      if (!_hasError)
                        SizedBox(
                          width: 140,
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.white.withValues(alpha: 0.15),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF00D8FF),
                            ),
                            minHeight: 4,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        )
                      else
                        const Icon(
                          Icons.refresh,
                          color: Colors.white70,
                          size: 32,
                        ),

                      const SizedBox(height: 24),

                      // Status text
                      Text(
                        _resolveStatusText(context),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}