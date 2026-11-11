import 'package:flutter/material.dart';

/// Bandeau affiché partout où des valeurs fictives sont utilisées.
class SimulationBanner extends StatelessWidget {
  const SimulationBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.orange.withAlpha(40),
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(children: [
        Icon(Icons.science, color: Colors.orange),
        SizedBox(width: 10),
        Expanded(
          child: Text('MODE SIMULATION : valeurs fictives, ce ne sont pas des mesures réelles.',
              style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}
