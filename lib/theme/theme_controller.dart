import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gère le thème (clair / sombre) et le conserve entre deux lancements
/// grâce à shared_preferences (déjà déclaré dans pubspec.yaml).
class ThemeController extends ChangeNotifier {
  static const String _key = 'airsense_theme_mode';
  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  /// Charge le choix enregistré. Sans effet bloquant en cas d'erreur.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final v = prefs.getString(_key);
      if (v == 'light') {
        _mode = ThemeMode.light;
      } else if (v == 'dark') {
        _mode = ThemeMode.dark;
      }
      notifyListeners();
    } catch (_) {
      // Stockage indisponible : on garde le thème du système.
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _key, mode == ThemeMode.dark ? 'dark' : mode == ThemeMode.light ? 'light' : 'system');
    } catch (_) {
      // Non persistant si le stockage est indisponible.
    }
  }
}

/// Instance partagée par l'application.
final ThemeController themeController = ThemeController();
