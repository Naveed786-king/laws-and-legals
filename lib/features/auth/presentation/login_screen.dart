import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_shell.dart';
import '../application/auth_service.dart';

/// Optional login: Email/Password and Google sign-in are both real and
/// functional. Skip always works and unlocks the full app - no account
/// required. Signing in matters for future cloud-synced bookmarks.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showEmailForm = false;
  bool _isSignUp = false;
  bool _loading = false;
  String? _error;

  void _openApp() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AppShell()),
    );
  }

  Future<void> _submitEmail() async {
    setState(() { _loading = true; _error = null; });
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final error = _isSignUp
        ? await AuthService.signUpWithEmail(email, password)
        : await AuthService.signInWithEmail(email, password);
    if (!mounted) return;
    setState(() { _loading = false; _error = error; });
    if (error == null) _openApp();
  }

  Future<void> _submitGoogle() async {
    setState(() { _loading = true; _error = null; });
    final error = await AuthService.signInWithGoogle();
    if (!mounted) return;
    setState(() { _loading = false; _error = error; });
    if (error == null) _openApp();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
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
              if (_showEmailForm) ...[
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, style: const TextStyle(color: AppColors.error)),
                ],
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _loading ? null : _submitEmail,
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  child: _loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(_isSignUp ? 'Create Account' : 'Sign In'),
                ),
                TextButton(
                  onPressed: () => setState(() => _isSignUp = !_isSignUp),
                  child: Text(_isSignUp ? 'Already have an account? Sign In' : 'New here? Create an account'),
                ),
                const SizedBox(height: 8),
              ] else ...[
                OutlinedButton.icon(
                  icon: const FaIcon(FontAwesomeIcons.google, size: 20, color: Color(0xFF4285F4)),
                  label: const Text('Continue with Google'),
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  onPressed: _loading ? null : _submitGoogle,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const FaIcon(FontAwesomeIcons.solidEnvelope, size: 18),
                  label: const Text('Continue with Email'),
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  onPressed: () => setState(() => _showEmailForm = true),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, style: const TextStyle(color: AppColors.error), textAlign: TextAlign.center),
                ],
              ],
              const SizedBox(height: 24),
              TextButton(
                onPressed: _openApp,
                child: const Text('Skip for now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
