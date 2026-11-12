import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// ----- Styles de texte communs -----
const TextStyle styleTitrePage = TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.bold,
  color: AppColors.bleuMarine,
);

const TextStyle styleSousTitre = TextStyle(
  fontSize: 16,
  color: AppColors.texteSecondaire,
);

const TextStyle styleQuestion = TextStyle(
  fontSize: 17,
  fontWeight: FontWeight.w700,
  color: AppColors.texte,
);

// Ombre douce des cartes
const List<BoxShadow> ombreCarte = [
  BoxShadow(
    color: Color(0x1A0B2545),
    blurRadius: 14,
    offset: Offset(0, 4),
  ),
];

// ----- Dessin des vagues de l'en-tête -----
class _EnTetePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Grande forme bleu clair en haut à droite
    final forme = Path()
      ..moveTo(w * 0.62, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h * 0.48)
      ..quadraticBezierTo(w * 0.72, h * 0.30, w * 0.62, 0)
      ..close();
    canvas.drawPath(forme, Paint()..color = const Color(0x66A8DCF0));

    // Vague turquoise (dégradé) en bas
    final vague1 = Path()
      ..moveTo(0, h - 62)
      ..quadraticBezierTo(w * 0.25, h - 92, w * 0.55, h - 58)
      ..quadraticBezierTo(w * 0.82, h - 30, w, h - 80)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    final degrade = const LinearGradient(
      colors: [Color(0xFF3CC8BD), Color(0xFF9BE3DC)],
    ).createShader(Rect.fromLTWH(0, h - 100, w, 100));
    canvas.drawPath(vague1, Paint()..shader = degrade);

    // Vague de la couleur du fond, par-dessus
    final vague2 = Path()
      ..moveTo(0, h - 28)
      ..quadraticBezierTo(w * 0.30, h - 52, w * 0.60, h - 26)
      ..quadraticBezierTo(w * 0.85, h - 6, w, h - 34)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(vague2, Paint()..color = AppColors.fond);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ----- En-tête : nom AirSense, slogan, vagues, bouton réglages -----
class AirSenseHeader extends StatelessWidget {
  const AirSenseHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final haut = MediaQuery.of(context).padding.top;

    return SizedBox(
      width: double.infinity,
      height: 230 + haut,
      child: Stack(
        children: [
          // Fond dégradé bleu très clair
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFD5EEF4),
                    Color(0xFFEAF7F8),
                    AppColors.fond,
                  ],
                ),
              ),
            ),
          ),
          // Vagues
          Positioned.fill(child: CustomPaint(painter: _EnTetePainter())),
          // Nom et slogan
          Positioned(
            left: 24,
            top: 56 + haut,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    style: TextStyle(fontSize: 46, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                        text: 'Air',
                        style: TextStyle(color: AppColors.bleuMarine),
                      ),
                      TextSpan(
                        text: 'Sense',
                        style: TextStyle(color: AppColors.turquoiseFonce),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Respirez mieux. Vivez mieux.',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.bleuMarine,
                  ),
                ),
              ],
            ),
          ),
          // Bouton réglages (décoratif pour l'instant)
          Positioned(
            right: 20,
            top: 16 + haut,
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: ombreCarte,
              ),
              child: const Icon(Icons.settings, color: AppColors.bleuMarine),
            ),
          ),
        ],
      ),
    );
  }
}

// ----- Barre de progression en segments : "Étape 1 sur 3" -----
class EtapesProgression extends StatelessWidget {
  final int etapeActuelle; // 0 = première étape
  final int total;

