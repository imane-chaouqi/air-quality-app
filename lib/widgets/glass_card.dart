import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Intensité de l'effet vitré.
enum GlassStrength { strong, medium, subtle }

/// Carte « glassmorphism » : transparence, flou léger, bordure fine, reflet doux.
/// La lisibilité prime : l'opacité reste élevée pour le texte.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.radius = 20,
    this.strength = GlassStrength.medium,
    this.tint,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final GlassStrength strength;

  /// Teinte optionnelle (ex. couleur de l'évaluation).
  final Color? tint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final int alpha;
    final double blur;
    switch (strength) {
      case GlassStrength.strong:
        alpha = p.dark ? 160 : 215;
        blur = 18;
        break;
      case GlassStrength.medium:
        alpha = p.dark ? 130 : 180;
        blur = 12;
        break;
      case GlassStrength.subtle:
        alpha = p.dark ? 95 : 130;
        blur = 0;
        break;
    }
    var base = p.glassBase;
    if (tint != null) {
      base = Color.alphaBlend(tint!.withAlpha(p.dark ? 40 : 30), base);
    }
    final radiusGeo = BorderRadius.circular(radius);

    Widget content = Padding(padding: padding, child: child);
    if (onTap != null) {
      content = Material(
        type: MaterialType.transparency,
        child: InkWell(borderRadius: radiusGeo, onTap: onTap, child: content),
      );
    }

    Widget glass = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radiusGeo,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            base.withAlpha((alpha + 30).clamp(0, 255)),
            base.withAlpha(alpha),
          ],
        ),
        border: Border.all(color: p.glassBorder),
      ),
      child: content,
    );
    if (blur > 0) {
      glass = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: glass,
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radiusGeo,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(p.dark ? 60 : 16),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(borderRadius: radiusGeo, child: glass),
    );
  }
}
