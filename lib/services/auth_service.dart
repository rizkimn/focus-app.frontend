import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _keyAccessToken = 'access_token';
  static const _keyUserData = 'user_data';

  // Simpan user data setelah login
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserData, jsonEncode(userData));
  }

  // Dapatkan user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyUserData);
    return data != null ? jsonDecode(data) : null;
  }

  // Update user data
  static Future<void> updateUserData(Map<String, dynamic> newData) async {
    final currentData = await getUserData() ?? {};
    currentData.addAll(newData);
    await saveUserData(currentData);
  }

  // Simpan token
  static Future<void> saveTokens(String accessToken) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
  }

  // Dapatkan access token
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  // Hapus token (logout)
  static Future<void> deleteTokens() async {
    await _storage.delete(key: _keyAccessToken);
  }

  // Login dengan username dan password
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final apiUrl = dotenv.env['API_BASE_URL'];
    if (apiUrl == null || apiUrl.isEmpty) {
      throw Exception('API base URL not configured');
    }

    final response = await http.post(
      Uri.parse('$apiUrl/auth/login'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final responseData = jsonDecode(response.body)['data'];

      // Simpan token
      final accessToken = responseData['access_token'];
      final userData = responseData['user'];

      if (accessToken != null && userData != null) {
        await saveTokens(accessToken);
        await saveUserData(userData);
        return responseData;
      } else {
        throw Exception('Invalid response data');
      }
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Login failed');
    }
  }

  // Cek apakah user sudah login
  static Future<bool> isLoggedIn() async {
    return await getAccessToken() != null;
  }
}
