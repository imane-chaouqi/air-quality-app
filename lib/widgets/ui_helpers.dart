import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Vagues en bas de l'écran. À mettre dans un Stack.
class WaveBackground extends StatelessWidget {
  final double height;
  const WaveBackground({super.key, this.height = 110});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: height,
      child: IgnorePointer(child: CustomPaint(painter: _WavePainter())),
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path wave(double base, double amp, double phase) {
      final p = Path()..moveTo(0, size.height)..lineTo(0, base);
      for (double x = 0; x <= size.width; x += 4) {
        p.lineTo(x, base + amp * math.sin((x / size.width) * 2 * math.pi + phase));
      }
      p.lineTo(size.width, size.height);
      p.close();
      return p;
    }

    canvas.drawPath(wave(size.height * 0.45, 12, 0),
        Paint()..color = AppColors.primaryTeal.withOpacity(0.18));
    canvas.drawPath(wave(size.height * 0.62, 10, 1.6),
        Paint()..color = AppColors.primaryTeal.withOpacity(0.28));
    canvas.drawPath(wave(size.height * 0.80, 8, 3.2),
        Paint()..color = AppColors.primaryDark.withOpacity(0.35));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// Apparition douce (fondu + glissement), avec un délai selon l'index.
class FadeSlideIn extends StatelessWidget {
  final int index;
  final Widget child;
  const FadeSlideIn({super.key, required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + index * 120),
      curve: Curves.easeOutCubic,
      builder: (context, v, c) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 24 * (1 - v)), child: c),
      ),
      child: child,
    );
  }
}

/// Carte blanche arrondie, utilisée partout pour garder le même style.
BoxDecoration appCardDecoration({double radius = 24}) => BoxDecoration(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withOpacity(0.9), width: 1.5),
      boxShadow: [
        BoxShadow(
          color: AppColors.primaryDark.withOpacity(0.06),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );