const mongoose = require('mongoose');

const profileSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true }, // Champ pour stocker le mot de passe haché
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
}, { timestamps: true });

// Utilisation de la collection 'profiles' explicitement
module.exports = mongoose.models.Profile || mongoose.model('Profile', profileSchema, 'profiles');