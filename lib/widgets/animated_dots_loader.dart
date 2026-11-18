import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AnimatedDotsLoader extends StatefulWidget {
  const AnimatedDotsLoader({
    super.key,
    this.text = 'Mesures en cours...',
  });

  final String text;

  @override
  State<AnimatedDotsLoader> createState() => _AnimatedDotsLoaderState();
}

class _AnimatedDotsLoaderState extends State<AnimatedDotsLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  // Décalage de phase pour chaque point
                  final double phase = (_controller.value - (index * 0.2)) % 1.0;
                  final double scale = phase < 0.5
                      ? 0.7 + (phase * 1.2)
                      : 1.3 - ((phase - 0.5) * 1.2);
                  final double opacity = phase < 0.5
                      ? 0.4 + (phase * 1.2)
                      : 1.0 - ((phase - 0.5) * 1.2);

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: p.accent.withOpacity(opacity.clamp(0.3, 1.0)),
                    ),
                    transform: Matrix4.identity()..scale(scale.clamp(0.7, 1.3)),
                    transformAlignment: Alignment.center,
                  );
                },
              );
            }),
          ),
          const SizedBox(height: 16),
          Text(
            widget.text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: p.text,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}