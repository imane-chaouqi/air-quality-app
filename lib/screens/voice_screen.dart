import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/custom_button.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/glass_card.dart';

/// Page Voice : simple emplacement réservé, aucune logique vocale.
/// (La fonctionnalité vocale n'existe pas encore dans le projet : l'écran
/// conserve donc son message d'attente, présenté de façon plus soignée.)
class VoiceScreen extends StatelessWidget {
  const VoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return AppScaffold(
      title: 'Voice',
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: FadeSlideIn(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              GlassCard(
                strength: GlassStrength.strong,
                radius: 28,
                padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.ocean, AppColors.turquoise],
                      ),
                    ),
                    child: const Icon(Icons.mic, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Fonctionnalité en cours de développement.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, height: 1.25),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Elle sera disponible prochainement.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: p.muted),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    label: 'OK',
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ]),
              ),
              const SizedBox(height: 28),
              CustomPaint(
                size: const Size(double.infinity, 44),
                painter: _WaveformPainter(p.accent.withAlpha(p.dark ? 150 : 130)),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Forme d'onde décorative STATIQUE (aucune animation, aucun micro).
class _WaveformPainter extends CustomPainter {
  _WaveformPainter(this.color);
  final Color color;

  static const List<double> _bars = [
    0.18, 0.30, 0.22, 0.45, 0.35, 0.62, 0.40, 0.78, 0.52, 0.95, 0.60, 0.80,
    0.46, 0.68, 0.36, 0.55, 0.28, 0.42, 0.20, 0.32, 0.16,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final step = size.width / (_bars.length + 1);
    final cy = size.height / 2;
    for (var i = 0; i < _bars.length; i++) {
      final x = step * (i + 1);
      final h = size.height * _bars[i] / 2;
      canvas.drawLine(Offset(x, cy - h), Offset(x, cy + h), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter old) => old.color != color;
}
