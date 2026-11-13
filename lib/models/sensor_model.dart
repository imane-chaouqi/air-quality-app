import 'package:flutter/material.dart';

/// États possibles de la liaison avec l'ESP32.
enum ConnectionStatus {
  disconnected('Déconnecté', Colors.grey),
  connecting('Connexion en cours', Colors.orange),
  connected('Connecté', Colors.green),
  error('Erreur de connexion', Colors.red);

  const ConnectionStatus(this.label, this.color);
  final String label;
  final Color color;
}

/// État de fonctionnement d'un capteur tel qu'ESTIMÉ par l'application
/// (l'ESP32 ne transmet pas, pour l'instant, de diagnostic matériel).
enum SensorState {
  unknown('Inconnu', Colors.grey),
  stabilizing('Stabilisation', Colors.orange),
  ready('Opérationnel', Colors.green);

  const SensorState(this.label, this.color);
  final String label;
  final Color color;
}

/// Niveau global de qualité de l'air (basé sur PM2.5 et PM10).
enum AirQualityLevel {
  good('Bon', Colors.green, Icons.sentiment_very_satisfied),
  moderate('Modéré', Colors.amber, Icons.sentiment_satisfied),
  poor('Mauvais', Colors.deepOrange, Icons.sentiment_dissatisfied),
  veryPoor('Très mauvais', Colors.red, Icons.sentiment_very_dissatisfied);

  const AirQualityLevel(this.label, this.color, this.icon);
  final String label;
  final Color color;
  final IconData icon;
}

/// Repères utilisés par l'application (µg/m³).
///
/// Ce sont les valeurs de référence OMS 2021 pour des MOYENNES SUR 24 HEURES
/// (ligne directrice et cibles intermédiaires 4 et 2). Elles NE SONT PAS des
/// seuils instantanés de sécurité : appliquées à une mesure ponctuelle, elles
/// servent uniquement de repère de prévention.
class AirQualityReferences {
  AirQualityReferences._();
  static const double pm25Guideline = 15;
  static const double pm10Guideline = 45;
  static const double pm25Interim4 = 25;
  static const double pm10Interim4 = 50;
  static const double pm25Interim2 = 50;
  static const double pm10Interim2 = 100;

  // Plages de confort INDICATIVES propres à l'application (pas des valeurs OMS).
  static const double tempMin = 18, tempMax = 27;
  static const double humMin = 30, humMax = 60;

  static const String disclaimer =
      'Les valeurs de référence OMS 2021 citées sont des moyennes sur 24 heures, '
      'pas des seuils instantanés de sécurité. Les plages de température et '
      'd’humidité sont indicatives. Ces informations sont une aide à la '
      'prévention et ne constituent pas un diagnostic médical.';
}

/// Une mesure transmise par le dispositif (ou simulée).
class SensorReading {
  const SensorReading({
    required this.temperature,
    required this.humidity,
    required this.pm25,
    required this.pm10,
    required this.timestamp,
    required this.isSimulated,
  });

  final double temperature; // °C (DHT22)
  final double humidity; // % (DHT22)
  final double pm25; // µg/m³ (PMS5003)
  final double pm10; // µg/m³ (PMS5003)
  final DateTime timestamp;

  /// true = valeur fictive générée par le mode simulation.
  final bool isSimulated;
}

/// Description d'un capteur pour l'affichage de l'espace capteurs.
class SensorInfo {
  const SensorInfo(this.name, this.measures, this.icon);
  final String name;
  final String measures;
  final IconData icon;

  static const pms5003 =
      SensorInfo('PMS5003', 'Particules fines PM2.5 et PM10', Icons.grain);
  static const dht22 =
      SensorInfo('DHT22', 'Température et humidité', Icons.thermostat);
}

/// Résultat de l'évaluation d'une mesure.
class AirQualityAssessment {
  const AirQualityAssessment._({
    required this.level,
    required this.pm25Level,
    required this.pm10Level,
    required this.temperatureOk,
    required this.humidityOk,
    required this.recommendations,
    required this.exposureAdvice,
  });

