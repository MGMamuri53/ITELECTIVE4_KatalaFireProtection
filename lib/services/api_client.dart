import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api',
  );
  static const String _tokenKey = 'katala_api_token';
  static const String _roleKey = 'katala_user_role';

  static Future<String?> token() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<String?> role() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  static Future<void> saveSession(String token, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_roleKey, role);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_roleKey);
  }

  static Future<dynamic> get(String path) async {
    return _send('GET', path);
  }

  static Future<dynamic> post(String path, Map<String, dynamic> body) async {
    return _send('POST', path, body: body);
  }

  static Future<dynamic> put(String path, Map<String, dynamic> body) async {
    return _send('PUT', path, body: body);
  }

  static Future<dynamic> delete(String path) async {
    return _send('DELETE', path);
  }

  static Future<dynamic> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final savedToken = await token();
    final headers = {
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json',
      if (savedToken != null && savedToken.isNotEmpty)
        'Authorization': 'Bearer $savedToken',
    };

    final uri = Uri.parse('$baseUrl$path');
    final http.Response response;
    try {
      response = switch (method) {
        'GET' => await http.get(uri, headers: headers),
        'POST' => await http.post(
          uri,
          headers: headers,
          body: jsonEncode(body),
        ),
        'PUT' => await http.put(uri, headers: headers, body: jsonEncode(body)),
        'DELETE' => await http.delete(uri, headers: headers),
        _ => throw UnsupportedError('Unsupported method $method'),
      };
    } on http.ClientException catch (error) {
      throw Exception(
        'Cannot reach the Laravel API at $baseUrl. Start the backend with '
        '`php artisan serve --host 0.0.0.0 --port 8000`, or set '
        '`API_BASE_URL` to the running backend URL. $error',
      );
    }

    dynamic decoded;
    if (response.body.isNotEmpty) {
      try {
        decoded = jsonDecode(response.body);
      } on FormatException {
        decoded = response.body;
      }
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map<String, dynamic>
          ? decoded['message']?.toString()
          : null;
      throw Exception(message ?? 'Request failed with ${response.statusCode}');
    }

    return decoded;
  }
}
