import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:background_downloader/background_downloader.dart';
import 'l10n/app_localizations.dart';
import 'app/splash_screen.dart';
import 'core/themes/theme_config.dart';
import 'core/di/service_locator.dart';
import 'services/audio_storage_service.dart';
import 'services/model_downloader_service.dart';
import 'features/theme/presentation/providers/theme_provider.dart';
import 'features/settings/presentation/screens/model_manager_screen.dart';
import 'services/tts_service.dart';

/// Global navigator key for deep navigation from notifications
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );

  // Initialize dependency injection
  await initServiceLocator();

  // Initialize downloader (recovers in-flight downloads from previous session)
  await sl<ModelDownloaderService>().initialize();

  // Fire-and-forget temp file cleanup
  sl<AudioStorageService>().cleanupTempFiles();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: sl<TTSService>()),
        ChangeNotifierProvider.value(value: sl<ModelDownloaderService>()),
      ],
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Set up notification tap to open models screen
    FileDownloader().registerCallbacks(
      taskNotificationTapCallback: _onNotificationTap,
    );
  }

  void _onNotificationTap(Task task, NotificationType notificationType) {
    // Navigate to model manager when user taps download notification
    final navigator = navigatorKey.currentState;
    if (navigator != null) {
      navigator.push(
        MaterialPageRoute(builder: (_) => const ModelManagerScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'Sonify',
          debugShowCheckedModeBanner: false,
          theme: getLightTheme(),
          darkTheme: getDarkTheme(),
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SplashScreen(),
        );
      },
    );
  }
}
