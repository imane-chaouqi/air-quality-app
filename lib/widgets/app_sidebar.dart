import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../screens/dashboard_screen.dart';
import '../screens/history_screen.dart';
import '../screens/visualization_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/home_screen.dart';

class AppSidebar extends StatelessWidget {
  final String currentRoute;
  final String userName;
  final String userEmail;

  const AppSidebar({
    super.key,
    required this.currentRoute,
    this.userName = 'Siham Mahis',
    this.userEmail = 'siham@mail.com',
  });

  @override
  Widget build(BuildContext context) {
    final parts = userName.trim().split(' ');
    final prenom = parts.isNotEmpty ? parts[0] : 'Siham';
    final nom = parts.length > 1 ? parts.sublist(1).join(' ') : 'Mahis';
    final initials = '${prenom.isNotEmpty ? prenom[0] : ''}${nom.isNotEmpty ? nom[0] : ''}'.toUpperCase();

    return Container(
      width: 90,
      color: AppColors.primaryDark,
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primaryTeal,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildNavItem(
                      context,
                      icon: Icons.dashboard_outlined,
                      label: 'Mesures',
                      isActive: currentRoute == 'mesures',
                      onTap: () {
                        if (currentRoute != 'mesures') {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DashboardScreen(
                                userName: userName,
                                userEmail: userEmail,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildNavItem(
                      context,
                      icon: Icons.history_rounded,
                      label: 'Historique',
                      isActive: currentRoute == 'historique',
                      onTap: () {
                        if (currentRoute != 'historique') {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HistoryScreen(
                                userName: userName,
                                userEmail: userEmail,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildNavItem(
                      context,
                      icon: Icons.bar_chart_rounded,
                      label: 'Visualisation',
                      isActive: currentRoute == 'visualisation',
                      onTap: () {
                        if (currentRoute != 'visualisation') {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VisualizationScreen(
                                userName: userName,
                                userEmail: userEmail,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildNavItem(
                      context,
                      icon: Icons.mic_none_rounded,
                      label: 'Voice',
                      isActive: currentRoute == 'voice',
                      onTap: () {},
                    ),
                    const SizedBox(height: 10),
                    _buildNavItem(
                      context,
                      icon: Icons.person_outline_rounded,
                      label: 'Profil',
                      isActive: currentRoute == 'profil',
                      onTap: () {
                        if (currentRoute != 'profil') {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProfileScreen(
                                userName: userName,
                                userEmail: userEmail,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: InkWell(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.logout_rounded, color: Colors.white70, size: 18),
                    SizedBox(height: 3),
                    Text(
                      'Déconnexion',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 76,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryTeal : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.white70,
              size: 20,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: isActive ? Colors.white : Colors.white70,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}