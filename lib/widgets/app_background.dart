import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Fond dégradé discret avec deux halos décoratifs (turquoise / champagne).
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});
  final Widget child;

  Widget _glow(Color c, double size, int alpha) => IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [c.withAlpha(alpha), c.withAlpha(0)]),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [p.bgTop, p.bgBottom],
        ),
      ),
      child: Stack(children: [
        Positioned(top: -90, right: -70, child: _glow(AppColors.turquoise, 260, p.dark ? 60 : 70)),
        Positioned(bottom: -110, left: -90, child: _glow(AppColors.champagne, 290, p.dark ? 38 : 60)),
        Positioned.fill(child: child),
      ]),
    );
  }
}
