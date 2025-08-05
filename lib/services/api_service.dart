import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';

class ApiService {
  static Future<http.Response> authenticatedGet(
    BuildContext context,
    String endpoint,
  ) async {
    final accessToken = await AuthService.getAccessToken();
    if (accessToken == null) throw Exception('Not authenticated');

    return await http.get(
      Uri.parse('${dotenv.env['API_BASE_URL']}$endpoint'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      },
    );
  }

  static Future<http.Response> authenticatedPost(
    BuildContext context,
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final accessToken = await AuthService.getAccessToken();
    if (accessToken == null) throw Exception('Not authenticated');

    return await http.post(
      Uri.parse('${dotenv.env['API_BASE_URL']}$endpoint'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
  }
}
