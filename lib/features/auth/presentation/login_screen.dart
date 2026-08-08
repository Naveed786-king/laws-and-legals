import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_shell.dart';

/// Optional login. Google and Email sign-in are visibly present but
/// disabled until Firebase Auth is configured in Settings - tapping them
/// explains why instead of silently doing nothing. Skip always works and
/// unlocks the full app (Home, Categories, Bookmarks, Search, Offline
/// Reading, Notifications-after-permission) with no account required.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _openApp(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AppShell()),
    );
  }

  void _notConfigured(BuildContext context, String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$provider sign-in isn\'t configured yet. Use Skip for now.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.balance, size: 64, color: AppColors.primaryRed),
              const SizedBox(height: 16),
              Text('Welcome', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Sign in to sync bookmarks across devices later, or continue without an account.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                icon: const Icon(Icons.g_mobiledata, size: 28),
                label: const Text('Continue with Google'),
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                onPressed: () => _notConfigured(context, 'Google'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.email_outlined),
                label: const Text('Continue with Email'),
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                onPressed: () => _notConfigured(context, 'Email'),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => _openApp(context),
                child: const Text('Skip for now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
