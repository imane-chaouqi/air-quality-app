import 'package:flutter/material.dart';

/// Apparition très discrète (simple fondu de 220 ms, sans glissement).
/// Le paramètre [index] est conservé pour compatibilité avec l'ancienne API
/// mais n'introduit plus de décalage : l'interface reste calme et stable.
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({super.key, required this.child, this.index = 0});
  final Widget child;
  final int index;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      builder: (context, v, ch) => Opacity(opacity: v, child: ch),
      child: child,
    );
  }
}
