# Phase 1: Architecture & Foundation

**Goal:** Fix the broken scaffolding, set up dependency injection, implement error handling, and fill all 28 empty files so the clean architecture actually works.

**Prerequisite:** None — start here.

---

## Step 1.1: Fix Directory Typos

```bash
# Rename misspelled directories
git mv lib/features/text_to_speech/presentaiont lib/features/text_to_speech/presentation
git mv lib/features/theme/domin lib/features/theme/domain

# Update ALL imports across the codebase
# In every .dart file, replace:
#   'presentaiont' → 'presentation'
#   'theme/domin'  → 'theme/domain'
```

**Files affected by import changes:**
- `lib/app/home_screen.dart` — imports text_to_speech screen
- `lib/core/widgets/theme_switch_widget.dart` — imports ThemeProvider
- `lib/features/saved_audios/presentation/screens/saved_audios_screen.dart` — imports AudioPlayerWidget
- `lib/features/settings/presentation/screens/settings_screen.dart` — imports ThemeProvider

---

## Step 1.2: Add Dependencies

```yaml
# pubspec.yaml — ADD these dependencies:
dependencies:
  get_it: ^8.0.2          # Dependency injection
  sherpa_onnx: ^1.12.31   # TTS engine (replaces flutter_tts)
  path: ^1.9.0            # Path manipulation

  # REMOVE:
  # flutter_tts: ^4.2.2
```

---

## Step 1.3: Error Handling Infrastructure

### `lib/core/errors/exceptions.dart`

```dart
/// Base exception for all Sonify-specific errors
class SonifyException implements Exception {
  final String message;
  final String? code;
  const SonifyException(this.message, {this.code});

  @override
  String toString() => 'SonifyException($code): $message';
}

/// Thrown when TTS engine fails to initialize
class TtsInitializationException extends SonifyException {
  const TtsInitializationException(String message)
      : super(message, code: 'TTS_INIT_FAILED');
}

/// Thrown when speech generation fails
class TtsGenerationException extends SonifyException {
  const TtsGenerationException(String message)
      : super(message, code: 'TTS_GENERATION_FAILED');
}

/// Thrown when file operations fail
class StorageException extends SonifyException {
  const StorageException(String message)
      : super(message, code: 'STORAGE_ERROR');
}

/// Thrown when an audio file is not found
class AudioNotFoundException extends SonifyException {
  const AudioNotFoundException(String message)
      : super(message, code: 'AUDIO_NOT_FOUND');
}

/// Thrown when model files are missing or corrupted
class ModelNotFoundException extends SonifyException {
  const ModelNotFoundException(String message)
      : super(message, code: 'MODEL_NOT_FOUND');
}
```

### `lib/core/errors/failures.dart`

```dart
/// Base failure class for use case return types.
/// Use these instead of throwing exceptions from repositories.
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class TtsFailure extends Failure {
  const TtsFailure(String message) : super(message);
}

class StorageFailure extends Failure {
  const StorageFailure(String message) : super(message);
}

class GenerationFailure extends Failure {
  const GenerationFailure(String message) : super(message);
}
```

---

## Step 1.4: File Utilities

### `lib/core/utils/file_utils.dart`

```dart
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class FileUtils {
  static const String audioDirectoryName = 'sonify_audio';

  /// Get the directory where saved audio files are stored
  static Future<Directory> getAudioDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final audioDir = Directory(p.join(appDir.path, audioDirectoryName));
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    return audioDir;
  }

  /// Get a temporary directory for in-progress audio
  static Future<Directory> getTempAudioDirectory() async {
    return await getTemporaryDirectory();
  }

  /// Check if a file exists at the given path
  static Future<bool> fileExists(String path) async {
    return await File(path).exists();
  }

  /// Get file size in bytes
  static Future<int> getFileSize(String path) async {
    final file = File(path);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  /// Format file size for display (e.g., "1.2 MB")
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Delete a file safely (no error if missing)
  static Future<void> deleteFileSafely(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
```

---

## Step 1.5: Dependency Injection with GetIt

### `lib/core/di/service_locator.dart`

