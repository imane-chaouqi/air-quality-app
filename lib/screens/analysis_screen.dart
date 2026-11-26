import 'dart:async';
import 'package:flutter/material.dart';

import '../models/sensor_model.dart';
import '../services/http_esp32_transport.dart';
import '../services/iot_service.dart';
import '../theme/app_colors.dart';
import '../widgets/animated_dots_loader.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/connection_indicator.dart';
import '../widgets/custom_button.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/glass_card.dart';
import '../widgets/sensor_status_tile.dart';
import '../widgets/simulation_banner.dart';
import 'result_screen.dart';

/// Espace capteurs : connexion à l'ESP32, attente des mesures en direct,
/// affichage des valeurs reçues et accès à l'évaluation.
class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({
    super.key,
    this.simulation = false, // Passé à false par défaut pour utiliser le vrai Back-end
    this.scenario = SimulationScenario.good,
    this.simulateConnectionError = false,
    this.transport,
    this.categories,
  });

  final bool simulation;
  final SimulationScenario scenario;
  final bool simulateConnectionError;
  final Esp32Transport? transport;
  final List<int>? categories; // catégories de l'utilisateur (1 à 4)

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
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
    _resetState();
    _start();
  }

  void _resetState() {
    _isWaitingForData = false;
    _linkLost = false;
    _latest = null;
    _error = null;
  }

  Future<void> _start() async {
    final gen = ++_generation;
    // Si simulation = false et aucun transport fourni, on utilise HttpEsp32Transport
    final effectiveTransport = widget.simulation
        ? null
        : (widget.transport ?? HttpEsp32Transport());

    final service = createIotService(
      simulation: widget.simulation,
      scenario: widget.scenario,
      simulateConnectionError: widget.simulateConnectionError,
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
        _isWaitingForData = true;
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
    await _teardown();
    if (!mounted) return;
    setState(_resetState);
    await _start();
  }

  Future<void> _teardown() async {
    await _statusSub?.cancel();
    await _readingSub?.cancel();
    _statusSub = null;
    _readingSub = null;
    _service.dispose();
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

  // Gestion claire des 4 états demandés
  SensorState get _sensorState {
    if (_status != ConnectionStatus.connected) return SensorState.unknown;
    if (_latest == null) return SensorState.stabilizing;
    return SensorState.ready;
  }

  String get _systemText {
    if (_status == ConnectionStatus.error || _linkLost) {
      return 'État : Erreur de communication';
    }
    if (_status == ConnectionStatus.connecting) {
      return 'État : Connexion à la maquette...';
    }
    if (_status == ConnectionStatus.connected && _latest == null) {
      return 'État : En attente des données des capteurs...';
    }
    if (_status == ConnectionStatus.connected && _latest != null) {
      return 'État : Données reçues en temps réel';
    }
    return 'État : En attente';
  }

  String _v(double? v, int digits) => v == null ? '—' : v.toStringAsFixed(digits);

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final failed = _status == ConnectionStatus.error || _linkLost;
    final r = _latest;
    final hasData = r != null && !failed;

    final items = <Widget>[
      if (widget.simulation) const SimulationBanner(),

      // 1. Carte d'état de la liaison avec la maquette
      GlassCard(
        strength: GlassStrength.strong,
        padding: const EdgeInsets.all(14),
        radius: 20,
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: p.chipFill,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(Icons.memory, size: 22, color: p.accentText),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Liaison avec la maquette ESP32',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5)),
                const SizedBox(height: 2),
                Text(_systemText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: p.muted)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ConnectionIndicator(status: _status),
        ]),
      ),

      // 2. État Erreur de communication
      if (failed)
        GlassCard(
          tint: AppColors.alertRed,
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Row(children: [
              const Icon(Icons.error_outline,
                  color: AppColors.alertRed, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _error ?? 'Erreur de communication avec la maquette.',
                  style: const TextStyle(fontSize: 13.5, height: 1.35),
                ),
              ),
            ]),
            const SizedBox(height: 14),
            CustomButton(
                label: 'Réessayer la connexion',
                icon: Icons.refresh,
                onPressed: _retry),
          ]),
        ),

      // 3. État Connexion / Attente des données (Trois points animés + "Mesures en cours...")
      if (!failed && !hasData)
        GlassCard(
          strength: GlassStrength.strong,
          radius: 24,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(children: [
            AnimatedDotsLoader(
              text: _status == ConnectionStatus.connecting
                  ? 'Connexion à la maquette...'
                  : 'Mesures en cours...',
            ),
            const SizedBox(height: 8),
            Text(
              'Acquisition des données du PMS5003, de l’AHT et de l’ENS160.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: p.muted),
            ),
          ]),
        ),

      // 4. Affichage amélioré des mesures reçues (Capteurs PMS5003 & DHT22)
      SensorStatusTile(
        info: SensorInfo.pms5003,
        state: _sensorState,
        provisional: false,
        metrics: [
          SensorMetric('PM2.5', _v(r?.pm25, 1), 'µg/m³'),
          SensorMetric('PM10', _v(r?.pm10, 1), 'µg/m³'),
        ],
      ),
      SensorStatusTile(
        info: SensorInfo.dht22,
        state: _sensorState,
        provisional: false,
        metrics: [
          SensorMetric('Température', _v(r?.temperature, 1), '°C'),
          SensorMetric('Humidité', _v(r?.humidity, 0), '%'),
        ],
      ),
      
      SensorStatusTile(
        info: SensorInfo.ens160,
        state: _sensorState,
        provisional: false,
        metrics: [
          SensorMetric('CO₂ estimé (eCO2)', _v(r?.eco2, 0), 'ppm'),
          SensorMetric('TVOC', _v(r?.tvoc, 0), 'ppb'),
        ],
      ),
      if (hasData)
        Text(AirQualityReferences.gasDisclaimer,
            style: TextStyle(fontSize: 11.5, color: p.muted, height: 1.35)),
      
      // Bouton d'accès direct à l'analyse complète dès que les mesures sont reçues
      if (hasData)
        CustomButton(
          label: 'Voir le diagnostic complet',
          icon: Icons.analytics_outlined,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ResultScreen(reading: r, categories: widget.categories)),
            );
          },
        ),
    ];

    return AppScaffold(
      title: 'Espace capteurs',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            FadeSlideIn(index: i, child: items[i]),
          ],
        ],
      ),
    );
  }
}