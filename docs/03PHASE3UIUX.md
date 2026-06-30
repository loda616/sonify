# Phase 3: UI/UX Polish

**Goal:** Make Sonify feel like a finished, polished app — not a prototype. Add proper loading states, a voice picker, onboarding, animations, and error feedback.

**Prerequisite:** Phase 2 complete (Piper TTS generating audio end-to-end).

---

## Step 3.1: Smart Splash Screen (Replace Timer Hack)

The current splash screen waits a hardcoded 4 seconds. Replace with actual initialization:

### `lib/app/splash_screen.dart` — Rewrite

```dart
import 'package:flutter/material.dart';
import 'package:sonify/core/di/service_locator.dart';
import 'package:sonify/services/tts_engine.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeIn;
  late Animation<double> _scale;
  String _statusText = 'Loading...';
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scale = Tween<double>(begin: 0.8, end: 1.0).animate(
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
      // Step 1: Copy model files (first launch only)
      setState(() => _statusText = 'Preparing voice model...');
      final engine = sl<TtsEngine>();
      await engine.initialize();

      // Step 2: Brief pause so user sees the splash
      setState(() => _statusText = 'Ready!');
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 3: Navigate
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
      setState(() {
        _statusText = 'Failed to load. Tap to retry.';
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF1A3684);

    return Scaffold(
      backgroundColor: bgColor,
      body: GestureDetector(
        onTap: _hasError ? () {
          setState(() { _hasError = false; });
          _initializeApp();
        } : null,
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeIn,
                child: ScaleTransition(
                  scale: _scale,
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
                              color: Colors.black.withOpacity(0.3),
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

                      // Progress indicator or error icon
                      if (!_hasError)
                        SizedBox(
                          width: 140,
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.white.withOpacity(0.15),
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
                        _statusText,
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
```

**What changed:**
- Initializes TTS engine instead of `Timer(4 seconds)`
- Shows "Preparing voice model..." during first-launch file copy
- Shows error state with tap-to-retry if init fails
- Smooth fade transition to HomeScreen

---

## Step 3.2: TTS Screen — Loading States & Generation Progress

### Updates to `text_to_speech_screen.dart`

```dart
// KEY CHANGES:

// 1. Remove pitch slider entirely
// The whole "Pitch control" Row widget — delete it

// 2. Add character counter below text field
Align(
  alignment: Alignment.centerRight,
  child: Text(
    '${_textController.text.length} / ${AppConstants.maxTextLength}',
    style: theme.textTheme.bodySmall?.copyWith(
      color: _textController.text.length > AppConstants.maxTextLength
          ? Colors.red
          : null,
    ),
  ),
),

// 3. Replace hardcoded voice list with dynamic loading
List<String> _availableVoices = ['Default'];
bool _isLoadingVoices = true;

@override
void initState() {
  super.initState();
  _loadVoices();
  _textController.addListener(() => setState(() {})); // for char count
}

Future<void> _loadVoices() async {
  final voices = await _ttsService.getAvailableVoices();
  if (mounted) {
    setState(() {
      _availableVoices = voices;
      _isLoadingVoices = false;
    });
  }
}

// 4. Add estimated time hint during generation
// For long text, show "Generating... ~5 seconds"
if (_isGenerating)
  Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const SizedBox(width: 20, height: 20,
        child: CircularProgressIndicator(strokeWidth: 2)),
      const SizedBox(width: 12),
      Text(
        _textController.text.length > 200
            ? 'Generating... this may take a few seconds'
            : 'Generating...',
      ),
    ],
  ),

// 5. Disable generate button for empty or over-limit text
onPressed: _isGenerating ||
    _textController.text.trim().isEmpty ||
    _textController.text.length > AppConstants.maxTextLength
        ? null
        : _generateSpeech,
```

---

## Step 3.3: Sound Wave Animation Widget

Currently empty. Create an animated waveform that plays during audio generation:

### `lib/core/widgets/sound_wave_animation.dart`

```dart
import 'dart:math';
import 'package:flutter/material.dart';

class SoundWaveAnimation extends StatefulWidget {
  final bool isAnimating;
  final Color color;
  final int barCount;
  final double height;

  const SoundWaveAnimation({
    Key? key,
    required this.isAnimating,
    this.color = const Color(0xFF00A896),
    this.barCount = 5,
    this.height = 40,
  }) : super(key: key);

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
```

