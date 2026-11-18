import 'package:flutter/material.dart';
import '../theme/profile_form_model.dart';
import '../theme/app_colors.dart';
import '../widgets/airsense_widgets.dart';
import '../services/api_service.dart';
import 'profile_analysis_screen.dart';

const List<String> _heures = ['Moins de 4 h', '4 à 8 h', 'Plus de 8 h'];

class FormScreen extends StatefulWidget {
  final String userName;
  final String userEmail;

  const FormScreen({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final ProfileFormModel _profil = ProfileFormModel();
  final TextEditingController _remarquesController = TextEditingController();

  @override
  void dispose() {
    _remarquesController.dispose();
    super.dispose();
  }

  bool _formValide() {
    bool baseValide = _profil.trancheAge != null &&
        _profil.piece != null &&
        _profil.aeration != null &&
        _profil.moisissures != null;
    if (!baseValide) return false;

    if (_profil.aVulnerable) {
      if (_profil.personnesVulnerables.isEmpty ||
          _profil.heuresVulnerable == null ||
          _profil.dortDansPiece == null ||
          _profil.maladieRespVulnerable == null) {
        return false;
      }
    }

    if (_profil.aSport) {
      if (_profil.activites.isEmpty || _profil.heuresSport == null) {
        return false;
      }
    }

    if (_profil.concerneRespiratoire) {
      if (_profil.diagnostics.isEmpty) return false;
      if (_profil.asthme) {
        if (_profil.ginaSymptomesJour == null ||
            _profil.ginaReveilNuit == null ||
            _profil.ginaMedicamentSecours == null ||
            _profil.ginaLimitation == null) {
          return false;
        }
      }
      if (_profil.criseSevere == null) return false;
    }

    return true;
  }

  // Fonction de soumission : envoie les données à MongoDB sans afficher de message vert
  void _soumettre() async {
    if (!_formValide()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Merci de répondre à toutes les questions obligatoires.'),
        ),
      );
      return;
    }

    // 1. Envoi des données vers le back-end Node.js / MongoDB Atlas (en arrière-plan)
    await ApiService.saveProfile(widget.userEmail, _profil.toJson());

    if (!mounted) return;

    // 2. Navigation directe vers l'écran d'analyse suivant, sans message de succès
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileAnalysisScreen(
          profil: _profil,
          userName: widget.userName,
          userEmail: widget.userEmail,
        ),
      ),
    );
  }

  Widget _titreSection(String texte) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(texte, style: styleTitrePage),
    );
  }

  Widget _titreQuestion(String texte) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(texte, style: styleQuestion),
    );
  }

  Widget _choixUnique(
    String question,
    List<String> options,
    String? valeur,
    void Function(String) quandChoisi, {
    Map<String, IconData>? icones,
    Map<String, String>? sousTitres,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _titreQuestion(question),
        ...options.map((option) {
          return OptionTuile(
            titre: option,
            sousTitre: sousTitres?[option],
            icone: icones?[option],
            teinte: options.indexOf(option),
            selectionnee: valeur == option,
            multiple: false,
            onTap: () => setState(() => quandChoisi(option)),
          );
        }),
      ],
    );
  }

  Widget _choixMultiple(
    String question,
    List<String> options,
    Set<String> valeurs, {
    Map<String, IconData>? icones,
    Map<String, String>? sousTitres,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _titreQuestion(question),
        ...options.map((option) {
          return OptionTuile(
            titre: option,
            sousTitre: sousTitres?[option],
            icone: icones?[option],
            teinte: options.indexOf(option),
            selectionnee: valeurs.contains(option),
            multiple: true,
            onTap: () {
              setState(() {
                if (valeurs.contains(option)) {
                  valeurs.remove(option);
                } else {
                  valeurs.add(option);
                }
              });
            },
          );
        }),
      ],
    );
  }

  Widget _ouiNon(String question, bool? valeur, void Function(bool) quandChoisi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _titreQuestion(question),
        Row(
          children: [
            Expanded(
              child: OptionTuile(
                titre: 'Oui',
                selectionnee: valeur == true,
                onTap: () => setState(() => quandChoisi(true)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OptionTuile(
                titre: 'Non',
                selectionnee: valeur == false,
                onTap: () => setState(() => quandChoisi(false)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _champRemarques() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _titreQuestion('Remarques ou informations supplémentaires (optionnel)'),
        const SizedBox(height: 8),
        TextField(
          controller: _remarquesController,
          maxLines: 4,
          onChanged: (valeur) {
            _profil.remarques = valeur;
          },
          decoration: InputDecoration(
            hintText: 'Ajoutez ici toute information utile...',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fond,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AirSenseHeader(),
                  const SizedBox(height: 12),
                  Text('Personnalisation de votre profil', style: styleTitrePage),
                  const SizedBox(height: 6),
                  Text('Remplissez ce formulaire pour adapter l\'application à vos besoins.', style: styleSousTitre),
                  const SizedBox(height: 16),

                  _titreSection('1. Votre situation et votre logement'),
                  _choixUnique(
                    "Tranche d'âge de la personne qui utilisera l'application",
                    ['Moins de 12 ans', '12 à 17 ans', '18 à 64 ans', ProfileFormModel.age65],
                    _profil.trancheAge,
                    (v) => _profil.trancheAge = v,
                  ),
                  _choixUnique(
                    'Pièce que vous souhaitez surveiller',
                    ['Chambre', 'Salon', 'Bureau', 'Autre'],
                    _profil.piece,
                    (v) => _profil.piece = v,
                  ),
                  _choixMultiple(
                    'Quelles situations vous concernent ? (plusieurs choix possibles)',
                    [
                      ProfileFormModel.sitRespiratoire,
                      ProfileFormModel.sitVulnerable,
                      ProfileFormModel.sitSport,
                    ],
                    _profil.situations,
                    icones: {
                      ProfileFormModel.sitRespiratoire: Icons.medical_services_outlined,
                      ProfileFormModel.sitVulnerable: Icons.family_restroom,
                      ProfileFormModel.sitSport: Icons.fitness_center,
                    },
                    sousTitres: {
                      ProfileFormModel.sitRespiratoire: 'Asthme, bronchite chronique, allergies',
                      ProfileFormModel.sitVulnerable: 'Bébés, jeunes enfants, personnes âgées',
                      ProfileFormModel.sitSport: 'Yoga, fitness, télétravail',
                    },
                  ),
                  _choixMultiple(
                    'Sources de particules dans votre logement (optionnel)',
                    [
                      'Fumée de tabac',
                      'Cuisine au gaz ou au charbon',
                      'Bougies ou encens',
                      'Chauffage au bois',
                      'Animaux',
                    ],
                    _profil.sources,
                  ),
                  _choixUnique(
                    'À quelle fréquence aérez-vous la pièce ?',
                    ['Chaque jour', 'Parfois', 'Rarement'],
                    _profil.aeration,
                    (v) => _profil.aeration = v,
                  ),
                  _ouiNon(
                    "Voyez-vous des traces d'humidité ou de moisissures dans la pièce ?",
                    _profil.moisissures,
                    (v) => _profil.moisissures = v,
                  ),

                  if (_profil.aVulnerable) ...[
                    const Divider(height: 40, thickness: 1),
                    _titreSection('2. Personnes vulnérables'),
                    _choixMultiple(
                      'Qui est concerné ?',
                      [
                        'Bébé de moins de 1 an',
                        'Enfant de 1 à 5 ans',
                        'Enfant de 6 à 11 ans',
                        'Personne de 65 ans et plus',
                      ],
                      _profil.personnesVulnerables,
                    ),
                    _choixUnique(
                      'Temps passé par jour dans la pièce surveillée',
                      _heures,
                      _profil.heuresVulnerable,
                      (v) => _profil.heuresVulnerable = v,
                    ),
                    _ouiNon(
                      'La personne dort-elle dans cette pièce ?',
                      _profil.dortDansPiece,
                      (v) => _profil.dortDansPiece = v,
                    ),
                    _ouiNon(
                      'La personne a-t-elle une maladie respiratoire ou une allergie diagnostiquée ?',
                      _profil.maladieRespVulnerable,
                      (v) => _profil.maladieRespVulnerable = v,
                    ),
                  ],

                  if (_profil.aSport) ...[
                    const Divider(height: 40, thickness: 1),
                    _titreSection('3. Sport et télétravail'),
                    _choixMultiple(
                      "Type d'activité dans la pièce",
                      ['Yoga', 'Fitness', 'Télétravail'],
                      _profil.activites,
                    ),
                    _choixUnique(
                      'Temps passé par jour dans la pièce',
                      _heures,
                      _profil.heuresSport,
                      (v) => _profil.heuresSport = v,
                    ),
                    _choixMultiple(
                      'Symptômes ressentis dans la pièce (optionnel)',
                      [
                        'Fatigue',
                        'Maux de tête',
                        'Difficulté de concentration',
                        'Gorge ou yeux irrités',
                      ],
                      _profil.symptomes,
                    ),
                  ],

                  if (_profil.concerneRespiratoire) ...[
                    const Divider(height: 40, thickness: 1),
                    _titreSection('4. Santé respiratoire'),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: BandeauInfo(
                        texte: "Ces questions servent uniquement à personnaliser l'application. "
                            "Elles ne remplacent pas un avis médical.",
                      ),
                    ),
                    _choixMultiple(
                      'Diagnostic',
                      [
                        ProfileFormModel.diagAsthme,
                        'Bronchite chronique',
                        'Allergie respiratoire',
                        'Autre',
                      ],
                      _profil.diagnostics,
                    ),
                    if (_profil.asthme) ...[
                      _titreQuestion('Au cours des 4 dernières semaines :'),
                      _ouiNon(
                        'Symptômes de jour plus de 2 fois par semaine ?',
                        _profil.ginaSymptomesJour,
                        (v) => _profil.ginaSymptomesJour = v,
                      ),
                      _ouiNon(
                        "Réveil pendant la nuit à cause de l'asthme ?",
                        _profil.ginaReveilNuit,
                        (v) => _profil.ginaReveilNuit = v,
                      ),
                      _ouiNon(
                        'Médicament de secours utilisé plus de 2 fois par semaine ?',
                        _profil.ginaMedicamentSecours,
                        (v) => _profil.ginaMedicamentSecours = v,
                      ),
                      _ouiNon(
                        "Activités limitées à cause de l'asthme ?",
                        _profil.ginaLimitation,
                        (v) => _profil.ginaLimitation = v,
                      ),
                    ],
                    _ouiNon(
                      'Au moins une crise sévère (urgences, hospitalisation ou cure de corticoïdes) dans les 12 derniers mois ?',
                      _profil.criseSevere,
                      (v) => _profil.criseSevere = v,
                    ),
                    _choixMultiple(
                      'Déclencheurs connus (optionnel)',
                      [
                        'Poussière',
                        'Fumée',
                        'Humidité ou moisissures',
                        'Air froid',
                        'Odeurs fortes',
                      ],
                      _profil.declencheurs,
                    ),
                  ],

                  const Divider(height: 40, thickness: 1),
                  _champRemarques(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          BarreBasse(
            child: BoutonPrincipal(
              texte: 'Terminer',
              onPressed: _soumettre,
            ),
          ),
        ],
      ),
    );
  }
}