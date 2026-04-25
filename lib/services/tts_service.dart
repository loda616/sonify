import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sonify/core/models/audio_file.dart';
import 'package:sonify/core/models/remote_model.dart';
import 'package:sonify/core/constants/models_directory.dart';
import 'package:sonify/core/constants/constants.dart';
import 'package:sonify/services/tts_engine.dart';
import 'package:sonify/services/audio_storage_service.dart';

/// Facade that combines TTS generation and audio storage.
class TTSService extends ChangeNotifier {
  final TtsEngine engine;
  final AudioStorageService storage;

  RemoteModel _activeModel = ModelsDirectory.catalog.first;
  RemoteModel get activeModel => _activeModel;

  final Completer<void> _initCompleter = Completer<void>();

  /// Completes when the persisted default model has been loaded.
  Future<void> get initialized => _initCompleter.future;

  /// Prevents concurrent setActiveModel calls from corrupting state.
  Future<void>? _pendingModelSwitch;

  TTSService({required this.engine, required this.storage}) {
    _loadDefaultModel();
  }

  Future<void> _loadDefaultModel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modelId = prefs.getString(AppConstants.storageKeyDefaultModelId);
      if (modelId != null) {
        final model = ModelsDirectory.catalog.firstWhere(
          (m) => m.id == modelId,
          orElse: () => ModelsDirectory.catalog.first,
        );
        await setActiveModel(model);
      } else {
        await setActiveModel(ModelsDirectory.catalog.first);
      }
      if (!_initCompleter.isCompleted) _initCompleter.complete();
    } catch (e) {
      debugPrint('Failed to load default model: $e');
      // Complete with error so callers can handle it, but don't crash the app
      if (!_initCompleter.isCompleted) _initCompleter.completeError(e);
    }
  }

  Future<void> setActiveModel(RemoteModel model) async {
    // Wait for any pending model switch to finish first
    if (_pendingModelSwitch != null) {
      await _pendingModelSwitch;
    }

    final completer = Completer<void>();
    _pendingModelSwitch = completer.future;

    try {
      await engine.setModel(model.directoryName, isBundled: model.isBundled);

      _activeModel = model;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.storageKeyDefaultModelId, model.id);
      notifyListeners();
    } finally {
      completer.complete();
      _pendingModelSwitch = null;
    }
  }

  Future<String> generateSpeech(
    String text, {
    String voice = 'Default',
    double speed = 1.0,
  }) async {
    // Wait for default model to load; catch error from failed init
    try {
      await initialized;
    } catch (_) {
      // Init failed — try to proceed anyway with whatever state we have
      debugPrint('Default model init had failed, attempting generation anyway');
    }
    int speakerId = 0;
    if (voice != 'Default') {
      final match = RegExp(r'Speaker (\d+)').firstMatch(voice);
      if (match != null) {
        speakerId = (int.tryParse(match.group(1)!) ?? 1) - 1;
      }
    }
    // Clamp to valid range to prevent native library crash
    final maxSpeaker = max(0, engine.numSpeakers - 1);
    speakerId = speakerId.clamp(0, maxSpeaker);
    return engine.generateSpeech(text, speakerId: speakerId, speed: speed);
  }

  Future<List<String>> getAvailableVoices() async {
    // Ensure default model is loaded first; catch error from failed init
    try {
      await initialized;
    } catch (_) {
      debugPrint('Default model init had failed, attempting voice load anyway');
    }
    await engine.initialize();
    final count = engine.numSpeakers;
    if (count <= 1) return ['Default'];
    return ['Default', ...List.generate(count, (i) => 'Speaker ${i + 1}')];
  }

  Future<bool> saveAudio(String path, String title) =>
      storage.saveAudio(path, title);
  Future<List<AudioFile>> getSavedAudios() => storage.getSavedAudios();
  Future<bool> deleteAudio(String id) => storage.deleteAudio(id);
  Future<bool> renameAudio(String id, String newTitle) =>
      storage.renameAudio(id, newTitle);
  Future<bool> clearAllSavedAudios() => storage.clearAllSavedAudios();
  Future<String> exportAllAudios() => storage.exportAllAudios();
  Future<void> shareAudio(String path, String title) =>
      storage.shareAudio(path, title);
  Future<void> stop() async {}
}
