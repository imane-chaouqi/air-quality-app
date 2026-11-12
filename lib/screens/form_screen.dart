import 'package:flutter/material.dart';
import '../theme/profile_form_model.dart';
import '../theme/app_colors.dart';
import '../widgets/airsense_widgets.dart';
import 'analysis_screen.dart';

const List<String> _heures = ['Moins de 4 h', '4 à 8 h', 'Plus de 8 h'];

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final ProfileFormModel _profil = ProfileFormModel();
  int _etape = 0; // numéro de l'étape affichée (0 = première)

  // Liste des étapes à afficher selon les réponses : A, puis C, D, B si nécessaires
  List<String> _listeEtapes() {
    final etapes = <String>['A'];
    if (_profil.aVulnerable) etapes.add('C');
    if (_profil.aSport) etapes.add('D');
    if (_profil.concerneRespiratoire) etapes.add('B');
    return etapes;
  }

  // Vérifie que les questions obligatoires de l'étape sont remplies
  bool _etapeValide(String etape) {
    if (etape == 'A') {
      return _profil.trancheAge != null &&
          _profil.piece != null &&
          _profil.aeration != null &&
          _profil.moisissures != null;
    }
    if (etape == 'C') {
      return _profil.personnesVulnerables.isNotEmpty &&
          _profil.heuresVulnerable != null &&
          _profil.dortDansPiece != null &&
          _profil.maladieRespVulnerable != null;
    }
    if (etape == 'D') {
      return _profil.activites.isNotEmpty && _profil.heuresSport != null;
    }
    // Étape B
    if (_profil.diagnostics.isEmpty) return false;
    if (_profil.asthme) {
      if (_profil.ginaSymptomesJour == null ||
          _profil.ginaReveilNuit == null ||
          _profil.ginaMedicamentSecours == null ||
          _profil.ginaLimitation == null) {
        return false;
      }
    }
    return _profil.criseSevere != null;
  }

  void _suivant() {
    final etapes = _listeEtapes();
    if (!_etapeValide(etapes[_etape])) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Merci de répondre à toutes les questions obligatoires.'),
        ),
      );
      return;
    }
    if (_etape < etapes.length - 1) {
      setState(() {
        _etape++;
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AnalysisScreen(profil: _profil)),
      );
    }
  }

  void _precedent() {
    setState(() {
      _etape--;
    });
  }

  // ----- Composants de question -----

  Widget _titreQuestion(String texte) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Text(texte, style: styleQuestion),
    );
  }

  // Une seule réponse possible (cartes avec bouton radio)
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

  // Plusieurs réponses possibles (cartes avec case à cocher)
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

  // Question Oui / Non (deux cartes côte à côte)
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

  // ----- Contenu de chaque étape -----

  String _titreEtape(String etape) {
    if (etape == 'A') return 'Votre situation';
    if (etape == 'C') return 'Personnes vulnérables';
    if (etape == 'D') return 'Sport et télétravail';
    return 'Santé respiratoire';
  }

  String _sousTitreEtape(String etape) {
    if (etape == 'A') return 'Parlez-nous de vous et de votre logement.';
    if (etape == 'C') return 'Ces informations concernent la personne la plus fragile.';
    if (etape == 'D') return 'Dites-nous comment vous utilisez la pièce.';
    return 'Ces informations nous aident à adapter les alertes.';
  }

  List<Widget> _contenuEtape(String etape) {
    if (etape == 'A') return _etapeA();
    if (etape == 'C') return _etapeC();
    if (etape == 'D') return _etapeD();
    return _etapeB();
  }

  List<Widget> _etapeA() {
    return [
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
        'Quelles situations vous concernent ? (plusieurs choix possibles, '
        'laissez tout décoché si aucune ne vous concerne)',
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
    ];
  }

  List<Widget> _etapeC() {
    return [
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
        'La personne a-t-elle une maladie respiratoire ou une allergie '
        'diagnostiquée ?',
        _profil.maladieRespVulnerable,
        (v) => _profil.maladieRespVulnerable = v,
      ),
    ];
  }

  List<Widget> _etapeD() {
    return [
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
    ];
  }

  List<Widget> _etapeB() {
    return [
      const Padding(
        padding: EdgeInsets.only(top: 16),
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
      // Les 4 questions GINA ne s'affichent que pour l'asthme
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
        'Au moins une crise sévère (urgences, hospitalisation ou cure de '
        'corticoïdes) dans les 12 derniers mois ?',
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
    ];
  }

  // ----- Écran -----

  @override
  Widget build(BuildContext context) {
    final etapes = _listeEtapes();
    final etape = etapes[_etape];
    final estDerniere = _etape == etapes.length - 1;

    return Scaffold(
      backgroundColor: AppColors.fond,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AirSenseHeader(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EtapesProgression(
                          etapeActuelle: _etape,
                          total: etapes.length,
                        ),
                        const SizedBox(height: 24),
                        Text(_titreEtape(etape), style: styleTitrePage),
                        const SizedBox(height: 6),
                        Text(_sousTitreEtape(etape), style: styleSousTitre),
                        ..._contenuEtape(etape),
                        const SizedBox(height: 16),
                        const BandeauInfo(
                          texte:
                              'Vos réponses nous aident à personnaliser vos conseils.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          BarreBasse(
            child: Row(
              children: [
                if (_etape > 0) ...[
                  Expanded(
                    flex: 2,
                    child: BoutonSecondaire(
                      texte: 'Retour',
                      onPressed: _precedent,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  flex: 3,
                  child: BoutonPrincipal(
                    texte: estDerniere ? 'Terminer' : 'Continuer',
                    onPressed: _suivant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}