import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/profile_form_model.dart';
import '../widgets/airsense_widgets.dart';
import '../screens/dashboard_screen.dart';

// Page d'analyse : profil, analyse courte, comment l'application aide, sensibilité.
// Les seuils et recommandations seront affichés dans la page des mesures.
class AnalysisScreen extends StatelessWidget {
    final ProfileFormModel profil;
  final String userName;
  final String userEmail;

  const AnalysisScreen({
    super.key,
    required this.profil,
    required this.userName,
    required this.userEmail,
  });

  IconData _icone(int categorie) {
    if (categorie == 1) return Icons.medical_services_outlined;
    if (categorie == 2) return Icons.family_restroom;
    if (categorie == 3) return Icons.fitness_center;
    return Icons.eco;
  }

  Color _couleurSensibilite(String niveau) {
    if (niveau == 'très élevée') return const Color(0xFFC62828);
    if (niveau == 'élevée') return const Color(0xFFE08A00);
    return AppColors.turquoiseFonce;
  }

  // Transforme un ensemble de réponses en texte : "poussière, fumée"
  String _liste(Iterable<String> elements) {
    return elements.map((e) => e.toLowerCase()).join(', ');
  }

  // ----- Phrases de l'analyse -----

  String _phraseGina() {
    final score = profil.scoreGina();
    String etat;
    if (score == 0) {
      etat = 'bien contrôlé';
    } else if (score <= 2) {
      etat = 'partiellement contrôlé';
    } else {
      etat = 'non contrôlé';
    }
    return "Les réponses au questionnaire suggèrent que l'asthme est $etat.";
  }

  // Phrases propres à une catégorie, de la plus importante à la moins importante
  List<String> _phrasesCategorie(int categorie) {
    final phrases = <String>[];

    if (categorie == 1) {
      final diagnostics = profil.diagnostics
          .map((d) => d == 'Autre' ? 'autre problème respiratoire' : d.toLowerCase())
          .join(', ');
      phrases.add('Un problème respiratoire a été indiqué : $diagnostics.');
      if (profil.criseSevere == true) {
        phrases.add('Une crise sévère a été signalée au cours des 12 derniers mois.');
      }
      if (profil.asthme) phrases.add(_phraseGina());
      if (profil.declencheurs.isNotEmpty) {
        phrases.add('Les déclencheurs connus sont : ${_liste(profil.declencheurs)}.');
      }
      phrases.add(
        "Les particules fines et l'humidité peuvent influencer les symptômes : "
        "l'air de la pièce mérite une surveillance renforcée.",
      );
    } else if (categorie == 2) {
      phrases.add(
        "Une personne plus sensible à la qualité de l'air (bébé, jeune enfant "
        "ou personne de 65 ans et plus) utilise cette pièce.",
      );
      if (profil.dortDansPiece == true) {
        phrases.add("Elle y dort, ce qui allonge son temps d'exposition à l'air de la pièce.");
      }
      phrases.add("Des seuils d'alerte plus stricts seront appliqués.");
    } else if (categorie == 3) {
      phrases.add(
        'La pièce est utilisée pour le sport ou le télétravail '
        '(${_liste(profil.activites)}).',
      );
      if (profil.symptomes.isNotEmpty) {
        phrases.add(
          'Des symptômes sont ressentis dans la pièce : ${_liste(profil.symptomes)}.',
        );
        phrases.add(
          "Ils ne sont pas propres à la qualité de l'air, mais la surveillance "
          "peut aider à repérer une cause possible.",
        );
      }
    } else {
      phrases.add("Aucune situation particulière n'a été signalée.");
      phrases.add(
        "L'application vous aidera à suivre l'air, la température et "
        "l'humidité de la pièce au quotidien.",
      );
    }
    return phrases;
  }

  // Phrases sur le logement (sources de particules, humidité, aération)
  List<String> _phrasesContexte() {
    final phrases = <String>[];
    if (profil.sources.isNotEmpty) {
      phrases.add(
        'Des sources de particules ont été signalées dans le logement : '
        '${_liste(profil.sources)}.',
      );
    }
    if (profil.moisissures == true) {
      phrases.add(
        "Des traces d'humidité ou de moisissures ont été signalées : une "
        "humidité élevée favorise les moisissures et les acariens.",
      );
    }
    if (profil.aeration == 'Rarement') {
      phrases.add(
        "La pièce est rarement aérée, ce qui peut laisser les polluants s'accumuler.",
      );
    }
    return phrases;
  }

