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
  const TtsInitializationException(super.message)
      : super(code: 'TTS_INIT_FAILED');
}

/// Thrown when speech generation fails
class TtsGenerationException extends SonifyException {
  const TtsGenerationException(super.message)
      : super(code: 'TTS_GENERATION_FAILED');
}

/// Thrown when file operations fail
class StorageException extends SonifyException {
  const StorageException(super.message)
      : super(code: 'STORAGE_ERROR');
}

/// Thrown when an audio file is not found
class AudioNotFoundException extends SonifyException {
  const AudioNotFoundException(super.message)
      : super(code: 'AUDIO_NOT_FOUND');
}

/// Thrown when model files are missing or corrupted
class ModelNotFoundException extends SonifyException {
  const ModelNotFoundException(super.message)
      : super(code: 'MODEL_NOT_FOUND');
}
