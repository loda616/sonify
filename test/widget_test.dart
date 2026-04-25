import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sonify/main.dart';
import 'package:sonify/features/theme/presentation/providers/theme_provider.dart';

void main() {
  testWidgets('App renders splash screen on startup', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => ThemeProvider())],
        child: const MyApp(),
      ),
    );

    // Verify that the splash screen or app title is present.
    expect(find.text('Sonify'), findsWidgets);
  });

  testWidgets('Theme toggle works correctly', (WidgetTester tester) async {
    final themeProvider = ThemeProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider.value(value: themeProvider)],
        child: MaterialApp(
          home: Scaffold(
            body: Consumer<ThemeProvider>(
              builder: (context, provider, child) {
                return Text(provider.isDarkMode ? 'Dark' : 'Light');
              },
            ),
          ),
        ),
      ),
    );

    // Verify initial state
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsNothing);

    // Toggle theme
    themeProvider.toggleTheme();
    await tester.pump();

    // Verify toggled state
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('Light'), findsNothing);
  });
}
