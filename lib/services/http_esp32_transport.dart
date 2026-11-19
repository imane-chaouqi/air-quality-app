import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sensor_model.dart';
import 'iot_service.dart';

class HttpEsp32Transport implements Esp32Transport {
  HttpEsp32Transport({
    this.baseUrl = 'http://localhost:3000/api/measures',
  });

  final String baseUrl;
  final _readingCtrl = StreamController<SensorReading>.broadcast();
  Timer? _pollingTimer;
  int _consecutiveErrors = 0;

  @override
  Stream<SensorReading> get readings => _readingCtrl.stream;

  @override
  Future<void> open() async {
    final uri = Uri.parse('$baseUrl/status');
    final response = await http.get(uri).timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception('Serveur inaccessible (code ${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['mqttConnected'] != true) {
      throw Exception('Le serveur n’est pas connecté au broker MQTT.');
    }
  }

  @override
  Future<void> sendActivation() async {
    final uri = Uri.parse('$baseUrl/activate');
    final response = await http.post(uri).timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? 'Échec de l’activation de la maquette.');
    }

    // Démarre l'écoute des nouvelles mesures toutes les 2 secondes
    _consecutiveErrors = 0;
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (_) => _fetchLatest());
  }

  Future<void> _fetchLatest() async {
    try {
      final uri = Uri.parse('$baseUrl/latest');
      final response = await http.get(uri).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        _consecutiveErrors = 0;
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final reading = SensorReading(
          temperature: (json['temperature'] as num).toDouble(),
          humidity: (json['humidity'] as num).toDouble(),
          pm25: (json['pm25'] as num).toDouble(),
          pm10: (json['pm10'] as num).toDouble(),
          timestamp: DateTime.parse(json['timestamp'] as String),
          isSimulated: false,
        );
        if (!_readingCtrl.isClosed) {
          _readingCtrl.add(reading);
        }
      } else if (response.statusCode == 408) {
        _consecutiveErrors++;
        if (_consecutiveErrors >= 5 && !_readingCtrl.isClosed) {
          _readingCtrl.addError('Aucune nouvelle mesure reçue de l’ESP32.');
        }
      }
    } catch (e) {
      _consecutiveErrors++;
      if (_consecutiveErrors >= 4 && !_readingCtrl.isClosed) {
        _readingCtrl.addError('Erreur de communication avec le serveur.');
      }
    }
  }

  @override
  Future<void> close() async {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    if (!_readingCtrl.isClosed) {
      await _readingCtrl.close();
    }
  }
}