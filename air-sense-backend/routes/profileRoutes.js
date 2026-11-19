const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const nodemailer = require('nodemailer');
const profileStore = require('../models/Profile');

const ALLOWED_PROFILE_FIELDS = [
  'name',
  'trancheAge',
  'piece',
  'situations',
  'sources',
  'aeration',
  'moisissures',
  'remarques',
  'personnesVulnerables',
  'heuresVulnerable',
  'dortDansPiece',
  'maladieRespVulnerable',
  'activites',
  'heuresSport',
  'symptomes',
  'diagnostics',
  'ginaSymptomesJour',
  'ginaReveilNuit',
  'ginaMedicamentSecours',
  'ginaLimitation',
  'criseSevere',
  'declencheurs',
];

function resolveProfileModel() {
  if (profileStore && typeof profileStore.getProfileModel === 'function') {
    return profileStore.getProfileModel();
  }
  if (typeof profileStore === 'function') {
    return profileStore;
  }
  throw new Error('Modèle Profile indisponible ou non initialisé.');
}

function extractSafeProfileFields(profil = {}) {
  const clean = {};
  for (const field of ALLOWED_PROFILE_FIELDS) {
    if (profil[field] !== undefined) {
      clean[field] = profil[field];
    }
  }
  return clean;
}

// 1. INSCRIPTION (Register)
router.post('/register', async (req, res) => {
  try {
    const email = (req.body.email || '').trim().toLowerCase();
    const { password, confirmPassword, profil } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        error: "L'email et le mot de passe sont requis.",
      });
    }

    if (confirmPassword !== undefined && password !== confirmPassword) {
      return res.status(400).json({
        success: false,
        error: 'Les mots de passe ne correspondent pas.',
      });
    }

    const Profile = resolveProfileModel();
    const existingUser = await Profile.findOne({ email });
    if (existingUser) {
      return res.status(400).json({
        success: false,
        error: 'Cet email est déjà utilisé.',
      });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);
    const safeProfil = extractSafeProfileFields(profil || {});

    const newProfile = new Profile({
      email,
      password: hashedPassword,
      canResetPassword: false,
      ...safeProfil,
    });

    await newProfile.save();

    // Envoi de l'e-mail de bienvenue (sans bloquer l'inscription en cas d'erreur SMTP)
    try {
      const transporter = nodemailer.createTransport({
        service: 'gmail',
        auth: {
          user: process.env.EMAIL_USER,
          pass: process.env.EMAIL_PASS,
        },
      });

      await transporter.sendMail({
        from: process.env.EMAIL_USER,
        to: email,
        subject: 'Bienvenue sur AirSense - Compte créé avec succès',
        text: `Bonjour,\n\nVotre compte AirSense a été créé avec succès avec l'adresse : ${email}.\n\nMerci de votre confiance et bienvenue sur notre plateforme !\n\nL'équipe AirSense`,
      });
      console.log(`E-mail de bienvenue envoyé avec succès à -> ${email}`);
    } catch (mailError) {
      console.error("Erreur lors de l'envoi de l'e-mail de bienvenue :", mailError);
    }

    const safeData = newProfile.toObject();
    delete safeData.password;

    return res.status(201).json({
      success: true,
      message: 'Inscription réussie !',
      data: safeData,
    });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

// 2. CONNEXION (Login)
router.post('/login', async (req, res) => {
  try {
    const email = (req.body.email || '').trim().toLowerCase();
    const { password } = req.body;

    const Profile = resolveProfileModel();
    const user = await Profile.findOne({ email });
    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'Email ou mot de passe incorrect.',
      });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({
        success: false,
        error: 'Email ou mot de passe incorrect.',
      });
    }

    const safeUser = user.toObject();
    delete safeUser.password;

    return res.status(200).json({
      success: true,
      message: 'Connexion réussie !',
      data: safeUser,
    });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

