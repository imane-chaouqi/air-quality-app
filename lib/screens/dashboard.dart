import 'package:flutter/material.dart';

import '../models/sensor_model.dart';
import '../theme/app_colors.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/connection_indicator.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/glass_card.dart';
import '../widgets/sensor_status_tile.dart';
import 'analysis_screen.dart';
import 'voice_screen.dart';

/// Tableau de bord : état du système, capteurs, accès à l'espace capteurs et
/// à la page Voice. (L'historique, le profil, etc. restent gérés par les
/// autres développeurs.)
///
/// Aucune mesure n'existe tant que l'espace capteurs n'a pas été lancé : le
/// tableau de bord affiche donc des états « en attente » (—), jamais de
/// valeurs inventées.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);

    Widget tile(IconData icon, String title, String subtitle, VoidCallback onTap) {
      return GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.all(14),
        radius: 20,
        child: Row(children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: p.chipFill,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 24, color: p.accentText),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5)),
              Text(subtitle, style: TextStyle(fontSize: 12.5, color: p.muted)),
            ]),
          ),
          Icon(Icons.chevron_right, color: p.accentText),
        ]),
      );
    }

    final items = <Widget>[
      GlassCard(
        strength: GlassStrength.strong,
        radius: 24,
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: p.chipFill,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.air, size: 23, color: p.accentText),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Qualité de l’air',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
            ),
            const ConnectionIndicator(status: ConnectionStatus.disconnected),
          ]),
          const SizedBox(height: 12),
          Text(
            'Aucune mesure en cours. Lancez l’espace capteurs pour mesurer : '
            'les valeurs apparaîtront après la stabilisation des capteurs.',
            style: TextStyle(fontSize: 13, color: p.muted, height: 1.35),
          ),
        ]),
      ),
      const SensorStatusTile(
        info: SensorInfo.pms5003,
        state: SensorState.unknown,
        metrics: [
          SensorMetric('PM2.5', '—', 'µg/m³'),
          SensorMetric('PM10', '—', 'µg/m³'),
        ],
      ),
      const SensorStatusTile(
        info: SensorInfo.dht22,
        state: SensorState.unknown,
        metrics: [
          SensorMetric('Température', '—', '°C'),
          SensorMetric('Humidité', '—', '%'),
        ],
      ),
      tile(Icons.sensors, 'Espace capteurs', 'Mesure en mode simulation',
          () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const AnalysisScreen(simulation: true)))),
      tile(Icons.mic_none, 'Voice', 'Bientôt disponible',
          () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const VoiceScreen()))),
    ];

    return AppScaffold(
      title: 'Tableau de bord',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            FadeSlideIn(index: i, child: items[i]),
          ],
        ],
      ),
    );
  }
}
