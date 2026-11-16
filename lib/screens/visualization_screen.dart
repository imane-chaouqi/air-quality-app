import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_sidebar.dart';

class VisualizationScreen extends StatefulWidget {
  final String userName;
  final String userEmail;

  const VisualizationScreen({
    super.key,
    this.userName = 'Siham Mahis',
    this.userEmail = 'siham@mail.com',
  });

  @override
  State<VisualizationScreen> createState() => _VisualizationScreenState();
}

class _VisualizationScreenState extends State<VisualizationScreen> {
  String _period = 'Jour';

  static const _periods = ['Heure', 'Jour', 'Semaine', 'Mois'];

  static const Map<String, Map<String, List<double>>> _data = {
    'Heure': {
      'pm25': [22, 28, 31, 26, 35, 30, 27, 33, 29, 25],
      'temp': [22, 22, 23, 23, 24, 24, 23, 23, 22, 22],
      'hum': [54, 55, 55, 56, 57, 56, 55, 55, 54, 54],
      'pm10': [30, 34, 38, 33, 42, 40, 36, 39, 35, 32],
    },
    'Jour': {
      'pm25': [20, 35, 50, 30, 45, 60, 35, 55, 40, 65, 45],
      'temp': [22, 24, 23, 25, 28, 26, 25, 29, 27, 28],
      'hum': [50, 55, 60, 58, 62, 53, 56, 65, 60, 68],
      'pm10': [15, 25, 30, 28, 35, 40, 32, 38, 42, 36],
    },
    'Semaine': {
      'pm25': [28, 35, 18, 41, 25, 33, 30],
      'temp': [22, 21, 23, 20, 22, 24, 23],
      'hum': [55, 60, 52, 58, 59, 57, 56],
      'pm10': [38, 44, 29, 52, 36, 45, 40],
    },
    'Mois': {
      'pm25': [30, 27, 34, 29],
      'temp': [22, 21, 23, 22],
      'hum': [56, 58, 55, 57],
      'pm10': [40, 37, 43, 39],
    },
  };

  @override
  Widget build(BuildContext context) {
    final d = _data[_period]!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // On transmet le nom et l'email reçus de l'écran précédent
          AppSidebar(
            currentRoute: 'visualisation',
            userName: widget.userName,
            userEmail: widget.userEmail,
          ),
          Expanded(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text(
                  'Visualisation',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                centerTitle: true,
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _periodSelector(),
                      const SizedBox(height: 18),
                      _chartCard('PM2.5 (µg/m³)', d['pm25']!, AppColors.primaryTeal,
                          isBar: true),
                      const SizedBox(height: 14),
                      _chartCard('Température (°C)', d['temp']!, const Color(0xFF2EAD5B),
                          isBar: false),
                      const SizedBox(height: 14),
                      _chartCard('Humidité (%)', d['hum']!, const Color(0xFF8E6CF0),
                          isBar: true),
                      const SizedBox(height: 14),
                      _chartCard('PM10 (µg/m³)', d['pm10']!, const Color(0xFF19B5A5),
                          isBar: true),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _periodSelector() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
              color: AppColors.primaryDark.withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        children: _periods.map((p) {
          final selected = p == _period;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _period = p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: selected
                      ? const LinearGradient(
                          colors: [AppColors.primaryDark, AppColors.primaryTeal])
                      : null,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  p,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: selected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _chartCard(String title, List<double> values, Color color,
      {required bool isBar}) {
    final avg = values.reduce((a, b) => a + b) / values.length;
    final maxV = values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: AppColors.primaryDark.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('moy. ${avg.toStringAsFixed(0)}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: color)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 110,
            child: isBar
                ? _bars(values, maxV, color)
                : TweenAnimationBuilder<double>(
                    key: ValueKey('$title$_period'),
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (_, t, __) => CustomPaint(
                      size: Size.infinite,
                      painter: _LinePainter(values, color, t),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _bars(List<double> values, double maxV, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (int i = 0; i < values.length; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: TweenAnimationBuilder<double>(
                key: ValueKey('$color$_period$i'),
                tween: Tween(begin: 0, end: values[i] / (maxV * 1.1)),
                duration: Duration(milliseconds: 500 + i * 60),
                curve: Curves.easeOutCubic,
                builder: (_, v, __) => Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    heightFactor: v.clamp(0.02, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [color, color.withOpacity(0.45)],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _LinePainter extends CustomPainter {
  final List<double> v;
  final Color color;
  final double t;

  _LinePainter(this.v, this.color, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final minV = v.reduce((a, b) => a < b ? a : b) - 2;
    final maxV = v.reduce((a, b) => a > b ? a : b) + 2;
    final dx = size.width / (v.length - 1);

    Offset pt(int i) => Offset(
          i * dx,
          size.height - ((v[i] - minV) / (maxV - minV)) * size.height * t,
        );

    final grid = Paint()
      ..color = Colors.grey.withOpacity(0.15)
      ..strokeWidth = 1;
    for (int i = 0; i < 4; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final path = Path()..moveTo(pt(0).dx, pt(0).dy);
    for (int i = 0; i < v.length - 1; i++) {
      final p0 = pt(i), p1 = pt(i + 1);
      final mid = (p0.dx + p1.dx) / 2;
      path.cubicTo(mid, p0.dy, mid, p1.dy, p1.dx, p1.dy);
    }

    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withOpacity(0.28), color.withOpacity(0.0)],
        ).createShader(Offset.zero & size),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    for (int i = 0; i < v.length; i++) {
      canvas.drawCircle(pt(i), 4.5, Paint()..color = Colors.white);
      canvas.drawCircle(pt(i), 3, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter old) =>
      old.t != t || old.v != v;
}