import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/theme_controller.dart';

/// Bouton rond vitré (retour, thème…).
class GlassIconButton extends StatelessWidget {
  const GlassIconButton(
      {super.key, required this.icon, required this.onTap, this.tooltip});
  final Widget icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: p.glassBase.withAlpha(p.dark ? 140 : 200),
        shape: CircleBorder(side: BorderSide(color: p.glassBorder)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(width: 44, height: 44, child: Center(child: icon)),
        ),
      ),
    );
  }
}

/// Bascule clair / sombre (choix mémorisé).
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return GlassIconButton(
      tooltip: 'Changer de thème',
      onTap: () =>
          themeController.setMode(p.dark ? ThemeMode.light : ThemeMode.dark),
      icon: Icon(
        p.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
        size: 20,
        color: p.accentText,
      ),
    );
  }
}
