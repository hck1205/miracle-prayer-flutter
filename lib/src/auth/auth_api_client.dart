import "dart:convert";

import "package:http/http.dart" as http;

import "auth_models.dart";

class AuthApiException implements Exception {
  const AuthApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthApiClient {
  AuthApiClient({required this.baseUrl, http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client _httpClient;

  Future<AuthSession> loginWithGoogle(String idToken) async {
    final Map<String, dynamic> json = await _postJson(
      "/v1/auth/google/login",
      body: <String, dynamic>{"idToken": idToken},
    );

    return AuthSession.fromLoginResponse(json);
  }

  Future<AuthSession> refreshSession(AuthSession session) async {
    final Map<String, dynamic> json = await _postJson(
      "/v1/auth/refresh",
      body: <String, dynamic>{"refreshToken": session.refreshToken},
    );

    return session.copyWith(
      accessToken: json["accessToken"] as String,
      tokenType: json["tokenType"] as String,
      expiresIn: json["expiresIn"] as int,
      refreshToken: json["refreshToken"] as String,
      refreshExpiresIn: json["refreshExpiresIn"] as int,
    );
  }

  Future<AuthenticatedUser> getCurrentUser(String accessToken) async {
    final Map<String, dynamic> json = await _getJson(
      "/v1/auth/me",
      headers: _bearerHeaders(accessToken),
    );

    return AuthenticatedUser.fromJson(json);
  }

  Future<void> logout(String accessToken) async {
    final http.Response response = await _httpClient.post(
      _buildUri("/v1/auth/logout"),
      headers: _bearerHeaders(accessToken),
    );

    if (response.statusCode >= 400) {
      throw _exceptionFromResponse(response);
    }
  }

  Uri _buildUri(String path) => Uri.parse("$baseUrl$path");

  Future<Map<String, dynamic>> _getJson(
    String path, {
    Map<String, String>? headers,
  }) async {
    final http.Response response = await _httpClient.get(
      _buildUri(path),
      headers: headers,
    );

    return _decodeJsonResponse(response);
  }

  Future<Map<String, dynamic>> _postJson(
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

    return _decodeJsonResponse(response);
  }

  Map<String, String> _bearerHeaders(String accessToken) {
    return <String, String>{"Authorization": "Bearer $accessToken"};
  }

  Map<String, dynamic> _decodeJsonResponse(http.Response response) {
    if (response.statusCode >= 400) {
      throw _exceptionFromResponse(response);
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  AuthApiException _exceptionFromResponse(http.Response response) {
    try {
      final Object? decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        final Object? message = decoded["message"];

        if (message is String && message.isNotEmpty) {
          return AuthApiException(message);
        }

        if (message is List && message.isNotEmpty) {
          return AuthApiException(message.join("\n"));
        }
      }
    } catch (_) {
      // Fall back to the generic error below if the body is not JSON.
    }

    return AuthApiException(
      "Request failed with status ${response.statusCode}.",
    );
  }
}
