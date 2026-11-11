import 'package:flutter_test/flutter_test.dart';

import 'package:air_quality_app/models/sensor_model.dart';
import 'package:air_quality_app/main.dart';

void main() {
  testWidgets('L’accueil affiche le bouton Utiliser l’application', (tester) async {
    await tester.pumpWidget(const AirSenseApp());
    expect(find.text('Utiliser l’application'), findsOneWidget);
  });

  test('Évaluation : air sain puis très mauvais', () {
    SensorReading r(double pm25, double pm10) => SensorReading(
        temperature: 22, humidity: 45, pm25: pm25, pm10: pm10,
        timestamp: DateTime(2026), isSimulated: true);
    expect(AirQualityAssessment.evaluate(r(8, 20)).level, AirQualityLevel.good);
    expect(AirQualityAssessment.evaluate(r(90, 20)).level, AirQualityLevel.veryPoor);
  });
}
