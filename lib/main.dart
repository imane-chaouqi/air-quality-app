import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await themeController.load(); // thème mémorisé (clair / sombre)
  runApp(const AirSenseApp());
}

/// Point d'entrée de l'application (thèmes clair et sombre AirSense Premium).
/// Si d'autres développeurs ajoutent des routes, les fusionner ici.
class AirSenseApp extends StatelessWidget {
  const AirSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) => MaterialApp(
        title: 'AirSense',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeController.mode,
        home: const HomeScreen(),
      ),
    );
  }
}
