import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'glass_card.dart';

/// Repères d'une jauge à zones (valeurs en µg/m³) : limite de la zone « bon »,
/// de la zone « modéré » et de la zone « mauvais ». Au-delà : « très mauvais ».
class GaugeThresholds {
  const GaugeThresholds(this.good, this.moderate, this.poor);
  final double good;
  final double moderate;
  final double poor;
}

/// Carte compacte d'une mesure : icône, nom, valeur, unité, jauge et état.
///
/// API historique conservée (label, value, unit, icon, color, statusText,
/// ratio). Nouveauté optionnelle : [thresholds] + [numericValue] remplacent la
/// jauge linéaire par une barre à quatre zones avec repère de position.
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
    this.thresholds,
    this.numericValue,
  });

  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final String? statusText;

  /// Position de la valeur par rapport à une référence (0 à 1+), optionnelle.
  final double? ratio;

  /// Zones de qualité (barre à quatre zones). Nécessite [numericValue].
  final GaugeThresholds? thresholds;
  final double? numericValue;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final zoned = thresholds != null && numericValue != null;
    return GlassCard(
      padding: const EdgeInsets.all(14),
      radius: 20,
      tint: color,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withAlpha(p.dark ? 60 : 44),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 17, color: p.text),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: p.muted)),
          ),
        ]),
        const SizedBox(height: 10),
        Text.rich(
          TextSpan(children: [
            TextSpan(
                text: value,
                style: const TextStyle(
                    fontSize: 28, fontWeight: FontWeight.w800, height: 1.05)),
            TextSpan(
                text: ' $unit', style: TextStyle(fontSize: 12, color: p.muted)),
          ]),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (zoned) ...[
          const SizedBox(height: 10),
          CustomPaint(
            size: const Size(double.infinity, 14),
            painter: _ZonedBarPainter(
              value: numericValue!,
              t: thresholds!,
              marker: p.text,
              markerRing: p.dark ? AppColors.navy : Colors.white,
            ),
          ),
        ] else if (ratio != null) ...[
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio!.clamp(0.0, 1.0),
              minHeight: 6,
              color: color,
              backgroundColor: p.trackFill,
            ),
          ),
        ],
        if (statusText != null) ...[
          const SizedBox(height: 9),
          Row(children: [
            Icon(Icons.circle, size: 8, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(statusText!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w600, color: p.text)),
            ),
          ]),
        ],
      ]),
    );
  }
}

/// Barre à quatre zones (bon / modéré / mauvais / très mauvais) et repère.
class _ZonedBarPainter extends CustomPainter {
  _ZonedBarPainter({
    required this.value,
    required this.t,
    required this.marker,
    required this.markerRing,
  });

  final double value;
  final GaugeThresholds t;
  final Color marker;
  final Color markerRing;

  @override
  void paint(Canvas canvas, Size size) {
    final max = t.poor * 1.5;
    double x(double v) => (v / max).clamp(0.0, 1.0) * size.width;
    const barH = 6.0;
    final top = (size.height - barH) / 2;
    final bar = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, top, size.width, barH),
      const Radius.circular(barH / 2),
    );
    canvas.save();
    canvas.clipRRect(bar);
    final edges = [0.0, x(t.good), x(t.moderate), x(t.poor), size.width];
    final colors = [
      AppColors.good,
      AppColors.moderate,
      AppColors.poor,
      AppColors.veryPoor,
    ];
    for (var i = 0; i < 4; i++) {
      canvas.drawRect(
        Rect.fromLTRB(edges[i], top, edges[i + 1], top + barH),
        Paint()..color = colors[i].withAlpha(225),
      );
    }
    canvas.restore();

    final mx = x(value).clamp(6.0, size.width - 6.0);
    final c = Offset(mx, size.height / 2);
    canvas.drawCircle(c, 7, Paint()..color = markerRing);
    canvas.drawCircle(c, 5, Paint()..color = marker);
  }

  @override
  bool shouldRepaint(covariant _ZonedBarPainter old) =>
      old.value != value ||
      old.t.good != t.good ||
      old.t.moderate != t.moderate ||
      old.t.poor != t.poor ||
      old.marker != marker ||
      old.markerRing != markerRing;
}
