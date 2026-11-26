import 'dart:async';

import 'package:flutter/material.dart';

import '../models/sensor_model.dart';
import '../services/http_esp32_transport.dart';
import '../services/iot_service.dart';
import '../theme/app_colors.dart';
import '../widgets/animated_dots_loader.dart';
import '../widgets/app_sidebar.dart';
import 'result_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final bool isSensitiveProfile; // true si profil sensible (asthme, allergies, enfant, senior)
  final bool simulation;
  final Esp32Transport? transport;

  const DashboardScreen({
    super.key,
    this.userName = 'Siham Mahis',
    this.userEmail = 'siham@mail.com',
    this.isSensitiveProfile = false,
    this.simulation = false,
    this.transport,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late IotService _service;
  StreamSubscription<ConnectionStatus>? _statusSub;
  StreamSubscription<SensorReading>? _readingSub;

  int _generation = 0;
  ConnectionStatus _status = ConnectionStatus.disconnected;
  String? _error;
  SensorReading? _latest;
  bool _isWaitingForData = false;
  bool _linkLost = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final gen = ++_generation;
    final effectiveTransport = widget.simulation
        ? null
        : (widget.transport ??
              HttpEsp32Transport(
                baseUrl: 'http://localhost:3000/api/measures',
              ));

    final service = createIotService(
      simulation: widget.simulation,
      transport: effectiveTransport,
    );

    _service = service;
    _status = service.status;
    _statusSub = service.statusStream.listen(_onStatus);
    _readingSub = service.readingStream.listen((r) {
      if (!mounted || gen != _generation) return;
      setState(() {
        _latest = r;
        _isWaitingForData = false;
        _linkLost = false;
      });
    });

    await service.connect();
    if (!mounted ||
        gen != _generation ||
        service.status != ConnectionStatus.connected) {
      return;
    }

    try {
      await service.requestActivation();
      if (!mounted || gen != _generation) return;
      setState(() {
        _isWaitingForData = _latest == null;
      });
    } catch (e) {
      if (mounted && gen == _generation) {
        setState(() {
          _status = ConnectionStatus.error;
          _error = 'Activation impossible : $e';
          _isWaitingForData = false;
        });
      }
    }
  }

  void _onStatus(ConnectionStatus s) {
    if (!mounted) return;
    final lost =
        (s == ConnectionStatus.error || s == ConnectionStatus.disconnected) &&
        (_isWaitingForData || _latest != null);
    setState(() {
      _status = s;
      _error = _service.errorMessage;
      if (lost) {
        _isWaitingForData = false;
        _linkLost = true;
        _error ??= 'La liaison avec la maquette a été interrompue.';
      }
    });
  }

  Future<void> _retry() async {
    _generation++;
    await _statusSub?.cancel();
    await _readingSub?.cancel();
    _service.dispose();
    if (!mounted) return;
    setState(() {
      _latest = null;
      _error = null;
      _linkLost = false;
      _isWaitingForData = false;
    });
    await _start();
  }

  @override
  void dispose() {
    _generation++;
    _statusSub?.cancel();
    _readingSub?.cancel();
    _service.disconnect();
    _service.dispose();
    super.dispose();
  }

  /// Traduit les mesures techniques en message clair adapté au profil utilisateur
  ({
    String title,
    String actionMessage,
    String simpleExplanation,
    Color color,
    IconData icon,
  })
  _getPersonalizedVerdict(AirQualityAssessment assessment) {
    final sensitive = widget.isSensitiveProfile;
    switch (assessment.level) {
      case AirQualityLevel.good:
        return (
          title: 'L’air est sain pour vous',
          actionMessage:
              'Vous pouvez rester dans cette pièce en toute sécurité.',
          simpleExplanation: 'Le taux de particules fines est faible et l’air est parfaitement respirable.',
          color: Colors.green,
          icon: Icons.check_circle_outline_rounded,
        );
      case AirQualityLevel.moderate:
        return (
          title: sensitive
              ? 'Attention : air moyen pour votre profil sensible'
              : 'Qualité de l’air moyenne',
          actionMessage: sensitive
              ? 'Évitez de rester trop longtemps dans cette pièce et pensez à aérer.'
              : 'Vous pouvez rester, mais ouvrez une fenêtre pour renouveler l’air.',
          simpleExplanation: 'Une légère présence de poussières fines a été détectée dans l’air.',
          color: Colors.amber.shade700,
          icon: Icons.info_outline_rounded,
        );
      case AirQualityLevel.poor:
        return (
          title: 'Mauvaise qualité de l’air détectée',
          actionMessage: sensitive
              ? 'Sortez de cette pièce dès maintenant et ventilez l’espace.'
              : 'Limitez votre présence ici et aérez immédiatement la pièce.',
          simpleExplanation: 'L’air est chargé en particules fines (fumée, cuisson ou poussière).',
          color: Colors.deepOrange,
          icon: Icons.warning_amber_rounded,
        );
      case AirQualityLevel.veryPoor:
        return (
          title: 'Alerte : air très pollué et nocif',
          actionMessage:
              'Sortez immédiatement de cette pièce et ne restez pas exposé.',
          simpleExplanation: 'Niveau élevé de particules fines pouvant provoquer une gêne respiratoire.',
          color: Colors.red,
          icon: Icons.dangerous_outlined,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final failed = _status == ConnectionStatus.error || _linkLost;
    final r = _latest;
    final assessment = r != null ? AirQualityAssessment.evaluate(r) : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          AppSidebar(
            currentRoute: 'mesures',
            userName: widget.userName,
            userEmail: widget.userEmail,
          ),
          Expanded(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTopBar(),
                    const SizedBox(height: 16),

                    // ÉTAT 1 : ERREUR DE COMMUNICATION
                    if (failed) _buildErrorCard(),

                    // ÉTAT 2 & 3 : CONNEXION OU ATTENTE DES DONNÉES
                    if (!failed && r == null) _buildWaitingCard(),

                    // ÉTAT 4 : DONNÉES REÇUES + MESSAGE PERSONNALISÉ VULGARISÉ
                    if (!failed && r != null && assessment != null) ...[
                      // TEMP TEST MAQUETTE : affichage indique l'origine live MQTT.
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.softTealBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.primaryTeal.withOpacity(0.3),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.sensors,
                              size: 18,
                              color: AppColors.primaryTeal,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'MODE TEST MAQUETTE - dernière mesure MQTT reçue',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildPersonalizedVerdictCard(assessment),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildPollutantCard(
                            'PM2.5',
                            r.pm25.toStringAsFixed(1),
                            'µg/m³',
                            assessment.pm25Level.label,
                            assessment.pm25Level.color,
                          ),
                          const SizedBox(width: 10),
                          _buildPollutantCard(
                            'PM10',
                            r.pm10.toStringAsFixed(1),
                            'µg/m³',
                            assessment.pm10Level.label,
                            assessment.pm10Level.color,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _buildClimateCard(
                              icon: Icons.thermostat,
                              iconColor: Colors.redAccent,
                              label: 'Température',
                              value: '${r.temperature.toStringAsFixed(1)} °C',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildClimateCard(
                              icon: Icons.water_drop_outlined,
                              iconColor: AppColors.primaryTeal,
                              label: 'Humidité',
                              value: '${r.humidity.toStringAsFixed(0)} %',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _buildRecommendationsCard(assessment),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ResultScreen(reading: r),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.analytics_outlined,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Voir le diagnostic complet',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryTeal,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalizedVerdictCard(AirQualityAssessment assessment) {
    final verdict = _getPersonalizedVerdict(assessment);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: verdict.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: verdict.color.withOpacity(0.45), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(verdict.icon, color: verdict.color, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isSensitiveProfile
                          ? 'Analyse adaptée à votre profil sensible'
                          : 'Analyse personnalisée',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: verdict.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      verdict.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: verdict.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              verdict.actionMessage,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            verdict.simpleExplanation,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Mesures',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.circle, size: 10, color: _status.color),
              const SizedBox(width: 6),
              Text(
                _status.label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: _status.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWaitingCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          AnimatedDotsLoader(
            text: _status == ConnectionStatus.connecting
                ? 'Connexion à la maquette...'
                : 'Mesures en cours...',
          ),
          const SizedBox(height: 8),
          const Text(
            'Acquisition des capteurs PMS5003 et DHT22...',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacity(0.35)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _error ?? 'Erreur de communication avec la maquette.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: _retry,
            icon: const Icon(Icons.refresh, size: 18, color: Colors.white),
            label: const Text(
              'Réessayer',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPollutantCard(
    String title,
    String value,
    String unit,
    String status,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              unit,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClimateCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard(AirQualityAssessment assessment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nos recommandations',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < assessment.recommendations.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle,
                  color: assessment.level.color,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    assessment.recommendations[i],
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
