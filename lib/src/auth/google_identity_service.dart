import "dart:async";

import "package:google_sign_in/google_sign_in.dart";

class GoogleIdentityService {
  GoogleIdentityService({String? clientId, String? serverClientId})
    : _clientId = _normalize(clientId),
      _serverClientId = _normalize(serverClientId);

  final String? _clientId;
  final String? _serverClientId;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  Future<void>? _initialization;

  Stream<GoogleSignInAuthenticationEvent> get authenticationEvents =>
      _googleSignIn.authenticationEvents;

  bool get supportsAuthenticate => _googleSignIn.supportsAuthenticate();

  Future<void> initialize() {
    _initialization ??= _googleSignIn
        .initialize(clientId: _clientId, serverClientId: _serverClientId)
        .then((_) {
          final Future<GoogleSignInAccount?>? attempt = _googleSignIn
              .attemptLightweightAuthentication();

          if (attempt != null) {
            unawaited(attempt);
          }
        });

    return _initialization!;
  }

  Future<void> authenticate() async {
    await initialize();
    await _googleSignIn.authenticate();
  }

  Future<void> signOut() async {
    await initialize();
    await _googleSignIn.signOut();
  }

  Future<String> getIdToken(GoogleSignInAccount user) async {
    final GoogleSignInAuthentication authentication = user.authentication;
    final String? idToken = authentication.idToken;

    if (idToken == null || idToken.isEmpty) {
      throw StateError(
        "Google sign-in succeeded, but no ID token was returned. "
        "Check your Google OAuth client configuration.",
      );
    }

    return idToken;
  }

  static String? _normalize(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return value.trim();
  }
}
