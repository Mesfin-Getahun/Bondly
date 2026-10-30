import 'dart:convert';
import 'package:http/http.dart' as http;
import '../errors/exceptions.dart';

/// Centralized API client for HTTP / Cloud Functions calls.
class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// Generic GET request
  Future<dynamic> get(
    Uri uri, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _client.get(uri, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      throw ServerException('Network GET request failed: $e');
    }
  }

  /// Generic POST request
  Future<dynamic> post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    try {
      final defaultHeaders = {
        'Content-Type': 'application/json',
        ...?headers,
      };
      final encodedBody = body is String ? body : jsonEncode(body);
      final response = await _client.post(
        uri,
        headers: defaultHeaders,
        body: encodedBody,
      );
      return _handleResponse(response);
    } catch (e) {
      throw ServerException('Network POST request failed: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      throw ServerException(
        'Request failed with status code ${response.statusCode}: ${response.body}',
      );
    }
  }

  void close() {
    _client.close();
  }
}