```dart
import 'package:get_it/get_it.dart';

// Services
import 'package:sonify/services/tts_engine.dart';
import 'package:sonify/services/audio_storage_service.dart';
import 'package:sonify/services/tts_service.dart';

// Repositories
import 'package:sonify/features/text_to_speech/domain/repositories/tts_repository.dart';
import 'package:sonify/features/text_to_speech/data/repositories/tts_repository_impl.dart';
import 'package:sonify/features/saved_audios/domain/repositories/saved_audios_repository.dart';
import 'package:sonify/features/saved_audios/data/repositories/saved_audios_repository_impl.dart';
import 'package:sonify/features/settings/domain/repositories/settings_repository.dart';
import 'package:sonify/features/settings/data/repositories/settings_repository_impl.dart';

// Use Cases
import 'package:sonify/features/text_to_speech/domain/usecases/generate_speech.dart';
import 'package:sonify/features/text_to_speech/domain/usecases/get_available_voices.dart';
import 'package:sonify/features/saved_audios/domain/usecases/save_audio.dart';
import 'package:sonify/features/saved_audios/domain/usecases/delete_audio.dart';
import 'package:sonify/features/saved_audios/domain/usecases/get_saved_audios.dart';
import 'package:sonify/features/settings/domain/usecases/clear_all_saved_audios.dart';
import 'package:sonify/features/settings/domain/usecases/export_all_audios.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // ─── Services (Singletons) ───
  sl.registerLazySingleton<TtsEngine>(() => TtsEngine());
  sl.registerLazySingleton<AudioStorageService>(() => AudioStorageService());
  sl.registerLazySingleton<TTSService>(
    () => TTSService(engine: sl(), storage: sl()),
  );

  // ─── Repositories ───
  sl.registerLazySingleton<TtsRepository>(
    () => TtsRepositoryImpl(engine: sl()),
  );
  sl.registerLazySingleton<SavedAudiosRepository>(
    () => SavedAudiosRepositoryImpl(storageService: sl()),
  );
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(storageService: sl()),
  );

  // ─── Use Cases ───
  sl.registerFactory(() => GenerateSpeech(sl()));
  sl.registerFactory(() => GetAvailableVoices(sl()));
  sl.registerFactory(() => SaveAudio(sl()));
  sl.registerFactory(() => DeleteAudio(sl()));
  sl.registerFactory(() => GetSavedAudios(sl()));
  sl.registerFactory(() => ClearAllSavedAudios(sl()));
  sl.registerFactory(() => ExportAllAudios(sl()));
}
```

### Update `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app/splash_screen.dart';
import 'core/themes/theme_config.dart';
import 'core/di/service_locator.dart';
import 'features/theme/presentation/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );

  // Initialize dependency injection
  await initServiceLocator();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Sonify',
          debugShowCheckedModeBanner: false,
          theme: getLightTheme(),
          darkTheme: getDarkTheme(),
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const SplashScreen(),
        );
      },
    );
  }
}
```

---

## Step 1.6: Fill Text-to-Speech Domain & Data Layer

### `lib/features/text_to_speech/domain/entities/speech_options.dart`

```dart
class SpeechOptions {
  final String text;
  final int speakerId;
  final double speed;

  const SpeechOptions({
    required this.text,
    this.speakerId = 0,
    this.speed = 1.0,
  });

  SpeechOptions copyWith({String? text, int? speakerId, double? speed}) {
    return SpeechOptions(
      text: text ?? this.text,
      speakerId: speakerId ?? this.speakerId,
      speed: speed ?? this.speed,
    );
  }
}
```

### `lib/features/text_to_speech/domain/repositories/tts_repository.dart`

```dart
import '../entities/speech_options.dart';

abstract class TtsRepository {
  /// Generate speech audio from text. Returns file path to WAV.
  Future<String> generateSpeech(SpeechOptions options);

  /// Get list of available voice names
  Future<List<String>> getAvailableVoices();

  /// Initialize the TTS engine (load model)
  Future<void> initialize();

  /// Whether the engine is ready to generate
  bool get isInitialized;

  /// Number of available speaker IDs
  int get numSpeakers;
}
```

### `lib/features/text_to_speech/domain/usecases/generate_speech.dart`

```dart
import '../entities/speech_options.dart';
import '../repositories/tts_repository.dart';

