require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const { initMqtt } = require('./services/mqttClient');
const measuresRoutes = require('./routes/measures');
const profileStore = require('../air-sense-backend/models/Profile');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// Routes API
app.use('/api/measures', measuresRoutes);

// MongoDB des mesures/MQTT (connexion Mongoose principale)
const measuresUri = process.env.MONGODB_URI;

// MongoDB dédiée aux profils/authentification
const authUri = process.env.MONGO_URI_AUTH || process.env.MONGO_URI;

if (!measuresUri) {
  console.error('[MongoDB] MONGODB_URI est requis pour les mesures.');
  process.exit(1);
}

if (!authUri) {
  console.error('[MongoDB] MONGO_URI_AUTH (ou MONGO_URI) est requis pour les profils/authentification.');
  process.exit(1);
}

Promise.all([
  mongoose.connect(measuresUri, { family: 4 }),
  mongoose.createConnection(authUri, { family: 4 }).asPromise(),
])
  .then(([, authConnection]) => {
    profileStore.configure(authConnection);
    console.log('[MongoDB] Mesures connectées à Atlas');
    console.log('[MongoDB] Profils/authentification connectés à Atlas');

    try {
      const profileRoutes = require('../air-sense-backend/routes/profileRoutes');
      app.use('/api', profileRoutes);
    } catch (e) {
      console.error('Erreur chargement profileRoutes :', e);
      process.exit(1);
    }

    initMqtt();
    app.listen(PORT, () => {
      console.log(`[Serveur] API AirSense démarrée sur http://localhost:${PORT}`);
    });
  })
  .catch((err) => {
    console.error('[MongoDB] Échec de connexion :', err.message);
  });