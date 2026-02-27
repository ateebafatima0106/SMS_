import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:school_management_system/services/auth_service.dart';

/// Centralized API service for all HTTP calls.
/// All networking goes through this class — no direct HTTP calls from controllers.
class ApiService {
  static const String baseUrl = 'http://209.126.84.176:2099';

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  /// Build headers with optional JWT auth token.
  Future<Map<String, String>> _buildHeaders({bool requiresAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await AuthService().getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// Generic GET request.
  /// Returns decoded JSON (Map or List) on success.
  /// Throws [ApiException] on failure.
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParams,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl$endpoint',
      ).replace(queryParameters: queryParams);
      final headers = await _buildHeaders(requiresAuth: requiresAuth);
      final response = await http.get(uri, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}', statusCode: 0);
    }
  }

  /// Generic POST request.
  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = await _buildHeaders(requiresAuth: requiresAuth);
      final response = await http.post(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}', statusCode: 0);
    }
  }

  /// Handle HTTP response: parse JSON or throw ApiException.
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;

      // Try to parse as JSON
      try {
        return jsonDecode(response.body);
      } catch (_) {
        // Response is a plain string (some endpoints return "No Record Found", etc.)
        return response.body;
      }
    } else if (response.statusCode == 401) {
      throw ApiException('Unauthorized. Please login again.', statusCode: 401);
    } else {
      String message = 'Server error (${response.statusCode})';
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body.containsKey('message')) {
          message = body['message'];
        }
      } catch (_) {
        if (response.body.isNotEmpty) {
          message = response.body;
        }
      }
      throw ApiException(message, statusCode: response.statusCode);
    }
  }
}

/// Custom exception for API errors.
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, {required this.statusCode});

  @override
  String toString() => message;
}
