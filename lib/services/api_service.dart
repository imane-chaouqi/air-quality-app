import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

typedef JsonMap = Map<String, dynamic>;

class ApiService {
  // Sur émulateur/appareil physique, remplace 'localhost' par l'IP locale de ton PC (ex: 'http://192.168.1.10:3000/api')
  static const String baseUrl = 'http://localhost:3000/api';

  static Future<bool> saveProfile(
    String email,
    JsonMap profilData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/profile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim().toLowerCase(),
          'profil': profilData,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> registerUser(
    String email,
    String password,
    String confirmPassword,
    JsonMap profilData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim().toLowerCase(),
          'password': password,
          'confirmPassword': confirmPassword,
          'profil': profilData,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<JsonMap?> loginUser(
    String email,
    String password,
  ) async {
    try {
      final cleanEmail = email.trim().toLowerCase();
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': cleanEmail,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final latestProfile = await getProfile(cleanEmail);
        return {
          'user': decoded['user'] ?? decoded,
          'profil': latestProfile ?? decoded['profil'],
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<JsonMap?> getProfile(String email) async {
    try {
      final encodedEmail = Uri.encodeComponent(email.trim().toLowerCase());
      final response = await http.get(
        Uri.parse('$baseUrl/profile/$encodedEmail'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final payload = data['data'] ?? data;
        if (payload is Map<String, dynamic>) {
          return payload['profil'] is Map<String, dynamic>
              ? JsonMap.from(payload['profil'])
              : JsonMap.from(payload);
        }
        return null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email.trim().toLowerCase()}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<JsonMap> resetPassword(
    String email,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim().toLowerCase(),
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'Succès'};
      }
      return {
        'success': false,
        'error': data['error'] ?? 'Une erreur est survenue',
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}