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
  // Valeurs ANNUELLES OMS 2021 : limite de la zone « bon » pour les profils sensibles.
  static const double pm25Annual = 5;
  static const double pm10Annual = 15;

  // Plages de confort INDICATIVES propres à l'application (pas des valeurs OMS).
  static const double tempMin = 18, tempMax = 27;
  static const double humMin = 30, humMax = 60;
  
  // CO2 estimé (eCO2, ppm) : repères de l'agence allemande de l'environnement
  // (< 1000 : bon ; 1000 à 2000 : modéré ; > 2000 : mauvais). Valeurs indicatives.
  static const double eco2Good = 1000;
  static const double eco2Moderate = 2000;

  // TVOC (ppb) : repères provisoires, à confirmer dans la fiche technique du capteur.
  static const double tvocGood = 220;
  static const double tvocModerate = 660;
  static const double tvocPoor = 2200;

  static const String gasDisclaimer =
      'Le CO₂ affiché (eCO2) est une ESTIMATION calculée par le capteur à partir '
      'des gaz présents dans l’air, pas une mesure directe du CO₂. Le TVOC '
      'représente l’ensemble des composés organiques volatils. Ces valeurs sont '
      'indicatives et peuvent être imprécises juste après l’allumage du capteur.';

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
    this.tvoc,
    this.eco2,
  });

  final double temperature; // °C (AHT)
  final double humidity; // % (AHT)
  final double pm25; // µg/m³ (PMS5003)
  final double pm10; // µg/m³ (PMS5003)
  final double? tvoc; // ppb (ENS160), null si non reçu
  final double? eco2; // ppm, CO2 estimé (ENS160), null si non reçu
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
      SensorInfo('AHT', 'Température et humidité', Icons.thermostat);
  static const ens160 = SensorInfo('ENS160',
      'CO₂ estimé (eCO2) et composés organiques volatils (TVOC)', Icons.air);
}

/// Résultat de l'évaluation d'une mesure.
class AirQualityAssessment {
  const AirQualityAssessment._({
    required this.level,
    required this.pmLevel,
    required this.pm25Level,
    required this.pm10Level,
    required this.eco2Level,
    required this.tvocLevel,
    required this.temperatureOk,
    required this.humidityOk,
    required this.recommendations,
    required this.exposureAdvice,
  });

  /// Niveau global affiché à l'utilisateur.
  final AirQualityLevel level;

  /// Niveau dû uniquement aux particules.
  final AirQualityLevel pmLevel;
  final AirQualityLevel pm25Level;
  final AirQualityLevel pm10Level;

  /// Niveaux liés aux gaz (null si la mesure n'est pas disponible).
  final AirQualityLevel? eco2Level;
  final AirQualityLevel? tvocLevel;

  final bool temperatureOk;
  final bool humidityOk;
  final List<String> recommendations;

  /// Conseil QUALITATIF (aucune durée chiffrée : aucune donnée ne permet
  /// d'établir une durée d'exposition médicalement sûre).
  final String exposureAdvice;

  /// true si les gaz (eCO2 / TVOC) ont relevé le niveau global.
  bool get gasRaisedLevel => level.index > pmLevel.index;

  static AirQualityLevel _levelFor(double v, double g, double i4, double i2) {
    if (v <= g) return AirQualityLevel.good;
    if (v <= i4) return AirQualityLevel.moderate;
    if (v <= i2) return AirQualityLevel.poor;
    return AirQualityLevel.veryPoor;
  }

  static AirQualityLevel _levelForEco2(double v) {
    if (v <= AirQualityReferences.eco2Good) return AirQualityLevel.good;
    if (v <= AirQualityReferences.eco2Moderate) return AirQualityLevel.moderate;
    return AirQualityLevel.poor;
  }

  static AirQualityLevel _levelForTvoc(double v) {
    if (v <= AirQualityReferences.tvocGood) return AirQualityLevel.good;
    if (v <= AirQualityReferences.tvocModerate) return AirQualityLevel.moderate;
    if (v <= AirQualityReferences.tvocPoor) return AirQualityLevel.poor;
    return AirQualityLevel.veryPoor;
  }

  static AirQualityLevel _worst(AirQualityLevel a, AirQualityLevel b) =>
      a.index >= b.index ? a : b;

  /// Les gaz sont des estimations : ils ne peuvent pas, à eux seuls,
  /// donner le niveau « très mauvais ».
  static AirQualityLevel _capAtPoor(AirQualityLevel l) =>
      l.index > AirQualityLevel.poor.index ? AirQualityLevel.poor : l;

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

  /// [categories] : catégories de l'utilisateur (1 à 4). Si elles sont absentes,
  /// seuls les particules, la température et l'humidité décident du niveau.
  /// Catégories 3 et 4 : l'eCO2 peut relever le niveau.
  /// Catégories 1 et 2 : le TVOC peut relever le niveau.
  static AirQualityAssessment evaluate(SensorReading r,
      {List<int>? categories}) {
    final cats = categories ?? const <int>[];
    final sensitive = cats.contains(1) || cats.contains(2);
    final l25 = sensitive
        ? _levelFor(r.pm25, AirQualityReferences.pm25Annual,
            AirQualityReferences.pm25Guideline, AirQualityReferences.pm25Interim4)
        : _levelFor(r.pm25, AirQualityReferences.pm25Guideline,
            AirQualityReferences.pm25Interim4, AirQualityReferences.pm25Interim2);
    final l10 = sensitive
        ? _levelFor(r.pm10, AirQualityReferences.pm10Annual,
            AirQualityReferences.pm10Guideline, AirQualityReferences.pm10Interim4)
        : _levelFor(r.pm10, AirQualityReferences.pm10Guideline,
            AirQualityReferences.pm10Interim4, AirQualityReferences.pm10Interim2);
    final pmLevel = _worst(l25, l10); // le pire des deux

    final eco2Level = r.eco2 == null ? null : _levelForEco2(r.eco2!);
    final tvocLevel = r.tvoc == null ? null : _levelForTvoc(r.tvoc!);

    
    var level = pmLevel;
    if (eco2Level != null && (cats.contains(3) || cats.contains(4))) {
      level = _worst(level, _capAtPoor(eco2Level));
    }
    if (tvocLevel != null && (cats.contains(1) || cats.contains(2))) {
      level = _worst(level, _capAtPoor(tvocLevel));
    }

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
    if (eco2Level != null && eco2Level.index >= AirQualityLevel.moderate.index) {
      reco.add('Le CO₂ estimé est élevé : la pièce manque d’air frais. '
          'Ouvrez une fenêtre quelques minutes.');
    }
    if (tvocLevel != null && tvocLevel.index >= AirQualityLevel.moderate.index) {
      reco.add('Les composés organiques volatils sont élevés : aérez et évitez '
          'produits ménagers, parfums d’ambiance et aérosols.');
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
      pmLevel: pmLevel,
      pm25Level: l25,
      pm10Level: l10,
      eco2Level: eco2Level,
      tvocLevel: tvocLevel,
      temperatureOk: tOk,
      humidityOk: hOk,
      recommendations: reco,
      exposureAdvice: _adviceFor(level),
    );
  }
}