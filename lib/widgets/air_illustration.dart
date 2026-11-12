import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Petit logo (carré arrondi en dégradé océan → turquoise).
class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = 36});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.3),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.ocean, AppColors.aqua],
        ),
      ),
      child: Icon(Icons.air, size: size * 0.6, color: Colors.white),
    );
  }
}

/// Illustration vectorielle statique : anneaux, flux d'air et particules.
class AirIllustration extends StatelessWidget {
  const AirIllustration({super.key, this.size = 130});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _AirPainter(AppPalette.of(context).dark)),
    );
  }
}

class _AirPainter extends CustomPainter {
  _AirPainter(this.dark);
  final bool dark;

  @override
  void paint(Canvas canvas, Size s) {
    final c = Offset(s.width / 2, s.height / 2);
    final r = s.width / 2;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    ring.color = AppColors.teal.withAlpha(dark ? 110 : 120);
    canvas.drawCircle(c, r * 0.98, ring);
    ring.color = AppColors.aqua.withAlpha(dark ? 90 : 110);
    canvas.drawCircle(c, r * 0.80, ring);

    canvas.drawCircle(
      c,
      r * 0.62,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.ocean, AppColors.navyDeep],
        ).createShader(Rect.fromCircle(center: c, radius: r * 0.62)),
    );

    final wave = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.2;
    const colors = [AppColors.turquoise, Colors.white, AppColors.aqua];
    for (var i = 0; i < 3; i++) {
      final y = c.dy - r * 0.22 + i * r * 0.22;
      final x0 = c.dx - r * 0.36;
      final w = r * 0.72;
      wave.color = colors[i].withAlpha(i == 1 ? 230 : 255);
      final path = Path()
        ..moveTo(x0, y)
        ..quadraticBezierTo(x0 + w * 0.25, y - r * 0.12, x0 + w * 0.5, y)
        ..quadraticBezierTo(x0 + w * 0.75, y + r * 0.12, x0 + w, y);
      canvas.drawPath(path, wave);
    }

    final dot = Paint();
    for (var i = 0; i < 7; i++) {
      final a = i * 2 * math.pi / 7 + 0.4;
      final d = r * (0.88 + (i % 3) * 0.04);
      dot.color = (i.isEven ? AppColors.turquoise : AppColors.leaf).withAlpha(200);
      canvas.drawCircle(
          c + Offset(math.cos(a) * d, math.sin(a) * d), 2.2 + (i % 3), dot);
    }
  }

  @override
  bool shouldRepaint(covariant _AirPainter old) => old.dark != dark;
}
