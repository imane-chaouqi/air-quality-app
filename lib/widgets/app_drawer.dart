import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../screens/form_screen.dart';
import '../screens/home_screen.dart'; // <-- Importation correcte de ta page d'accueil principale
import '../theme/profile_form_model.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Nécessaire pour nettoyer la session locale

class AppDrawer extends StatelessWidget {
  final String userName;
  final String userEmail;
  final ProfileFormModel? currentProfil;

  const AppDrawer({
    super.key,
    required this.userName,
    required this.userEmail,
    this.currentProfil,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.fond,
      child: Column(
        children: [
          // En-tête avec les informations du profil utilisateur
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.turquoiseFonce,
            ),
            accountName: Text(
              userName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              userEmail,
              style: const TextStyle(fontSize: 14),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                size: 40,
                color: AppColors.turquoiseFonce,
              ),
            ),
          ),
          
          // Option pour modifier le profil
          ListTile(
            leading: const Icon(Icons.edit_note, color: AppColors.texte),
            title: const Text('Modifier mon profil (Formulaire)'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FormScreen(
                    userName: userName,
                    userEmail: userEmail,
                  ),
                ),
              );
            },
          ),
          
          // Spacer pour pousser l'option de déconnexion tout en bas
          const Spacer(),

          const Divider(height: 1),

          // Option de déconnexion calée tout en bas
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              'Se déconnecter',
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: const Text('Déconnexion'),
                    content: const Text('Voulez-vous vraiment vous déconnecter ?'),
                    actions: [
                      TextButton(
                        child: const Text('Annuler'),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                      ),
                      TextButton(
                        child: const Text(
                          'Déconnexion',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                        onPressed: () async {
                          // 1. Fermer la boîte de dialogue
                          Navigator.of(dialogContext).pop(); 
                          
                          // 2. Supprimer l'email sauvegardé localement pour effacer la session
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove('user_email');

                          // 3. Rediriger vers la première page (HomeScreen) et vider l'historique de navigation
                          if (!context.mounted) return;
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const HomeScreen()),
                            (route) => false,
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
          // Un petit espace de marge tout en bas
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}