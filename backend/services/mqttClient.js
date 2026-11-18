const mqtt = require('mqtt');
const Measure = require('../models/Measure');

let client = null;
let lastMessageTime = null;
let mqttConnected = false;

function initMqtt() {
  const brokerUrl = process.env.MQTT_BROKER_URL || 'mqtt://broker.hivemq.com:1883';
  const topicData = process.env.MQTT_TOPIC_DATA || 'airsense/esp32/measures';

  client = mqtt.connect(brokerUrl);

  client.on('connect', () => {
    mqttConnected = true;
    console.log(`[MQTT] Connecté au broker : ${brokerUrl}`);
    client.subscribe(topicData, (err) => {
      if (err) {
        console.error(`[MQTT] Erreur d'abonnement au topic ${topicData}:`, err);
      } else {
        console.log(`[MQTT] Abonné au topic : ${topicData}`);
      }
    });
  });

  client.on('message', async (topic, message) => {
    try {
      const payload = JSON.parse(message.toString());
      const { temperature, humidity, pm25, pm10 } = payload;

      // Vérification de validité des mesures PMS5003 et DHT22
      if (
        typeof temperature !== 'number' || Number.isNaN(temperature) ||
        typeof humidity !== 'number' || Number.isNaN(humidity) ||
        typeof pm25 !== 'number' || Number.isNaN(pm25) ||
        typeof pm10 !== 'number' || Number.isNaN(pm10)
      ) {
        console.warn('[MQTT] Mesure invalide ou capteur défaillant ignorée :', payload);
        return;
      }

      const newMeasure = new Measure({
        temperature: Number(temperature.toFixed(1)),
        humidity: Number(humidity.toFixed(1)),
        pm25: Number(pm25.toFixed(1)),
        pm10: Number(pm10.toFixed(1)),
        isSimulated: false,
        timestamp: new Date()
      });

      await newMeasure.save();
      lastMessageTime = Date.now();
      console.log('[MQTT] Mesure enregistrée :', newMeasure);
    } catch (error) {
      console.error('[MQTT] Erreur de traitement du message :', error.message);
    }
  });

  client.on('error', (err) => {
    mqttConnected = false;
    console.error('[MQTT] Erreur de connexion :', err.message);
  });

  client.on('offline', () => {
    mqttConnected = false;
    console.warn('[MQTT] Client hors ligne');
  });
}

// Envoie la commande d'activation à l'ESP32 (appelé par requestActivation dans Flutter)
function sendActivationCommand() {
  const topicCmd = process.env.MQTT_TOPIC_CMD || 'airsense/esp32/command';
  if (client && mqttConnected) {
    client.publish(topicCmd, JSON.stringify({ action: 'START_MEASURE' }));
    return true;
  }
  return false;
}

// Vérifie l'état de la maquette (ex: considère hors-ligne si aucune donnée depuis > 15s)
function getDeviceHealth() {
  const now = Date.now();
  const isReceivingData = lastMessageTime !== null && (now - lastMessageTime) < 15000;
  return {
    mqttConnected,
    isReceivingData,
    lastMessageTime
  };
}

module.exports = { initMqtt, sendActivationCommand, getDeviceHealth };