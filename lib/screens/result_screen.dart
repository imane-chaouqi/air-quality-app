import 'package:flutter/material.dart';

import '../models/sensor_model.dart';
import '../theme/app_colors.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/custom_button.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/glass_card.dart';
import '../widgets/measure_card.dart';
import '../widgets/simulation_banner.dart';

/// Résultats : mesures, état de l'air, recommandations et conseil d'exposition.
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.reading});
  final SensorReading reading;

  String _summary(AirQualityLevel l) {
    switch (l) {
      case AirQualityLevel.good:
        return 'L’air intérieur est de bonne qualité.';
      case AirQualityLevel.moderate:
        return 'Qualité acceptable : quelques précautions sont utiles.';
      case AirQualityLevel.poor:
        return 'L’air est dégradé : agissez pour l’améliorer.';
      case AirQualityLevel.veryPoor:
        return 'Air très dégradé : réduisez les sources et ventilez si possible.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final a = AirQualityAssessment.evaluate(reading);
    final level = a.level;
    final lc = AppColors.level(level);
    const ok = AppColors.good;
    const warn = AppColors.amber;

    Widget pair(Widget l, Widget r) => IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(child: l),
            const SizedBox(width: 12),
            Expanded(child: r),
          ]),
        );

    String fmt(double v) => v.toStringAsFixed(0);

    final items = <Widget>[
      if (reading.isSimulated) const SimulationBanner(),
      // Évaluation globale
      GlassCard(
        strength: GlassStrength.strong,
        radius: 26,
        tint: lc,
        padding: const EdgeInsets.all(18),
        child: Column(children: [
          Row(children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: lc.withAlpha(p.dark ? 60 : 46),
                border: Border.all(color: lc, width: 2),
              ),
              child: Icon(level.icon, size: 32, color: p.text),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Qualité de l’air', style: TextStyle(fontSize: 12.5, color: p.muted)),
                Text(level.label,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: AppColors.levelText(level, dark: p.dark))),
                Text('Niveau de risque : ${level.index + 1} / 4',
                    style: TextStyle(fontSize: 12.5, color: p.muted)),
              ]),
            ),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            for (var i = 0; i < 4; i++) ...[
              if (i > 0) const SizedBox(width: 5),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: i <= level.index ? lc : p.trackFill,
                  ),
                ),
              ),
            ],
          ]),
          const SizedBox(height: 12),
          Text(_summary(level),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, height: 1.3)),
        ]),
      ),
      // Mesures 2 × 2
      pair(
        MeasureCard(
          label: 'Température',
          value: reading.temperature.toStringAsFixed(1),
          unit: '°C',
          icon: Icons.thermostat,
          color: a.temperatureOk ? ok : warn,
          ratio: reading.temperature / 40,
          statusText: a.temperatureOk ? 'Plage de confort' : 'Hors plage de confort',
        ),
        MeasureCard(
          label: 'Humidité',
          value: reading.humidity.toStringAsFixed(0),
          unit: '%',
          icon: Icons.water_drop_outlined,
          color: a.humidityOk ? ok : warn,
          ratio: reading.humidity / 100,
          statusText: a.humidityOk ? 'Plage de confort' : 'Hors plage de confort',
        ),
      ),
      pair(
        MeasureCard(
          label: 'PM2.5',
          value: reading.pm25.toStringAsFixed(1),
          unit: 'µg/m³',
          icon: Icons.grain,
          color: AppColors.level(a.pm25Level),
          ratio: reading.pm25 / AirQualityReferences.pm25Interim2,
          numericValue: reading.pm25,
          thresholds: const GaugeThresholds(
            AirQualityReferences.pm25Guideline,
            AirQualityReferences.pm25Interim4,
            AirQualityReferences.pm25Interim2,
          ),
          statusText: a.pm25Level.label,
        ),
        MeasureCard(
          label: 'PM10',
          value: reading.pm10.toStringAsFixed(1),
          unit: 'µg/m³',
          icon: Icons.blur_on,
          color: AppColors.level(a.pm10Level),
          ratio: reading.pm10 / AirQualityReferences.pm10Interim2,
          numericValue: reading.pm10,
          thresholds: const GaugeThresholds(
            AirQualityReferences.pm10Guideline,
            AirQualityReferences.pm10Interim4,
            AirQualityReferences.pm10Interim2,
          ),
          statusText: a.pm10Level.label,
        ),
      ),
      Text(
        'Barres PM : zones Bon, Modéré, Mauvais et Très mauvais selon les repères '
        'OMS 2021 (moyennes sur 24 h). Seuils en µg/m³ : '
        '${fmt(AirQualityReferences.pm25Guideline)} / ${fmt(AirQualityReferences.pm25Interim4)} / '
        '${fmt(AirQualityReferences.pm25Interim2)} pour les PM2.5 ; '
        '${fmt(AirQualityReferences.pm10Guideline)} / ${fmt(AirQualityReferences.pm10Interim4)} / '
        '${fmt(AirQualityReferences.pm10Interim2)} pour les PM10.',
        style: TextStyle(fontSize: 11.5, color: p.muted, height: 1.35),
      ),
      // Recommandations
      GlassCard(
        padding: const EdgeInsets.all(16),
        radius: 22,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.tips_and_updates_outlined, size: 21, color: p.accentText),
            const SizedBox(width: 8),
            const Text('Recommandations',
                style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 8),
          for (final r in a.recommendations)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Padding(
                  padding: EdgeInsets.only(top: 1),
                  child: Icon(Icons.check_circle, size: 19, color: AppColors.leaf),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(r, style: const TextStyle(fontSize: 13.5, height: 1.35))),
              ]),
            ),
        ]),
      ),
      // Exposition (conseil qualitatif)
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: p.warnFill,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.amber.withAlpha(120)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.schedule, size: 21, color: p.warnIcon),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Exposition (conseil qualitatif)',
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(a.exposureAdvice, style: const TextStyle(fontSize: 13.5, height: 1.35)),
            ]),
          ),
        ]),
      ),
      Text(AirQualityReferences.disclaimer,
          style: TextStyle(fontSize: 11.5, color: p.muted, height: 1.35)),
      CustomButton(
        label: 'Nouvelle mesure',
        icon: Icons.refresh,
        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
      ),
    ];

    return AppScaffold(
      title: 'Résultats',
      showBack: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            FadeSlideIn(index: i, child: items[i]),
          ],
        ],
      ),
    );
  }
}
