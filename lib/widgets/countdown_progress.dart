import 'package:flutter/material.dart';

/// Compte à rebours circulaire avec temps restant (mm:ss).
class CountdownProgress extends StatelessWidget {
  const CountdownProgress({super.key, required this.remaining, required this.total, this.active = true});
  final Duration remaining;
  final Duration total;
  final bool active;

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final progress = total.inSeconds == 0
        ? 1.0
        : 1 - remaining.inSeconds / total.inSeconds;
    return Column(children: [
      SizedBox(
        width: 180,
        height: 180,
        child: Stack(alignment: Alignment.center, children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: active ? progress.clamp(0.0, 1.0) : 0,
              strokeWidth: 10,
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text(_fmt(remaining),
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold)),
            const Text('restant'),
          ]),
        ]),
      ),
      const SizedBox(height: 16),
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LinearProgressIndicator(value: active ? progress.clamp(0.0, 1.0) : 0, minHeight: 10),
      ),
      const SizedBox(height: 6),
      Text('${(progress.clamp(0.0, 1.0) * 100).round()} % de la stabilisation'),
    ]);
  }
}
