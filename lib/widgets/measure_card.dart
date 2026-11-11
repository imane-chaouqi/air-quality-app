import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'glass_card.dart';

/// Carte compacte d'une mesure : icône, nom, valeur, unité, jauge et état.
/// (Même API qu'avant : label, value, unit, icon, color, statusText, ratio.)
class MeasureCard extends StatelessWidget {
  const MeasureCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    this.statusText,
    this.ratio,
  });

  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final String? statusText;

  /// Position de la valeur par rapport à une référence (0 à 1+), optionnelle.
  final double? ratio;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return GlassCard(
      padding: const EdgeInsets.all(12),
      radius: 18,
      tint: color,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withAlpha(p.dark ? 55 : 45),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: p.text),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: p.muted)),
          ),
        ]),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(children: [
            TextSpan(text: value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
            TextSpan(text: ' $unit', style: TextStyle(fontSize: 12, color: p.muted)),
          ]),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (ratio != null) ...[
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(end: ratio!.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOut,
            builder: (context, v, _) => ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: v,
                minHeight: 5,
                color: color,
                backgroundColor: p.text.withAlpha(p.dark ? 30 : 20),
              ),
            ),
          ),
        ],
        if (statusText != null) ...[
          const SizedBox(height: 7),
          Row(children: [
            Icon(Icons.circle, size: 8, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(statusText!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: p.text)),
            ),
          ]),
        ],
      ]),
    );
  }
}
