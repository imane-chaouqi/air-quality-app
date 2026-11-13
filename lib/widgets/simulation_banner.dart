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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: p.warnFill,
        border: Border.all(color: AppColors.amber.withAlpha(170)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        Icon(Icons.science_outlined, size: 20, color: p.warnIcon),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'MODE SIMULATION : les valeurs affichées sont fictives.',
            style: TextStyle(
                fontWeight: FontWeight.w600, fontSize: 12.5, color: p.text),
          ),
        ),
      ]),
    );
  }
}
