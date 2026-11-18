const express = require('express');
const router = express.Router();
const Measure = require('../models/Measure');
const { sendActivationCommand, getDeviceHealth } = require('../services/mqttClient');

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
  try {
    const latest = await Measure.findOne().sort({ timestamp: -1 });
    if (!latest) {
      return res.status(404).json({ error: 'Aucune mesure disponible.' });
    }
    res.json(latest);
  } catch (err) {
    res.status(500).json({ error: 'Erreur serveur lors de la récupération.' });
  }
});

// 4. Récupérer l'historique des mesures (par défaut les 50 dernières)
router.get('/history', async (req, res) => {
  try {
    const limit = parseInt(req.query.limit, 10) || 50;
    const history = await Measure.find()
      .sort({ timestamp: -1 })
      .limit(limit);
    res.json(history);
  } catch (err) {
    res.status(500).json({ error: 'Erreur lors de la récupération de l’historique.' });
  }
});

module.exports = router;