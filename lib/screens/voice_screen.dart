import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/glass_card.dart';

/// Page Voice : simple emplacement réservé, aucune logique vocale.
class VoiceScreen extends StatelessWidget {
  const VoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return AppScaffold(
      title: 'Voice',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: FadeSlideIn(
            child: GlassCard(
              strength: GlassStrength.strong,
              radius: 26,
              padding: const EdgeInsets.fromLTRB(22, 26, 22, 26),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.champagne.withAlpha(p.dark ? 40 : 50),
                    border: Border.all(color: AppColors.champagne, width: 1.5),
                  ),
                  child: Icon(Icons.mic_none, size: 38, color: p.champagneText),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Fonctionnalité en cours de développement.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Elle sera disponible prochainement.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: p.muted),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
