import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/presentation/login_screen.dart';

/// Splash Manager: reads logo, background color, duration, and tagline text
/// from Firestore (splash/config), written by the Admin Panel. Falls back
/// to sensible defaults if nothing has been configured yet or if offline.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashConfig {
  final String logoUrl;
  final Color backgroundColor;
  final int durationMs;
  final String text;

  const _SplashConfig({
    required this.logoUrl,
    required this.backgroundColor,
    required this.durationMs,
    required this.text,
  });

  static const defaults = _SplashConfig(
    logoUrl: '',
    backgroundColor: AppColors.primaryRed,
    durationMs: 1800,
    text: 'Hindi Legal News',
  );
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  _SplashConfig _config = _SplashConfig.defaults;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    _loadConfigAndProceed();
  }

  Future<void> _loadConfigAndProceed() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('splash').doc('config').get();
      if (doc.exists) {
        final d = doc.data()!;
        setState(() {
          _config = _SplashConfig(
            logoUrl: d['logoUrl'] ?? '',
            backgroundColor: _parseColor(d['backgroundColor']) ?? AppColors.primaryRed,
            durationMs: (d['durationMs'] ?? 1800) as int,
            text: d['text'] ?? 'Hindi Legal News',
          );
        });
      }
    } catch (_) {
      // Offline or not configured yet - use defaults, still proceed.
    }
    await Future.delayed(Duration(milliseconds: _config.durationMs));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Color? _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final cleaned = hex.replaceAll('#', '');
    final value = int.tryParse(cleaned, radix: 16);
    if (value == null) return null;
    return Color(0xFF000000 | value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _config.backgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_config.logoUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: CachedNetworkImage(
                      imageUrl: _config.logoUrl,
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                      errorWidget: (c, _, __) => _defaultLogo(),
                    ),
                  )
                else
                  _defaultLogo(),
                const SizedBox(height: 20),
                const Text(
                  'Laws And Legals',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  _config.text,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _defaultLogo() {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Icon(Icons.balance, color: _config.backgroundColor, size: 48),
    );
  }
}
