import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Centralized Shared API Service connecting the Mazhi Sheti Android App
/// to the unified Next.js + Neon PostgreSQL backend.
/// Uses native dart:io HttpClient with zero external dependencies.
class MazhiShetiApiService {
  // Update this to your deployed domain or local machine IP when testing on physical Wi-Fi
  static String baseUrl = 'http://10.0.2.2:3000/api';

  static void setBaseUrl(String url) {
    baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  /// Synchronize farmer identity across Android and Neon PostgreSQL.
  /// Guarantees that users logging in via Google on Android resolve to the exact
  /// same database record as the Web platform.
  static Future<Map<String, dynamic>?> syncFarmerWithNeon({
    required String email,
    required String fullName,
    String? photoUrl,
    required String uid,
  }) async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 4);
      final request = await client.postUrl(Uri.parse('$baseUrl/me/sync'));
      request.headers.set('content-type', 'application/json; charset=utf-8');
      request.write(jsonEncode({
        'email': email,
        'fullName': fullName,
        'photoUrl': photoUrl,
        'uid': uid,
      }));
      final response = await request.close();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = await response.transform(utf8.decoder).join();
        return jsonDecode(body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('[ApiService] Neon sync notice: $e (Proceeding with local cache)');
    }
    return null;
  }

  /// Fetch farms from Neon PostgreSQL
  static Future<List<dynamic>> fetchFarms() async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 4);
      final request = await client.getUrl(Uri.parse('$baseUrl/farms'));
      final response = await request.close();
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final data = jsonDecode(body);
        if (data is List) return data;
        if (data is Map && data['data'] is List) return data['data'] as List;
      }
    } catch (e) {
      debugPrint('[ApiService] Fetch farms notice: $e');
    }
    return [];
  }

  /// Fetch live sensor telemetry & drone NDVI from Neon
  static Future<Map<String, dynamic>?> fetchLiveTelemetry() async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 4);
      final request = await client.getUrl(Uri.parse('$baseUrl/devices/telemetry'));
      final response = await request.close();
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        return jsonDecode(body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('[ApiService] Fetch telemetry notice: $e');
    }
    return null;
  }
}
