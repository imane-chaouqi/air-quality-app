import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Intensité de l'effet vitré.
enum GlassStrength { strong, medium, subtle }

/// Carte « glassmorphism » : verre dépoli, flou léger, bordure fine, reflet
/// doux. La lisibilité prime : l'opacité reste élevée pour le texte.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 22,
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
        alpha = p.dark ? 175 : 210;
        blur = 16;
        break;
      case GlassStrength.medium:
        alpha = p.dark ? 145 : 175;
        blur = 12;
        break;
      case GlassStrength.subtle:
        alpha = p.dark ? 105 : 125;
        blur = 8;
        break;
    }
    var base = p.glassBase;
    if (tint != null) {
      base = Color.alphaBlend(tint!.withAlpha(p.dark ? 46 : 34), base);
    }
    final radiusGeo = BorderRadius.circular(radius);

    Widget content = Padding(padding: padding, child: child);
    if (onTap != null) {
      content = Material(
        type: MaterialType.transparency,
        child: InkWell(borderRadius: radiusGeo, onTap: onTap, child: content),
      );
    }

    final glass = BackdropFilter(
      filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: DecoratedBox(
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
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radiusGeo,
        boxShadow: [
          BoxShadow(
            color: p.shadow,
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(borderRadius: radiusGeo, child: glass),
    );
  }
}
