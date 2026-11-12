import 'package:flutter/material.dart';

class AppColors {
  // Arrière-plans
  static const Color background = Color(0xFFF3F7FA);
  static const Color cardBackground = Colors.white;
  static const Color subCardBackground = Color(0xFFF6F9FC);

  // Couleurs principales
  static const Color primaryDark = Color(0xFF0A4D68);
  static const Color primaryTeal = Color(0xFF088395);
  static const Color softTealBg = Color(0xFFE0F2F1);

  // Textes
  static const Color textPrimary = Color(0xFF102A43);
  static const Color textSecondary = Color(0xFF627D98);

  // États
  static const Color warningBg = Color(0xFFFEF3C7);
  static const Color warningText = Color(0xFFB45309);

  // Compatibilité avec les anciens noms de la collègue
  static const Color bleuPrincipal = primaryDark;
  static const Color grisDoux = textSecondary;
  static const Color vertAccent = primaryTeal;

  // Compatibilité avec tes anciens noms (ils utilisent maintenant le design de ta collègue)
  static const Color turquoise = primaryTeal;
  static const Color turquoiseFonce = primaryDark;
  static const Color turquoiseClair = softTealBg;
  static const Color bleuMarine = primaryDark;
  static const Color texte = textPrimary;
  static const Color texteSecondaire = textSecondary;
  static const Color fond = background;
}