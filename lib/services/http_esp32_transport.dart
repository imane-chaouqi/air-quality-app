import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/sensor_model.dart';
import 'iot_service.dart';

class HttpEsp32Transport implements Esp32Transport {

  HttpEsp32Transport({this.baseUrl = 'http://localhost:3000/api/measures'});


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

    // TEMP TEST SANS MONGODB : polling direct de la derniere mesure en memoire.
    _consecutiveErrors = 0;
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _fetchLatest(),
    );
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
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _fetchLatest(),
    );
    // TEMP TEST SANS MONGODB : lecture immediate pour ne pas attendre le premier tick.
    await _fetchLatest();
  }

  Future<void> _fetchLatest() async {
    try {
      final uri = Uri.parse('$baseUrl/latest');
      final response = await http.get(uri).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        // TEMP TEST SANS MONGODB : ignore proprement la reponse vide avant premiere mesure.
        if (json.isEmpty || json['received'] == false) {
          return;
        }
        _consecutiveErrors = 0;
        // TEMP TEST SANS MONGODB : conversion robuste des champs JSON MQTT.
        double mqttNumber(String key, [List<String> aliases = const []]) {
          final candidates = [key, ...aliases];
          for (final candidate in candidates) {
            final value = json[candidate];
            if (value is num) return value.toDouble();
            if (value is String) {
              final parsed = double.tryParse(value);
              if (parsed != null) return parsed;
            }
          }
          throw const FormatException('Champ de mesure MQTT absent');
        }

        final reading = SensorReading(
          temperature: mqttNumber('temperature', ['temp', 'temperature_c']),
          humidity: mqttNumber('humidity', ['hum']),
          pm25: mqttNumber('pm25', ['pm2.5', 'pm2_5']),
          pm10: mqttNumber('pm10'),
          timestamp:
              DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
              DateTime.now(),
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
      // ignore: avoid_print
      print('[HTTP] _fetchLatest erreur : $e');
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
   // On ne ferme pas le contrôleur : il vit autant que le transport.
}
}
