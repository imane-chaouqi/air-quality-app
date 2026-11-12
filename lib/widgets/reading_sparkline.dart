import 'package:flutter/material.dart';

/// Courbe compacte et statique des dernières valeurs reçues (widget auxiliaire
/// de l'écran d'analyse). Aucune donnée n'est inventée : seules les valeurs
/// fournies sont tracées.
class ReadingSparkline extends StatelessWidget {
  const ReadingSparkline({
    super.key,
    required this.values,
    required this.color,
    this.height = 70,
  });

  final List<double> values;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, height),
      painter: _SparklinePainter(List<double>.of(values), color),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter(this.values, this.color);
  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    var lo = values.reduce((a, b) => a < b ? a : b);
    var hi = values.reduce((a, b) => a > b ? a : b);
    if (hi - lo < 1) {
      lo -= 0.5;
      hi += 0.5;
    }
    const pad = 6.0;
    final w = size.width - pad * 2;
    final h = size.height - pad * 2;
    Offset pt(int i) => Offset(
          pad + w * i / (values.length - 1),
          pad + h * (1 - (values[i] - lo) / (hi - lo)),
        );

    final line = Path()..moveTo(pt(0).dx, pt(0).dy);
    for (var i = 1; i < values.length; i++) {
      line.lineTo(pt(i).dx, pt(i).dy);
    }
    final area = Path.from(line)
      ..lineTo(pt(values.length - 1).dx, size.height)
      ..lineTo(pt(0).dx, size.height)
      ..close();

    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withAlpha(70), color.withAlpha(0)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      line,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );
    canvas.drawCircle(pt(values.length - 1), 4, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) =>
      old.color != color ||
      old.values.length != values.length ||
      (values.isNotEmpty && old.values.last != values.last);
}
