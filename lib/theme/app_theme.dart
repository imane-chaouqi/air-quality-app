import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'app_colors.dart';

/// Thèmes Material 3 clair et sombre d'AirSense Premium.
class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness b) {
    final p = AppPalette(b == Brightness.dark);
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.turquoise,
      brightness: b,
    ).copyWith(
      primary: p.accent,
      onPrimary: AppColors.navy,
      secondary: AppColors.champagne,
      onSecondary: AppColors.navy,
      surface: p.solidSurface,
      onSurface: p.text,
      error: AppColors.veryPoor,
    );
    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    return base.copyWith(
      scaffoldBackgroundColor: p.bgBottom,
      canvasColor: p.solidSurface,
      textTheme: base.textTheme.apply(bodyColor: p.text, displayColor: p.text),
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
                ? AppColors.turquoise
                : p.muted.withAlpha(110)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.navy,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
