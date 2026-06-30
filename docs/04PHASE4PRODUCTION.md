# Phase 4: Production Readiness

**Goal:** Turn Sonify into a shippable product — proper identity, testing, performance optimization, and release configuration.

**Prerequisite:** Phase 3 complete (polished UI/UX).

---

## Step 4.1: App Identity

### Package Name
Change from `com.example.sonify` to your real package name:

```kotlin
// android/app/build.gradle.kts
android {
    namespace = "com.sonifyapp.tts"    // or your domain
    defaultConfig {
        applicationId = "com.sonifyapp.tts"
    }
}
```

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<!-- No changes needed — uses namespace from gradle -->
```

```
// iOS: Update in Xcode → Runner → General → Bundle Identifier
// com.sonifyapp.tts
```

### App Icon

Replace the default Flutter icon. You already have `assets/images/sonify-logo.png`.

```bash
# Add flutter_launcher_icons to dev_dependencies
# pubspec.yaml:
dev_dependencies:
  flutter_launcher_icons: ^0.14.3

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/images/sonify-logo.png"
  min_sdk_android: 24
  adaptive_icon_background: "#1A3684"
  adaptive_icon_foreground: "assets/images/sonify-logo.png"

# Then run:
flutter pub run flutter_launcher_icons
```

### App Display Name

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<application android:label="Sonify" ...>
<!-- Already "sonify" in lowercase — capitalize to "Sonify" -->
```

```xml
<!-- ios/Runner/Info.plist -->
<key>CFBundleDisplayName</key>
<string>Sonify</string>
<key>CFBundleName</key>
<string>Sonify</string>
```

---

## Step 4.2: Performance Optimization

### Run TTS in a Dart Isolate

The TTS generation blocks the main thread. For production, move it to an Isolate:

```dart
// lib/services/tts_engine.dart — add this method:

import 'dart:isolate';

/// Generate speech in a background isolate to keep UI responsive.
/// Falls back to main-thread generation if isolate fails.
Future<String> generateSpeechInBackground(
  String text, {
  int speakerId = 0,
  double speed = 1.0,
}) async {
  // For now, use main thread (Isolate support requires
  // sherpa-onnx model to be re-initialized in the isolate).
  // TODO: Implement full isolate support per sherpa-onnx example
  return generateSpeech(text, speakerId: speakerId, speed: speed);
}
```

