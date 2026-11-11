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
    final ok = AppColors.good;
    final warn = AppColors.poor;

    Widget pair(Widget l, Widget r) => IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(child: l),
            const SizedBox(width: 10),
            Expanded(child: r),
          ]),
        );

    final items = <Widget>[
      if (reading.isSimulated) const SimulationBanner(),
      // Évaluation globale
      GlassCard(
        strength: GlassStrength.strong,
        radius: 24,
        tint: lc,
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: lc.withAlpha(p.dark ? 60 : 50),
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
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.levelText(level, dark: p.dark))),
                Text('Niveau de risque : ${level.index + 1} / 4',
                    style: TextStyle(fontSize: 12.5, color: p.muted)),
              ]),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            for (var i = 0; i < 4; i++) ...[
              if (i > 0) const SizedBox(width: 5),
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: i <= level.index ? lc : p.text.withAlpha(p.dark ? 30 : 20),
                  ),
                ),
              ),
            ],
          ]),
          const SizedBox(height: 10),
          Text(_summary(level),
              textAlign: TextAlign.center, style: const TextStyle(fontSize: 13.5)),
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
          statusText: a.pm25Level.label,
        ),
        MeasureCard(
          label: 'PM10',
          value: reading.pm10.toStringAsFixed(1),
          unit: 'µg/m³',
          icon: Icons.blur_on,
          color: AppColors.level(a.pm10Level),
          ratio: reading.pm10 / AirQualityReferences.pm10Interim2,
          statusText: a.pm10Level.label,
        ),
      ),
      Text(
        'Jauges PM : valeur rapportée à la cible intermédiaire OMS 2 (moyenne sur 24 h) : '
        '50 µg/m³ (PM2.5) et 100 µg/m³ (PM10).',
        style: TextStyle(fontSize: 11.5, color: p.muted),
      ),
      // Recommandations
      GlassCard(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.tips_and_updates_outlined, size: 20, color: p.accent),
            const SizedBox(width: 8),
            const Text('Recommandations',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 8),
          for (final r in a.recommendations)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(Icons.check_circle_outline, size: 17, color: p.accent),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(r, style: const TextStyle(fontSize: 13.5, height: 1.3))),
              ]),
            ),
        ]),
      ),
      // Exposition (conseil qualitatif)
      GlassCard(
        strength: GlassStrength.subtle,
        padding: const EdgeInsets.all(14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.schedule, size: 20, color: p.champagneText),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Exposition (conseil qualitatif)',
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text(a.exposureAdvice, style: const TextStyle(fontSize: 13.5, height: 1.3)),
            ]),
          ),
        ]),
      ),
      Text(AirQualityReferences.disclaimer,
          style: TextStyle(fontSize: 11.5, color: p.muted, height: 1.3)),
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
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            FadeSlideIn(index: i, child: items[i]),
          ],
        ],
      ),
    );
  }
}
