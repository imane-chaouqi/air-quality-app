import 'package:flutter/material.dart';

import '../models/sensor_model.dart';

/// Palette AirSense Premium et couleurs d'évaluation de la qualité de l'air.
///
/// Les couleurs d'évaluation sont définies ici (et non dans les modèles de
/// données) afin de rester identiques dans tous les écrans et les deux thèmes.
class AppColors {
  AppColors._();

  static const Color navy = Color(0xFF142536); // bleu nuit
  static const Color turquoise = Color(0xFF55BFA9);
  static const Color champagne = Color(0xFFC8AD78);
  static const Color lightBg = Color(0xFFF5F7F8);
  static const Color ink = Color(0xFF172635); // texte principal

  // Qualité de l'air : tons doux, non saturés.
  static const Color good = Color(0xFF3DAA78);
  static const Color moderate = Color(0xFFE0B63A);
  static const Color poor = Color(0xFFE8862E);
  static const Color veryPoor = Color(0xFFD64F4F);

  static Color level(AirQualityLevel l) {
    switch (l) {
      case AirQualityLevel.good:
        return good;
      case AirQualityLevel.moderate:
        return moderate;
      case AirQualityLevel.poor:
        return poor;
      case AirQualityLevel.veryPoor:
        return veryPoor;
    }
  }

  /// Variante lisible pour du TEXTE (plus foncée en mode clair).
  static Color levelText(AirQualityLevel l, {required bool dark}) {
    if (dark) return level(l);
    switch (l) {
      case AirQualityLevel.good:
        return const Color(0xFF1F7F55);
      case AirQualityLevel.moderate:
        return const Color(0xFF8A6D0B);
      case AirQualityLevel.poor:
        return const Color(0xFFB85E10);
      case AirQualityLevel.veryPoor:
        return const Color(0xFFB22F2F);
    }
  }

  static Color connection(ConnectionStatus s) {
    switch (s) {
      case ConnectionStatus.disconnected:
        return const Color(0xFF8795A1);
      case ConnectionStatus.connecting:
        return moderate;
      case ConnectionStatus.connected:
        return good;
      case ConnectionStatus.error:
        return veryPoor;
    }
  }

  static Color sensor(SensorState s) {
    switch (s) {
      case SensorState.unknown:
        return const Color(0xFF8795A1);
      case SensorState.stabilizing:
        return moderate;
      case SensorState.ready:
        return good;
    }
  }
}

/// Couleurs dépendantes du thème (clair / sombre).
class AppPalette {
  const AppPalette(this.dark);
  final bool dark;

  factory AppPalette.of(BuildContext context) =>
      AppPalette(Theme.of(context).brightness == Brightness.dark);

  Color get bgTop => dark ? const Color(0xFF0B1722) : AppColors.lightBg;
  Color get bgBottom => dark ? const Color(0xFF142536) : const Color(0xFFE9F0F1);
  Color get text => dark ? const Color(0xFFEEF3F6) : AppColors.ink;
  Color get muted => dark ? const Color(0xFFA5B5C2) : const Color(0xFF5E7081);
  Color get glassBase => dark ? const Color(0xFF1B3349) : Colors.white;
  Color get glassBorder =>
      dark ? Colors.white.withAlpha(30) : Colors.white.withAlpha(210);
  Color get hairline =>
      dark ? Colors.white.withAlpha(24) : AppColors.navy.withAlpha(22);
  Color get solidSurface => dark ? const Color(0xFF1B3349) : Colors.white;

  /// Turquoise lisible en texte / icônes.
  Color get accent => dark ? AppColors.turquoise : const Color(0xFF2E8F7B);
  Color get champagneText => dark ? AppColors.champagne : const Color(0xFF8A7140);
}
