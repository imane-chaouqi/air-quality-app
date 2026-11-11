import 'package:flutter/material.dart';
import '../models/sensor_model.dart';

/// Ligne décrivant un capteur et son état de fonctionnement estimé.
class SensorStatusTile extends StatelessWidget {
  const SensorStatusTile({super.key, required this.info, required this.state});
  final SensorInfo info;
  final SensorState state;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(info.icon, size: 30),
        title: Text(info.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(info.measures),
        trailing: Chip(
          label: Text(state.label, style: TextStyle(color: state.color, fontWeight: FontWeight.w600)),
          backgroundColor: state.color.withAlpha(30),
          side: BorderSide(color: state.color),
        ),
      ),
    );
  }
}
