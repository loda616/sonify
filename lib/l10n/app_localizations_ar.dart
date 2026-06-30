// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Sonify';

  @override
  String get splashTagline => 'حوّل النص إلى كلام';

  @override
  String get homeTabTts => 'نص إلى كلام';

  @override
  String get homeTabSaved => 'الصوتيات المحفوظة';

  @override
  String get homeTabSettings => 'الإعدادات';

  @override
  String get ttsTitle => 'تحويل النص إلى كلام';

  @override
  String get ttsHintText => 'أدخل النص لتحويله إلى كلام...';

  @override
  String get ttsVoiceLabel => 'الصوت';

  @override
  String get ttsPitchLabel => 'درجة الصوت:';

  @override
  String get ttsSpeedLabel => 'السرعة:';

  @override
  String get ttsGenerateBtn => 'توليد الكلام';

  @override
  String get ttsGeneratingBtn => 'جارٍ التوليد...';

  @override
  String get ttsEnterTextError => 'يرجى إدخال نص';

  @override
  String ttsError(String error) {
    return 'خطأ في توليد الكلام: $error';
  }

  @override
  String get ttsTitleTruncated => 'تم اقتطاع العنوان إلى 30 حرفًا للحفظ';

  @override
  String get ttsSaveSuccess => 'تم حفظ الصوت بنجاح';

  @override
  String get ttsSaveFailed => 'فشل حفظ الصوت';

  @override
  String get voiceDefault => 'افتراضي';

  @override
  String get audioSaveBtn => 'حفظ';

  @override
  String get savedTitle => 'الملفات الصوتية المحفوظة';

  @override
  String get savedRefreshTooltip => 'تحديث';

  @override
  String get savedEmptyTitle => 'لا توجد ملفات صوتية محفوظة بعد';

  @override
  String get savedEmptySubtitle =>
      'حوّل النص إلى كلام واحفظ الملفات الصوتية لتظهر هنا';

  @override
  String savedCreatedPrefix(String date) {
    return 'تاريخ الإنشاء: $date';
  }

  @override
  String get savedDeleteConfirmTitle => 'تأكيد الحذف';

  @override
  String savedDeleteConfirmContent(String title) {
    return 'هل أنت متأكد من رغبتك في حذف \"$title\"؟';
  }

  @override
  String get savedCancelBtn => 'إلغاء';

  @override
  String get savedDeleteBtn => 'حذف';

  @override
  String get savedDeleteSuccess => 'تم حذف الصوت بنجاح';

  @override
  String get savedDeleteFailed => 'فشل حذف الصوت';

  @override
  String savedLoadError(String error) {
    return 'خطأ في تحميل الملفات الصوتية: $error';
  }

  @override
  String savedDeleteError(String error) {
    return 'خطأ في حذف الصوت: $error';
  }

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsAppearanceSection => 'المظهر';

  @override
  String get settingsDarkModeLabel => 'الوضع الليلي';

  @override
  String get settingsDarkModeOn => 'استخدام السمة الداكنة';

  @override
  String get settingsDarkModeOff => 'استخدام السمة الفاتحة';

  @override
  String get settingsStorageSection => 'التخزين';

  @override
  String get settingsClearAllTitle => 'مسح جميع الصوتيات المحفوظة';

  @override
  String get settingsClearAllSubtitle => 'حذف جميع الملفات الصوتية المحفوظة';

  @override
  String get settingsClearConfirmTitle => 'تأكيد الحذف';

  @override
  String get settingsClearConfirmContent =>
      'هل أنت متأكد من رغبتك في حذف جميع الملفات الصوتية المحفوظة؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get settingsClearCancelBtn => 'إلغاء';

  @override
  String get settingsClearDeleteAllBtn => 'حذف الكل';

  @override
  String get settingsClearSuccess => 'تم حذف جميع الملفات الصوتية';

  @override
  String get settingsExportTitle => 'تصدير جميع الملفات الصوتية';

  @override
  String get settingsExportSubtitle => 'تصدير جميع الملفات الصوتية إلى التخزين';

  @override
  String settingsExportSuccess(String path) {
    return 'تم تصدير الملفات الصوتية إلى: $path';
  }

  @override
  String settingsError(String error) {
    return 'خطأ: $error';
  }

  @override
  String get settingsAboutSection => 'حول';

  @override
  String get settingsAboutAppName => 'Sonify';

  @override
  String settingsAboutVersion(String version) {
    return 'الإصدار $version';
  }

  @override
  String get settingsAboutDescription =>
      'Sonify هو تطبيق لتحويل النص إلى كلام يستخدم نموذج ذكاء اصطناعي محلي لتوليد كلام عالي الجودة من النص.';

  @override
  String get settingsLanguageLabel => 'اللغة';
}
