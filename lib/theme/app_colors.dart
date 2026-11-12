import 'package:flutter/material.dart';

import '../models/sensor_model.dart';

/// Palette AirSense (Premium Glassmorphism).
///
/// Toutes les teintes ci-dessous ont été relevées sur l'image de référence
/// fournie (boutons, barre latérale, cartes, graphiques, alertes). Aucune
/// couleur n'est inventée : les variations de transparence sont obtenues
/// uniquement avec `withAlpha` à partir de ces teintes.
class AppColors {
  AppColors._();

  // Bleus profonds (titres, barre latérale, fond sombre)
  static const Color deepBlue = Color(0xFF001E60);
  static const Color navyDeep = Color(0xFF013265);
  static const Color navy = Color(0xFF024479);
  static const Color ocean = Color(0xFF016794);

  // Turquoises (boutons, accents, icônes)
  static const Color teal = Color(0xFF0494A6);
  static const Color turquoise = Color(0xFF11BAA6);
  static const Color aqua = Color(0xFF08B8B6);

  // Vert feuille (état « bon », validations)
  static const Color leaf = Color(0xFF24AF64);

  // Fonds clairs
  static const Color skyBlue = Color(0xFFD9E7FD);
  static const Color mist = Color(0xFFF2F5FE);
  static const Color iceBlue = Color(0xFFE1F5FE);
  static const Color mint = Color(0xFFC8F5EF);

  // Attention / alerte
  static const Color amber = Color(0xFFF3A334);
  static const Color peach = Color(0xFFFEDDB0);
  static const Color sand = Color(0xFFF9E9D7);
  static const Color alertRed = Color(0xFFF73E28);
  static const Color rust = Color(0xFFB82F0C);

  // Neutres bleutés (texte secondaire, état inconnu)
  static const Color slate = Color(0xFF5F7798);
  static const Color mutedBlue = Color(0xFF3E517D);

  // Graphiques
  static const Color chartBlue = Color(0xFF2D81FB);
  static const Color chartPurple = Color(0xFFA97CF7);
  static const Color chartTeal = Color(0xFF20C6C2);

  // Alias conservés pour ne pas casser le code existant.
  static const Color lightBg = mist;
  static const Color ink = deepBlue;

  /// Ancien accent « champagne » : remplacé par l'ambre de la palette.
  static const Color champagne = amber;

  // Qualité de l'air.
  static const Color good = leaf;
  static const Color moderate = amber;
  static const Color poor = alertRed;
  static const Color veryPoor = rust;

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

  /// Couleur lisible pour un TEXTE de niveau : texte principal en mode clair
  /// (la couleur du niveau est portée par les pastilles et les barres),
  /// couleur du niveau en mode sombre.
  static Color levelText(AirQualityLevel l, {required bool dark}) {
    if (dark) {
      return l == AirQualityLevel.veryPoor ? alertRed : level(l);
    }
    switch (l) {
      case AirQualityLevel.good:
      case AirQualityLevel.moderate:
        return deepBlue;
      case AirQualityLevel.poor:
      case AirQualityLevel.veryPoor:
        return rust;
    }
  }

  static Color connection(ConnectionStatus s) {
    switch (s) {
      case ConnectionStatus.disconnected:
        return slate;
      case ConnectionStatus.connecting:
        return moderate;
      case ConnectionStatus.connected:
        return good;
      case ConnectionStatus.error:
        return alertRed;
    }
  }

  static Color sensor(SensorState s) {
    switch (s) {
      case SensorState.unknown:
        return slate;
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

  // Fond
  Color get bgTop => dark ? AppColors.deepBlue : AppColors.skyBlue;
  Color get bgBottom => dark ? AppColors.navyDeep : AppColors.mist;

  // Texte
  Color get text => dark ? AppColors.mist : AppColors.deepBlue;
  Color get muted =>
      dark ? AppColors.skyBlue.withAlpha(215) : AppColors.mutedBlue;

  // Verre
  Color get glassBase => dark ? AppColors.navy : Colors.white;
  Color get glassBorder =>
      dark ? Colors.white.withAlpha(40) : Colors.white.withAlpha(225);
  Color get hairline =>
      dark ? Colors.white.withAlpha(30) : AppColors.deepBlue.withAlpha(24);
  Color get solidSurface => dark ? AppColors.navy : Colors.white;
  Color get shadow => AppColors.deepBlue.withAlpha(dark ? 110 : 28);

  // Accents
  Color get accent => dark ? AppColors.aqua : AppColors.teal; // icônes
  Color get accentText => dark ? AppColors.aqua : AppColors.ocean; // texte
  Color get primary => dark ? AppColors.aqua : AppColors.ocean;
  Color get onPrimary => dark ? AppColors.deepBlue : Colors.white;

  // Surfaces secondaires
  Color get subtleFill =>
      dark ? Colors.white.withAlpha(20) : AppColors.deepBlue.withAlpha(12);
  Color get chipFill => dark ? AppColors.aqua.withAlpha(48) : AppColors.mint;
  Color get warnFill =>
      dark ? AppColors.amber.withAlpha(46) : AppColors.peach.withAlpha(215);
  Color get warnIcon => dark ? AppColors.amber : AppColors.rust;
  Color get trackFill =>
      dark ? Colors.white.withAlpha(34) : AppColors.deepBlue.withAlpha(24);

  /// Ancien nom (accent « champagne ») conservé comme alias.
  Color get champagneText => warnIcon;
}
