import 'package:flutter/material.dart';
import '../models/sensor_model.dart';

/// Palette AirSense : couleurs du redesign (glassmorphism)
/// + anciens noms conservés pour que tous les écrans compilent.
class AppColors {
  AppColors._();

  // ===== Noms de l'ancien design (écrans d'inscription, connexion, formulaire) =====
  static const Color background = Color(0xFFF3F7FA);
  static const Color cardBackground = Colors.white;
  static const Color subCardBackground = Color(0xFFF6F9FC);

  static const Color primaryDark = Color(0xFF0A4D68);
  static const Color primaryTeal = Color(0xFF088395);
  static const Color softTealBg = Color(0xFFE0F2F1);

  static const Color textPrimary = Color(0xFF102A43);
  static const Color textSecondary = Color(0xFF627D98);

  static const Color warningBg = Color(0xFFFEF3C7);
  static const Color warningText = Color(0xFFB45309);

  static const Color bleuPrincipal = primaryDark;
  static const Color grisDoux = textSecondary;
  static const Color vertAccent = primaryTeal;

  // Tes anciens noms (« turquoise » est défini plus bas, avec la palette du redesign)
  static const Color turquoiseFonce = primaryDark;
  static const Color turquoiseClair = softTealBg;
  static const Color bleuMarine = primaryDark;
  static const Color texte = textPrimary;
  static const Color texteSecondaire = textSecondary;
  static const Color fond = background;

  // ===== Palette du redesign (espace capteurs, mesures) =====
  // Bleus profonds
  static const Color deepBlue = Color(0xFF001E60);
  static const Color navyDeep = Color(0xFF013265);
  static const Color navy = Color(0xFF024479);
  static const Color ocean = Color(0xFF016794);

  // Turquoises
  static const Color teal = Color(0xFF0494A6);
  static const Color turquoise = Color(0xFF11BAA6);
  static const Color aqua = Color(0xFF08B8B6);

  // Vert (état « bon »)
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

  // Neutres bleutés
  static const Color slate = Color(0xFF5F7798);
  static const Color mutedBlue = Color(0xFF3E517D);

  // Graphiques
  static const Color chartBlue = Color(0xFF2D81FB);
  static const Color chartPurple = Color(0xFFA97CF7);
  static const Color chartTeal = Color(0xFF20C6C2);

  // Alias du redesign
  static const Color lightBg = mist;
  static const Color ink = deepBlue;
  static const Color champagne = amber;

  // Qualité de l'air
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
  Color get accent => dark ? AppColors.aqua : AppColors.teal;
  Color get accentText => dark ? AppColors.aqua : AppColors.ocean;
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

  Color get champagneText => warnIcon;
}