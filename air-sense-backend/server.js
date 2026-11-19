const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(express.json());
app.use(cors());

// Désactiver le buffering pour détecter immédiatement tout problème de connexion DB
mongoose.set('bufferCommands', false);

const MONGO_URI =
  process.env.MONGO_URI ||
  'mongodb+srv://malakmahfoudi_db_user:Malak2026Password@cluster0.ozxj0j1.mongodb.net/airsense?retryWrites=true&w=majority';

const profileStore = require('./models/Profile');
const profileRoutes = require('./routes/profileRoutes');

mongoose
  .connect(MONGO_URI, { family: 4 })
  .then(() => {
    console.log('Connecté à MongoDB avec succès !');

    // Initialise le modèle Profile sur la connexion Mongoose active AVANT de monter les routes
    profileStore.configure(mongoose.connection);

    app.use('/api', profileRoutes);

    const PORT = process.env.PORT || 3000;
    app.listen(PORT, () => {
      console.log(`Serveur démarré sur le port ${PORT}`);
    });
  })
  .catch((err) => {
    console.error('Erreur de connexion MongoDB :', err);
  });