class GenerateSpeech {
  final TtsRepository repository;
  GenerateSpeech(this.repository);

  /// Returns the file path of the generated WAV audio
  Future<String> call(SpeechOptions options) {
    return repository.generateSpeech(options);
  }
}
```

### `lib/features/text_to_speech/domain/usecases/get_available_voices.dart`

```dart
import '../repositories/tts_repository.dart';

class GetAvailableVoices {
  final TtsRepository repository;
  GetAvailableVoices(this.repository);

  Future<List<String>> call() {
    return repository.getAvailableVoices();
  }
}
```

### `lib/features/text_to_speech/data/models/speech_options_model.dart`

```dart
import '../../domain/entities/speech_options.dart';

class SpeechOptionsModel extends SpeechOptions {
  const SpeechOptionsModel({
    required String text,
    int speakerId = 0,
    double speed = 1.0,
  }) : super(text: text, speakerId: speakerId, speed: speed);

  factory SpeechOptionsModel.fromEntity(SpeechOptions entity) {
    return SpeechOptionsModel(
      text: entity.text,
      speakerId: entity.speakerId,
      speed: entity.speed,
    );
  }

  Map<String, dynamic> toJson() => {
    'text': text,
    'speakerId': speakerId,
    'speed': speed,
  };
}
```

### `lib/features/text_to_speech/data/datasource/tts_local_data_source.dart`

```dart
import 'package:sonify/services/tts_engine.dart';

/// Wraps the TTS engine for the data layer
abstract class TtsLocalDataSource {
  Future<void> initialize();
  Future<String> generateSpeech(String text, {int speakerId, double speed});
  Future<List<String>> getAvailableVoices();
  bool get isInitialized;
  int get numSpeakers;
}

class TtsLocalDataSourceImpl implements TtsLocalDataSource {
  final TtsEngine engine;
  TtsLocalDataSourceImpl({required this.engine});

  @override
  Future<void> initialize() => engine.initialize();

  @override
  Future<String> generateSpeech(
    String text, {
    int speakerId = 0,
    double speed = 1.0,
  }) => engine.generateSpeech(text, speakerId: speakerId, speed: speed);

  @override
  Future<List<String>> getAvailableVoices() async {
    await engine.initialize();
    final count = engine.numSpeakers;
    if (count <= 1) return ['Default'];
    return ['Default', ...List.generate(count, (i) => 'Speaker ${i + 1}')];
  }

  @override
  bool get isInitialized => engine.isInitialized;

  @override
  int get numSpeakers => engine.numSpeakers;
}
```

### `lib/features/text_to_speech/data/repositories/tts_repository_impl.dart`

```dart
import 'package:sonify/core/errors/exceptions.dart';
import 'package:sonify/services/tts_engine.dart';
import '../../domain/entities/speech_options.dart';
import '../../domain/repositories/tts_repository.dart';

class TtsRepositoryImpl implements TtsRepository {
  final TtsEngine engine;
  TtsRepositoryImpl({required this.engine});

  @override
  Future<String> generateSpeech(SpeechOptions options) async {
    try {
      return await engine.generateSpeech(
        options.text,
        speakerId: options.speakerId,
        speed: options.speed,
      );
    } catch (e) {
      throw TtsGenerationException('Failed to generate speech: $e');
    }
  }

  @override
  Future<List<String>> getAvailableVoices() async {
    await initialize();
    final count = engine.numSpeakers;
    if (count <= 1) return ['Default'];
    return ['Default', ...List.generate(count, (i) => 'Speaker ${i + 1}')];
  }

  @override
  Future<void> initialize() async {
    try {
      await engine.initialize();
    } catch (e) {
      throw TtsInitializationException('Failed to initialize TTS: $e');
    }
  }

  @override
  bool get isInitialized => engine.isInitialized;

  @override
  int get numSpeakers => engine.numSpeakers;
}
```

---

## Step 1.7: Fill Saved Audios Domain & Data Layer

### `lib/features/saved_audios/domain/repositories/saved_audios_repository.dart`

```dart
import 'package:sonify/core/models/audio_file.dart';

