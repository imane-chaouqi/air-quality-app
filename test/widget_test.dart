import 'package:airsense/main.dart' show AirSenseApp;
import 'package:airsense/models/sensor_model.dart';
import 'package:airsense/screens/analysis_screen.dart';
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

  testWidgets('Countdown : va jusqu’à zéro, puis ouvre les résultats une seule fois',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    // Horloge contrôlée : le temps restant dépend de l'échéance, pas du
    // nombre de ticks du Timer.
    var now = DateTime(2026, 1, 1, 12);
    await tester.pumpWidget(_app(AnalysisScreen(
      simulation: true,
      fastCountdown: true, // 10 s
      clock: () => now,
    )));

    // Connexion simulée (2 s) puis activation : le compte à rebours démarre.
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
    expect(find.text('00:10'), findsOneWidget);

    now = now.add(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('00:06'), findsOneWidget);

    // Un « trou » (écran verrouillé, app en arrière-plan…) ne fige plus le
    // compte à rebours : il se resynchronise sur l'échéance et atteint zéro.
    now = now.add(const Duration(seconds: 7));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('00:00'), findsOneWidget);

    // Première mesure reçue → passage automatique aux résultats.
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Résultats'), findsOneWidget);
  });

  test('Évaluation : air sain puis très mauvais', () {
    expect(AirQualityAssessment.evaluate(_reading(8, 20)).level, AirQualityLevel.good);
    expect(AirQualityAssessment.evaluate(_reading(90, 20)).level, AirQualityLevel.veryPoor);
  });
}
