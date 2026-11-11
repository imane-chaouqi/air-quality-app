import 'package:flutter/material.dart';

import '../services/iot_service.dart';
import '../widgets/custom_button.dart';
import 'analysis_screen.dart';
import 'dashboard.dart';

/// Accueil : bouton « Utiliser l'application » + réglages du mode simulation.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _simulation = true;
  bool _simulateError = false;
  bool _fast = false;
  SimulationScenario _scenario = SimulationScenario.good;

  void _use() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AnalysisScreen(
        simulation: _simulation,
        scenario: _scenario,
        simulateConnectionError: _simulateError,
        fastCountdown: _fast,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AirSense')),
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.all(20), children: [
          const SizedBox(height: 12),
          const Icon(Icons.air, size: 90),
          const Center(
              child: Text('AirSense', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
          const Center(child: Text('Surveillance de la qualité de l’air intérieur')),
          const SizedBox(height: 24),
          CustomButton(label: 'Utiliser l’application', icon: Icons.play_arrow, onPressed: _use),
          const SizedBox(height: 10),
          CustomButton(
            label: 'Tableau de bord',
            icon: Icons.dashboard,
            secondary: true,
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const DashboardScreen())),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(children: [
                SwitchListTile(
                  title: const Text('Mode simulation'),
                  subtitle: Text(_simulation
                      ? 'Valeurs fictives'
                      : 'Connexion réelle (protocole ESP32 à définir)'),
                  value: _simulation,
                  onChanged: (v) => setState(() => _simulation = v),
                ),
                if (_simulation) ...[
                  ListTile(
                    title: const Text('Scénario'),
                    trailing: DropdownButton<SimulationScenario>(
                      value: _scenario,
                      onChanged: (v) => setState(() => _scenario = v ?? _scenario),
                      items: SimulationScenario.values
                          .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                          .toList(),
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Simuler une erreur de connexion'),
                    value: _simulateError,
                    onChanged: (v) => setState(() => _simulateError = v),
                  ),
                  SwitchListTile(
                    title: const Text('Accélérer le compte à rebours (démo, 10 s)'),
                    value: _fast,
                    onChanged: (v) => setState(() => _fast = v),
                  ),
                ],
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
