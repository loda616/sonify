import 'package:flutter/foundation.dart';

import '../core/models/remote_model.dart';
import '../core/constants/models_directory.dart';

class ModelDownloaderService extends ChangeNotifier {
  bool _initialized = false;

  final Set<String> _bundledModelIds = {};

  List<RemoteModel> get allModels => ModelsDirectory.catalog;

  bool get isLoadingModels => !_initialized;

  bool isDownloaded(String modelId) => _bundledModelIds.contains(modelId);

  Future<void> initialize() async {
    if (_initialized) return;

    for (var model in ModelsDirectory.catalog) {
      if (model.isBundled) {
        _bundledModelIds.add(model.id);
      }
    }

    _initialized = true;
    notifyListeners();
  }
}

class DownloadException implements Exception {
  final String message;
  const DownloadException(this.message);
  @override
  String toString() => message;
}
