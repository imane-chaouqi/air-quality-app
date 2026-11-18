const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const Profile = require('../models/Profile');
const nodemailer = require('nodemailer');

// 1. INSCRIPTION (Register)
router.post('/register', async (req, res) => {
  try {
    const { email, password, confirmPassword, profil } = req.body;

    // Vérification si les mots de passe correspondent
    if (password !== confirmPassword) {
      return res.status(400).json({ success: false, error: "Les mots de passe ne correspondent pas." });
    }

    // Vérifier si l'utilisateur existe déjà
    const existingUser = await Profile.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ success: false, error: "Cet email est déjà utilisé." });
    }

    // Hacher le mot de passe
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Créer et enregistrer le profil avec le mot de passe sécurisé
    const newProfile = new Profile({
      email,
      password: hashedPassword,
      canResetPassword: false, // Initialisé à false
      ...profil
    });

    await newProfile.save();
    res.status(201).json({ success: true, message: "Inscription réussie !", data: newProfile });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// 2. CONNEXION (Login)
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    // Trouver l'utilisateur par son email
    const user = await Profile.findOne({ email });
    if (!user) {
      return res.status(404).json({ success: false, error: "Email ou mot de passe incorrect." });
    }

    // Vérifier le mot de passe
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ success: false, error: "Email ou mot de passe incorrect." });
    }

    res.status(200).json({ success: true, message: "Connexion réussie !", data: user });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// 3. Enregistrer ou mettre à jour le profil (Formulaire)
router.post('/profile', async (req, res) => {
  try {
    const { email, profil } = req.body;
    const updatedProfile = await Profile.findOneAndUpdate(
      { email },
      { ...profil },
      { new: true, upsert: true }
    );
    res.status(200).json({ success: true, data: updatedProfile });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// 4. Récupérer le profil par email
router.get('/profile/:email', async (req, res) => {
  try {
    const profile = await Profile.findOne({ email: req.params.email });
    if (!profile) return res.status(404).json({ message: 'Profil non trouvé' });
    res.status(200).json(profile);
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// 5. Demande de réinitialisation du mot de passe (Envoi de l'e-mail avec OUI / NON)
router.post('/forgot-password', async (req, res) => {
  try {
    const { email } = req.body;
    console.log("----------------------------------------");
    console.log("Requête forgot-password reçue pour l'e-mail :", email);

    // Vérification si l'utilisateur existe dans la base de données
    const user = await Profile.findOne({ email });
    
    if (!user) {
      console.log("Utilisateur non trouvé en BD, mais on renvoie un message neutre par sécurité.");
      return res.status(200).json({ message: 'Si cet e-mail existe, un message a été envoyé.' });
    }

    // Par sécurité, on remet le statut à false tant qu'il n'a pas cliqué sur OUI
    user.canResetPassword = false;
    await user.save();

    // Configuration de Nodemailer
    const transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS
      }
    });

    // Liens dynamiques pour intercepter le OUI ou le NON
    const mailOptions = {
      from: process.env.EMAIL_USER,
      to: email,
      subject: 'Réinitialisation de votre mot de passe AirSense',
      text: `Bonjour,\n\nVous avez demandé la réinitialisation de votre mot de passe pour l'application AirSense.\n\nEst-ce bien vous ?\n\n- OUI (Autoriser le changement) : http://localhost:3000/api/confirm-reset?email=${email}&choice=yes\n- NON (Refuser) : http://localhost:3000/api/confirm-reset?email=${email}&choice=no\n\nSi vous avez cliqué sur OUI, retournez dans l'application pour définir votre nouveau mot de passe.`
    };

    // Envoi effectif de l'e-mail
    await transporter.sendMail(mailOptions);

    console.log(`Succès : E-mail de réinitialisation (avec OUI/NON) envoyé à -> ${email}`);
    console.log("----------------------------------------");
    
    res.status(200).json({ message: 'E-mail de réinitialisation envoyé avec succès.' });
  } catch (error) {
    console.error('Erreur (forgot-password) :', error);
    res.status(500).json({ success: false, error: "Erreur lors de l'envoi de l'e-mail." });
  }
});

// 5. bis - Route pour intercepter le clic sur "OUI" ou "NON" depuis l'e-mail
router.get('/confirm-reset', async (req, res) => {
  try {
    const { email, choice } = req.query;

    const user = await Profile.findOne({ email });
    if (!user) {
      return res.status(404).send("<h1>Erreur</h1><p>Utilisateur non trouvé.</p>");
    }

    if (choice === 'yes') {
      user.canResetPassword = true;
      await user.save();
      res.send(`
        <div style="text-align: center; margin-top: 50px; font-family: Arial;">
          <h1 style="color: green;">Demande confirmée avec succès !</h1>
          <p>Vous pouvez maintenant retourner dans l'application <b>AirSense</b> pour définir votre nouveau mot de passe.</p>
        </div>
      `);
    } else {
      user.canResetPassword = false;
      await user.save();
      res.send(`
        <div style="text-align: center; margin-top: 50px; font-family: Arial;">
          <h1 style="color: red;">Demande annulée</h1>
          <p>Vous avez indiqué que vous n'êtes pas à l'origine de cette demande. Aucun changement ne sera effectué.</p>
        </div>
      `);
    }
  } catch (error) {
    res.status(500).send("Erreur serveur lors de la confirmation.");
  }
});

// 5. ter - Route pour que l'application Flutter vérifie si l'utilisateur a cliqué sur "OUI"
router.get('/check-reset-status', async (req, res) => {
  try {
    const { email } = req.query;
    const user = await Profile.findOne({ email });
    if (!user) {
      return res.status(404).json({ success: false, error: "Utilisateur non trouvé." });
    }
    
    // Forcer un retour booléen strict (true ou false) pour éviter les valeurs nulles ou undefined
    const status = user.canResetPassword === true;
    res.status(200).json({ success: true, canResetPassword: status });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// 6. Route pour mettre à jour le mot de passe (Réinitialisation effective depuis l'application)
router.post('/reset-password', async (req, res) => {
  try {
    const { email, newPassword, confirmPassword } = req.body;

    // Vérifier si les deux mots de passe correspondent
    if (newPassword !== confirmPassword) {
      return res.status(400).json({ success: false, error: "Les mots de passe ne correspondent pas." });
    }

    // Trouver l'utilisateur par son email
    const user = await Profile.findOne({ email });
    if (!user) {
      return res.status(404).json({ success: false, error: "Utilisateur non trouvé." });
    }

    // Hacher le nouveau mot de passe de manière sécurisée
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(newPassword, salt);

    // Mettre à jour le mot de passe directement dans MongoDB et réinitialiser le flag de sécurité
    user.password = hashedPassword;
    user.canResetPassword = false; 
    await user.save();

    console.log(`Mot de passe mis à jour avec succès pour : ${email}`);
    res.status(200).json({ success: true, message: "Mot de passe réinitialisé avec succès !" });
  } catch (error) {
    console.error('Erreur (reset-password) :', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router;