import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/glass_card.dart';
import 'analysis_screen.dart';
import 'voice_screen.dart';

/// Tableau de bord : accès à l'espace capteurs et à la page Voice.
/// (L'historique, le profil, etc. restent gérés par les autres développeurs.)
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);

    Widget tile(IconData icon, Color accent, String title, String subtitle, VoidCallback onTap) {
      return GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withAlpha(p.dark ? 45 : 50),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, size: 24, color: p.text),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5)),
              Text(subtitle, style: TextStyle(fontSize: 12.5, color: p.muted)),
            ]),
          ),
          Icon(Icons.chevron_right, color: p.muted),
        ]),
      );
    }

    final items = <Widget>[
      tile(Icons.sensors, AppColors.turquoise, 'Espace capteurs', 'Mesure en mode simulation',
          () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const AnalysisScreen(simulation: true)))),
      tile(Icons.mic_none, AppColors.champagne, 'Voice', 'Bientôt disponible',
          () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const VoiceScreen()))),
    ];

    return AppScaffold(
      title: 'Tableau de bord',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            FadeSlideIn(index: i, child: items[i]),
          ],
        ],
      ),
    );
  }
}
