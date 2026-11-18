require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const { initMqtt } = require('./services/mqttClient');
const measuresRoutes = require('./routes/measures');

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

// Routes API
app.use('/api/measures', measuresRoutes);

// Connexion MongoDB Atlas puis démarrage du serveur et de MQTT
mongoose
  .connect(process.env.MONGODB_URI)
  .then(() => {
    console.log('[MongoDB] Connecté avec succès à Atlas');
    initMqtt();
    app.listen(PORT, () => {
      console.log(`[Serveur] API AirSense démarrée sur http://localhost:${PORT}`);
    });
  })
  .catch((err) => {
    console.error('[MongoDB] Échec de connexion :', err.message);
  });