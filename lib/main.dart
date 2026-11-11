import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() => runApp(const AirSenseApp());

/// Point d'entrée : remplace le code de démonstration Flutter.
/// Si d'autres développeurs ajoutent des routes, les fusionner ici.
class AirSenseApp extends StatelessWidget {
  const AirSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AirSense',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}
