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
  String get navTextToSpeech => 'تحويل النص';

  @override
  String get navSavedAudio => 'الصوتيات المحفوظة';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get splashLoading => 'جارٍ التحميل...';

  @override
  String get splashPreparing => 'جارٍ تحضير نموذج الصوت...';

  @override
  String get splashReady => 'جاهز!';

  @override
  String get splashFailed => 'فشل التحميل. انقر لإعادة المحاولة.';

  @override
  String get ttsTitle => 'تحويل النص إلى كلام';

  @override
  String get ttsHint => 'أدخل النص لتحويله إلى كلام...';

  @override
  String get ttsVoiceLabel => 'الصوت';

  @override
  String get ttsPreviewTooltip => 'معاينة الصوت';

  @override
  String get ttsPreviewDefault => 'مرحباً، هكذا يبدو صوتي.';

  @override
  String get ttsSpeedLabel => 'السرعة:';

  @override
  String get ttsGenerating => 'جارٍ التوليد...';

  @override
  String get ttsGeneratingLong => 'جارٍ التوليد... قد يستغرق بضع ثوانٍ';

  @override
  String get ttsGenerateButton => 'توليد الكلام';

  @override
  String get ttsVoiceLoadError => 'تعذر تحميل الأصوات لهذا النموذج.';

  @override
  String get ttsEmptyTextError => 'يرجى إدخال نص';

  @override
  String ttsTextTooLong(int maxLength) {
    return 'النص طويل جداً (الحد الأقصى $maxLength حرف)';
  }

  @override
  String get ttsEngineError =>
      'فشل تحميل محرك الصوت. حاول إعادة تشغيل التطبيق.';

  @override
  String get ttsGenerationError => 'تعذر توليد الكلام. جرّب نصاً أقصر.';

  @override
  String get ttsPreviewFailed => 'فشلت المعاينة';

  @override
  String get ttsAudioSaved => 'تم حفظ الصوت بنجاح';

  @override
  String get ttsAudioSaveFailed => 'فشل حفظ الصوت';

  @override
  String get ttsHistory => 'السجل';

  @override
  String get ttsHistoryTitle => 'النصوص الأخيرة';

  @override
  String get ttsHistoryEmpty => 'لا توجد نصوص سابقة بعد';

  @override
  String get ttsHistoryDeleteItem => 'إزالة من السجل';

  @override
  String ttsBatchGenerate(int count) {
    return 'توليد $count أجزاء';
  }

  @override
  String ttsBatchProgress(int current, int total) {
    return 'جارٍ توليد الجزء $current من $total...';
  }

  @override
  String ttsBatchComplete(int count) {
    return 'تم حفظ جميع الأجزاء ($count) بنجاح!';
  }

  @override
  String ttsWordCount(int count, String duration) {
    return '$count كلمة ~ $duration';
  }

  @override
  String get playerSave => 'حفظ';

  @override
  String get savedTitle => 'الملفات الصوتية المحفوظة';

  @override
  String get savedRefresh => 'تحديث';

  @override
  String get savedEmpty => 'لا توجد ملفات صوتية محفوظة بعد';

  @override
  String get savedEmptyHint =>
      'حوّل النص إلى كلام واحفظ الملفات الصوتية لتظهر هنا';

  @override
  String get savedDeleteConfirmTitle => 'تأكيد الحذف';

  @override
  String savedDeleteConfirmMessage(String title) {
    return 'هل أنت متأكد من حذف \"$title\"؟';
  }

  @override
  String get savedDeleted => 'تم حذف الصوت بنجاح';

  @override
  String get savedDeleteFailed => 'فشل حذف الصوت';

  @override
  String get savedLoadError => 'خطأ في تحميل الملفات الصوتية';

  @override
  String get savedDeleteError => 'خطأ في حذف الصوت';

  @override
  String get savedFileNotFound => 'الملف الصوتي لم يعد متاحاً';

  @override
  String get savedShare => 'مشاركة';

  @override
  String get savedShareFailed => 'فشلت مشاركة الصوت';

  @override
  String get savedCopied => 'تم نسخ النص';

  @override
  String get savedSearchHint => 'البحث في الصوتيات المحفوظة...';

  @override
  String get savedSortByDate => 'ترتيب حسب التاريخ';

  @override
  String get savedSortByName => 'ترتيب حسب الاسم';

  @override
  String get savedRename => 'إعادة تسمية';

  @override
  String get savedRenameTitle => 'إعادة تسمية الصوت';

  @override
  String get savedRenameHint => 'أدخل الاسم الجديد';

  @override
  String get savedRenamed => 'تمت إعادة التسمية';

  @override
  String get savedRenameFailed => 'فشلت إعادة التسمية';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsAppearance => 'المظهر';

  @override
  String get settingsDarkMode => 'الوضع الداكن';

  @override
  String get settingsDarkTheme => 'المظهر الداكن مفعّل';

  @override
  String get settingsLightTheme => 'المظهر الفاتح مفعّل';

  @override
  String get settingsVoice => 'إعدادات الصوت';

  @override
  String get settingsDefaultSpeed => 'السرعة الافتراضية';

  @override
  String get settingsTtsEngine => 'محرك تحويل النص';

  @override
  String get settingsDiscoverVoices => 'اختر الصوت';

  @override
  String get settingsDiscoverVoicesDesc =>
      'اختر من الأصوات العربية والإنجليزية المدمجة';

  @override
  String get settingsStorage => 'التخزين';

  @override
  String get settingsClearAll => 'حذف جميع الصوتيات';

  @override
  String get settingsClearAllDesc => 'حذف جميع الملفات الصوتية المحفوظة';

  @override
  String get settingsClearConfirmTitle => 'تأكيد الحذف';

  @override
  String get settingsClearConfirmMessage =>
      'هل أنت متأكد من حذف جميع الملفات الصوتية المحفوظة؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get settingsClearSuccess => 'تم حذف جميع الملفات الصوتية';

  @override
  String get settingsExportAll => 'تصدير جميع الصوتيات';

  @override
  String get settingsExportAllDesc =>
      'تصدير جميع الملفات الصوتية إلى ذاكرة الجهاز';

  @override
  String settingsExportSuccess(String path) {
    return 'تم تصدير الملفات الصوتية إلى: $path';
  }

  @override
  String get settingsAbout => 'حول التطبيق';

  @override
  String get settingsAboutDescription =>
      'Sonify يحوّل النص إلى كلام طبيعي باستخدام Piper AI، مدعوم بـ sherpa-onnx. يعمل بالكامل بدون إنترنت.';

  @override
  String get settingsAboutTechInfo =>
      'نموذج الصوت: Piper Lessac (إنجليزي)\nالمحرك: sherpa-onnx\nالرخصة: Apache 2.0 / MIT';

  @override
  String get modelManagerTitle => 'إدارة الأصوات';

  @override
  String modelDownloaded(String name) {
    return 'تم تحميل $name بنجاح!';
  }

  @override
  String modelActivated(String name) {
    return 'تم تفعيل $name!';
  }

  @override
  String get modelDeleteTitle => 'حذف الصوت';

  @override
  String modelDeleteConfirm(String name) {
    return 'هل أنت متأكد من حذف $name؟ سيتم تحرير مساحة التخزين.';
  }

  @override
  String get modelDeleted => 'تم حذف الصوت.';

  @override
  String get modelDeleteFailed => 'فشل حذف الصوت. يرجى المحاولة مرة أخرى.';

  @override
  String get modelActivateFailed => 'فشل تفعيل الصوت. يرجى المحاولة مرة أخرى.';

  @override
  String get modelCannotDeleteDefault =>
      'لا يمكن حذف النموذج الافتراضي المدمج.';

  @override
  String modelQuality(String quality) {
    return 'الجودة: $quality';
  }

  @override
  String get modelInstalling => 'جارٍ تثبيت الصوت...';

  @override
  String modelDownloading(String percent) {
    return 'جارٍ التحميل... $percent٪';
  }

  @override
  String get modelActive => 'مفعّل';

  @override
  String get modelBundled => 'مدمج';

  @override
  String get modelCancelDownload => 'إلغاء التحميل';

  @override
  String get modelDeleteVoice => 'حذف الصوت';

  @override
  String get modelDownloadVoice => 'تحميل الصوت';

  @override
  String get modelAnotherInProgress => 'يوجد تحميل آخر قيد التنفيذ';

  @override
  String get modelDownloadCancelled => 'تم إلغاء التحميل.';

  @override
  String get modelInfoTitle => 'حول نماذج الأصوات';

  @override
  String get modelInfoDescription =>
      'Sonify يستخدم Piper TTS — أصوات مجانية ومفتوحة المصدر تعمل بدون إنترنت. جميع النماذج من مشروع sherpa-onnx.';

  @override
  String get modelBrowseAll => 'تصفح جميع الأصوات';

  @override
  String get modelImportCustom => 'استيراد نموذج مخصص';

  @override
  String get modelImportTitle => 'استيراد نموذج صوتي';

  @override
  String get modelImportUrlLabel => 'رابط النموذج (.tar.bz2)';

  @override
  String get modelImportUrlHint => 'https://github.com/.../model.tar.bz2';

  @override
  String get modelImportNameLabel => 'اسم النموذج';

  @override
  String get modelImportNameHint => 'مثال: صوتي المخصص';

  @override
  String get modelImportLanguageLabel => 'اللغة';

  @override
  String get modelImportLanguageHint => 'مثال: العربية';

  @override
  String get modelImportInvalid => 'يرجى تقديم رابط .tar.bz2 صالح';

  @override
  String get modelImportNameRequired => 'يرجى إدخال اسم النموذج';

  @override
  String modelStorageSize(String size) {
    return '$size ميغابايت';
  }

  @override
  String modelStorageTotal(int count, String size) {
    return '$count أصوات · $size ميغابايت إجمالي';
  }

  @override
  String get modelImportSuccess => 'تمت إضافة النموذج المخصص! انقر للتحميل.';

  @override
  String get modelCustomRemoved => 'تم حذف النموذج المخصص.';

  @override
  String get modelSwipeDelete => 'اسحب للحذف';

  @override
  String get modelInstallFailed => 'فشل تثبيت الصوت. يرجى المحاولة مرة أخرى.';

  @override
  String get modelInstallCorrupted =>
      'فشل التثبيت — ملفات النموذج مفقودة أو تالفة. يرجى المحاولة مرة أخرى.';

  @override
  String get modelImportUrlUnreachable =>
      'تعذر الوصول إلى الرابط. تحقق من الرابط واتصالك بالإنترنت.';

  @override
  String get genericCancel => 'إلغاء';

  @override
  String get genericDelete => 'حذف';

  @override
  String get genericDeleteAll => 'حذف الكل';

  @override
  String get genericSave => 'حفظ';

  @override
  String get genericError => 'حدث خطأ ما. يرجى المحاولة مرة أخرى.';

  @override
  String genericErrorPrefix(String message) {
    return 'خطأ: $message';
  }
}
