const mqtt = require('mqtt');


let client = null;
let lastMessageTime = null;
let mqttConnected = false;
// TEMP TEST MAQUETTE : cache de la derniere mesure, sans MongoDB.
let lastMeasure = null;

function initMqtt() {
  // TEMP TEST MAQUETTE : connexion au broker EMQX fourni pour l'ingestion directe.
  const brokerUrl = 'mqtts://s2f03b08.ala.eu-central-1.emqxsl.com:8883';
  const topicData = 'airquality/esp32s3/data';

  // TEMP TEST MAQUETTE : authentification EMQX pour le consommateur MQTT.
  client = mqtt.connect(brokerUrl, {
    port: 8883,
    username: 'Consumer',
    password: '1234',
  });

  client.on('connect', () => {
    mqttConnected = true;
    console.log(`[MQTT] Connecté au broker EMQX : ${brokerUrl}`);
    console.log(`[MQTT] Abonnement demandé au topic : ${topicData}`);
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
      // TEMP TEST SANS MONGODB : affichage brut de chaque trame recue.
      console.log(`[MQTT] Mesure brute recue sur ${topic} :`, message.toString());

      const payload = JSON.parse(message.toString());
      // TEMP TEST SANS MONGODB : affichage parse de chaque mesure recue.
      console.log('[MQTT] Mesure parsée recue :', payload);
      // TEMP TEST SANS MONGODB : accepte les champs numeriques et leurs variantes courantes.
      const toNumber = (value) => {
        if (typeof value === 'number') return value;
        if (typeof value === 'string' && value.trim() !== '') return Number(value);
        return NaN;
      };
      const temperature = toNumber(payload.temperature ?? payload.temp ?? payload.temperature_c);
      const humidity = toNumber(payload.humidity ?? payload.hum);
      const pm25 = toNumber(payload.pm25 ?? payload['pm2.5'] ?? payload.pm2_5);
      const pm10 = toNumber(payload.pm10);

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

      // TEMP TEST SANS MONGODB : aucune creation ni sauvegarde Measure.
      // const newMeasure = new Measure({...});
      // await newMeasure.save();
      lastMessageTime = Date.now();
      // TEMP TEST MAQUETTE : conserve directement la derniere mesure en memoire.
      // TEMP TEST SANS MONGODB : cache uniquement en memoire pour l'affichage live.
      lastMeasure = {
        temperature: Number(temperature.toFixed(1)),
        humidity: Number(humidity.toFixed(1)),
        pm25: Number(pm25.toFixed(1)),
        pm10: Number(pm10.toFixed(1)),
        isSimulated: false,
        timestamp: new Date().toISOString(),
        testMode: true,
      };
      console.log('[MQTT] Mesure reçue et acceptée (MongoDB désactivé).');
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

// TEMP TEST MAQUETTE : expose la derniere mesure MQTT sans base de donnees.
function getLatestMqttReading() {
  // TEMP TEST SANS MONGODB : aucune lecture MongoDB.
  return lastMeasure;
}

module.exports = {
  initMqtt,
  sendActivationCommand,
  getDeviceHealth,
  getLatestMqttReading,
};

function injectTestMeasure(m) {
  lastMessageTime = Date.now();
  lastMeasure = {
    temperature: m.temperature,
    humidity: m.humidity,
    pm25: m.pm25,
    pm10: m.pm10,
    isSimulated: false,
    timestamp: new Date().toISOString(),
    testMode: true,
  };
}

module.exports = {
  initMqtt,
  sendActivationCommand,
  getDeviceHealth,
  getLatestMqttReading,
  injectTestMeasure,
};