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
  String get navTextToSpeech => 'Text to Speech';

  @override
  String get navSavedAudio => 'Saved Audio';

  @override
  String get navSettings => 'Settings';

  @override
  String get splashLoading => 'Loading...';

  @override
  String get splashPreparing => 'Preparing voice model...';

  @override
  String get splashReady => 'Ready!';

  @override
  String get splashFailed => 'Failed to load. Tap to retry.';

  @override
  String get ttsTitle => 'Convert Text to Speech';

  @override
  String get ttsHint => 'Enter text to convert to speech...';

  @override
  String get ttsVoiceLabel => 'Voice';

  @override
  String get ttsPreviewTooltip => 'Preview voice';

  @override
  String get ttsPreviewDefault => 'Hello, this is how I sound.';

  @override
  String get ttsSpeedLabel => 'Speed:';

  @override
  String get ttsGenerating => 'Generating...';

  @override
  String get ttsGeneratingLong => 'Generating... this may take a few seconds';

  @override
  String get ttsGenerateButton => 'Generate Speech';

  @override
  String get ttsVoiceLoadError => 'Could not load voices for this model.';

  @override
  String get ttsEmptyTextError => 'Please enter some text';

  @override
  String ttsTextTooLong(int maxLength) {
    return 'Text is too long (max $maxLength characters)';
  }

  @override
  String get ttsEngineError =>
      'Voice engine failed to load. Try restarting the app.';

  @override
  String get ttsGenerationError =>
      'Could not generate speech. Try shorter text.';

  @override
  String get ttsPreviewFailed => 'Preview failed';

  @override
  String get ttsAudioSaved => 'Audio saved successfully';

  @override
  String get ttsAudioSaveFailed => 'Failed to save audio';

  @override
  String get ttsHistory => 'History';

  @override
  String get ttsHistoryTitle => 'Recent Texts';

  @override
  String get ttsHistoryEmpty => 'No recent texts yet';

  @override
  String get ttsHistoryDeleteItem => 'Remove from history';

  @override
  String ttsBatchGenerate(int count) {
    return 'Generate $count Parts';
  }

  @override
  String ttsBatchProgress(int current, int total) {
    return 'Generating part $current of $total...';
  }

  @override
  String ttsBatchComplete(int count) {
    return 'All $count parts saved!';
  }

  @override
  String ttsWordCount(int count, String duration) {
    return '$count words ~ $duration';
  }

  @override
  String get playerSave => 'Save';

  @override
  String get savedTitle => 'Saved Audio Files';

  @override
  String get savedRefresh => 'Refresh';

  @override
  String get savedEmpty => 'No saved audio files yet';

  @override
  String get savedEmptyHint =>
      'Convert text to speech and save audio files to see them here';

  @override
  String get savedDeleteConfirmTitle => 'Confirm Delete';

  @override
  String savedDeleteConfirmMessage(String title) {
    return 'Are you sure you want to delete \"$title\"?';
  }

  @override
  String get savedDeleted => 'Audio deleted successfully';

  @override
  String get savedDeleteFailed => 'Failed to delete audio';

  @override
  String get savedLoadError => 'Error loading audio files';

  @override
  String get savedDeleteError => 'Error deleting audio';

  @override
  String get savedFileNotFound => 'Audio file no longer available';

  @override
  String get savedShare => 'Share';

  @override
  String get savedShareFailed => 'Failed to share audio';

  @override
  String get savedCopied => 'Text copied to clipboard';

  @override
  String get savedSearchHint => 'Search saved audio...';

  @override
  String get savedSortByDate => 'Sort by date';

  @override
  String get savedSortByName => 'Sort by name';

  @override
  String get savedRename => 'Rename';

  @override
  String get savedRenameTitle => 'Rename Audio';

  @override
  String get savedRenameHint => 'Enter new name';

  @override
  String get savedRenamed => 'Audio renamed';

  @override
  String get savedRenameFailed => 'Failed to rename audio';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsDarkMode => 'Dark Mode';

  @override
  String get settingsDarkTheme => 'Using dark theme';

  @override
  String get settingsLightTheme => 'Using light theme';

  @override
  String get settingsVoice => 'Voice Settings';

  @override
  String get settingsDefaultSpeed => 'Default Speed';

  @override
  String get settingsTtsEngine => 'TTS Engine';

  @override
  String get settingsDiscoverVoices => 'Select Voice';

  @override
  String get settingsDiscoverVoicesDesc =>
      'Choose from built-in Arabic & English voices';

  @override
  String get settingsStorage => 'Storage';

  @override
  String get settingsClearAll => 'Clear All Saved Audio';

  @override
  String get settingsClearAllDesc => 'Delete all saved audio files';

  @override
  String get settingsClearConfirmTitle => 'Confirm Deletion';

  @override
  String get settingsClearConfirmMessage =>
      'Are you sure you want to delete all saved audio files? This action cannot be undone.';

  @override
  String get settingsClearSuccess => 'All audio files have been deleted';

  @override
  String get settingsExportAll => 'Export All Audio Files';

  @override
  String get settingsExportAllDesc =>
      'Export all audio files to device storage';

  @override
  String settingsExportSuccess(String path) {
    return 'Audio files exported to: $path';
  }

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsAboutDescription =>
      'Sonify transforms text into natural-sounding speech using Piper AI, powered by sherpa-onnx. Fully offline — no internet required.';

  @override
  String get settingsAboutTechInfo =>
      'Voice Model: Piper Lessac (English)\nEngine: sherpa-onnx\nLicense: Apache 2.0 / MIT';

  @override
  String get modelManagerTitle => 'Manage Voices';

  @override
  String modelDownloaded(String name) {
    return '$name downloaded successfully!';
  }

  @override
  String modelActivated(String name) {
    return '$name activated!';
  }

  @override
  String get modelDeleteTitle => 'Delete Voice';

  @override
  String modelDeleteConfirm(String name) {
    return 'Are you sure you want to delete $name? This frees up storage space.';
  }

  @override
  String get modelDeleted => 'Voice deleted.';

  @override
  String get modelDeleteFailed => 'Failed to delete voice. Please try again.';

  @override
  String get modelActivateFailed =>
      'Failed to activate voice. Please try again.';

  @override
  String get modelCannotDeleteDefault =>
      'Cannot delete the default bundled model.';

  @override
  String modelQuality(String quality) {
    return 'Quality: $quality';
  }

  @override
  String get modelInstalling => 'Installing voice...';

  @override
  String modelDownloading(String percent) {
    return 'Downloading... $percent%';
  }

  @override
  String get modelActive => 'Active';

  @override
  String get modelBundled => 'Bundled';

  @override
  String get modelCancelDownload => 'Cancel download';

  @override
  String get modelDeleteVoice => 'Delete voice';

  @override
  String get modelDownloadVoice => 'Download voice';

  @override
  String get modelAnotherInProgress => 'Another download in progress';

  @override
  String get modelDownloadCancelled => 'Download cancelled.';

  @override
  String get modelInfoTitle => 'About Voice Models';

  @override
  String get modelInfoDescription =>
      'Sonify uses Piper TTS — free, open-source voices that work 100% offline. All models are from the sherpa-onnx project.';

  @override
  String get modelBrowseAll => 'Browse All Voices';

  @override
  String get modelImportCustom => 'Import Custom Model';

  @override
  String get modelImportTitle => 'Import Voice Model';

  @override
  String get modelImportUrlLabel => 'Model URL (.tar.bz2)';

  @override
  String get modelImportUrlHint => 'https://github.com/.../model.tar.bz2';

  @override
  String get modelImportNameLabel => 'Model Name';

  @override
  String get modelImportNameHint => 'e.g. My Custom Voice';

  @override
  String get modelImportLanguageLabel => 'Language';

  @override
  String get modelImportLanguageHint => 'e.g. English';

  @override
  String get modelImportInvalid => 'Please provide a valid .tar.bz2 URL';

  @override
  String get modelImportNameRequired => 'Please enter a model name';

  @override
  String modelStorageSize(String size) {
    return '$size MB';
  }

  @override
  String modelStorageTotal(int count, String size) {
    return '$count voices · $size MB total';
  }

  @override
  String get modelImportSuccess => 'Custom model added! Tap to download.';

  @override
  String get modelCustomRemoved => 'Custom model removed.';

  @override
  String get modelSwipeDelete => 'Swipe to delete';

  @override
  String get modelInstallFailed => 'Failed to install voice. Please try again.';

  @override
  String get modelInstallCorrupted =>
      'Installation failed — model files are missing or corrupted. Please try again.';

  @override
  String get modelImportUrlUnreachable =>
      'Could not reach the URL. Check the link and your connection.';

  @override
  String get genericCancel => 'Cancel';

  @override
  String get genericDelete => 'Delete';

  @override
  String get genericDeleteAll => 'Delete All';

  @override
  String get genericSave => 'Save';

  @override
  String get genericError => 'Something went wrong. Please try again.';

  @override
  String genericErrorPrefix(String message) {
    return 'Error: $message';
  }
}