  const EtapesProgression({
    super.key,
    required this.etapeActuelle,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Étape ${etapeActuelle + 1} sur $total',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.bleuMarine,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(total, (i) {
            return Expanded(
              child: Container(
                height: 10,
                margin: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
                decoration: BoxDecoration(
                  color: i <= etapeActuelle
                      ? AppColors.turquoiseFonce
                      : const Color(0xFFDCE4E8),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ----- Carte blanche avec ombre douce -----
class CarteBlanche extends StatelessWidget {
  final Widget child;

  const CarteBlanche({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: ombreCarte,
      ),
      child: child,
    );
  }
}

// ----- Carte de choix (réponse sélectionnable) -----
class OptionTuile extends StatelessWidget {
  final String titre;
  final String? sousTitre;
  final IconData? icone;
  final int teinte; // 0 = turquoise, 1 = vert, 2 = bleu (couleur de l'icône)
  final bool selectionnee;
  final bool multiple; // true = plusieurs choix possibles
  final bool indicateur; // false = carte d'affichage seulement
  final VoidCallback? onTap;

  const OptionTuile({
    super.key,
    required this.titre,
    this.sousTitre,
    this.icone,
    this.teinte = 0,
    this.selectionnee = false,
    this.multiple = false,
    this.indicateur = true,
    this.onTap,
  });

  static const List<Color> _fonds = [
    Color(0xFFDDF3F0),
    Color(0xFFDDF3E4),
    Color(0xFFD6E8FB),
  ];
  static const List<Color> _couleurs = [
    AppColors.turquoiseFonce,
    Color(0xFF2E9E5B),
    Color(0xFF2F7BD6),
  ];

  @override
  Widget build(BuildContext context) {
    final i = teinte % 3;

    IconData iconeIndicateur;
    if (multiple) {
      iconeIndicateur =
          selectionnee ? Icons.check_circle : Icons.radio_button_unchecked;
    } else {
      iconeIndicateur = selectionnee
          ? Icons.radio_button_checked
          : Icons.radio_button_unchecked;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: icone != null ? 14 : 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selectionnee
                ? AppColors.turquoiseFonce
                : const Color(0xFFE6ECEF),
            width: selectionnee ? 2 : 1,
          ),
          boxShadow: ombreCarte,
        ),
        child: Row(
          children: [
            if (icone != null) ...[
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _fonds[i],
                  shape: BoxShape.circle,
                ),
                child: Icon(icone, color: _couleurs[i], size: 28),
              ),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titre,
                    style: TextStyle(
                      fontSize: icone != null ? 17 : 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.texte,
                    ),
                  ),
                  if (sousTitre != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        sousTitre!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.texteSecondaire,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (indicateur)
              Icon(
                iconeIndicateur,
                size: 28,
                color: selectionnee
                    ? AppColors.turquoiseFonce
                    : const Color(0xFFB8C2CC),
              ),
          ],
        ),
      ),
    );
  }
}

// ----- Bandeau d'information -----
class BandeauInfo extends StatelessWidget {
  final String texte;

  const BandeauInfo({super.key, required this.texte});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.turquoiseClair,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.info, color: AppColors.turquoiseFonce, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              texte,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.turquoiseFonce,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ----- Dessin des vagues du bas de l'écran -----
class _BasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final turquoise = Path()
      ..moveTo(0, h * 0.55)
      ..quadraticBezierTo(w * 0.25, h * 0.25, w * 0.55, h * 0.65)
      ..quadraticBezierTo(w * 0.85, h * 1.00, w, h * 0.50)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(turquoise, Paint()..color = const Color(0x3326C1B5));

    final vert = Path()
      ..moveTo(0, h * 0.80)
      ..quadraticBezierTo(w * 0.35, h * 0.55, w * 0.70, h * 0.90)
      ..quadraticBezierTo(w * 0.90, h * 1.05, w, h * 0.75)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(vert, Paint()..color = const Color(0x332E9E5B));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ----- Barre du bas : vagues décoratives + boutons -----
class BarreBasse extends StatelessWidget {
  final Widget child;

  const BarreBasse({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _BasPainter())),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
            child: child,
          ),
        ),
      ],
    );
  }
}

// ----- Bouton plein "Continuer →" -----
class BoutonPrincipal extends StatelessWidget {
  final String texte;
  final VoidCallback onPressed;

  const BoutonPrincipal({
    super.key,
    required this.texte,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.turquoiseFonce,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(texte),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, size: 22),
          ],
        ),
      ),
    );
  }
}

// ----- Bouton contour "← Retour" -----
class BoutonSecondaire extends StatelessWidget {
  final String texte;
  final VoidCallback onPressed;

  const BoutonSecondaire({
    super.key,
    required this.texte,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.turquoiseFonce,
          side: const BorderSide(color: AppColors.turquoiseFonce, width: 1.5),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.arrow_back, size: 22),
            const SizedBox(width: 8),
            Text(texte),
          ],
        ),
      ),
    );
  }
}