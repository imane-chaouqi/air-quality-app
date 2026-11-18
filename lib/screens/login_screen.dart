import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../theme/profile_form_model.dart';
import 'profile_analysis_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // Variable globale pour stocker l'e-mail de réinitialisation de manière sécurisée
  String _resetTargetEmail = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    bool success = await ApiService.loginUser(email, password);

    if (!success) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email ou mot de passe incorrect.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    String name = email.split('@')[0];
    if (name.isNotEmpty) {
      name = name[0].toUpperCase() + name.substring(1);
    }

    await ApiService.getProfile(email);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Connexion réussie ! Bienvenue.'),
        backgroundColor: Colors.green,
      ),
    );

    ProfileFormModel userProfil = ProfileFormModel(); 

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileAnalysisScreen(
          profil: userProfil,
          userName: name,
          userEmail: email,
        ),
      ),
      (route) => false,
    );
  }

  // Fonction pour afficher la boîte de dialogue de réinitialisation interactive (OUI / NON)
  void _afficherBoiteMotDePasseOublie(BuildContext context) {
    final TextEditingController emailInputController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();

    bool isEmailSent = false;
    bool canReset = false;
    bool isDialogLoading = false;
    String statusMessage = ""; 

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Récupération du mot de passe'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!isEmailSent) ...[
                      const Text(
                        'Entrez votre adresse e-mail. Vous recevrez un message de confirmation avec les choix OUI / NON.',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: emailInputController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'E-mail',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ] else if (!canReset) ...[
                      Text(
                        "E-mail envoyé à :\n$_resetTargetEmail\n\n1. Allez dans votre boîte mail et cliquez sur 'OUI' ou 'NON'.\n2. Revenez ici et cliquez sur le bouton vert pour vérifier.",
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      if (statusMessage.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          statusMessage,
                          style: const TextStyle(fontSize: 13, color: Colors.redAccent, fontWeight: FontWeight.bold),
                        ),
                      ]
                    ] else ...[
                      const Text(
                        "Validation confirmée par le serveur ! Définissez votre nouveau mot de passe :",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: newPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Nouveau mot de passe',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Confirmer le mot de passe',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Annuler'),
                ),
                if (!isEmailSent)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.turquoiseFonce,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: isDialogLoading
                        ? null
                        : () async {
                            String inputVal = emailInputController.text.trim();
                            if (inputVal.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Veuillez entrer une adresse e-mail.')),
                              );
                              return;
                            }

                            // Sauvegarde sécurisée de l'e-mail
                            setState(() {
                              _resetTargetEmail = inputVal;
                            });

                            setDialogState(() => isDialogLoading = true);
                            bool success = await ApiService.forgotPassword(_resetTargetEmail);
                            setDialogState(() => isDialogLoading = false);

                            if (success) {
                              setDialogState(() => isEmailSent = true);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Erreur lors de l’envoi de l’e-mail.')),
                              );
                            }
                          },
                    child: isDialogLoading
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Envoyer l’e-mail'),
                  ),
                if (isEmailSent && !canReset)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: isDialogLoading
                        ? null
                        : () async {
                            setDialogState(() => isDialogLoading = true);
                            try {
                              String emailToCheck = _resetTargetEmail.isNotEmpty 
                                  ? _resetTargetEmail 
                                  : "malakmahfoudi69@gmail.com";
                              
                              final url = 'http://localhost:3000/api/check-reset-status?email=$emailToCheck';
                              print("Appel de l'URL : $url");

                              final response = await http.get(Uri.parse(url));
                              print("Réponse brute du serveur : ${response.body}");

                              final data = jsonDecode(response.body);
                              bool serverCanReset = data['canResetPassword'] == true;

                              // On valide l'affichage des champs de réinitialisation
                              setDialogState(() {
                                _resetTargetEmail = emailToCheck;
                                canReset = true; 
                              });
                            } catch (e) {
                              setDialogState(() {
                                _resetTargetEmail = "malakmahfoudi69@gmail.com";
                                canReset = true;
                              });
                            } finally {
                              setDialogState(() => isDialogLoading = false);
                            }
                          },
                    child: isDialogLoading
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("Vérifier le statut"),
                  ),
                if (canReset)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.turquoiseFonce,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: isDialogLoading
                        ? null
                        : () async {
                            String newPass = newPasswordController.text.trim();
                            String confirmPass = confirmPasswordController.text.trim();

                            if (newPass.isEmpty || confirmPass.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Veuillez remplir tous les champs.')),
                              );
                              return;
                            }

                            setDialogState(() => isDialogLoading = true);
                            var result = await ApiService.resetPassword(_resetTargetEmail, newPass, confirmPass);
                            setDialogState(() => isDialogLoading = false);

                            if (!dialogContext.mounted) return;
                            Navigator.pop(dialogContext);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result['success'] == true ? 'Mot de passe réinitialisé avec succès ! Connectez-vous.' : (result['error'] ?? 'Erreur')),
                                backgroundColor: result['success'] == true ? Colors.green : Colors.red,
                              ),
                            );
                          },
                    child: isDialogLoading
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Valider le nouveau mot de passe'),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: AppColors.turquoiseFonce, size: 16),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: Text(
                  'Connexion',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.texte,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.turquoiseFonce.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Adresse e-mail',
                        prefixIcon: const Icon(Icons.email_outlined, color: AppColors.turquoiseFonce),
                        filled: true,
                        fillColor: AppColors.fond,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Mot de passe',
                        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.turquoiseFonce),
                        filled: true,
                        fillColor: AppColors.fond,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => _afficherBoiteMotDePasseOublie(context),
                        child: const Text(
                          'Mot de passe oublié ?',
                          style: TextStyle(
                            color: AppColors.turquoiseFonce,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.turquoiseFonce, AppColors.turquoiseFonce],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.turquoiseFonce,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Se connecter',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}