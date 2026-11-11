import 'dart:async';

import 'package:flutter/material.dart';

import '../models/sensor_model.dart';
import '../services/iot_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/connection_indicator.dart';
import '../widgets/countdown_progress.dart';
import '../widgets/custom_button.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/glass_card.dart';
import '../widgets/sensor_status_tile.dart';
import '../widgets/simulation_banner.dart';
import 'result_screen.dart';

/// Espace capteurs : connexion à l'ESP32, activation, stabilisation (4 min),
/// puis passage automatique à l'écran des résultats.
class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({
    super.key,
    this.simulation = true,
    this.scenario = SimulationScenario.good,
    this.simulateConnectionError = false,
    this.fastCountdown = false,
    this.transport,
  });

  final bool simulation;
  final SimulationScenario scenario;
  final bool simulateConnectionError;

  /// Démo uniquement (simulation) : réduit les 4 minutes à 10 secondes.
  final bool fastCountdown;

  /// Transport réel (à fournir quand le protocole ESP32 sera défini).
  final Esp32Transport? transport;

  static const Duration stabilization = Duration(minutes: 4);

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  late IotService _service;
  StreamSubscription<ConnectionStatus>? _statusSub;
  StreamSubscription<SensorReading>? _readingSub;
  Timer? _timer;

  late Duration _total;
  late Duration _remaining;
  ConnectionStatus _status = ConnectionStatus.disconnected;
  String? _error;
  SensorReading? _latest;
  bool _countdownRunning = false;
  bool _countdownDone = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  /// (Re)crée le service et lance connexion + activation.
  Future<void> _start() async {
    _total = widget.simulation && widget.fastCountdown
        ? const Duration(seconds: 10)
        : AnalysisScreen.stabilization;
    _remaining = _total;
    _countdownRunning = false;
    _countdownDone = false;
    _latest = null;
    _error = null;

    _service = createIotService(
      simulation: widget.simulation,
      scenario: widget.scenario,
      simulateConnectionError: widget.simulateConnectionError,
      transport: widget.transport,
    );
    _status = _service.status;
    _statusSub = _service.statusStream.listen(_onStatus);
    _readingSub = _service.readingStream.listen((r) {
      if (!mounted) return;
      setState(() => _latest = r); // rafraîchit l'affichage des valeurs
      _tryFinish();
    });

    await _service.connect();
    if (!mounted || _service.status != ConnectionStatus.connected) return;
    try {
      await _service.requestActivation();
      _startCountdown();
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = ConnectionStatus.error;
          _error = 'Activation impossible : $e';
        });
      }
    }
  }

  void _onStatus(ConnectionStatus s) {
    if (!mounted) return;
    setState(() {
      _status = s;
      _error = _service.errorMessage;
    });
    // Liaison perdue ou en erreur pendant la stabilisation : on arrête.
    if ((s == ConnectionStatus.error || s == ConnectionStatus.disconnected) &&
        _countdownRunning) {
      _timer?.cancel();
      setState(() {
        _countdownRunning = false;
        _error ??= 'La liaison avec le dispositif a été perdue.';
      });
    }
  }

  void _startCountdown() {
    if (!mounted) return;
    setState(() => _countdownRunning = true);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      final next = _remaining - const Duration(seconds: 1);
      setState(() => _remaining = next.isNegative ? Duration.zero : next);
      if (_remaining == Duration.zero) {
        t.cancel();
        _countdownDone = true;
        _countdownRunning = false;
        _tryFinish();
      }
    });
  }

  /// Passe aux résultats quand stabilisation terminée ET mesure disponible.
  void _tryFinish() {
    if (_navigated || !mounted || !_countdownDone || _latest == null) return;
    _navigated = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ResultScreen(reading: _latest!)),
    );
  }

  Future<void> _retry() async {
    await _teardown();
    if (!mounted) return;
    setState(() {});
    await _start();
  }

  Future<void> _teardown() async {
    _timer?.cancel();
    await _statusSub?.cancel();
    await _readingSub?.cancel();
    _service.dispose();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _statusSub?.cancel();
    _readingSub?.cancel();
    _service.disconnect();
    _service.dispose();
    super.dispose();
  }

  SensorState get _sensorState {
    if (_status != ConnectionStatus.connected) return SensorState.unknown;
    return _countdownDone ? SensorState.ready : SensorState.stabilizing;
  }

  String get _systemText {
    if (_status == ConnectionStatus.error) return 'Système : erreur de liaison';
    if (_status == ConnectionStatus.connecting) return 'Connexion au dispositif en cours…';
    if (_status == ConnectionStatus.connected) {
      return _countdownDone ? 'Système prêt' : 'Système actif · stabilisation en cours';
    }
    return 'Système en attente';
  }

  String _v(double? v, int digits) => v == null ? '—' : v.toStringAsFixed(digits);

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final failed = _status == ConnectionStatus.error;
    final r = _latest;
    final provisional = _sensorState == SensorState.stabilizing && r != null;

    final items = <Widget>[
      if (widget.simulation) const SimulationBanner(),
      GlassCard(
        strength: GlassStrength.strong,
        padding: const EdgeInsets.all(12),
        radius: 18,
        child: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.champagne.withAlpha(p.dark ? 50 : 55),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(Icons.memory, size: 20, color: p.champagneText),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Liaison avec l’ESP32',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              Text(_systemText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: p.muted)),
            ]),
          ),
          const SizedBox(width: 8),
          ConnectionIndicator(status: _status),
        ]),
      ),
      if (failed)
        GlassCard(
          tint: AppColors.veryPoor,
          padding: const EdgeInsets.all(14),
          child: Column(children: [
            Row(children: [
              const Icon(Icons.error_outline, color: AppColors.veryPoor, size: 26),
              const SizedBox(width: 10),
              Expanded(
                child: Text(_error ?? 'Erreur de connexion.', style: const TextStyle(fontSize: 13.5)),
              ),
            ]),
            const SizedBox(height: 12),
            CustomButton(label: 'Réessayer', icon: Icons.refresh, onPressed: _retry),
          ]),
        ),
      SensorStatusTile(
        info: SensorInfo.pms5003,
        state: _sensorState,
        provisional: provisional,
        metrics: [
          SensorMetric('PM2.5', _v(r?.pm25, 1), 'µg/m³'),
          SensorMetric('PM10', _v(r?.pm10, 1), 'µg/m³'),
        ],
      ),
      SensorStatusTile(
        info: SensorInfo.dht22,
        state: _sensorState,
        provisional: provisional,
        metrics: [
          SensorMetric('Température', _v(r?.temperature, 1), '°C'),
          SensorMetric('Humidité', _v(r?.humidity, 0), '%'),
        ],
      ),
      if (!failed)
        GlassCard(
          strength: GlassStrength.strong,
          radius: 22,
          padding: const EdgeInsets.all(14),
          child: Column(children: [
            CountdownProgress(
                remaining: _remaining, total: _total, active: _countdownRunning || _countdownDone),
            const SizedBox(height: 10),
            Text(
              _countdownDone && _latest == null
                  ? 'Stabilisation terminée, en attente de la première mesure…'
                  : _status == ConnectionStatus.connected
                      ? 'Merci de patienter : les résultats s’afficheront automatiquement.'
                      : 'Connexion au dispositif en cours…',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: p.muted),
            ),
          ]),
        ),
      if (provisional || r == null)
        Text(
          'État de fonctionnement estimé par l’application.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11.5, color: p.muted),
        ),
    ];

    return AppScaffold(
      title: 'Espace capteurs',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            FadeSlideIn(index: i, child: items[i]),
          ],
        ],
      ),
    );
  }
}
