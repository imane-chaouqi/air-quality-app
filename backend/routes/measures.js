const express = require('express');
const router = express.Router();

const {
  sendActivationCommand,
  getDeviceHealth,
  getLatestMqttReading,
} = require('../services/mqttClient');

router.post('/test-inject', (req, res) => {
  injectTestMeasure({
    temperature: 24.5 + Math.random(),
    humidity: 50,
    pm25: 12 + Math.random() * 5,
    pm10: 20,
  });
  res.json({ ok: true });
});

// 1. Vérifier l'état de connexion avec la maquette / le broker
router.get('/status', (req, res) => {
  const health = getDeviceHealth();
  res.json(health);
});

// 2. Déclencher la prise de mesure sur l'ESP32
router.post('/activate', (req, res) => {
  const sent = sendActivationCommand();
  if (!sent) {
    return res.status(503).json({
      error: 'Broker MQTT déconnecté. Impossible de joindre la maquette.'
    });
  }
  res.json({ message: 'Commande d’activation envoyée à l’ESP32.' });
});

// 3. Récupérer la toute dernière mesure enregistrée
router.get('/latest', async (req, res) => {
  // TEMP TEST SANS MONGODB : lecture directe de la derniere mesure en memoire.
  const latest = getLatestMqttReading();
  if (!latest) {
    return res.status(200).json({ received: false, testMode: true });
  }
  res.json(latest);
});

module.exports = router;