  // Assemble l'analyse complète : 6 phrases maximum
  List<String> _analyse(List<int> categories, String niveau) {
    final budget = niveau == 'très élevée' ? 5 : 6;
    final parCategorie =
        categories.length == 1 ? budget : budget ~/ categories.length;

    final phrases = <String>[];
    for (final categorie in categories) {
      phrases.addAll(_phrasesCategorie(categorie).take(parCategorie));
    }
    phrases.addAll(_phrasesContexte().take(budget - phrases.length));

    if (niveau == 'très élevée') {
      phrases.add(
        "Si les symptômes sont fréquents ou s'aggravent, parlez-en à un "
        "médecin : cette application ne remplace pas un avis médical.",
      );
    }
    return phrases;
  }

  // ----- Comment l'application peut aider -----

  List<String> _aides(List<int> categories) {
    final aides = <String>[
      "Elle mesure les particules fines (PM1.0, PM2.5, PM10), la température "
          "et l'humidité de la pièce.",
    ];
    for (final categorie in categories) {
      if (categorie == 1) {
        aides.add(
          "Elle vous prévient quand les particules ou l'humidité atteignent "
          "des niveaux qui peuvent aggraver les symptômes.",
        );
      } else if (categorie == 2) {
        aides.add(
          "Elle vous prévient quand l'air de la pièce devient moins sain pour "
          "la personne vulnérable, avec des seuils d'alerte plus stricts.",
        );
      } else if (categorie == 3) {
        aides.add(
          "Elle vous aide à choisir le bon moment pour aérer la pièce ou "
          "faire votre activité.",
        );
      } else {
        aides.add(
          "Elle vous permet de suivre au quotidien la propreté de l'air, la "
          "température et l'humidité.",
        );
      }
    }
    return aides;
  }

  Widget _titreSection(String texte) {
    return Padding(
      padding: const EdgeInsets.only(top: 26, bottom: 12),
      child: Text(texte, style: styleQuestion),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = profil.detecterCategories();
    final niveau = profil.niveauSensibilite();

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
                        const Text('Analyse et orientation', style: styleTitrePage),
                        const SizedBox(height: 6),
                        const Text(
                          'Voici ce que nous avons compris de votre situation.',
                          style: styleSousTitre,
                        ),

                        // 1. Profil
                        _titreSection('Votre profil'),
                        ...List.generate(categories.length, (i) {
                          return OptionTuile(
                            titre: ProfileFormModel.nomCategorie(categories[i]),
                            sousTitre: i == 0 ? 'Profil principal' : 'Profil secondaire',
                            icone: _icone(categories[i]),
                            teinte: categories[i] - 1,
                            selectionnee: i == 0,
                            indicateur: false,
                          );
                        }),

                        // 2. Analyse
                        _titreSection('Votre analyse'),
                        CarteBlanche(
                          child: Text(
                            _analyse(categories, niveau).join(' '),
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: AppColors.texte,
                            ),
                          ),
                        ),

                        // 3. Comment l'application peut vous aider
                        _titreSection("Comment l'application peut vous aider"),
                        CarteBlanche(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ..._aides(categories).map((texte) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: AppColors.turquoiseFonce,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          texte,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            height: 1.4,
                                            color: AppColors.texte,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              const Text(
                                'Elle ne détecte pas les gaz (CO, CO₂, COV) ni les pollens.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.texteSecondaire,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 4. Sensibilité
                        _titreSection('Niveau de sensibilité'),
                        CarteBlanche(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.shield_outlined,
                                color: AppColors.turquoiseFonce,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Sensibilité',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.texte,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: _couleurSensibilite(niveau),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  niveau,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                Expanded(
                  flex: 2,
                  child: BoutonSecondaire(
                    texte: 'Retour',
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: BoutonPrincipal(
                    texte: 'Continuer',
                      onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DashboardScreen(
                            userName: userName,
                            userEmail: userEmail,
                          ),
                        ),
                        (route) => false,
                      );
                    },
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