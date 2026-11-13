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
import '../widgets/reading_sparkline.dart';
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
    this.clock,
  });

  final bool simulation;
  final SimulationScenario scenario;
  final bool simulateConnectionError;

  /// Démo uniquement (simulation) : réduit les 4 minutes à 10 secondes.
  final bool fastCountdown;

  /// Transport réel (à fournir quand le protocole ESP32 sera défini).
  final Esp32Transport? transport;

  /// Horloge injectable (tests uniquement). Par défaut : DateTime.now.
  final DateTime Function()? clock;

  static const Duration stabilization = Duration(minutes: 4);

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen>
    with WidgetsBindingObserver {
  static const int _maxHistory = 90;

  late IotService _service;
  StreamSubscription<ConnectionStatus>? _statusSub;
  StreamSubscription<SensorReading>? _readingSub;

  /// UNIQUE timer du compte à rebours (jamais plus d'un actif à la fois).
  Timer? _timer;

  /// Identifie la session en cours : une session périmée (retry, dispose)
  /// ne peut plus démarrer de compte à rebours.
  int _generation = 0;

  late Duration _total;
  late Duration _remaining;

  /// Instant de fin du compte à rebours. Le temps restant est TOUJOURS
  /// recalculé à partir de cette échéance (et non décrémenté tick par tick).
  late DateTime _deadline;

  ConnectionStatus _status = ConnectionStatus.disconnected;
  String? _error;
  SensorReading? _latest;
  final List<double> _pm25History = <double>[];
  bool _countdownRunning = false;
  bool _countdownDone = false;
  bool _linkLost = false;
  bool _navigated = false;

  DateTime _now() => (widget.clock ?? DateTime.now)();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _resetState();
    _start();
  }

  void _resetState() {
    _total = widget.simulation && widget.fastCountdown
        ? const Duration(seconds: 10)
        : AnalysisScreen.stabilization;
    _remaining = _total;
    _countdownRunning = false;
    _countdownDone = false;
    _linkLost = false;
    _latest = null;
    _error = null;
    _pm25History.clear();
  }

  /// Crée le service et lance connexion + activation.
  Future<void> _start() async {
    final gen = ++_generation;
    final service = createIotService(
      simulation: widget.simulation,
      scenario: widget.scenario,
      simulateConnectionError: widget.simulateConnectionError,
      transport: widget.transport,
    );
    _service = service;
    _status = service.status;
    _statusSub = service.statusStream.listen(_onStatus);
    _readingSub = service.readingStream.listen((r) {
      if (!mounted || gen != _generation) return;
      setState(() {
        _latest = r;
        _pm25History.add(r.pm25);
        if (_pm25History.length > _maxHistory) _pm25History.removeAt(0);
      });
      _tryFinish();
    });

    await service.connect();
    if (!mounted || gen != _generation || service.status != ConnectionStatus.connected) {
      return;
    }
    try {
      await service.requestActivation();
      if (!mounted || gen != _generation) return;
      _startCountdown();
    } catch (e) {
      if (mounted && gen == _generation) {
        setState(() {
          _status = ConnectionStatus.error;
          _error = 'Activation impossible : $e';
        });
      }
    }
  }

  void _onStatus(ConnectionStatus s) {
    if (!mounted) return;
    // Liaison perdue ou en erreur pendant la stabilisation : on arrête le
    // compte à rebours ET on l'indique clairement (carte d'erreur + Réessayer).
    final lost = (s == ConnectionStatus.error || s == ConnectionStatus.disconnected) &&
        _countdownRunning;
    if (lost) _stopTimer();
    setState(() {
      _status = s;
      _error = _service.errorMessage;
      if (lost) {
        _countdownRunning = false;
        _linkLost = true;
        _error ??= 'La liaison avec le dispositif a été perdue.';
      }
    });
  }

  // ---------------------------------------------------------------------
  // COMPTE À REBOURS
  // ---------------------------------------------------------------------

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// Démarre le compte à rebours (une seule fois, un seul timer).
  void _startCountdown() {
    if (!mounted || _countdownDone || (_timer?.isActive ?? false)) return;
    _deadline = _now().add(_total);
    setState(() {
      _remaining = _total;
      _countdownRunning = true;
    });
    // 250 ms : le texte (secondes entières) change au bon instant même si un
    // tick est retardé. Le temps restant vient de l'échéance, pas du nombre de ticks.
    _timer = Timer.periodic(const Duration(milliseconds: 250), (_) => _tick());
  }

  static int _ceilSeconds(Duration d) => (d.inMilliseconds + 999) ~/ 1000;

  void _tick() {
    if (!mounted || !_countdownRunning) return;
    final left = _deadline.difference(_now());
    if (left <= Duration.zero) {
      _completeCountdown();
      return;
    }
    final capped = left > _total ? _total : left;
    final secs = _ceilSeconds(capped);
    if (secs != _remaining.inSeconds) {
      setState(() => _remaining = Duration(seconds: secs));
    }
  }

  /// Action de fin : exécutée une seule fois (le timer est arrêté et
  /// `_countdownRunning` passe à false avant toute autre chose).
  void _completeCountdown() {
    _stopTimer();
    setState(() {
      _remaining = Duration.zero;
      _countdownRunning = false;
      _countdownDone = true;
    });
    _tryFinish();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Au retour au premier plan (écran déverrouillé, retour dans l'app) on
    // resynchronise immédiatement avec l'échéance réelle.
    if (state == AppLifecycleState.resumed) _tick();
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
    _generation++; // invalide toute session en cours
    await _teardown();
    if (!mounted) return;
    setState(_resetState);
    await _start();
  }

  Future<void> _teardown() async {
    _stopTimer();
    await _statusSub?.cancel();
    await _readingSub?.cancel();
    _statusSub = null;
    _readingSub = null;
    _service.dispose();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _generation++;
    _stopTimer();
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
    if (_status == ConnectionStatus.connecting) {
      return 'Connexion au dispositif en cours…';
    }
    if (_status == ConnectionStatus.connected) {
      return _countdownDone ? 'Système prêt' : 'Système actif · stabilisation en cours';
    }
    return 'Système en attente';
  }

  String _v(double? v, int digits) => v == null ? '—' : v.toStringAsFixed(digits);

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final failed = _status == ConnectionStatus.error || _linkLost;
    final r = _latest;
    final provisional = _sensorState == SensorState.stabilizing && r != null;

    final items = <Widget>[
      if (widget.simulation) const SimulationBanner(),
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
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Liaison avec l’ESP32',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5)),
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
          tint: AppColors.alertRed,
          padding: const EdgeInsets.all(14),
          child: Column(children: [
            Row(children: [
              const Icon(Icons.error_outline, color: AppColors.alertRed, size: 26),
              const SizedBox(width: 10),
              Expanded(
                child: Text(_error ?? 'Erreur de connexion.',
                    style: const TextStyle(fontSize: 13.5, height: 1.3)),
              ),
            ]),
            const SizedBox(height: 12),
            CustomButton(label: 'Réessayer', icon: Icons.refresh, onPressed: _retry),
          ]),
        ),
      if (!failed)
        GlassCard(
          strength: GlassStrength.strong,
          radius: 24,
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            CountdownProgress(
                remaining: _remaining,
                total: _total,
                active: _countdownRunning || _countdownDone),
            const SizedBox(height: 12),
            Text(
              _countdownDone && _latest == null
                  ? 'Stabilisation terminée, en attente de la première mesure…'
                  : _status == ConnectionStatus.connected
                      ? 'Merci de patienter : les résultats s’afficheront automatiquement.'
                      : 'Connexion au dispositif en cours…',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: p.muted, height: 1.3),
            ),
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
      if (_pm25History.length >= 2)
        GlassCard(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
          radius: 20,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(Icons.show_chart, size: 20, color: p.accentText),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Évolution des PM2.5',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
              ),
              Text('${_pm25History.length} mesures',
                  style: TextStyle(fontSize: 12, color: p.muted)),
            ]),
            const SizedBox(height: 8),
            ReadingSparkline(values: _pm25History, color: p.accent),
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
