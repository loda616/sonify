import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Sonify'**
  String get appTitle;

  /// No description provided for @navTextToSpeech.
  ///
  /// In en, this message translates to:
  /// **'Text to Speech'**
  String get navTextToSpeech;

  /// No description provided for @navSavedAudio.
  ///
  /// In en, this message translates to:
  /// **'Saved Audio'**
  String get navSavedAudio;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @splashLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get splashLoading;

  /// No description provided for @splashPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing voice model...'**
  String get splashPreparing;

  /// No description provided for @splashReady.
  ///
  /// In en, this message translates to:
  /// **'Ready!'**
  String get splashReady;

  /// No description provided for @splashFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load. Tap to retry.'**
  String get splashFailed;

  /// No description provided for @ttsTitle.
  ///
  /// In en, this message translates to:
  /// **'Convert Text to Speech'**
  String get ttsTitle;

  /// No description provided for @ttsHint.
  ///
  /// In en, this message translates to:
  /// **'Enter text to convert to speech...'**
  String get ttsHint;

  /// No description provided for @ttsVoiceLabel.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get ttsVoiceLabel;

  /// No description provided for @ttsPreviewTooltip.
  ///
  /// In en, this message translates to:
  /// **'Preview voice'**
  String get ttsPreviewTooltip;

  /// No description provided for @ttsPreviewDefault.
  ///
  /// In en, this message translates to:
  /// **'Hello, this is how I sound.'**
  String get ttsPreviewDefault;

  /// No description provided for @ttsSpeedLabel.
  ///
  /// In en, this message translates to:
  /// **'Speed:'**
  String get ttsSpeedLabel;

  /// No description provided for @ttsGenerating.
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get ttsGenerating;

  /// No description provided for @ttsGeneratingLong.
  ///
  /// In en, this message translates to:
  /// **'Generating... this may take a few seconds'**
  String get ttsGeneratingLong;

  /// No description provided for @ttsGenerateButton.
  ///
  /// In en, this message translates to:
  /// **'Generate Speech'**
  String get ttsGenerateButton;

  /// No description provided for @ttsVoiceLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load voices for this model.'**
  String get ttsVoiceLoadError;

  /// No description provided for @ttsEmptyTextError.
  ///
  /// In en, this message translates to:
  /// **'Please enter some text'**
  String get ttsEmptyTextError;

  /// No description provided for @ttsTextTooLong.
  ///
  /// In en, this message translates to:
  /// **'Text is too long (max {maxLength} characters)'**
  String ttsTextTooLong(int maxLength);

  /// No description provided for @ttsEngineError.
  ///
  /// In en, this message translates to:
  /// **'Voice engine failed to load. Try restarting the app.'**
  String get ttsEngineError;

  /// No description provided for @ttsGenerationError.
  ///
  /// In en, this message translates to:
  /// **'Could not generate speech. Try shorter text.'**
  String get ttsGenerationError;

  /// No description provided for @ttsPreviewFailed.
  ///
  /// In en, this message translates to:
  /// **'Preview failed'**
  String get ttsPreviewFailed;

  /// No description provided for @ttsAudioSaved.
  ///
  /// In en, this message translates to:
  /// **'Audio saved successfully'**
  String get ttsAudioSaved;

  /// No description provided for @ttsAudioSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save audio'**
  String get ttsAudioSaveFailed;

  /// No description provided for @ttsHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get ttsHistory;

  /// No description provided for @ttsHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Texts'**
  String get ttsHistoryTitle;

  /// No description provided for @ttsHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No recent texts yet'**
  String get ttsHistoryEmpty;

  /// No description provided for @ttsHistoryDeleteItem.
  ///
  /// In en, this message translates to:
  /// **'Remove from history'**
  String get ttsHistoryDeleteItem;

  /// No description provided for @ttsBatchGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate {count} Parts'**
  String ttsBatchGenerate(int count);

  /// No description provided for @ttsBatchProgress.
  ///
  /// In en, this message translates to:
  /// **'Generating part {current} of {total}...'**
  String ttsBatchProgress(int current, int total);

  /// No description provided for @ttsBatchComplete.
  ///
  /// In en, this message translates to:
  /// **'All {count} parts saved!'**
  String ttsBatchComplete(int count);

  /// No description provided for @ttsWordCount.
  ///
  /// In en, this message translates to:
  /// **'{count} words ~ {duration}'**
  String ttsWordCount(int count, String duration);

  /// No description provided for @playerSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get playerSave;

  /// No description provided for @savedTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved Audio Files'**
  String get savedTitle;

  /// No description provided for @savedRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get savedRefresh;

  /// No description provided for @savedEmpty.
  ///
  /// In en, this message translates to:
  /// **'No saved audio files yet'**
  String get savedEmpty;

  /// No description provided for @savedEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Convert text to speech and save audio files to see them here'**
  String get savedEmptyHint;

  /// No description provided for @savedDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get savedDeleteConfirmTitle;

  /// No description provided for @savedDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"?'**
  String savedDeleteConfirmMessage(String title);

  /// No description provided for @savedDeleted.
  ///
  /// In en, this message translates to:
  /// **'Audio deleted successfully'**
  String get savedDeleted;

  /// No description provided for @savedDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete audio'**
  String get savedDeleteFailed;

  /// No description provided for @savedLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading audio files'**
  String get savedLoadError;

  /// No description provided for @savedDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Error deleting audio'**
  String get savedDeleteError;

  /// No description provided for @savedFileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Audio file no longer available'**
  String get savedFileNotFound;

  /// No description provided for @savedShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get savedShare;

  /// No description provided for @savedShareFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to share audio'**
  String get savedShareFailed;

  /// No description provided for @savedCopied.
  ///
  /// In en, this message translates to:
  /// **'Text copied to clipboard'**
  String get savedCopied;

  /// No description provided for @savedSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search saved audio...'**
  String get savedSearchHint;

  /// No description provided for @savedSortByDate.
  ///
  /// In en, this message translates to:
  /// **'Sort by date'**
  String get savedSortByDate;

  /// No description provided for @savedSortByName.
  ///
  /// In en, this message translates to:
  /// **'Sort by name'**
  String get savedSortByName;

  /// No description provided for @savedRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get savedRename;

  /// No description provided for @savedRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename Audio'**
  String get savedRenameTitle;

  /// No description provided for @savedRenameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter new name'**
  String get savedRenameHint;

  /// No description provided for @savedRenamed.
  ///
  /// In en, this message translates to:
  /// **'Audio renamed'**
  String get savedRenamed;

  /// No description provided for @savedRenameFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to rename audio'**
  String get savedRenameFailed;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsDarkTheme.
  ///
  /// In en, this message translates to:
  /// **'Using dark theme'**
  String get settingsDarkTheme;

  /// No description provided for @settingsLightTheme.
  ///
  /// In en, this message translates to:
  /// **'Using light theme'**
  String get settingsLightTheme;

  /// No description provided for @settingsVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice Settings'**
  String get settingsVoice;

  /// No description provided for @settingsDefaultSpeed.
  ///
  /// In en, this message translates to:
  /// **'Default Speed'**
  String get settingsDefaultSpeed;

  /// No description provided for @settingsTtsEngine.
  ///
  /// In en, this message translates to:
  /// **'TTS Engine'**
  String get settingsTtsEngine;

  /// No description provided for @settingsDiscoverVoices.
  ///
  /// In en, this message translates to:
  /// **'Select Voice'**
  String get settingsDiscoverVoices;

  /// No description provided for @settingsDiscoverVoicesDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose from built-in Arabic & English voices'**
  String get settingsDiscoverVoicesDesc;

  /// No description provided for @settingsStorage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get settingsStorage;

  /// No description provided for @settingsClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All Saved Audio'**
  String get settingsClearAll;

  /// No description provided for @settingsClearAllDesc.
  ///
  /// In en, this message translates to:
  /// **'Delete all saved audio files'**
  String get settingsClearAllDesc;

  /// No description provided for @settingsClearConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get settingsClearConfirmTitle;

  /// No description provided for @settingsClearConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all saved audio files? This action cannot be undone.'**
  String get settingsClearConfirmMessage;

  /// No description provided for @settingsClearSuccess.
  ///
  /// In en, this message translates to:
  /// **'All audio files have been deleted'**
  String get settingsClearSuccess;

  /// No description provided for @settingsExportAll.
  ///
  /// In en, this message translates to:
  /// **'Export All Audio Files'**
  String get settingsExportAll;

  /// No description provided for @settingsExportAllDesc.
  ///
  /// In en, this message translates to:
  /// **'Export all audio files to device storage'**
  String get settingsExportAllDesc;

  /// No description provided for @settingsExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Audio files exported to: {path}'**
  String settingsExportSuccess(String path);

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsAboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Sonify transforms text into natural-sounding speech using Piper AI, powered by sherpa-onnx. Fully offline — no internet required.'**
  String get settingsAboutDescription;

  /// No description provided for @settingsAboutTechInfo.
  ///
  /// In en, this message translates to:
  /// **'Voice Model: Piper Lessac (English)\nEngine: sherpa-onnx\nLicense: Apache 2.0 / MIT'**
  String get settingsAboutTechInfo;

  /// No description provided for @modelManagerTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Voices'**
  String get modelManagerTitle;

  /// No description provided for @modelDownloaded.
  ///
  /// In en, this message translates to:
  /// **'{name} downloaded successfully!'**
  String modelDownloaded(String name);

  /// No description provided for @modelActivated.
  ///
  /// In en, this message translates to:
  /// **'{name} activated!'**
  String modelActivated(String name);

  /// No description provided for @modelDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Voice'**
  String get modelDeleteTitle;

  /// No description provided for @modelDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}? This frees up storage space.'**
  String modelDeleteConfirm(String name);

  /// No description provided for @modelDeleted.
  ///
  /// In en, this message translates to:
  /// **'Voice deleted.'**
  String get modelDeleted;

  /// No description provided for @modelDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete voice. Please try again.'**
  String get modelDeleteFailed;

  /// No description provided for @modelActivateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to activate voice. Please try again.'**
  String get modelActivateFailed;

  /// No description provided for @modelCannotDeleteDefault.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete the default bundled model.'**
  String get modelCannotDeleteDefault;

  /// No description provided for @modelQuality.
  ///
  /// In en, this message translates to:
  /// **'Quality: {quality}'**
  String modelQuality(String quality);

  /// No description provided for @modelInstalling.
  ///
  /// In en, this message translates to:
  /// **'Installing voice...'**
  String get modelInstalling;

  /// No description provided for @modelDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading... {percent}%'**
  String modelDownloading(String percent);

  /// No description provided for @modelActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get modelActive;

  /// No description provided for @modelBundled.
  ///
  /// In en, this message translates to:
  /// **'Bundled'**
  String get modelBundled;

  /// No description provided for @modelCancelDownload.
  ///
  /// In en, this message translates to:
  /// **'Cancel download'**
  String get modelCancelDownload;

  /// No description provided for @modelDeleteVoice.
  ///
  /// In en, this message translates to:
  /// **'Delete voice'**
  String get modelDeleteVoice;

  /// No description provided for @modelDownloadVoice.
  ///
  /// In en, this message translates to:
  /// **'Download voice'**
  String get modelDownloadVoice;

  /// No description provided for @modelAnotherInProgress.
  ///
  /// In en, this message translates to:
  /// **'Another download in progress'**
  String get modelAnotherInProgress;

  /// No description provided for @modelDownloadCancelled.
  ///
  /// In en, this message translates to:
  /// **'Download cancelled.'**
  String get modelDownloadCancelled;

  /// No description provided for @modelInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'About Voice Models'**
  String get modelInfoTitle;

  /// No description provided for @modelInfoDescription.
  ///
  /// In en, this message translates to:
  /// **'Sonify uses Piper TTS — free, open-source voices that work 100% offline. All models are from the sherpa-onnx project.'**
  String get modelInfoDescription;

  /// No description provided for @modelBrowseAll.
  ///
  /// In en, this message translates to:
  /// **'Browse All Voices'**
  String get modelBrowseAll;

  /// No description provided for @modelImportCustom.
  ///
  /// In en, this message translates to:
  /// **'Import Custom Model'**
  String get modelImportCustom;

  /// No description provided for @modelImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Voice Model'**
  String get modelImportTitle;

  /// No description provided for @modelImportUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Model URL (.tar.bz2)'**
  String get modelImportUrlLabel;

  /// No description provided for @modelImportUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://github.com/.../model.tar.bz2'**
  String get modelImportUrlHint;

  /// No description provided for @modelImportNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Model Name'**
  String get modelImportNameLabel;

  /// No description provided for @modelImportNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. My Custom Voice'**
  String get modelImportNameHint;

  /// No description provided for @modelImportLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get modelImportLanguageLabel;

  /// No description provided for @modelImportLanguageHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. English'**
  String get modelImportLanguageHint;

  /// No description provided for @modelImportInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please provide a valid .tar.bz2 URL'**
  String get modelImportInvalid;

  /// No description provided for @modelImportNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a model name'**
  String get modelImportNameRequired;

  /// No description provided for @modelStorageSize.
  ///
  /// In en, this message translates to:
  /// **'{size} MB'**
  String modelStorageSize(String size);

  /// No description provided for @modelStorageTotal.
  ///
  /// In en, this message translates to:
  /// **'{count} voices · {size} MB total'**
  String modelStorageTotal(int count, String size);

  /// No description provided for @modelImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Custom model added! Tap to download.'**
  String get modelImportSuccess;

  /// No description provided for @modelCustomRemoved.
  ///
  /// In en, this message translates to:
  /// **'Custom model removed.'**
  String get modelCustomRemoved;

  /// No description provided for @modelSwipeDelete.
  ///
  /// In en, this message translates to:
  /// **'Swipe to delete'**
  String get modelSwipeDelete;

  /// No description provided for @modelInstallFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to install voice. Please try again.'**
  String get modelInstallFailed;

  /// No description provided for @modelInstallCorrupted.
  ///
  /// In en, this message translates to:
  /// **'Installation failed — model files are missing or corrupted. Please try again.'**
  String get modelInstallCorrupted;

  /// No description provided for @modelImportUrlUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the URL. Check the link and your connection.'**
  String get modelImportUrlUnreachable;

  /// No description provided for @genericCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get genericCancel;

  /// No description provided for @genericDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get genericDelete;

  /// No description provided for @genericDeleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get genericDeleteAll;

  /// No description provided for @genericSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get genericSave;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get genericError;

  /// No description provided for @genericErrorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String genericErrorPrefix(String message);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
