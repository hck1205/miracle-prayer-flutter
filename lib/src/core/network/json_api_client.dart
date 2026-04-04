import "dart:convert";

import "package:http/http.dart" as http;

import "api_exception.dart";

class JsonApiClient {
  JsonApiClient({required this.baseUrl, http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client _httpClient;

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? headers,
  }) async {
    final http.Response response = await _httpClient.get(
      _buildUri(path),
      headers: headers,
    );

    return _decodeJsonMap(response);
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    final http.Response response = await _httpClient.post(
      _buildUri(path),
      headers: <String, String>{
        "Content-Type": "application/json",
        ...?headers,
      },
      body: jsonEncode(body),
    );

    return _decodeJsonMap(response);
  }

  Future<void> postEmpty(
    String path, {
    Map<String, String>? headers,
  }) async {
    final http.Response response = await _httpClient.post(
      _buildUri(path),
      headers: headers,
    );

    if (response.statusCode >= 400) {
      throw _exceptionFromResponse(response);
    }
  }

  Map<String, String> bearerHeaders(String accessToken) {
    return <String, String>{"Authorization": "Bearer $accessToken"};
  }

  Uri _buildUri(String path) => Uri.parse("$baseUrl$path");

  Map<String, dynamic> _decodeJsonMap(http.Response response) {
    if (response.statusCode >= 400) {
      throw _exceptionFromResponse(response);
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  ApiException _exceptionFromResponse(http.Response response) {
    try {
      final Object? decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        final Object? message = decoded["message"];

        if (message is String && message.isNotEmpty) {
          return ApiException(message);
        }

        if (message is List && message.isNotEmpty) {
          return ApiException(message.join("\n"));
        }
      }
    } catch (_) {
      // If the response body is not JSON, fall back to a generic message.
    }

    return ApiException("Request failed with status ${response.statusCode}.");
  }
}
