import 'package:flutter/material.dart';

/// A simple, recognizable Google "G" mark drawn with basic shapes (four
/// quarter-arcs in Google's brand colors), used only for the standard
/// "Sign in with Google" button - the conventional, expected way to
/// indicate that sign-in option. Not an imported/copied asset file.
class GoogleGIcon extends StatelessWidget {
  const GoogleGIcon({super.key, this.size = 20});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleGPainter()),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = size.width * 0.22;
    final rect = Rect.fromCircle(radius: radius - strokeWidth / 2, center: center);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Four arcs approximating the Google "G" ring, colored per the
    // standard brand palette (blue/green/yellow/red), plus a short blue
    // crossbar to complete the "G" shape - a simplified, original
    // rendering, not a traced/copied logo file.
    const twoPi = 6.283185307179586;
    paint.color = const Color(0xFF4285F4); // blue
    canvas.drawArc(rect, -0.35, twoPi * 0.28, false, paint);
    paint.color = const Color(0xFF34A853); // green
    canvas.drawArc(rect, 1.25, twoPi * 0.22, false, paint);
    paint.color = const Color(0xFFFBBC05); // yellow
    canvas.drawArc(rect, 2.6, twoPi * 0.22, false, paint);
    paint.color = const Color(0xFFEA4335); // red
    canvas.drawArc(rect, 3.9, twoPi * 0.22, false, paint);

    // Crossbar of the "G"
    final barPaint = Paint()..color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(center.dx, center.dy - strokeWidth / 2, radius - strokeWidth / 2, strokeWidth),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
