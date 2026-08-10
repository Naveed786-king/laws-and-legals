import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/theme/dynamic_theme_provider.dart';
import 'features/notifications/application/notification_service.dart';
import 'features/splash/presentation/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  try {
    await Firebase.initializeApp();
    await NotificationService.init();
  } catch (_) {
    // Firebase not reachable (e.g. no network on first launch) - the app
    // still works fully offline via Hive-cached/demo content.
  }
  runApp(const ProviderScope(child: LawsAndLegalsApp()));
}

class LawsAndLegalsApp extends ConsumerWidget {
  const LawsAndLegalsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeControllerProvider);
    final dynamicColorsAsync = ref.watch(dynamicThemeProvider);
    final dynamicColors = dynamicColorsAsync.valueOrNull;

    return MaterialApp(
      title: 'Laws And Legals',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(dynamicColors),
      darkTheme: AppTheme.dark(dynamicColors),
      themeMode: themeMode,
      home: const SplashScreen(),
    );
  }
}
