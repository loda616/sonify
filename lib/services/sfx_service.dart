import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart' as ap;

class SfxService {
  // Singleton pattern
  static final SfxService _instance = SfxService._internal();
  factory SfxService() => _instance;
  SfxService._internal();

  final ap.AudioPlayer _sfxPlayer = ap.AudioPlayer();
  bool _sfxEnabled = true;
  bool _hapticsEnabled = true;

  void toggleSfx(bool enabled) {
    _sfxEnabled = enabled;
  }

  void toggleHaptics(bool enabled) {
    _hapticsEnabled = enabled;
  }

  Future<void> playClick() async {
    if (_hapticsEnabled) {
      await HapticFeedback.lightImpact();
    }
    if (_sfxEnabled) {
      await _playAsset('assets/sounds/click.wav');
    }
  }

  Future<void> playSuccess() async {
    if (_hapticsEnabled) {
      await HapticFeedback.mediumImpact();
    }
    if (_sfxEnabled) {
      await _playAsset('assets/sounds/success.wav');
    }
  }

  Future<void> playDelete() async {
    if (_hapticsEnabled) {
      await HapticFeedback.heavyImpact();
    }
    if (_sfxEnabled) {
      await _playAsset('assets/sounds/delete.wav');
    }
  }

  Future<void> _playAsset(String assetPath) async {
    try {
      // Remove "assets/" prefix since AssetSource assumes assets/ folder by default
      final relativePath = assetPath.replaceFirst('assets/', '');
      await _sfxPlayer.play(ap.AssetSource(relativePath));
    } catch (e) {
      // Fail silently to prevent SFX errors from crashing app
      debugPrint('SFX Error: $e');
    }
  }

  void dispose() {
    _sfxPlayer.dispose();
  }
}
