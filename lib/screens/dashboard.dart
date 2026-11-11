import 'package:flutter/material.dart';

import 'analysis_screen.dart';
import 'voice_screen.dart';

/// Tableau de bord : accès à l'espace capteurs et à la page Voice.
/// (L'historique, le profil, etc. restent gérés par les autres développeurs.)
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Widget tile(IconData icon, String title, String subtitle, VoidCallback onTap) => Card(
          child: ListTile(
            leading: Icon(icon, size: 32),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(subtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: onTap,
          ),
        );
    return Scaffold(
      appBar: AppBar(title: const Text('Tableau de bord')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        tile(Icons.sensors, 'Espace capteurs', 'Mesure en mode simulation',
            () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const AnalysisScreen(simulation: true)))),
        tile(Icons.mic, 'Voice', 'Bientôt disponible',
            () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const VoiceScreen()))),
      ]),
    );
  }
}
