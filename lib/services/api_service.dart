import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

  static Future<bool> saveProfile(String email, Map<String, dynamic> profilData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/profile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'profil': profilData,
        }),
      );

      if (response.statusCode == 200) {
        print('Profil enregistré avec succès !');
        return true;
      } else {
        print('Erreur serveur : ${response.body}');
        return false;
      }
    } catch (e) {
      print('Erreur de connexion : $e');
      return false;
    }
  }

  static Future<bool> registerUser(String email, String password, String confirmPassword, Map<String, dynamic> profilData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
          'profil': profilData,
        }),
      );

      if (response.statusCode == 201) {
        print('Inscription réussie !');
        return true;
      } else {
        final data = jsonDecode(response.body);
        print('Erreur serveur : ${data['error']}');
        return false;
      }
    } catch (e) {
      print('Erreur de connexion : $e');
      return false;
    }
  }

  static Future<bool> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        print('Connexion réussie !');
        return true;
      } else {
        final data = jsonDecode(response.body);
        print('Erreur serveur : ${data['error']}');
        return false;
      }
    } catch (e) {
      print('Erreur de connexion : $e');
      return false;
    }
  }

  static Future<dynamic> getProfile(String email) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile/$email'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else {
        print('Erreur lors de la récupération du profil : ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception réseau : $e');
      return null;
    }
  }

  // Méthode pour demander la réinitialisation du mot de passe
  static Future<bool> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Erreur réseau : $e');
      return false;
    }
  }

  // Méthode pour envoyer le nouveau mot de passe au backend
  static Future resetPassword(String email, String newPassword, String confirmPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'Succès'};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Une erreur est survenue'};
      }
    } catch (e) {
      print('Erreur réseau : $e');
      return {'success': false, 'error': e.toString()};
    }
  }
}