import 'package:flutter/material.dart';

import '../models/sensor_model.dart';
import '../theme/app_colors.dart';

/// Pastille + libellé de l'état de connexion à l'ESP32.
class ConnectionIndicator extends StatelessWidget {
  const ConnectionIndicator({super.key, required this.status});
  final ConnectionStatus status;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final color = AppColors.connection(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(p.dark ? 50 : 34),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(180)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        status == ConnectionStatus.connecting
            ? SizedBox(
                width: 11,
                height: 11,
                child: CircularProgressIndicator(strokeWidth: 2, color: color))
            : Icon(Icons.circle, size: 10, color: color),
        const SizedBox(width: 7),
        Text(status.label,
            style: TextStyle(
                fontWeight: FontWeight.w600, fontSize: 12.5, color: p.text)),
      ]),
    );
  }
}
