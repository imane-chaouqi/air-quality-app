import 'package:flutter/material.dart';

/// Carte d'une mesure : valeur, unité, couleur d'état et jauge optionnelle.
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
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), side: BorderSide(color: color, width: 1.5)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          ]),
          const SizedBox(height: 8),
          Text.rich(TextSpan(children: [
            TextSpan(text: value, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            TextSpan(text: ' $unit'),
          ])),
          if (ratio != null) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(value: ratio!.clamp(0.0, 1.0), color: color, minHeight: 6),
          ],
          if (statusText != null) ...[
            const SizedBox(height: 6),
            Text(statusText!, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          ],
        ]),
      ),
    );
  }
}