**Usage in TTS screen:**
```dart
// Show during generation instead of just a spinner
if (_isGenerating)
  SoundWaveAnimation(
    isAnimating: true,
    color: isDarkMode ? darkAccentColor : lightAccentColor,
  ),
```

---

## Step 3.4: Enhanced Audio Player Widget

Add waveform visualization and share button to `audio_player_widget.dart`:

```dart
// ADD to the existing Row of buttons:

// Share button
if (_generatedAudioPath != null) ...[
  const SizedBox(width: 12),
  InkWell(
    onTap: () => _ttsService.shareAudio(
      widget.audioPath,
      'Sonify Audio',
    ),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: accentColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.share, color: accentColor, size: 16),
          const SizedBox(width: 4),
          Text('Share', style: TextStyle(color: accentColor)),
        ],
      ),
    ),
  ),
],
```

---

## Step 3.5: Voice Picker with Preview

If using the multi-speaker model (libritts_r-medium, 904 speakers), add a voice preview feature:

### Add to TTS screen — Voice Preview Button

```dart
// Next to the voice dropdown, add a small "Preview" button
Row(
  children: [
    Expanded(
      child: DropdownButtonFormField<String>(
        value: _selectedVoice,
        items: _availableVoices.map((v) =>
          DropdownMenuItem(value: v, child: Text(v)),
        ).toList(),
        onChanged: (v) => setState(() => _selectedVoice = v ?? 'Default'),
        decoration: const InputDecoration(labelText: 'Voice'),
      ),
    ),
    const SizedBox(width: 8),
    IconButton(
      icon: const Icon(Icons.play_circle_outline),
      tooltip: 'Preview voice',
      onPressed: _isGenerating ? null : () async {
        setState(() => _isGenerating = true);
        try {
          final path = await _ttsService.generateSpeech(
            'Hello, this is how I sound.',
            voice: _selectedVoice,
            speed: _speed,
          );
          setState(() => _generatedAudioPath = path);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Preview failed: $e')),
          );
        } finally {
          setState(() => _isGenerating = false);
        }
      },
    ),
  ],
),
```

---

## Step 3.6: Empty States & Error Feedback

### Saved Audios screen — Better empty state

The existing empty state is fine but add a CTA button:

```dart
// After the "No saved audio files yet" text, add:
const SizedBox(height: 16),
OutlinedButton.icon(
  icon: const Icon(Icons.record_voice_over),
  label: const Text('Create your first audio'),
  onPressed: () {
    // Switch to TTS tab (index 0 in HomeScreen)
    // Use a callback or state management
  },
),
```

### Snackbar improvements

Replace plain text snackbars with styled ones:

```dart
// Create a utility method in a new file or as an extension
void showSuccessSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white),
          const SizedBox(width: 8),
          Text(message),
        ],
      ),
      backgroundColor: Colors.green.shade700,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}

void showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: Colors.red.shade700,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}
```

---

## Step 3.7: Settings Screen Enhancements

Add TTS-related settings:

```dart
// Add a new "Voice Settings" card above the Storage card:

Card(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Voice Settings', style: theme.textTheme.titleMedium),
      const SizedBox(height: 16),

      // Default speed
      ListTile(
        title: const Text('Default Speed'),
        subtitle: Text('${_defaultSpeed.toStringAsFixed(1)}x'),
        trailing: SizedBox(
          width: 150,
          child: Slider(
            value: _defaultSpeed,
            min: 0.5, max: 3.0, divisions: 25,
            onChanged: (v) {
              setState(() => _defaultSpeed = v);
              _saveDefaultSpeed(v);
            },
          ),
        ),
      ),

      // Model info
      ListTile(
        title: const Text('TTS Engine'),
        subtitle: const Text('Piper Lessac (English) — Offline'),
        trailing: const Icon(Icons.offline_bolt, color: Colors.green),
      ),
    ],
  ),
),
```

---

## Phase 3 Definition of Done

- [ ] Splash screen initializes TTS engine with progress feedback
- [ ] Splash shows error + retry if init fails
- [ ] Pitch slider removed from TTS screen
- [ ] Character counter shown below text input
- [ ] Text length limit enforced (5000 chars)
- [ ] Voice dropdown loads dynamically from engine
- [ ] Sound wave animation plays during generation
- [ ] Snackbars use success/error styling
- [ ] Settings has voice settings card
- [ ] Empty states have CTAs (not just text)
- [ ] No hardcoded Timer delays anywhere
