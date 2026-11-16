import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Thèmes Material 3 clair et sombre d'AirSense (Premium Glassmorphism).
/// Toutes les couleurs proviennent de [AppColors] / [AppPalette].
class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness b) {
    final p = AppPalette(b == Brightness.dark);
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      brightness: b,
    ).copyWith(
      primary: p.primary,
      onPrimary: p.onPrimary,
      secondary: AppColors.teal,
      onSecondary: Colors.white,
      surface: p.solidSurface,
      onSurface: p.text,
      onSurfaceVariant: p.muted,
      error: AppColors.alertRed,
    );
    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    return base.copyWith(
      scaffoldBackgroundColor: p.bgBottom,
      canvasColor: p.solidSurface,
      textTheme: base.textTheme
          .apply(bodyColor: p.text, displayColor: p.text)
          .copyWith(
            titleLarge: base.textTheme.titleLarge?.copyWith(
              color: p.text,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
      iconTheme: IconThemeData(color: p.text),
      dividerColor: p.hairline,
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AppColors.teal
                : p.muted.withAlpha(110)),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.navy,
        contentTextStyle: TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
