const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const nodemailer = require('nodemailer');
require('dotenv').config();

const app = express();
app.use(express.json());
app.use(cors());

// Désactiver complètement le buffering des requêtes Mongoose
mongoose.set('bufferCommands', false);

// URI de connexion MongoDB Atlas
const MONGO_URI = process.env.MONGO_URI || 'mongodb+srv://malakmahfoudi_db_user:Malak2026Password@cluster0.ozxj0j1.mongodb.net/airsense?retryWrites=true&w=majority';

// Configuration de Nodemailer avec tes variables d'environnement
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS
  }
});

// Import du modèle Profile (assure-toi que ton modèle gère bien le champ password et profil)
const Profile = require('./models/Profile'); // Adapte le chemin si nécessaire

// Connexion à MongoDB
mongoose.connect(MONGO_URI, { family: 4 })
  .then(() => {
    console.log('Connecté à MongoDB avec succès !');

    // Route d'inscription sécurisée avec envoi d'e-mail de confirmation
    app.post('/api/register', async (req, res) => {
      try {
        const { email, password, confirmPassword, profil } = req.body;

        // 1. Vérification des champs requis
        if (!email || !password || !confirmPassword) {
          return res.status(400).json({ error: 'Veuillez remplir tous les champs obligatoires.' });
        }

        // 2. Vérification de la correspondance des mots de passe
        if (password !== confirmPassword) {
          return res.status(400).json({ error: 'Les mots de passe ne correspondent pas.' });
        }

        // 3. Vérifier si l'utilisateur existe déjà
        const existingUser = await Profile.findOne({ email });
        if (existingUser) {
          return res.status(400).json({ error: 'Cet email est déjà utilisé.' });
        }

        // 4. Hachage du mot de passe
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        // 5. Création et sauvegarde du profil/utilisateur en base de données
        const newProfile = new Profile({
          email,
          password: hashedPassword,
          profil: profil || {}
        });

        await newProfile.save();

        // 6. Envoi de l'e-mail de confirmation/bienvenue
        const mailOptions = {
          from: process.env.EMAIL_USER,
          to: email,
          subject: 'Bienvenue sur AirSense - Compte créé avec succès',
          text: `Bonjour,\n\nVotre compte AirSense a été créé avec succès avec l'adresse : ${email}.\n\nMerci de votre confiance et bienvenue sur notre plateforme !\n\nL'équipe AirSense`
        };

        transporter.sendMail(mailOptions, (error, info) => {
          if (error) {
            console.error("Erreur lors de l'envoi de l'e-mail :", error);
          } else {
            console.log('E-mail de confirmation envoyé avec succès : ' + info.response);
          }
        });

        // Réponse de succès (201 Created)
        res.status(201).json({ message: 'Inscription réussie, e-mail envoyé et profil enregistré !' });

      } catch (err) {
        console.error("Erreur serveur lors de l'inscription :", err);
        res.status(500).json({ error: err.message });
      }
    });

    // Monter les autres routes existantes (ex: profileRoutes)
    try {
      const profileRoutes = require('./routes/profileRoutes');
      app.use('/api', profileRoutes);
    } catch (e) {
      console.log('Routes additionnelles non chargées ou optionnelles.');
    }

    const PORT = process.env.PORT || 3000;
    app.listen(PORT, () => {
      console.log(`Serveur démarré sur le port ${PORT}`);
    });
  })
  .catch((err) => {
    console.error('Erreur de connexion MongoDB :', err);
  });