import 'dart:async';

import 'package:flutter/material.dart';

import '../models/sensor_model.dart';
import '../services/iot_service.dart';
import '../widgets/connection_indicator.dart';
import '../widgets/countdown_progress.dart';
import '../widgets/custom_button.dart';
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
      _latest = r;
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

  @override
  Widget build(BuildContext context) {
    final failed = _status == ConnectionStatus.error;
    return Scaffold(
      appBar: AppBar(title: const Text('Espace capteurs')),
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.all(16), children: [
          if (widget.simulation) ...[const SimulationBanner(), const SizedBox(height: 12)],
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Liaison avec l’ESP32', style: TextStyle(fontWeight: FontWeight.bold)),
            ConnectionIndicator(status: _status),
          ]),
          const SizedBox(height: 16),
          SensorStatusTile(info: SensorInfo.pms5003, state: _sensorState),
          SensorStatusTile(info: SensorInfo.dht22, state: _sensorState),
          const Text('État de fonctionnement estimé par l’application.',
              style: TextStyle(fontSize: 12)),
          const SizedBox(height: 20),
          if (failed)
            Card(
              color: Colors.red.withAlpha(25),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 36),
                  const SizedBox(height: 8),
                  Text(_error ?? 'Erreur de connexion.', textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  CustomButton(label: 'Réessayer', icon: Icons.refresh, onPressed: _retry),
                ]),
              ),
            )
          else ...[
            const Text('Stabilisation des capteurs',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(_status == ConnectionStatus.connected
                ? 'Merci de patienter, les mesures seront affichées automatiquement.'
                : 'Connexion au dispositif en cours…'),
            const SizedBox(height: 16),
            Center(
              child: CountdownProgress(
                  remaining: _remaining, total: _total, active: _countdownRunning || _countdownDone),
            ),
            if (_countdownDone && _latest == null)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Stabilisation terminée, en attente de la première mesure…',
                    textAlign: TextAlign.center),
              ),
          ],
        ]),
      ),
    );
  }
}
