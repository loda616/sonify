class AppConstants {
  // App Info
  static const String appName = 'Sonify';
  static const String appVersion = '1.0.0';

  // Default Values
  static const double defaultPitch = 1.0;
  static const double defaultSpeed = 1.0;
  static const String defaultVoice = 'Default';

  // Pitch and Speed limits
  static const double minPitch = 0.5;
  static const double maxPitch = 2.0;
  static const double minSpeed = 0.5;
  static const double maxSpeed = 2.0;

  // Storage Keys
  static const String storageKeyTheme = 'theme_mode';
  static const String storageKeyDefaultVoice = 'default_voice';
  static const String storageKeyDefaultPitch = 'default_pitch';
  static const String storageKeyDefaultSpeed = 'default_speed';

  // Model Info
  static const String modelVersion = '1.0.0';
  static const String modelName = 'tts_model.tflite';
}