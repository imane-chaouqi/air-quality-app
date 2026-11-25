
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


// MongoDB dédiée aux profils/authentification
const authUri = process.env.MONGO_URI_AUTH;

if (!authUri) {
  console.error('[MongoDB] MONGO_URI_AUTH est requis pour les profils/authentification.');
  process.exit(1);
}


Promise.resolve(mongoose.createConnection(authUri, { family: 4 }).asPromise())
  .then((authConnection) => {
    
    console.log('[MongoDB] Profils/authentification connectés à Atlas');

    initMqtt();
    app.listen(PORT, () => {
      console.log(`[Serveur] API AirSense démarrée sur http://localhost:${PORT}`);
    });
  })
  .catch((err) => {
    console.error('[MongoDB] Échec de connexion :', err.message);
  });