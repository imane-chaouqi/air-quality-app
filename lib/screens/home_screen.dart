import 'package:flutter/material.dart';

import '../services/iot_service.dart';
import '../theme/app_colors.dart';
import '../widgets/air_illustration.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/custom_button.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/glass_card.dart';
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

  Widget _feature(AppPalette p, IconData icon, String label) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
          decoration: BoxDecoration(
            color: p.subtleFill,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: [
            Icon(icon, size: 22, color: p.accent),
            const SizedBox(height: 5),
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);

    final items = <Widget>[
      GlassCard(
        strength: GlassStrength.strong,
        radius: 28,
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
        child: Column(children: [
          const AirIllustration(size: 128),
          const SizedBox(height: 12),
          const Text(
            'Surveillance de la qualité de l’air intérieur',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w800, height: 1.25, letterSpacing: -0.2),
          ),
          const SizedBox(height: 8),
          Text(
            'Particules fines, température et humidité, avec des recommandations adaptées.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5, color: p.muted, height: 1.35),
          ),
          const SizedBox(height: 16),
          Row(children: [
            _feature(p, Icons.grain, 'PM2.5 · PM10'),
            const SizedBox(width: 8),
            _feature(p, Icons.thermostat, 'Température'),
            const SizedBox(width: 8),
            _feature(p, Icons.water_drop_outlined, 'Humidité'),
          ]),
        ]),
      ),
      Column(children: [
        CustomButton(
            label: 'Utiliser l’application',
            icon: Icons.play_arrow_rounded,
            onPressed: _use),
        const SizedBox(height: 12),
        CustomButton(
          label: 'Tableau de bord',
          icon: Icons.dashboard_outlined,
          secondary: true,
          onPressed: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const DashboardScreen())),
        ),
      ]),
      GlassCard(
        strength: GlassStrength.subtle,
        padding: EdgeInsets.zero,
        radius: 20,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: Icon(Icons.science_outlined, color: p.warnIcon),
            iconColor: p.accentText,
            collapsedIconColor: p.accentText,
            title: const Text('Réglages de simulation',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
            subtitle: Text(_simulation ? 'Valeurs fictives' : 'Connexion réelle',
                style: TextStyle(fontSize: 12, color: p.muted)),
            shape: const Border(),
            collapsedShape: const Border(),
            childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            children: [
              SwitchListTile(
                dense: true,
                title: const Text('Mode simulation'),
                subtitle: Text(_simulation
                    ? 'Valeurs fictives'
                    : 'Connexion réelle (protocole ESP32 à définir)'),
                value: _simulation,
                onChanged: (v) => setState(() => _simulation = v),
              ),
              if (_simulation) ...[
                ListTile(
                  dense: true,
                  title: const Text('Scénario'),
                  trailing: DropdownButton<SimulationScenario>(
                    value: _scenario,
                    isDense: true,
                    underline: const SizedBox.shrink(),
                    iconEnabledColor: p.accentText,
                    onChanged: (v) => setState(() => _scenario = v ?? _scenario),
                    items: SimulationScenario.values
                        .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                        .toList(),
                  ),
                ),
                SwitchListTile(
                  dense: true,
                  title: const Text('Simuler une erreur de connexion'),
                  value: _simulateError,
                  onChanged: (v) => setState(() => _simulateError = v),
                ),
                SwitchListTile(
                  dense: true,
                  title: const Text('Accélérer le compte à rebours (démo, 10 s)'),
                  value: _fast,
                  onChanged: (v) => setState(() => _fast = v),
                ),
              ],
            ],
          ),
        ),
      ),
    ];

    return AppScaffold(
      title: 'AirSense',
      showBack: false,
      leading: const LogoMark(size: 36),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            FadeSlideIn(index: i, child: items[i]),
          ],
        ],
      ),
    );
  }
}
