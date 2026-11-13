import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Bouton réutilisable (même API qu'avant) : principal en dégradé
/// océan → turquoise, secondaire vitré à contour bleu, état de chargement.
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.secondary = false,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool secondary;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final enabled = onPressed != null && !loading;
    final fg = secondary ? p.text : Colors.white;
    final radius = BorderRadius.circular(26);

    final content = loading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        : Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: secondary ? p.accentText : fg),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: fg,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    letterSpacing: 0.1),
              ),
            ),
          ]);

    final decoration = secondary
        ? BoxDecoration(
            borderRadius: radius,
            color: p.glassBase.withAlpha(p.dark ? 120 : 190),
            border: Border.all(
                color: p.dark ? AppColors.aqua : AppColors.ocean, width: 1.4),
          )
        : BoxDecoration(
            borderRadius: radius,
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [AppColors.ocean, AppColors.teal],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.teal.withAlpha(p.dark ? 70 : 80),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          );

    return Opacity(
      opacity: onPressed == null ? 0.5 : 1,
      child: DecoratedBox(
        decoration: decoration,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            onTap: enabled ? onPressed : null,
            child: Container(
              height: 52,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
