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

import 'package:sonify/services/model_downloader_service.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // Core Services
  sl.registerLazySingleton(() => AudioStorageService());
  sl.registerLazySingleton(() => TtsEngine());
  sl.registerLazySingleton(() => ModelDownloaderService());

  sl.registerLazySingleton<TTSService>(
    () => TTSService(
      engine: sl(),
      storage: sl(),
    ),
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
