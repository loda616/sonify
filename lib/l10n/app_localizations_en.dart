// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Sonify';

  @override
  String get splashTagline => 'Transform Text to Speech';

  @override
  String get homeTabTts => 'Text to Speech';

  @override
  String get homeTabSaved => 'Saved Audio';

  @override
  String get homeTabSettings => 'Settings';

  @override
  String get ttsTitle => 'Convert Text to Speech';

  @override
  String get ttsHintText => 'Enter text to convert to speech...';

  @override
  String get ttsVoiceLabel => 'Voice';

  @override
  String get ttsPitchLabel => 'Pitch:';

  @override
  String get ttsSpeedLabel => 'Speed:';

  @override
  String get ttsGenerateBtn => 'Generate Speech';

  @override
  String get ttsGeneratingBtn => 'Generating...';

  @override
  String get ttsEnterTextError => 'Please enter some text';

  @override
  String ttsError(String error) {
    return 'Error generating speech: $error';
  }

  @override
  String get ttsTitleTruncated => 'Title truncated to 30 characters for saving';

  @override
  String get ttsSaveSuccess => 'Audio saved successfully';

  @override
  String get ttsSaveFailed => 'Failed to save audio';

  @override
  String get voiceDefault => 'Default';

  @override
  String get audioSaveBtn => 'Save';

  @override
  String get savedTitle => 'Saved Audio Files';

  @override
  String get savedRefreshTooltip => 'Refresh';

  @override
  String get savedEmptyTitle => 'No saved audio files yet';

  @override
  String get savedEmptySubtitle =>
      'Convert text to speech and save audio files to see them here';

  @override
  String savedCreatedPrefix(String date) {
    return 'Created: $date';
  }

  @override
  String get savedDeleteConfirmTitle => 'Confirm Delete';

  @override
  String savedDeleteConfirmContent(String title) {
    return 'Are you sure you want to delete \"$title\"?';
  }

  @override
  String get savedCancelBtn => 'Cancel';

  @override
  String get savedDeleteBtn => 'Delete';

  @override
  String get savedDeleteSuccess => 'Audio deleted successfully';

  @override
  String get savedDeleteFailed => 'Failed to delete audio';

  @override
  String savedLoadError(String error) {
    return 'Error loading audio files: $error';
  }

  @override
  String savedDeleteError(String error) {
    return 'Error deleting audio: $error';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearanceSection => 'Appearance';

  @override
  String get settingsDarkModeLabel => 'Dark Mode';

  @override
  String get settingsDarkModeOn => 'Using dark theme';

  @override
  String get settingsDarkModeOff => 'Using light theme';

  @override
  String get settingsStorageSection => 'Storage';

  @override
  String get settingsClearAllTitle => 'Clear All Saved Audio';

  @override
  String get settingsClearAllSubtitle => 'Delete all saved audio files';

  @override
  String get settingsClearConfirmTitle => 'Confirm Deletion';

  @override
  String get settingsClearConfirmContent =>
      'Are you sure you want to delete all saved audio files? This action cannot be undone.';

  @override
  String get settingsClearCancelBtn => 'Cancel';

  @override
  String get settingsClearDeleteAllBtn => 'Delete All';

  @override
  String get settingsClearSuccess => 'All audio files have been deleted';

  @override
  String get settingsExportTitle => 'Export All Audio Files';

  @override
  String get settingsExportSubtitle =>
      'Export all audio files to device storage';

  @override
  String settingsExportSuccess(String path) {
    return 'Audio files exported to: $path';
  }

  @override
  String settingsError(String error) {
    return 'Error: $error';
  }

  @override
  String get settingsAboutSection => 'About';

  @override
  String get settingsAboutAppName => 'Sonify';

  @override
  String settingsAboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get settingsAboutDescription =>
      'Sonify is a text-to-speech application that uses a local AI model to generate high-quality speech from text.';

  @override
  String get settingsLanguageLabel => 'Language';
}
