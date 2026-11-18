const mongoose = require('mongoose');

const uri = 'mongodb+srv://malakmahfoudi_db_user:Malak2026Password@cluster0.ozxj0j1.mongodb.net/airsense?retryWrites=true&w=majority';

const profileSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  trancheAge: String,
}, { timestamps: true });

const Profile = mongoose.model('Profile', profileSchema, 'profiles');

mongoose.connect(uri, { family: 4 })
  .then(async () => {
    console.log("Connecté ! Test de recherche...");
    const result = await Profile.findOne({ email: "test@test.com" });
    console.log("Résultat findOne :", result);
    process.exit(0);
  })
  .catch(err => {
    console.error("Erreur :", err);
    process.exit(1);
  });