abstract class SavedAudiosRepository {
  Future<List<AudioFile>> getSavedAudios();
  Future<bool> saveAudio(String audioPath, String title);
  Future<bool> deleteAudio(String id);
}
```

### `lib/features/saved_audios/domain/usecases/get_saved_audios.dart`

```dart
import 'package:sonify/core/models/audio_file.dart';
import '../repositories/saved_audios_repository.dart';

class GetSavedAudios {
  final SavedAudiosRepository repository;
  GetSavedAudios(this.repository);

  Future<List<AudioFile>> call() => repository.getSavedAudios();
}
```

### `lib/features/saved_audios/domain/usecases/save_audio.dart`

```dart
import '../repositories/saved_audios_repository.dart';

class SaveAudio {
  final SavedAudiosRepository repository;
  SaveAudio(this.repository);

  Future<bool> call(String audioPath, String title) =>
      repository.saveAudio(audioPath, title);
}
```

### `lib/features/saved_audios/domain/usecases/delete_audio.dart`

```dart
import '../repositories/saved_audios_repository.dart';

class DeleteAudio {
  final SavedAudiosRepository repository;
  DeleteAudio(this.repository);

  Future<bool> call(String id) => repository.deleteAudio(id);
}
```

### `lib/features/saved_audios/data/models/saved_audio_model.dart`

```dart
import 'package:sonify/core/models/audio_file.dart';

class SavedAudioModel extends AudioFile {
  SavedAudioModel({
    required String id,
    required String title,
    required String filePath,
    required String createdAt,
  }) : super(id: id, title: title, filePath: filePath, createdAt: createdAt);

  factory SavedAudioModel.fromAudioFile(AudioFile file) {
    return SavedAudioModel(
      id: file.id,
      title: file.title,
      filePath: file.filePath,
      createdAt: file.createdAt,
    );
  }
}
```

### `lib/features/saved_audios/data/datasources/saved_audios_local_data_source.dart`

```dart
import 'package:sonify/core/models/audio_file.dart';
import 'package:sonify/services/audio_storage_service.dart';

abstract class SavedAudiosLocalDataSource {
  Future<List<AudioFile>> getSavedAudios();
  Future<bool> saveAudio(String audioPath, String title);
  Future<bool> deleteAudio(String id);
}

class SavedAudiosLocalDataSourceImpl implements SavedAudiosLocalDataSource {
  final AudioStorageService storageService;
  SavedAudiosLocalDataSourceImpl({required this.storageService});

  @override
  Future<List<AudioFile>> getSavedAudios() => storageService.getSavedAudios();

  @override
  Future<bool> saveAudio(String audioPath, String title) =>
      storageService.saveAudio(audioPath, title);

  @override
  Future<bool> deleteAudio(String id) => storageService.deleteAudio(id);
}
```

### `lib/features/saved_audios/data/repositories/saved_audios_repository_impl.dart`

```dart
import 'package:sonify/core/models/audio_file.dart';
import 'package:sonify/services/audio_storage_service.dart';
import '../../domain/repositories/saved_audios_repository.dart';

class SavedAudiosRepositoryImpl implements SavedAudiosRepository {
  final AudioStorageService storageService;
  SavedAudiosRepositoryImpl({required this.storageService});

  @override
  Future<List<AudioFile>> getSavedAudios() => storageService.getSavedAudios();

  @override
  Future<bool> saveAudio(String audioPath, String title) =>
      storageService.saveAudio(audioPath, title);

  @override
  Future<bool> deleteAudio(String id) => storageService.deleteAudio(id);
}
```

---

## Step 1.8: Fill Settings Domain & Data Layer

### `lib/features/settings/domain/repositories/settings_repository.dart`

```dart
abstract class SettingsRepository {
  Future<bool> clearAllSavedAudios();
  Future<String> exportAllAudios();
}
```

### `lib/features/settings/domain/usecases/clear_all_saved_audios.dart`

```dart
import '../repositories/settings_repository.dart';

class ClearAllSavedAudios {
  final SettingsRepository repository;
  ClearAllSavedAudios(this.repository);

  Future<bool> call() => repository.clearAllSavedAudios();
}
```

### `lib/features/settings/domain/usecases/export_all_audios.dart`

```dart
import '../repositories/settings_repository.dart';

