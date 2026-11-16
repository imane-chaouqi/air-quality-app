# AirSense – Refonte Premium (UI/UX)

Refonte visuelle du projet Flutter existant, sans changement d'architecture, de logique ni de dépendances.

## Ce qui est conservé (inchangé)
`lib/models/sensor_model.dart`, `lib/services/iot_service.dart` (abstraction `IotService` / `Esp32Transport`,
simulation), logique du compte à rebours (4 min, 10 s en démo), navigation (Accueil → Espace capteurs →
Résultats, Tableau de bord, Voice), évaluation et recommandations dynamiques, conseil d'exposition qualitatif.
Aucune dépendance ajoutée : `shared_preferences` (déjà dans pubspec.yaml) sert à mémoriser le thème.

## Nouveautés
- `lib/theme/` : palette (#142536, #55BFA9, #C8AD78, #F5F7F8, #172635), thèmes clair/sombre, `ThemeController` persistant.
- Widgets : `GlassCard` (effet vitré, 3 intensités), `AppBackground`, `AppScaffold`, `ThemeToggleButton`, `FadeSlideIn`, `AirIllustration`/`LogoMark`.
- Écrans refondus : accueil, espace capteurs (PMS5003 : PM2.5/PM10 ; DHT22 : température/humidité), résultats (carte globale + grille 2×2), Voice (placeholder), tableau de bord.
- Bouton de thème (soleil/lune) dans l'en-tête de chaque écran.

## Lancer
```powershell
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```
Réglages de démonstration : accueil → « Réglages de simulation » (scénario, erreur, compte à rebours 10 s).

## Limites
- Environnement de développement sans Flutter : `flutter pub get/analyze/test`, la compilation et les captures d'écran
  n'ont PAS été exécutés. Relecture manuelle uniquement.
- Navigation par pile conservée (pas de barre inférieure) pour ne pas modifier le parcours existant.
- Pas de communication réelle ESP32 : aucun protocole n'est défini ; le mode réel affiche une erreur explicite.
- Les seuils OMS cités sont des moyennes sur 24 h ; l'app les utilise comme repères de prévention, pas comme seuils instantanés.
