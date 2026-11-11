import 'package:flutter/material.dart';
import '../models/sensor_model.dart';

/// Pastille + libellé de l'état de connexion à l'ESP32.
class ConnectionIndicator extends StatelessWidget {
  const ConnectionIndicator({super.key, required this.status});
  final ConnectionStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: status.color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: status.color),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        status == ConnectionStatus.connecting
            ? SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2, color: status.color))
            : Icon(Icons.circle, size: 12, color: status.color),
        const SizedBox(width: 8),
        Text(status.label, style: TextStyle(fontWeight: FontWeight.w600, color: status.color)),
      ]),
    );
  }
}
