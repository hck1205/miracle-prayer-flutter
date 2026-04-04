import "package:http/http.dart" as http;

import "../core/network/json_api_client.dart";
import "auth_models.dart";

class AuthApiClient {
  AuthApiClient({required this.baseUrl, http.Client? httpClient})
    : _jsonApiClient = JsonApiClient(
        baseUrl: baseUrl,
        httpClient: httpClient,
      );

  final String baseUrl;
  final JsonApiClient _jsonApiClient;

  Future<AuthSession> loginWithGoogle(String idToken) async {
    final Map<String, dynamic> json = await _jsonApiClient.postJson(
      "/v1/auth/google/login",
      body: <String, dynamic>{"idToken": idToken},
    );

    return AuthSession.fromLoginResponse(json);
  }

  Future<AuthSession> refreshSession(AuthSession session) async {
    final Map<String, dynamic> json = await _jsonApiClient.postJson(
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
    final Map<String, dynamic> json = await _jsonApiClient.getJson(
      "/v1/auth/me",
      headers: _jsonApiClient.bearerHeaders(accessToken),
    );

    return AuthenticatedUser.fromJson(json);
  }

  Future<void> logout(String accessToken) async {
    await _jsonApiClient.postEmpty(
      "/v1/auth/logout",
      headers: _jsonApiClient.bearerHeaders(accessToken),
    );
  }
}
