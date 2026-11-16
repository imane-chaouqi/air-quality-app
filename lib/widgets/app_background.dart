import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Fond statique : dégradé ciel → brume (ou bleus profonds en mode sombre),
/// halo discret en haut à droite et deux vagues turquoise en bas, comme sur
/// la référence. Aucune animation.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [p.bgTop, p.bgBottom],
        ),
      ),
      child: Stack(children: [
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(painter: _BackdropPainter(p.dark)),
          ),
        ),
        Positioned.fill(child: child),
      ]),
    );
  }
}

class _BackdropPainter extends CustomPainter {
  _BackdropPainter(this.dark);
  final bool dark;

  Path _wave(Size s, double base, double amp, double shift) {
    return Path()
      ..moveTo(0, s.height)
      ..lineTo(0, base)
      ..cubicTo(s.width * 0.25, base - amp, s.width * 0.55, base + amp,
          s.width, base - amp * 0.4 + shift)
      ..lineTo(s.width, s.height)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final glowColor = dark ? AppColors.aqua : Colors.white;
    final center = Offset(size.width * 0.95, 0);
    final radius = size.width * 0.75;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(colors: [
          glowColor.withAlpha(dark ? 46 : 170),
          glowColor.withAlpha(0),
        ]).createShader(Rect.fromCircle(center: center, radius: radius)),
    );

    canvas.drawPath(
      _wave(size, size.height * 0.92, 26, 10),
      Paint()..color = AppColors.turquoise.withAlpha(dark ? 36 : 44),
    );
    canvas.drawPath(
      _wave(size, size.height * 0.95, 18, -6),
      Paint()..color = AppColors.teal.withAlpha(dark ? 40 : 38),
    );
  }

  @override
  bool shouldRepaint(covariant _BackdropPainter old) => old.dark != dark;
}
