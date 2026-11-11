import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Compte à rebours compact : anneau animé + temps restant + barre de
/// progression + état de stabilisation. (Affichage uniquement : la logique du
/// compte à rebours reste dans AnalysisScreen.)
class CountdownProgress extends StatelessWidget {
  const CountdownProgress({
    super.key,
    required this.remaining,
    required this.total,
    this.active = true,
  });

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
    final p = AppPalette.of(context);
    final progress = total.inSeconds == 0
        ? 1.0
        : (1 - remaining.inSeconds / total.inSeconds).clamp(0.0, 1.0);
    final shown = active ? progress : 0.0;
    final done = total.inSeconds > 0 && remaining == Duration.zero;
    final stateColor = done ? AppColors.good : AppColors.moderate;
    final stateText = done
        ? 'Capteurs prêts'
        : active
            ? 'Stabilisation en cours'
            : 'En attente de connexion';

    return Row(children: [
      SizedBox(
        width: 108,
        height: 108,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(end: shown),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOut,
          builder: (context, v, _) => CustomPaint(
            painter: _RingPainter(v, p.text.withAlpha(p.dark ? 30 : 22)),
            child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(_fmt(remaining),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                Text('restant', style: TextStyle(fontSize: 11, color: p.muted)),
              ]),
            ),
          ),
        ),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Stabilisation des capteurs',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Row(children: [
            Icon(Icons.circle, size: 9, color: stateColor),
            const SizedBox(width: 6),
            Flexible(
              child: Text(stateText,
                  style: TextStyle(fontSize: 12.5, color: p.muted),
                  overflow: TextOverflow.ellipsis),
            ),
          ]),
          const SizedBox(height: 10),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(end: shown),
            duration: const Duration(milliseconds: 900),
            builder: (context, v, _) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: v,
                minHeight: 8,
                color: AppColors.turquoise,
                backgroundColor: p.text.withAlpha(p.dark ? 30 : 22),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text('${(shown * 100).round()} % de la stabilisation',
              style: TextStyle(fontSize: 11.5, color: p.muted)),
        ]),
      ),
    ]);
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.progress, this.track);
  final double progress;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 9.0;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    canvas.drawArc(
      rect,
      0,
      2 * math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = track,
    );
    if (progress <= 0) return;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = stroke
        ..shader = const SweepGradient(
          startAngle: 0,
          endAngle: 2 * math.pi,
          colors: [AppColors.turquoise, AppColors.champagne, AppColors.turquoise],
          transform: GradientRotation(-math.pi / 2),
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.track != track;
}
