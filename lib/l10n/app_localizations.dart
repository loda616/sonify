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

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'Sonify'**
  String get appTitle;

  /// Tagline shown on the splash screen
  ///
  /// In en, this message translates to:
  /// **'Transform Text to Speech'**
  String get splashTagline;

  /// Bottom navigation tab label for Text to Speech
  ///
  /// In en, this message translates to:
  /// **'Text to Speech'**
  String get homeTabTts;

  /// Bottom navigation tab label for Saved Audio
  ///
  /// In en, this message translates to:
  /// **'Saved Audio'**
  String get homeTabSaved;

  /// Bottom navigation tab label for Settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get homeTabSettings;

  /// Title heading on the Text to Speech screen
  ///
  /// In en, this message translates to:
  /// **'Convert Text to Speech'**
  String get ttsTitle;

  /// Hint text in the text input field
  ///
  /// In en, this message translates to:
  /// **'Enter text to convert to speech...'**
  String get ttsHintText;

  /// Label for the voice selection dropdown
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get ttsVoiceLabel;

  /// Label for the pitch slider
  ///
  /// In en, this message translates to:
  /// **'Pitch:'**
  String get ttsPitchLabel;

  /// Label for the speed slider
  ///
  /// In en, this message translates to:
  /// **'Speed:'**
  String get ttsSpeedLabel;

  /// Button text to generate speech
  ///
  /// In en, this message translates to:
  /// **'Generate Speech'**
  String get ttsGenerateBtn;

  /// Button text while speech is being generated
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get ttsGeneratingBtn;

  /// Error shown when user tries to generate without entering text
  ///
  /// In en, this message translates to:
  /// **'Please enter some text'**
  String get ttsEnterTextError;

  /// Error message shown when TTS generation fails
  ///
  /// In en, this message translates to:
  /// **'Error generating speech: {error}'**
  String ttsError(String error);

  /// Notice shown when save title was truncated
  ///
  /// In en, this message translates to:
  /// **'Title truncated to 30 characters for saving'**
  String get ttsTitleTruncated;

  /// Success message after saving audio
  ///
  /// In en, this message translates to:
  /// **'Audio saved successfully'**
  String get ttsSaveSuccess;

  /// Error message when saving audio fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save audio'**
  String get ttsSaveFailed;

  /// Default voice option in the voice selector
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get voiceDefault;

  /// Button label to save the generated audio
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get audioSaveBtn;

  /// Title heading on the Saved Audio screen
  ///
  /// In en, this message translates to:
  /// **'Saved Audio Files'**
  String get savedTitle;

  /// Tooltip for the refresh button
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get savedRefreshTooltip;

  /// Title shown when no saved audio files exist
  ///
  /// In en, this message translates to:
  /// **'No saved audio files yet'**
  String get savedEmptyTitle;

  /// Subtitle shown when no saved audio files exist
  ///
  /// In en, this message translates to:
  /// **'Convert text to speech and save audio files to see them here'**
  String get savedEmptySubtitle;

  /// Prefix before the creation date of a saved audio file
  ///
  /// In en, this message translates to:
  /// **'Created: {date}'**
  String savedCreatedPrefix(String date);

  /// Title of the delete confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get savedDeleteConfirmTitle;

  /// Content of the delete confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"?'**
  String savedDeleteConfirmContent(String title);

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get savedCancelBtn;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get savedDeleteBtn;

  /// Success message after deleting audio
  ///
  /// In en, this message translates to:
  /// **'Audio deleted successfully'**
  String get savedDeleteSuccess;

  /// Error message when deleting audio fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete audio'**
  String get savedDeleteFailed;

  /// Error message when loading saved audio files fails
  ///
  /// In en, this message translates to:
  /// **'Error loading audio files: {error}'**
  String savedLoadError(String error);

  /// Error message when deleting an audio file fails
  ///
  /// In en, this message translates to:
  /// **'Error deleting audio: {error}'**
  String savedDeleteError(String error);

  /// Title heading on the Settings screen
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Section title for appearance settings
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearanceSection;

  /// Label for the dark mode toggle
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsDarkModeLabel;

  /// Subtitle when dark mode is on
  ///
  /// In en, this message translates to:
  /// **'Using dark theme'**
  String get settingsDarkModeOn;

  /// Subtitle when dark mode is off
  ///
  /// In en, this message translates to:
  /// **'Using light theme'**
  String get settingsDarkModeOff;

  /// Section title for storage settings
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get settingsStorageSection;

  /// Title for the clear all audio option
  ///
  /// In en, this message translates to:
  /// **'Clear All Saved Audio'**
  String get settingsClearAllTitle;

  /// Subtitle for the clear all audio option
  ///
  /// In en, this message translates to:
  /// **'Delete all saved audio files'**
  String get settingsClearAllSubtitle;

  /// Title of the clear all confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get settingsClearConfirmTitle;

  /// Content of the clear all confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all saved audio files? This action cannot be undone.'**
  String get settingsClearConfirmContent;

  /// Cancel button in the clear all dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsClearCancelBtn;

  /// Confirm button in the clear all dialog
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get settingsClearDeleteAllBtn;

  /// Success message after clearing all audio files
  ///
  /// In en, this message translates to:
  /// **'All audio files have been deleted'**
  String get settingsClearSuccess;

  /// Title for the export option
  ///
  /// In en, this message translates to:
  /// **'Export All Audio Files'**
  String get settingsExportTitle;

  /// Subtitle for the export option
  ///
  /// In en, this message translates to:
  /// **'Export all audio files to device storage'**
  String get settingsExportSubtitle;

  /// Success message after exporting audio files
  ///
  /// In en, this message translates to:
  /// **'Audio files exported to: {path}'**
  String settingsExportSuccess(String path);

  /// Generic error message format in settings
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String settingsError(String error);

  /// Section title for about information
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAboutSection;

  /// Application name in the About section
  ///
  /// In en, this message translates to:
  /// **'Sonify'**
  String get settingsAboutAppName;

  /// Version text shown in the About section
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String settingsAboutVersion(String version);

  /// Description text in the About dialog
  ///
  /// In en, this message translates to:
  /// **'Sonify is a text-to-speech application that uses a local AI model to generate high-quality speech from text.'**
  String get settingsAboutDescription;

  /// Label for the language selection dropdown
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageLabel;
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
