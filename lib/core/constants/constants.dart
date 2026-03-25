class AppConstants {
  // App Info
  static const String appName = 'Sonify';
  static const String appVersion = '1.0.0';

  // TTS Defaults
  static const double defaultSpeed = 1.0;
  static const String defaultVoice = 'Default';
  static const int defaultSpeakerId = 0;

  // Speed limits (pitch removed — Piper doesn't support pitch control)
  static const double minSpeed = 0.5;
  static const double maxSpeed = 3.0;

  // Text limits
  static const int maxTextLength = 5000;
  static const int maxTextLengthForInstantGeneration = 200;

  // Text History
  static const int maxTextHistory = 10;

  // Storage Keys
  static const String storageKeyTheme = 'theme_mode';
  static const String storageKeyDefaultVoice = 'default_voice';
  static const String storageKeyDefaultSpeed = 'default_speed';
  static const String storageKeyDefaultModelId = 'default_model_id';
  static const String storageKeyTextHistory = 'text_history';

  // Info
  static const String engineVersion = 'sherpa-onnx';
}