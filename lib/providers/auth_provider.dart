import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  String? _accessToken;

  String? get accessToken => _accessToken;

  Future<void> init() async {
    _accessToken = await AuthService.getAccessToken();
    notifyListeners();
  }

  Future<void> setTokens(String accessToken, String refreshToken) async {
    await AuthService.saveTokens(accessToken);
    _accessToken = accessToken;
    notifyListeners();
  }

  Future<void> logout() async {
    await AuthService.deleteTokens();
    _accessToken = null;
    notifyListeners();
  }
}