**Note:** Full Isolate implementation requires re-initializing the model inside the isolate (see sherpa-onnx's `isolate_tts.dart`). This is a Phase 5 enhancement. For now, the main thread handles it with loading UI.

### Chunk Long Text

For text over 500 characters, split into sentences and generate sequentially:

```dart
/// Split text into sentences for progressive generation
List<String> _splitIntoChunks(String text, {int maxChunkLength = 500}) {
  if (text.length <= maxChunkLength) return [text];

  final sentences = text.split(RegExp(r'(?<=[.!?])\s+'));
  final chunks = <String>[];
  var current = StringBuffer();

  for (final sentence in sentences) {
    if (current.length + sentence.length > maxChunkLength && current.isNotEmpty) {
      chunks.add(current.toString().trim());
      current = StringBuffer();
    }
    current.write('$sentence ');
  }

  if (current.isNotEmpty) {
    chunks.add(current.toString().trim());
  }

  return chunks;
}
```

### Clean Up Temp Files

Add periodic cleanup of temporary WAV files:

```dart
// lib/services/audio_storage_service.dart — add:

/// Delete temporary audio files older than 24 hours
Future<void> cleanupTempFiles() async {
  try {
    final tempDir = await getTemporaryDirectory();
    final files = await tempDir.list().toList();
    final now = DateTime.now();

    for (final entity in files) {
      if (entity is File && entity.path.contains('sonify_')) {
        final stat = await entity.stat();
        if (now.difference(stat.modified).inHours > 24) {
          await entity.delete();
        }
      }
    }
  } catch (e) {
    debugPrint('Cleanup error: $e');
  }
}
```

Call this in `main.dart` after initialization:
```dart
// After DI init, before runApp:
sl<AudioStorageService>().cleanupTempFiles(); // fire and forget
```

---

## Step 4.3: Error Recovery

### Handle model corruption

If the model files are corrupted (bad copy, disk issues), detect and re-copy:

```dart
// In TtsEngine.initialize(), add after creating OfflineTts:
try {
  _tts = sherpa_onnx.OfflineTts(config);
} catch (e) {
  // Model might be corrupted — force re-copy
  debugPrint('Model load failed, attempting re-copy: $e');
  _assetsCopied = false;
  await _copyModelAssets();
  _tts = sherpa_onnx.OfflineTts(config);
}
```

### Graceful degradation

If TTS completely fails, show a helpful message:

```dart
// In text_to_speech_screen.dart _generateSpeech():
} catch (e) {
  String message = 'Something went wrong.';
  if (e is TtsInitializationException) {
    message = 'Voice engine failed to load. Try restarting the app.';
  } else if (e is TtsGenerationException) {
    message = 'Could not generate speech. Try shorter text.';
  }
  showErrorSnackBar(context, message);
}
```

---

## Step 4.4: Testing Checklist

### Unit Tests

```dart
// test/services/audio_storage_service_test.dart
// - saveAudio creates file + metadata
// - getSavedAudios returns sorted list
// - deleteAudio removes both files
// - clearAllSavedAudios empties directory

// test/core/utils/file_utils_test.dart
// - formatFileSize displays correctly
// - getAudioDirectory creates if missing

// test/features/text_to_speech/domain/usecases/generate_speech_test.dart
// - calls repository with correct options
// - propagates errors
```

### Integration Tests (Manual)

| # | Test | Device | Expected |
|---|------|--------|----------|
| 1 | Fresh install | Android | Splash shows "Preparing...", model copies, app opens |
| 2 | Fresh install | iOS | Same as above |
| 3 | Second launch | Both | Splash loads in <2 seconds (no file copy) |
| 4 | Generate "Hello" | Both | Audio plays within 1-2 seconds |
| 5 | Generate 500-word text | Both | Audio plays within 5-15 seconds |
| 6 | Generate with speed 0.5 | Both | Audio is audibly slower |
| 7 | Generate with speed 2.0 | Both | Audio is audibly faster |
| 8 | Save audio | Both | Appears in Saved tab immediately |
| 9 | Delete audio | Both | Removed from list, file deleted |
| 10 | Export all | Android | Files appear in external storage |
| 11 | Export all | iOS | Files appear in Documents |
| 12 | Share audio | Both | System share sheet opens |
| 13 | Clear all | Both | Saved tab is empty |
| 14 | Empty text → Generate | Both | Button is disabled |
| 15 | 5001+ chars → Generate | Both | Button is disabled, counter is red |
| 16 | Airplane mode | Both | Everything works (fully offline) |
| 17 | Kill app during generation | Both | No crash on next launch |
| 18 | Low storage | Both | Error message, no crash |
| 19 | Dark mode toggle | Both | All screens render correctly |
| 20 | Rotate device | Both | Layout adapts, no overflow |

---

## Step 4.5: Release Configuration

### Android

```kotlin
// android/app/build.gradle.kts
android {
    buildTypes {
        release {
            // Enable ProGuard/R8 for smaller APK
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            // TODO: Create a real signing config
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}
```

```bash
# Build split APKs (much smaller than universal)
flutter build apk --split-per-abi --release

# Or build an App Bundle for Play Store
flutter build appbundle --release
```

**Expected APK sizes (split by ABI):**
- arm64-v8a: ~75-90 MB (model + runtime)
- armeabi-v7a: ~70-85 MB
- x86_64: ~80-95 MB

### iOS

```bash
flutter build ios --release
# Then archive and upload via Xcode
```

### ProGuard Rules (android/app/proguard-rules.pro)

```
# sherpa-onnx native libraries
-keep class com.k2fsa.sherpa.onnx.** { *; }
-dontwarn com.k2fsa.sherpa.onnx.**
```

---

## Step 4.6: About Screen Enhancement

Update the About dialog in Settings:

```dart
showAboutDialog(
  context: context,
  applicationName: 'Sonify',
  applicationVersion: '1.0.0',
  applicationLegalese: '© 2026 Khalid',
  applicationIcon: ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Image.asset(
      'assets/images/sonify-logo.png',
      width: 48, height: 48,
    ),
  ),
  children: [
    const SizedBox(height: 16),
    const Text(
      'Sonify transforms text into natural-sounding speech '
      'using Piper AI, powered by sherpa-onnx. '
      'Fully offline — no internet required.',
    ),
    const SizedBox(height: 12),
    const Text(
      'Voice Model: Piper Lessac (English)\n'
      'Engine: sherpa-onnx\n'
      'License: Apache 2.0 / MIT',
      style: TextStyle(fontSize: 12, color: Colors.grey),
    ),
  ],
);
```

---

## Step 4.7: Final File Structure

After all 4 phases, the project should look like this:

```
lib/
├── main.dart
├── app/
│   ├── home_screen.dart
│   └── splash_screen.dart
├── core/
│   ├── constants/constants.dart
│   ├── di/service_locator.dart          ← NEW
│   ├── errors/
│   │   ├── exceptions.dart              ← WAS EMPTY
│   │   └── failures.dart                ← WAS EMPTY
│   ├── models/audio_file.dart
│   ├── themes/theme_config.dart
│   ├── utils/file_utils.dart            ← WAS EMPTY
│   └── widgets/
│       ├── sound_wave_animation.dart    ← WAS EMPTY
│       └── theme_switch_widget.dart
├── services/
│   ├── tts_engine.dart                  ← NEW (sherpa-onnx wrapper)
│   ├── tts_service.dart                 ← REWRITTEN (facade)
│   └── audio_storage_service.dart       ← NEW (extracted from old tts_service)
├── features/
│   ├── text_to_speech/
│   │   ├── domain/
│   │   │   ├── entities/speech_options.dart      ← WAS EMPTY
│   │   │   ├── repositories/tts_repository.dart  ← WAS EMPTY
│   │   │   └── usecases/
│   │   │       ├── generate_speech.dart           ← WAS EMPTY
│   │   │       └── get_available_voices.dart      ← WAS EMPTY
│   │   ├── data/
│   │   │   ├── datasource/tts_local_data_source.dart  ← WAS EMPTY
│   │   │   ├── models/speech_options_model.dart        ← WAS EMPTY
│   │   │   └── repositories/tts_repository_impl.dart  ← WAS EMPTY
│   │   └── presentation/               ← RENAMED from presentaiont
│   │       ├── screens/text_to_speech_screen.dart  ← MODIFIED
│   │       └── widgets/audio_player_widget.dart    ← MODIFIED
│   ├── saved_audios/
│   │   ├── domain/
│   │   │   ├── repositories/saved_audios_repository.dart  ← WAS EMPTY
│   │   │   └── usecases/
│   │   │       ├── save_audio.dart      ← WAS EMPTY
│   │   │       ├── delete_audio.dart    ← WAS EMPTY
│   │   │       └── get_saved_audios.dart ← WAS EMPTY
│   │   ├── data/
│   │   │   ├── datasources/saved_audios_local_data_source.dart ← WAS EMPTY
│   │   │   ├── models/saved_audio_model.dart                   ← WAS EMPTY
│   │   │   └── repositories/saved_audios_repository_impl.dart  ← WAS EMPTY
│   │   └── presentation/screens/saved_audios_screen.dart
│   ├── settings/
│   │   ├── domain/
│   │   │   ├── repositories/settings_repository.dart  ← WAS EMPTY
│   │   │   └── usecases/
│   │   │       ├── clear_all_saved_audios.dart ← WAS EMPTY
│   │   │       └── export_all_audios.dart      ← WAS EMPTY
│   │   ├── data/
│   │   │   ├── datasources/settings_local_data_source.dart ← WAS EMPTY
│   │   │   └── repositories/settings_repository_impl.dart  ← WAS EMPTY
│   │   └── presentation/screens/settings_screen.dart ← MODIFIED
│   └── theme/
│       ├── domain/                      ← RENAMED from domin
│       │   ├── repositories/theme_repository.dart  ← WAS EMPTY
│       │   └── usecases/
│       │       ├── get_theme.dart        ← WAS EMPTY
│       │       └── toggle_theme.dart     ← WAS EMPTY
│       ├── data/
│       │   ├── datasources/theme_local_data_source.dart ← WAS EMPTY
│       │   ├── models/theme_model.dart                  ← WAS EMPTY
│       │   └── repositories/theme_repository_impl.dart  ← WAS EMPTY
│       └── presentation/providers/theme_provider.dart
assets/
├── images/sonify-logo.png
└── tts-model/
    └── vits-piper-en_US-lessac-medium/   ← NEW (~75MB)
        ├── en_US-lessac-medium.onnx
        ├── tokens.txt
        └── espeak-ng-data/
```

**Stats:**
- 0 empty files (was 28)
- 0 directory typos (was 2)
- Clean architecture fully implemented across all 4 features
- DI container manages all dependencies
- TTS engine is Piper via sherpa-onnx (was flutter_tts)

---

## Phase 4 Definition of Done

- [ ] App identity set (package name, display name, icon)
- [ ] About dialog updated with correct info
- [ ] Temp file cleanup runs on launch
- [ ] Error recovery for corrupted model files
- [ ] ProGuard rules configured
- [ ] Release APK builds successfully
- [ ] Release IPA builds successfully
- [ ] All 20 manual test cases pass
- [ ] No `com.example` references remain
- [ ] No hardcoded Timer delays remain
- [ ] No empty files remain
- [ ] `flutter analyze` reports 0 issues
