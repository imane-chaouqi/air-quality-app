const mongoose = require('mongoose');

const profileSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  trancheAge: String,
  piece: String,
  situations: [String],
  sources: [String],
  aeration: String,
  moisissures: Boolean,
  remarques: String, // Champ libre
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

module.exports = mongoose.model('Profile', profileSchema);