class ExportAllAudios {
  final SettingsRepository repository;
  ExportAllAudios(this.repository);

  Future<String> call() => repository.exportAllAudios();
}
```

### `lib/features/settings/data/datasources/settings_local_data_source.dart`

```dart
import 'package:sonify/services/audio_storage_service.dart';

abstract class SettingsLocalDataSource {
  Future<bool> clearAllSavedAudios();
  Future<String> exportAllAudios();
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final AudioStorageService storageService;
  SettingsLocalDataSourceImpl({required this.storageService});

  @override
  Future<bool> clearAllSavedAudios() => storageService.clearAllSavedAudios();

  @override
  Future<String> exportAllAudios() => storageService.exportAllAudios();
}
```

### `lib/features/settings/data/repositories/settings_repository_impl.dart`

```dart
import 'package:sonify/services/audio_storage_service.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final AudioStorageService storageService;
  SettingsRepositoryImpl({required this.storageService});

  @override
  Future<bool> clearAllSavedAudios() => storageService.clearAllSavedAudios();

  @override
  Future<String> exportAllAudios() => storageService.exportAllAudios();
}
```

---

## Step 1.9: Fill Theme Domain & Data Layer

### `lib/features/theme/domain/repositories/theme_repository.dart`

```dart
abstract class ThemeRepository {
  Future<bool> getIsDarkMode();
  Future<void> setIsDarkMode(bool isDarkMode);
}
```

### `lib/features/theme/domain/usecases/get_theme.dart`

```dart
import '../repositories/theme_repository.dart';

class GetTheme {
  final ThemeRepository repository;
  GetTheme(this.repository);

  Future<bool> call() => repository.getIsDarkMode();
}
```

### `lib/features/theme/domain/usecases/toggle_theme.dart`

```dart
import '../repositories/theme_repository.dart';

class ToggleTheme {
  final ThemeRepository repository;
  ToggleTheme(this.repository);

  Future<void> call(bool isDarkMode) => repository.setIsDarkMode(isDarkMode);
}
```

### `lib/features/theme/data/datasources/theme_local_data_source.dart`

```dart
import 'package:shared_preferences/shared_preferences.dart';

abstract class ThemeLocalDataSource {
  Future<bool> getIsDarkMode();
  Future<void> setIsDarkMode(bool isDarkMode);
}

class ThemeLocalDataSourceImpl implements ThemeLocalDataSource {
  static const String _key = 'isDarkMode';

  @override
  Future<bool> getIsDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  @override
  Future<void> setIsDarkMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, isDarkMode);
  }
}
```

### `lib/features/theme/data/models/theme_model.dart`

```dart
class ThemeModel {
  final bool isDarkMode;
  const ThemeModel({required this.isDarkMode});
}
```

### `lib/features/theme/data/repositories/theme_repository_impl.dart`

```dart
import '../datasources/theme_local_data_source.dart';
import '../../domain/repositories/theme_repository.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  final ThemeLocalDataSource dataSource;
  ThemeRepositoryImpl({required this.dataSource});

  @override
  Future<bool> getIsDarkMode() => dataSource.getIsDarkMode();

  @override
  Future<void> setIsDarkMode(bool isDarkMode) =>
      dataSource.setIsDarkMode(isDarkMode);
}
```

---

## Step 1.10: Consistent Theme Fonts

Update `lib/core/themes/theme_config.dart` — use one font family for both themes:

```dart
// CHANGE: Dark theme uses 'Manrope', light uses 'Inter'
// FIX: Use 'Inter' for both (or add both as custom fonts)

// In getDarkTheme(), replace all 'Manrope' with 'Inter'
```

---

## Phase 1 Definition of Done

- [ ] All 28 empty files are populated with working code
- [ ] Directory typos fixed (`presentaiont` → `presentation`, `domin` → `domain`)
- [ ] All imports updated to reflect renamed directories
- [ ] `get_it` added and service locator configured
- [ ] Error classes defined (exceptions + failures)
- [ ] File utilities implemented
- [ ] Theme uses consistent font family
- [ ] `flutter pub get` succeeds
- [ ] `flutter analyze` reports no errors
- [ ] App launches and navigates without crashes
