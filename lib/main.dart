import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audioplayers/audioplayers.dart' as ap;
import 'app/splash_screen.dart';
import 'core/themes/theme_config.dart';
import 'features/theme/presentation/providers/theme_provider.dart';
import 'l10n/app_localizations.dart';

void main() async {
  // Initialize Flutter binding
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Background Audio Service
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.sonify.channel.audio',
    androidNotificationChannelName: 'Sonify TTS Playback',
    androidNotificationOngoing: true,
    androidNotificationIcon: 'mipmap/ic_launcher',
    notificationColor: const Color(0xFF1A3684),
  );

  // Configure audioplayers globally to mix with other audio (avoids focus preemption)
  ap.AudioPlayer.global.setAudioContext(ap.AudioContext(
    iOS: ap.AudioContextIOS(
      category: ap.AVAudioSessionCategory.ambient,
      options: const {},
    ),
    android: const ap.AudioContextAndroid(
      audioFocus: ap.AndroidAudioFocus.none,
      contentType: ap.AndroidContentType.music,
      usageType: ap.AndroidUsageType.media,
    ),
  ));

  // Hide system UI overlays like the splash screen
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );

  // Run the app
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Sonify',
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: themeProvider.locale,
          theme: getLightTheme(),
          darkTheme: getDarkTheme(),
          themeMode:
              themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const SplashScreen(),
        );
      },
    );
  }
}
