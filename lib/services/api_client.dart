import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const Duration _requestTimeout = Duration(seconds: 15);
  static const Duration _imageUploadTimeout = Duration(seconds: 60);
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api',
  );
  static const String _tokenKey = 'katala_api_token';
  static const String _roleKey = 'katala_user_role';
  static const String _customerSectionKey = 'katala_customer_section';
  static const String _adminSectionKey = 'katala_admin_section';

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
    await prefs.remove(_customerSectionKey);
    await prefs.remove(_adminSectionKey);
  }

  static Future<int> savedSection(String role) async {
    final prefs = await SharedPreferences.getInstance();
    final key = role.toLowerCase().contains('admin')
        ? _adminSectionKey
        : _customerSectionKey;
    return prefs.getInt(key) ?? 0;
  }

  static Future<void> saveSection(String role, int index) async {
    final prefs = await SharedPreferences.getInstance();
    final key = role.toLowerCase().contains('admin')
        ? _adminSectionKey
        : _customerSectionKey;
    await prefs.setInt(key, index);
  }

  static Future<dynamic> get(String path, {Duration? timeout}) async {
    return _send('GET', path, timeout: timeout);
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

  static Future<dynamic> uploadImage(
    String path,
    Uint8List bytes,
    String fileName,
  ) async {
    final savedToken = await token();
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$path'))
      ..headers['Accept'] = 'application/json'
      ..files.add(
        http.MultipartFile.fromBytes('image', bytes, filename: fileName),
      );
    if (savedToken != null && savedToken.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $savedToken';
    }

    final client = http.Client();
    try {
      final streamedResponse = await client
          .send(request)
          .timeout(_imageUploadTimeout);
      final response = await http.Response.fromStream(
        streamedResponse,
      ).timeout(_imageUploadTimeout);
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
        throw Exception(
          message ?? 'Image upload failed (${response.statusCode})',
        );
      }
      return decoded;
    } on http.ClientException catch (error) {
      throw Exception('Unable to reach the Laravel API: $error');
    } on TimeoutException {
      throw Exception(
        'Image upload timed out after ${_imageUploadTimeout.inSeconds} seconds.',
      );
    } finally {
      client.close();
    }
  }

  static Future<dynamic> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Duration? timeout,
  }) async {
    final requestTimeout = timeout ?? _requestTimeout;
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
        'GET' => await http.get(uri, headers: headers).timeout(requestTimeout),
        'POST' =>
          await http
              .post(uri, headers: headers, body: jsonEncode(body))
              .timeout(requestTimeout),
        'PUT' =>
          await http
              .put(uri, headers: headers, body: jsonEncode(body))
              .timeout(requestTimeout),
        'DELETE' =>
          await http.delete(uri, headers: headers).timeout(requestTimeout),
        _ => throw UnsupportedError('Unsupported method $method'),
      };
    } on http.ClientException catch (error) {
      throw Exception(
        'Cannot reach the Laravel API at $baseUrl. Start the backend with '
        '`php artisan serve --host 0.0.0.0 --port 8000`, or set '
        '`API_BASE_URL` to the running backend URL. $error',
      );
    } on TimeoutException {
      throw Exception(
        'The request to the Laravel API timed out after '
        '${requestTimeout.inSeconds} seconds. Check that the backend and '
        'database are responsive.',
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
