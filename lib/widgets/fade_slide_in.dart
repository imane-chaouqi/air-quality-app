import 'package:flutter/material.dart';

/// Apparition progressive (fondu + léger glissement). L'index décale
/// légèrement la durée pour donner un effet d'enchaînement discret.
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({super.key, required this.child, this.index = 0});
  final Widget child;
  final int index;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 320 + 80 * index.clamp(0, 6)),
      curve: Curves.easeOutCubic,
      builder: (context, v, ch) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, (1 - v) * 14), child: ch),
      ),
      child: child,
    );
  }
}
