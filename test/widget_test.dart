import 'package:airsense/main.dart' show AirSenseApp;
import 'package:airsense/models/sensor_model.dart';
import 'package:airsense/screens/result_screen.dart';
import 'package:airsense/screens/voice_screen.dart';
import 'package:airsense/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

SensorReading _reading(double pm25, double pm10) => SensorReading(
      temperature: 22,
      humidity: 45,
      pm25: pm25,
      pm10: pm10,
      timestamp: DateTime(2026),
      isSimulated: true,
    );

Widget _app(Widget home, {ThemeMode mode = ThemeMode.light}) => MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: mode,
      home: home,
    );

void main() {
  testWidgets('L’accueil affiche le bouton Utiliser l’application', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const AirSenseApp());
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Utiliser l’application'), findsOneWidget);
  });

  testWidgets('Résultats : mesures et bandeau de simulation (mode sombre)', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        _app(ResultScreen(reading: _reading(8, 20)), mode: ThemeMode.dark));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('PM2.5'), findsOneWidget);
    expect(find.text('PM10'), findsOneWidget);
    expect(find.textContaining('MODE SIMULATION'), findsOneWidget);
  });

  testWidgets('Voice : simple message d’attente', (tester) async {
    await tester.pumpWidget(_app(const VoiceScreen()));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Fonctionnalité en cours de développement.'), findsOneWidget);
  });

  test('Évaluation : air sain puis très mauvais', () {
    expect(AirQualityAssessment.evaluate(_reading(8, 20)).level, AirQualityLevel.good);
    expect(AirQualityAssessment.evaluate(_reading(90, 20)).level, AirQualityLevel.veryPoor);
  });
}
