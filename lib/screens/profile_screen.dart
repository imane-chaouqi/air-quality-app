import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/ui_helpers.dart';
import '../widgets/app_sidebar.dart';

class ProfileScreen extends StatelessWidget {
  final String userName;
  final String userEmail;

  const ProfileScreen({
    super.key,
    this.userName = 'Siham Mahis',
    this.userEmail = 'siham@mail.com',
  });

  @override
  Widget build(BuildContext context) {
    // Extraction dynamique du prénom et du nom à partir de userName
    final parts = userName.trim().split(' ');
    final prenom = parts.isNotEmpty ? parts[0] : 'Siham';
    final nom = parts.length > 1 ? parts.sublist(1).join(' ') : 'Mahis';
    final initials =
        '${prenom.isNotEmpty ? prenom[0] : ''}${nom.isNotEmpty ? nom[0] : ''}'
            .toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // 1. Barre latérale fixe à gauche avec transmission des données
          AppSidebar(
            currentRoute: 'profil',
            userName: userName,
            userEmail: userEmail,
          ),
          
          // 2. Contenu du profil à droite
          Expanded(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text('Mon Profil',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                centerTitle: true,
              ),
              body: Stack(
                children: [
                  const WaveBackground(),
                  SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ---- Carte identité ----
                          FadeSlideIn(
                            index: 0,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: appCardDecoration(radius: 28),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: AppColors.primaryTeal.withOpacity(0.35),
                                          width: 2),
                                    ),
                                    child: Container(
                                      width: 76,
                                      height: 76,
                                      alignment: Alignment.center,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.primaryDark,
                                            AppColors.primaryTeal
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: Text(
                                        initials,
                                        style: const TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    '$prenom $nom',
                                    style: const TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    userEmail,
                                    style: const TextStyle(
                                        fontSize: 13, color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(child: _infoChip('Prénom', prenom)),
                                      const SizedBox(width: 10),
                                      Expanded(child: _infoChip('Nom', nom)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ---- Sécurité ----
                          FadeSlideIn(
                            index: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _sectionTitle('Sécurité'),
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: appCardDecoration(),
                                  child: Row(
                                    children: [
                                      _iconBox(Icons.lock_outline),
                                      const SizedBox(width: 12),
                                      const Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Mot de passe',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.textPrimary)),
                                            SizedBox(height: 2),
                                            Text('••••••••',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: AppColors.textSecondary)),
                                          ],
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.softTealBg,
                                          foregroundColor: AppColors.primaryTeal,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20)),
                                        ),
                                        child: const Text('Changer',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ---- Santé ----
                          FadeSlideIn(
                            index: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _sectionTitle('Informations de santé'),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: appCardDecoration(),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          _iconBox(Icons.medical_services_outlined),
                                          const SizedBox(width: 12),
                                          const Expanded(
                                            child: Text(
                                              'Asthme, allergies respiratoires',
                                              style: TextStyle(
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.textPrimary),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColors.softTealBg,
                                              AppColors.subCardBackground,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(18),
                                          border: Border.all(
                                              color: AppColors.primaryTeal
                                                  .withOpacity(0.2)),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.air,
                                                color: AppColors.primaryTeal, size: 28),
                                            const SizedBox(width: 12),
                                            const Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text('Catégorie actuelle',
                                                      style: TextStyle(
                                                          fontSize: 11,
                                                          color:
                                                              AppColors.textSecondary)),
                                                  SizedBox(height: 2),
                                                  Text(
                                                    'Personnes souffrant de problèmes respiratoires chroniques',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w600,
                                                        color: AppColors.textPrimary),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 5),
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryTeal,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Text('Cat. 1',
                                                  style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white)),
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
                          const SizedBox(height: 24),

                          // ---- Bouton réanalyser ----
                          FadeSlideIn(
                            index: 3,
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.refresh_rounded,
                                  color: AppColors.primaryTeal, size: 20),
                              label: const Text('Réanalyser mon profil',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryTeal)),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.85),
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                side: const BorderSide(
                                    color: AppColors.primaryTeal, width: 1.5),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
                color: AppColors.textSecondary)),
      );

  Widget _iconBox(IconData icon) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.softTealBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: AppColors.primaryTeal, size: 20),
      );

  Widget _infoChip(String label, String value) => Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.subCardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 10.5, color: AppColors.textSecondary)),
            const SizedBox(height: 2),
            Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ],
        ),
      );
}