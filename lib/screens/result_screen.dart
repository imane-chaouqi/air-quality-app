import 'package:flutter/material.dart';

import '../models/sensor_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/measure_card.dart';
import '../widgets/simulation_banner.dart';

/// Résultats : mesures, état de l'air, recommandations et conseil d'exposition.
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.reading});
  final SensorReading reading;

  @override
  Widget build(BuildContext context) {
    final a = AirQualityAssessment.evaluate(reading);
    final level = a.level;
    return Scaffold(
      appBar: AppBar(title: const Text('Résultats'), automaticallyImplyLeading: false),
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.all(16), children: [
          if (reading.isSimulated) ...[const SimulationBanner(), const SizedBox(height: 12)],
          Card(
            color: level.color.withAlpha(35),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18), side: BorderSide(color: level.color, width: 2)),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(children: [
                Icon(level.icon, size: 54, color: level.color),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Qualité de l’air'),
                    Text(level.label,
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: level.color)),
                    Text('Niveau de risque : ${level.index + 1} / 4'),
                  ]),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.05,
            children: [
              MeasureCard(
                label: 'Température',
                value: reading.temperature.toStringAsFixed(1),
                unit: '°C',
                icon: Icons.thermostat,
                color: a.temperatureOk ? Colors.green : Colors.orange,
                statusText: a.temperatureOk ? 'Dans la plage de confort' : 'Hors plage de confort',
              ),
              MeasureCard(
                label: 'Humidité',
                value: reading.humidity.toStringAsFixed(0),
                unit: '%',
                icon: Icons.water_drop,
                color: a.humidityOk ? Colors.green : Colors.orange,
                statusText: a.humidityOk ? 'Dans la plage de confort' : 'Hors plage de confort',
              ),
              MeasureCard(
                label: 'PM2.5',
                value: reading.pm25.toStringAsFixed(1),
                unit: 'µg/m³',
                icon: Icons.grain,
                color: a.pm25Level.color,
                statusText: a.pm25Level.label,
                ratio: reading.pm25 / AirQualityReferences.pm25Interim2,
              ),
              MeasureCard(
                label: 'PM10',
                value: reading.pm10.toStringAsFixed(1),
                unit: 'µg/m³',
                icon: Icons.blur_on,
                color: a.pm10Level.color,
                statusText: a.pm10Level.label,
                ratio: reading.pm10 / AirQualityReferences.pm10Interim2,
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Jauges PM : valeur rapportée à la cible intermédiaire OMS 2 (24 h) : '
            '50 µg/m³ (PM2.5) et 100 µg/m³ (PM10).',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 16),
          const Text('Recommandations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...a.recommendations.map((r) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.lightbulb_outline),
                title: Text(r),
              )),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Exposition (conseil qualitatif)'),
              subtitle: Text(a.exposureAdvice),
            ),
          ),
          const SizedBox(height: 8),
          Text(AirQualityReferences.disclaimer, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 16),
          CustomButton(
            label: 'Nouvelle mesure',
            icon: Icons.refresh,
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ]),
      ),
    );
  }
}
