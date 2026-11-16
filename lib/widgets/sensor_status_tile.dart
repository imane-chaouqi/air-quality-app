import 'package:flutter/material.dart';

import '../models/sensor_model.dart';
import '../theme/app_colors.dart';
import 'glass_card.dart';

/// Une valeur affichée dans la carte d'un capteur (ex. PM2.5 · 12.3 µg/m³).
class SensorMetric {
  const SensorMetric(this.label, this.value, this.unit);
  final String label;
  final String value;
  final String unit;
}

/// Carte d'un capteur : nom, état de fonctionnement estimé et ses mesures.
class SensorStatusTile extends StatelessWidget {
  const SensorStatusTile({
    super.key,
    required this.info,
    required this.state,
    this.metrics = const [],
    this.provisional = false,
  });

  final SensorInfo info;
  final SensorState state;
  final List<SensorMetric> metrics;

  /// true : valeurs reçues pendant la stabilisation (non définitives).
  final bool provisional;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final color = AppColors.sensor(state);
    return GlassCard(
      padding: const EdgeInsets.all(14),
      radius: 20,
      child: Column(children: [
        Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: p.chipFill,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(info.icon, size: 22, color: p.accentText),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(info.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15.5)),
              Text(info.measures,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: p.muted)),
            ]),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withAlpha(p.dark ? 50 : 34),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withAlpha(170)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.circle, size: 8, color: color),
              const SizedBox(width: 5),
              Text(state.label,
                  style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: p.text)),
            ]),
          ),
        ]),
        if (metrics.isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(children: [
            for (var i = 0; i < metrics.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(child: _MetricCell(metric: metrics[i], dim: provisional)),
            ],
          ]),
          if (provisional)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Valeurs provisoires pendant la stabilisation.',
                    style: TextStyle(
                        fontSize: 11.5,
                        fontStyle: FontStyle.italic,
                        color: p.muted)),
              ),
            ),
        ],
      ]),
    );
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({required this.metric, required this.dim});
  final SensorMetric metric;
  final bool dim;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: p.subtleFill,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(metric.label, style: TextStyle(fontSize: 12, color: p.muted)),
        const SizedBox(height: 2),
        Text.rich(
          TextSpan(children: [
            TextSpan(
              text: metric.value,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: dim ? p.muted : p.text),
            ),
            TextSpan(
                text: ' ${metric.unit}',
                style: TextStyle(fontSize: 11.5, color: p.muted)),
          ]),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ]),
    );
  }
}
