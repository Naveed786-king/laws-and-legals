import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/splash/presentation/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  // Firebase.initializeApp() is intentionally NOT called here yet - it
  // activates automatically once Settings > Firebase Config is completed
  // via Configure Everything, per the "no live connection until configured"
  // project rule.
  runApp(const ProviderScope(child: LawsAndLegalsApp()));
}

class LawsAndLegalsApp extends ConsumerWidget {
  const LawsAndLegalsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeControllerProvider);
    return MaterialApp(
      title: 'Laws And Legals',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: const SplashScreen(),
    );
  }
}
