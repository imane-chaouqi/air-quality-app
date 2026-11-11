import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Bandeau affiché partout où des valeurs fictives sont utilisées.
class SimulationBanner extends StatelessWidget {
  const SimulationBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.champagne.withAlpha(p.dark ? 40 : 55),
        border: Border.all(color: AppColors.champagne.withAlpha(190)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Icon(Icons.science_outlined, size: 18, color: p.champagneText),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'MODE SIMULATION : les valeurs affichées sont fictives.',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, color: p.text),
          ),
        ),
      ]),
    );
  }
}
