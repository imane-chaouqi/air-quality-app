# AirSense – Partie Flutter (Développeuse 3)

## Fichiers (chemins relatifs à la racine de `air-quality-app/`)
Créés : `lib/services/iot_service.dart` (remplit le fichier vide), `lib/screens/voice_screen.dart`,
`lib/widgets/{connection_indicator,simulation_banner,sensor_status_tile,countdown_progress,measure_card}.dart`
Remplacés (étaient vides ou démo) : `lib/main.dart`, `lib/models/sensor_model.dart`,
`lib/screens/{home_screen,dashboard,analysis_screen,result_screen}.dart`, `lib/widgets/custom_button.dart`,
`test/widget_test.dart` (l'ancien test référençait le code de démo `MyApp`).
Aucun fichier des coéquipiers n'est touché (user_model, form, register, history, profile).
**Avant de copier** : si `home_screen.dart`, `dashboard.dart` ou `main.dart` contiennent du code utile, fusionnez-le (git diff).

## Installation (PowerShell, dans le dossier air-quality-app)
```powershell
git checkout -b feature/dev3-flutter
Expand-Archive -Path "$HOME\Downloads\airsense-dev3-flutter.zip" -DestinationPath . -Force
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```
Aucune dépendance ajoutée (Flutter SDK seul, Flutter 3.22+ recommandé). `-d chrome` ou `-d edge`
évite d'activer le mode développeur Windows. Si `flutter test` échoue sur les imports, remplacez
`air_quality_app` dans `test/widget_test.dart` par le champ `name:` de votre `pubspec.yaml`.

## Fonctionnement
Accueil → « Utiliser l'application » → Espace capteurs (connexion, activation, compte à rebours de 4 min)
→ Résultats automatiques. Le mode simulation (réglé sur l'accueil : scénario, erreur de connexion,
compte à rebours accéléré à 10 s) affiche un bandeau « valeurs fictives » partout.

## Passer à l'ESP32 réel
Le protocole n'est pas défini : aucune IP, URL, endpoint ou UUID n'est codé. Implémentez
`Esp32Transport` (open, sendActivation, readings, close) dans `iot_service.dart` selon la spécification
du développeur ESP32, puis passez-le à `AnalysisScreen(simulation: false, transport: ...)`.
Sans transport, le mode réel affiche une erreur claire.

## Références de santé
Valeurs OMS 2021 (moyennes 24 h) : PM2.5 15 µg/m³, PM10 45 µg/m³, cibles intermédiaires 4 (25/50) et
2 (50/100). Ce ne sont pas des seuils instantanés. Niveaux : Bon ≤ ligne directrice, Modéré ≤ cible 4,
Mauvais ≤ cible 2, Très mauvais au-delà. Plages température (18–27 °C) et humidité (30–60 %) indicatives.
Exposition : conseil qualitatif uniquement, aucune durée chiffrée.
