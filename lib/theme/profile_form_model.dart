// Réponses du formulaire de personnalisation + règles de détection des catégories
class ProfileFormModel {
  // Intitulés des situations (question A3)
  static const String sitRespiratoire =
      "Maladie respiratoire ou allergie diagnostiquée";
  static const String sitVulnerable =
      "Bébé, enfant ou personne de 65 ans et plus dans la pièce";
  static const String sitSport = "Sport ou télétravail à la maison";

  static const String diagAsthme = "Asthme";

  // Intitulés utilisés dans les règles (doivent être identiques à ceux du formulaire)
  static const String age65 = "65 ans et plus";
  static const String symFatigue = "Fatigue";
  static const String symMauxDeTete = "Maux de tête";

  // ----- Bloc A : pour tous -----
  String? trancheAge;
  String? piece;
  final Set<String> situations = {};
  final Set<String> sources = {};
  String? aeration;
  bool? moisissures;

  // ----- Bloc C : personnes vulnérables -----
  final Set<String> personnesVulnerables = {};
  String? heuresVulnerable;
  bool? dortDansPiece;
  bool? maladieRespVulnerable;

  // ----- Bloc D : sport et télétravail -----
  final Set<String> activites = {};
  String? heuresSport;
  final Set<String> symptomes = {};

  // ----- Bloc B : santé respiratoire -----
  final Set<String> diagnostics = {};
  bool? ginaSymptomesJour;
  bool? ginaReveilNuit;
  bool? ginaMedicamentSecours;
  bool? ginaLimitation;
  bool? criseSevere;
  final Set<String> declencheurs = {};

  // ----- Raccourcis de lecture -----

  // Catégorie 2 : case cochée en A3, OU personne de 65 ans et plus (question d'âge)
  bool get aVulnerable =>
      situations.contains(sitVulnerable) || trancheAge == age65;

  bool get aSport => situations.contains(sitSport);
  bool get asthme => diagnostics.contains(diagAsthme);

  // Catégorie 1 : case cochée en A3, ou personne vulnérable avec maladie respiratoire
  bool get concerneRespiratoire =>
      situations.contains(sitRespiratoire) ||
      (aVulnerable && maladieRespVulnerable == true);

  // Au moins un des 4 symptômes coché (seulement si la catégorie 3 est présente)
  bool get symptomesSport => aSport && symptomes.isNotEmpty;

  // ----- Règles de détection -----

  // Renvoie la liste des catégories (1 à 4), la première est le profil principal
  List<int> detecterCategories() {
    final categories = <int>[];
    if (concerneRespiratoire) categories.add(1);
    if (aVulnerable) categories.add(2);
    if (aSport) categories.add(3);
    if (categories.isEmpty) categories.add(4);
    return categories;
  }

  // Nombre de "oui" aux 4 questions GINA (0 à 4)
  int scoreGina() {
    int score = 0;
    final reponses = [
      ginaSymptomesJour,
      ginaReveilNuit,
      ginaMedicamentSecours,
      ginaLimitation,
    ];
    for (final reponse in reponses) {
      if (reponse == true) score++;
    }
    return score;
  }

  // Niveau de sensibilité : "normale", "élevée" ou "très élevée"
  String niveauSensibilite() {
    if (concerneRespiratoire) {
      if (asthme && scoreGina() >= 3) return "très élevée";
      if (criseSevere == true) return "très élevée";
      return "élevée";
    }
    if (aVulnerable) return "élevée";
    if (symptomesSport) return "élevée";
    return "normale";
  }

  static String nomCategorie(int numero) {
    if (numero == 1) return "Problèmes respiratoires";
    if (numero == 2) return "Personnes vulnérables";
    if (numero == 3) return "Sport et télétravail";
    return "Grand public";
  }
}