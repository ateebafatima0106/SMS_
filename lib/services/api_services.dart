// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  static const String baseUrl = "http://209.126.84.176:2099";

  // ============================
  // HEADERS 
  // ============================
  static Map<String, String> getHeaders({String? token}) {
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // ============================
  // POST REQUEST
  // ============================
  static Future<dynamic> postRequest({
    required String endpoint,
    required Map<String, dynamic> body,
    String? token,
    int timeoutSeconds = 20,
  }) async {
    final url = Uri.parse("$baseUrl/$endpoint");

    try {
      final response = await http
          .post(
            url,
            headers: getHeaders(token: token),
            body: jsonEncode(body),
          )
          .timeout(Duration(seconds: timeoutSeconds));

      if (kDebugMode) {
        print("POST → $url");
        print("Body → $body");
        print("Status → ${response.statusCode}");
        print("Response → ${response.body}");
      }

      final decoded = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded;
      } else if (response.statusCode == 401) {
        throw Exception("Unauthorized. Please login again.");
      } else {
        throw Exception(decoded["message"] ?? "Server Error");
      }
    } on TimeoutException {
      throw Exception("Request timed out. Check your internet.");
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception:", ""));
    }
  }

  // ============================
  // GET REQUEST
  // ============================
  static Future<dynamic> getRequest({
    required String endpoint,
    String? token,
    int timeoutSeconds = 20,
  }) async {
    final url = Uri.parse("$baseUrl/$endpoint");

    try {
      final response = await http
          .get(
            url,
            headers: getHeaders(token: token),
          )
          .timeout(Duration(seconds: timeoutSeconds));

      if (kDebugMode) {
        print("GET → $url");
        print("Status → ${response.statusCode}");
        print("Response → ${response.body}");
      }

      final decoded = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded;
      } else if (response.statusCode == 401) {
        throw Exception("Unauthorized. Please login again.");
      } else {
        throw Exception(decoded["message"] ?? "Server Error");
      }
    } on TimeoutException {
      throw Exception("Request timed out. Check your internet.");
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception:", ""));
    }
  }

  // ============================
  // PUT REQUEST
  // ============================
  static Future<dynamic> putRequest({
    required String endpoint,
    required Map<String, dynamic> body,
    String? token,
    int timeoutSeconds = 20,
  }) async {
    final url = Uri.parse("$baseUrl/$endpoint");

    try {
      final response = await http
          .put(
            url,
            headers: getHeaders(token: token),
            body: jsonEncode(body),
          )
          .timeout(Duration(seconds: timeoutSeconds));

      final decoded = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded;
      } else {
        throw Exception(decoded["message"] ?? "Server Error");
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception:", ""));
    }
  }

  // ============================
  // DELETE REQUEST
  // ============================
  static Future<dynamic> deleteRequest({
    required String endpoint,
    String? token,
    int timeoutSeconds = 20,
  }) async {
    final url = Uri.parse("$baseUrl/$endpoint");

    try {
      final response = await http
          .delete(
            url,
            headers: getHeaders(token: token),
          )
          .timeout(Duration(seconds: timeoutSeconds));

      final decoded = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded;
      } else {
        throw Exception(decoded["message"] ?? "Server Error");
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception:", ""));
    }
  }

  // ============================
// ADMIT CARD API
// ============================
static Future<List<dynamic>> getAdmitCards({String? token}) async {
  final response = await getRequest(
    endpoint: "AdmitCard",
    token: token,
  );
  return response;
}

// ============================
// TASKS API
// ============================
static Future<List<dynamic>> getTasks({String? token}) async {
  final response = await getRequest(
    endpoint: "Marksheet/tasks",
    token: token,
  );
  return response;
}

}