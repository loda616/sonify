import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sonify/features/theme/presentation/providers/theme_provider.dart';
import 'package:sonify/app/splash_screen.dart';
import 'package:sonify/main.dart';

void main() {
  testWidgets('App renders splash screen', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const MyApp(),
      ),
    );
    await tester.pump();

    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
