const mongoose = require('mongoose');

const profileSchema = new mongoose.Schema(
  {
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    name: String,
    canResetPassword: { type: Boolean, default: false },
    trancheAge: String,
    piece: String,
    situations: [String],
    sources: [String],
    aeration: String,
    moisissures: Boolean,
    remarques: String,
    personnesVulnerables: [String],
    heuresVulnerable: String,
    dortDansPiece: Boolean,
    maladieRespVulnerable: Boolean,
    activites: [String],
    heuresSport: String,
    symptomes: [String],
    diagnostics: [String],
    ginaSymptomesJour: Boolean,
    ginaReveilNuit: Boolean,
    ginaMedicamentSecours: Boolean,
    ginaLimitation: Boolean,
    criseSevere: Boolean,
    declencheurs: [String],
  },
  { timestamps: true }
);

let profileModel = null;

function configure(connection) {
  if (!connection) {
    throw new Error('Connexion Mongoose manquante pour initialiser Profile.');
  }
  profileModel = connection.model('Profile', profileSchema, 'profiles');
  return profileModel;
}

function getProfileModel() {
  if (!profileModel) {
    throw new Error('MongoDB des profils/authentification non initialisé.');
  }
  return profileModel;
}

module.exports = {
  configure,
  getProfileModel,
};