import 'dart:async';
import 'dart:math';

import '../models/sensor_model.dart';

/// Contrat de communication entre l'application et le dispositif ESP32.
/// Les écrans n'utilisent que cette interface, jamais un protocole précis.
abstract class IotService {
  bool get isSimulation;
  ConnectionStatus get status;
  String? get errorMessage;
  Stream<ConnectionStatus> get statusStream;
  Stream<SensorReading> get readingStream;

  /// Ouvre la liaison avec le dispositif.
  Future<void> connect();

  /// Demande l'activation du dispositif (bouton « Utiliser l'application »).
  Future<void> requestActivation();

  Future<void> disconnect();
  void dispose();
}

/// Gestion commune de l'état et des flux.
abstract class BaseIotService implements IotService {
  final _statusCtrl = StreamController<ConnectionStatus>.broadcast();
  final _readingCtrl = StreamController<SensorReading>.broadcast();
  ConnectionStatus _status = ConnectionStatus.disconnected;
  String? _error;

  @override
  ConnectionStatus get status => _status;
  @override
  String? get errorMessage => _error;
  @override
  Stream<ConnectionStatus> get statusStream => _statusCtrl.stream;
  @override
  Stream<SensorReading> get readingStream => _readingCtrl.stream;

  void setStatus(ConnectionStatus s, {String? error}) {
    _status = s;
    _error = error;
    if (!_statusCtrl.isClosed) _statusCtrl.add(s);
  }

  void emitReading(SensorReading r) {
    if (!_readingCtrl.isClosed) _readingCtrl.add(r);
  }

  @override
  void dispose() {
    _statusCtrl.close();
    _readingCtrl.close();
  }
}

// ---------------------------------------------------------------------------
// MODE SIMULATION : toutes les valeurs sont FICTIVES (isSimulated = true).
// ---------------------------------------------------------------------------

enum SimulationScenario {
  good('Air sain', 8, 20, 23, 45),
  moderate('Qualité modérée', 20, 40, 26, 55),
  poor('Air mauvais', 40, 80, 28, 65),
  veryPoor('Air très mauvais', 85, 150, 31, 75);

  const SimulationScenario(
      this.label, this.pm25, this.pm10, this.temperature, this.humidity);
  final String label;
  final double pm25, pm10, temperature, humidity;
}

class SimulatedIotService extends BaseIotService {
  SimulatedIotService({
    this.scenario = SimulationScenario.good,
    this.failConnection = false,
  });

  final SimulationScenario scenario;
  final bool failConnection;
  final Random _rnd = Random();
  Timer? _timer;
  bool _disposed = false;

  @override
  bool get isSimulation => true;

  @override
  Future<void> connect() async {
    setStatus(ConnectionStatus.connecting);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (_disposed) return;
    if (failConnection) {
      setStatus(ConnectionStatus.error,
          error: 'Erreur simulée : appareil injoignable (simulation).');
      return;
    }
    setStatus(ConnectionStatus.connected);
  }

  @override
  Future<void> requestActivation() async {
    if (status != ConnectionStatus.connected) {
      throw StateError('Dispositif non connecté.');
    }
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      double j(double base, double spread) =>
          max(0.0, base + (_rnd.nextDouble() * 2 - 1) * spread);
      emitReading(SensorReading(
        temperature: j(scenario.temperature, 0.4),
        humidity: j(scenario.humidity, 1.5),
        pm25: j(scenario.pm25, scenario.pm25 * 0.08),
        pm10: j(scenario.pm10, scenario.pm10 * 0.08),
        timestamp: DateTime.now(),
        isSimulated: true,
      ));
    });
  }

  @override
  Future<void> disconnect() async {
    _timer?.cancel();
    setStatus(ConnectionStatus.disconnected);
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// COMMUNICATION RÉELLE : aucun protocole n'est encore défini.
// ---------------------------------------------------------------------------

/// À implémenter une fois le protocole confirmé avec le développeur ESP32
/// (Wi‑Fi/HTTP, Bluetooth, MQTT…). Aucune adresse, URL, endpoint ou UUID
/// n'est fourni ici volontairement : ils doivent venir de la spécification.
abstract class Esp32Transport {
  Future<void> open();
  Future<void> sendActivation();

  /// Doit produire des SensorReading avec isSimulated = false.
  Stream<SensorReading> get readings;
  Future<void> close();
}

class Esp32IotService extends BaseIotService {
  Esp32IotService({this.transport});

  final Esp32Transport? transport;
  StreamSubscription<SensorReading>? _sub;

  @override
  bool get isSimulation => false;

  @override
  Future<void> connect() async {
    final t = transport;
    if (t == null) {
      setStatus(ConnectionStatus.error,
          error: 'Protocole ESP32 non défini : aucun transport configuré. '
              'Utilisez le mode simulation en attendant.');
      return;
    }
    setStatus(ConnectionStatus.connecting);
    try {
      await t.open().timeout(const Duration(seconds: 15));
      _sub = t.readings.listen(
        emitReading,
        onError: (Object e) => setStatus(ConnectionStatus.error,
            error: 'Erreur de réception : $e'),
        onDone: () => setStatus(ConnectionStatus.disconnected),
      );
      setStatus(ConnectionStatus.connected);
    } on TimeoutException {
      setStatus(ConnectionStatus.error,
          error: 'Délai dépassé : le dispositif ne répond pas.');
    } catch (e) {
      setStatus(ConnectionStatus.error, error: 'Connexion impossible : $e');
    }
  }

  @override
  Future<void> requestActivation() async {
    final t = transport;
    if (t == null || status != ConnectionStatus.connected) {
      throw StateError('Dispositif non connecté.');
    }
    await t.sendActivation();
  }

  @override
  Future<void> disconnect() async {
    await _sub?.cancel();
    await transport?.close();
    setStatus(ConnectionStatus.disconnected);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

/// Point unique de création du service (à adapter à l'intégration finale).
IotService createIotService({
  required bool simulation,
  SimulationScenario scenario = SimulationScenario.good,
  bool simulateConnectionError = false,
  Esp32Transport? transport,
}) {
  if (simulation) {
    return SimulatedIotService(
        scenario: scenario, failConnection: simulateConnectionError);
  }
  return Esp32IotService(transport: transport);
}