  final AirQualityLevel level;
  final AirQualityLevel pm25Level;
  final AirQualityLevel pm10Level;
  final bool temperatureOk;
  final bool humidityOk;
  final List<String> recommendations;

  /// Conseil QUALITATIF (aucune durée chiffrée : aucune donnée ne permet
  /// d'établir une durée d'exposition médicalement sûre).
  final String exposureAdvice;

  static AirQualityLevel _levelFor(double v, double g, double i4, double i2) {
    if (v <= g) return AirQualityLevel.good;
    if (v <= i4) return AirQualityLevel.moderate;
    if (v <= i2) return AirQualityLevel.poor;
    return AirQualityLevel.veryPoor;
  }

  static String _adviceFor(AirQualityLevel level) {
    switch (level) {
      case AirQualityLevel.good:
        return 'Aucune limitation particulière liée aux particules.';
      case AirQualityLevel.moderate:
        return 'Les personnes sensibles (asthme, enfants, personnes âgées) '
            'peuvent écourter leur présence prolongée dans la pièce.';
      case AirQualityLevel.poor:
        return 'Limitez le temps passé dans la pièce, surtout pour les '
            'personnes sensibles, et améliorez l’air avant une présence prolongée.';
      case AirQualityLevel.veryPoor:
        return 'Évitez de rester dans la pièce si possible tant que l’air ne '
            's’est pas amélioré.';
    }
  }

  static AirQualityAssessment evaluate(SensorReading r) {
    final l25 = _levelFor(r.pm25, AirQualityReferences.pm25Guideline,
        AirQualityReferences.pm25Interim4, AirQualityReferences.pm25Interim2);
    final l10 = _levelFor(r.pm10, AirQualityReferences.pm10Guideline,
        AirQualityReferences.pm10Interim4, AirQualityReferences.pm10Interim2);
    final level = l25.index >= l10.index ? l25 : l10; // le pire des deux
    final tOk = r.temperature >= AirQualityReferences.tempMin &&
        r.temperature <= AirQualityReferences.tempMax;
    final hOk = r.humidity >= AirQualityReferences.humMin &&
        r.humidity <= AirQualityReferences.humMax;

    final reco = <String>[];
    switch (level) {
      case AirQualityLevel.good:
        reco.add('L’air est favorable : aucune action particulière.');
        reco.add('Continuez à aérer régulièrement la pièce.');
        break;
      case AirQualityLevel.moderate:
        reco.add('Aérez la pièce si l’air extérieur est de bonne qualité.');
        reco.add('Évitez fumée, bougies et encens à l’intérieur.');
        reco.add('Les personnes sensibles peuvent éviter les efforts intenses.');
        break;
      case AirQualityLevel.poor:
        reco.add('Identifiez et réduisez la source (fumée, cuisson, poussière).');
        reco.add('Aérez si l’air extérieur est meilleur ; évitez de balayer à sec.');
        reco.add('Limitez les activités physiques dans cette pièce.');
        break;
      case AirQualityLevel.veryPoor:
        reco.add('Réduisez immédiatement les sources de pollution.');
        reco.add('Ventilez si l’air extérieur est meilleur, sinon changez de pièce.');
        reco.add('En cas de gêne respiratoire, demandez un avis médical.');
        break;
    }
    if (r.temperature < AirQualityReferences.tempMin) {
      reco.add('Température basse : chauffez légèrement la pièce.');
    } else if (r.temperature > AirQualityReferences.tempMax) {
      reco.add('Température élevée : ventilez ou rafraîchissez la pièce.');
    }
    if (r.humidity < AirQualityReferences.humMin) {
      reco.add('Air sec : un humidificateur peut aider.');
    } else if (r.humidity > AirQualityReferences.humMax) {
      reco.add('Humidité élevée : aérez ou déshumidifiez pour limiter les moisissures.');
    }

    return AirQualityAssessment._(
      level: level,
      pm25Level: l25,
      pm10Level: l10,
      temperatureOk: tOk,
      humidityOk: hOk,
      recommendations: reco,
      exposureAdvice: _adviceFor(level),
    );
  }
}