// 3. Enregistrer ou mettre à jour le profil (Formulaire)
router.post('/profile', async (req, res) => {
  try {
    const email = (req.body.email || '').trim().toLowerCase();
    if (!email) {
      return res.status(400).json({
        success: false,
        error: "L'adresse e-mail est requise.",
      });
    }

    const rawProfil =
      req.body.profil && typeof req.body.profil === 'object'
        ? req.body.profil
        : req.body;
    const updates = extractSafeProfileFields(rawProfil);

    const Profile = resolveProfileModel();
    const updatedProfile = await Profile.findOneAndUpdate(
      { email },
      { $set: updates },
      {
        returnDocument: 'after',
        runValidators: true,
        context: 'query',
      }
    ).select('-password');

    if (!updatedProfile) {
      return res.status(404).json({
        success: false,
        error: 'Utilisateur introuvable.',
      });
    }

    return res.status(200).json({ success: true, data: updatedProfile });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

// 4. Récupérer le profil par email
router.get('/profile/:email', async (req, res) => {
  try {
    const email = decodeURIComponent(req.params.email || '')
      .trim()
      .toLowerCase();
    const Profile = resolveProfileModel();
    const profile = await Profile.findOne({ email }).select('-password');

    if (!profile) {
      return res.status(404).json({ message: 'Profil non trouvé' });
    }

    return res.status(200).json(profile);
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

// 5. Demande de réinitialisation du mot de passe (Envoi de l'e-mail avec OUI / NON)
router.post('/forgot-password', async (req, res) => {
  try {
    const email = (req.body.email || '').trim().toLowerCase();
    console.log('----------------------------------------');
    console.log("Requête forgot-password reçue pour l'e-mail :", email);

    const Profile = resolveProfileModel();
    const user = await Profile.findOne({ email });

    if (!user) {
      console.log(
        'Utilisateur non trouvé en BD, mais on renvoie un message neutre par sécurité.'
      );
      return res.status(200).json({
        message: 'Si cet e-mail existe, un message a été envoyé.',
      });
    }

    user.canResetPassword = false;
    await user.save();

    const transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,
      },
    });

    const encodedEmail = encodeURIComponent(email);
    const mailOptions = {
      from: process.env.EMAIL_USER,
      to: email,
      subject: 'Réinitialisation de votre mot de passe AirSense',
      text: `Bonjour,\n\nVous avez demandé la réinitialisation de votre mot de passe pour l'application AirSense.\n\nEst-ce bien vous ?\n\n- OUI (Autoriser le changement) : http://localhost:3000/api/confirm-reset?email=${encodedEmail}&choice=yes\n- NON (Refuser) : http://localhost:3000/api/confirm-reset?email=${encodedEmail}&choice=no\n\nSi vous avez cliqué sur OUI, retournez dans l'application pour définir votre nouveau mot de passe.`,
    };

    await transporter.sendMail(mailOptions);

    console.log(
      `Succès : E-mail de réinitialisation (avec OUI/NON) envoyé à -> ${email}`
    );
    console.log('----------------------------------------');

    return res.status(200).json({
      message: 'E-mail de réinitialisation envoyé avec succès.',
    });
  } catch (error) {
    console.error('Erreur (forgot-password) :', error);
    return res.status(500).json({
      success: false,
      error: "Erreur lors de l'envoi de l'e-mail.",
    });
  }
});

// 5. bis - Route pour intercepter le clic sur "OUI" ou "NON" depuis l'e-mail
router.get('/confirm-reset', async (req, res) => {
  try {
    const email = decodeURIComponent(String(req.query.email || ''))
      .trim()
      .toLowerCase();
    const choice = req.query.choice;

    const Profile = resolveProfileModel();
    const user = await Profile.findOne({ email });
    if (!user) {
      return res
        .status(404)
        .send('<h1>Erreur</h1><p>Utilisateur non trouvé.</p>');
    }

    if (choice === 'yes') {
      user.canResetPassword = true;
      await user.save();
      return res.send(`
        <div style="text-align: center; margin-top: 50px; font-family: Arial;">
          <h1 style="color: green;">Demande confirmée avec succès !</h1>
          <p>Vous pouvez maintenant retourner dans l'application <b>AirSense</b> pour définir votre nouveau mot de passe.</p>
        </div>
      `);
    }

    user.canResetPassword = false;
    await user.save();
    return res.send(`
      <div style="text-align: center; margin-top: 50px; font-family: Arial;">
        <h1 style="color: red;">Demande annulée</h1>
        <p>Vous avez indiqué que vous n'êtes pas à l'origine de cette demande. Aucun changement ne sera effectué.</p>
      </div>
    `);
  } catch (error) {
    return res
      .status(500)
      .send('Erreur serveur lors de la confirmation.');
  }
});

// 5. ter - Route pour que l'application Flutter vérifie si l'utilisateur a cliqué sur "OUI"
router.get('/check-reset-status', async (req, res) => {
  try {
    const email = decodeURIComponent(String(req.query.email || ''))
      .trim()
      .toLowerCase();
    const Profile = resolveProfileModel();
    const user = await Profile.findOne({ email });
    if (!user) {
      return res
        .status(404)
        .json({ success: false, error: 'Utilisateur non trouvé.' });
    }

    const status = user.canResetPassword === true;
    return res.status(200).json({ success: true, canResetPassword: status });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

// 6. Route pour mettre à jour le mot de passe (Réinitialisation effective depuis l'application)
router.post('/reset-password', async (req, res) => {
  try {
    const email = (req.body.email || '').trim().toLowerCase();
    const { newPassword, confirmPassword } = req.body;

    if (newPassword !== confirmPassword) {
      return res.status(400).json({
        success: false,
        error: 'Les mots de passe ne correspondent pas.',
      });
    }

    const Profile = resolveProfileModel();
    const user = await Profile.findOne({ email });
    if (!user) {
      return res
        .status(404)
        .json({ success: false, error: 'Utilisateur non trouvé.' });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(newPassword, salt);

    user.password = hashedPassword;
    user.canResetPassword = false;
    await user.save();

    console.log(`Mot de passe mis à jour avec succès pour : ${email}`);
    return res.status(200).json({
      success: true,
      message: 'Mot de passe réinitialisé avec succès !',
    });
  } catch (error) {
    console.error('Erreur (reset-password) :', error);
    return res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router;