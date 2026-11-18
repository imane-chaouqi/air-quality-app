import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/form_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Charger le thème mémorisé (clair / sombre)
  await themeController.load(); 

  // 2. Vérifier si un e-mail est déjà sauvegardé localement (Session active)
  final prefs = await SharedPreferences.getInstance();
  final String? savedEmail = prefs.getString('user_email');

  runApp(AirSenseApp(savedEmail: savedEmail));
}

class AirSenseApp extends StatelessWidget {
  final String? savedEmail;
  const AirSenseApp({super.key, this.savedEmail});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) => MaterialApp(
        title: 'AirSense',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeController.mode,
        // Si l'utilisateur est déjà connecté, on l'envoie directement sur FormScreen, sinon sur HomeScreen
        home: savedEmail != null
            ? FormScreen(
                userName: savedEmail!.split('@')[0],
                userEmail: savedEmail!,
              )
            : const HomeScreen(),
      ),
    );
  }
}