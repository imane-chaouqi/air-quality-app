import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'register_screen.dart';
import 'login_screen.dart';
import 'form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _orbit = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
  )..repeat();

  @override
  void dispose() {
    _orbit.dispose();
    super.dispose();
  }

  Widget _appear(int index, Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + index * 120),
      curve: Curves.easeOutCubic,
      builder: (context, v, c) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 24 * (1 - v)), child: c),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: -110,
            right: -90,
            child: _halo(300, AppColors.primaryTeal.withOpacity(0.14)),
          ),
          Positioned(
            top: 260,
            left: -120,
            child: _halo(240, AppColors.primaryDark.withOpacity(0.06)),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 120,
            child: IgnorePointer(
              child: CustomPaint(painter: _WavePainter()),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _appear(0, _buildHeader()),
                  const SizedBox(height: 28),
                  _appear(1, _buildHeroCard()),
                  const SizedBox(height: 32),
                  _appear(2, _buildPrimaryButton()),
                  const SizedBox(height: 14),
                  _appear(3, _buildSecondaryButton()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _halo(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryDark, AppColors.primaryTeal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryTeal.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(Icons.air, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        const Text(
          'AirSense',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDark,
            letterSpacing: 0.3,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.nightlight_round,
              size: 18, color: AppColors.primaryDark),
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: 130,
            height: 130,
            child: AnimatedBuilder(
              animation: _orbit,
              builder: (context, _) => CustomPaint(
                painter: _OrbitPainter(_orbit.value),
                child: Center(
                  child: Container(
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryDark, AppColors.primaryTeal],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryTeal.withOpacity(0.4),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.waves_rounded,
                        size: 38, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Surveillance de la qualité\nde l’air intérieur',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Particules fines, température et humidité, avec des recommandations adaptées à votre profil.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              _featureBadge(Icons.blur_on, 'PM2.5 · PM10'),
              const SizedBox(width: 10),
              _featureBadge(Icons.thermostat, 'Température'),
              const SizedBox(width: 10),
              _featureBadge(Icons.water_drop_outlined, 'Humidité'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _featureBadge(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.subCardBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: AppColors.primaryTeal.withOpacity(0.12), width: 1),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.softTealBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primaryTeal, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primaryTeal],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTeal.withOpacity(0.38),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegisterScreen()),
          );
          if (result != null && result is Map<String, String> && mounted) {
            // Redirige directement vers l'espace connecté avec le menu latéral !
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => FormScreen(
                  userName: result['name']!,
                  userEmail: result['email']!,
                ),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 17),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              'S’inscrire',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton() {
    return OutlinedButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.85),
        side: BorderSide(
            color: AppColors.primaryTeal.withOpacity(0.45), width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.login_rounded, color: AppColors.primaryDark, size: 20),
          SizedBox(width: 10),
          Text(
            'Connexion',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark),
          ),
        ],
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  final double t;
  _OrbitPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 4;

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = AppColors.primaryTeal.withOpacity(0.25);
    canvas.drawCircle(c, r, ring);
    canvas.drawCircle(
        c, r - 12, ring..color = AppColors.primaryTeal.withOpacity(0.12));

    final dot = Paint()..color = AppColors.primaryTeal;
    for (int i = 0; i < 8; i++) {
      final a = 2 * math.pi * (i / 8) + t * 2 * math.pi;
      final p = Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
      canvas.drawCircle(
          p,
          i.isEven ? 3.6 : 2.4,
          dot
            ..color =
                AppColors.primaryTeal.withOpacity(i.isEven ? 0.95 : 0.5));
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter old) => old.t != t;
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path wave(double base, double amp, double phase) {
      final p = Path()..moveTo(0, size.height);
      p.lineTo(0, base);
      for (double x = 0; x <= size.width; x += 4) {
        p.lineTo(
            x, base + amp * math.sin((x / size.width) * 2 * math.pi + phase));
      }
      p.lineTo(size.width, size.height);
      p.close();
      return p;
    }

    canvas.drawPath(wave(size.height * 0.45, 12, 0),
        Paint()..color = AppColors.primaryTeal.withOpacity(0.18));
    canvas.drawPath(wave(size.height * 0.62, 10, 1.6),
        Paint()..color = AppColors.primaryTeal.withOpacity(0.28));
    canvas.drawPath(wave(size.height * 0.80, 8, 3.2),
        Paint()..color = AppColors.primaryDark.withOpacity(0.35));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}