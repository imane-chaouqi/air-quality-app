import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Bouton Premium réutilisable (même API qu'avant) : principal turquoise,
/// secondaire vitré à liseré champagne, retour visuel à l'appui, chargement.
class CustomButton extends StatefulWidget {
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
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final enabled = widget.onPressed != null && !widget.loading;
    final fg = widget.secondary ? p.text : AppColors.navy;
    final radius = BorderRadius.circular(14);

    final content = widget.loading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        : Row(mainAxisSize: MainAxisSize.min, children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, size: 20, color: widget.secondary ? p.champagneText : fg),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
          ]);

    final decoration = widget.secondary
        ? BoxDecoration(
            borderRadius: radius,
            color: p.glassBase.withAlpha(p.dark ? 110 : 170),
            border: Border.all(color: AppColors.champagne.withAlpha(190), width: 1.2),
          )
        : BoxDecoration(
            borderRadius: radius,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF69D0BA), Color(0xFF4DB39D)],
            ),
            border: Border.all(color: AppColors.champagne.withAlpha(160)),
            boxShadow: [
              BoxShadow(
                color: AppColors.turquoise.withAlpha(p.dark ? 70 : 90),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          );

    return AnimatedScale(
      scale: _down ? 0.97 : 1,
      duration: const Duration(milliseconds: 120),
      child: AnimatedOpacity(
        opacity: widget.onPressed == null ? 0.5 : 1,
        duration: const Duration(milliseconds: 200),
        child: DecoratedBox(
          decoration: decoration,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: radius,
              onTap: enabled ? widget.onPressed : null,
              onHighlightChanged: (v) => setState(() => _down = v),
              child: Container(
                height: 48,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
