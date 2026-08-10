import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Brand color overrides set by the Admin Panel (Theme & Colors tab).
/// Any field left null falls back to the app's built-in default palette.
class DynamicThemeColors {
  final Color? primary;
  final Color? secondary;
  final Color? tertiary;
  final Color? background;

  const DynamicThemeColors({this.primary, this.secondary, this.tertiary, this.background});
}

Color? _parseHex(String? hex) {
  if (hex == null || hex.isEmpty) return null;
  final cleaned = hex.replaceAll('#', '');
  final value = int.tryParse(cleaned, radix: 16);
  if (value == null) return null;
  return Color(0xFF000000 | value);
}

final dynamicThemeProvider = FutureProvider<DynamicThemeColors>((ref) async {
  try {
    final doc = await FirebaseFirestore.instance.collection('theme').doc('config').get();
    if (!doc.exists) return const DynamicThemeColors();
    final d = doc.data()!;
    return DynamicThemeColors(
      primary: _parseHex(d['primaryColor']),
      secondary: _parseHex(d['secondaryColor']),
      tertiary: _parseHex(d['accentColor']),
      background: _parseHex(d['backgroundColor']),
    );
  } catch (_) {
    return const DynamicThemeColors();
  }
});
