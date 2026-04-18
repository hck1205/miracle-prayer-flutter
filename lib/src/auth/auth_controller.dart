import "dart:async";

import "package:flutter/foundation.dart";
import "package:google_sign_in/google_sign_in.dart";

import "auth_api_client.dart";
import "auth_error_message.dart";
import "auth_models.dart";
import "auth_session_storage.dart";
import "auth_state.dart";
import "google_identity_service.dart";

class AuthController extends ChangeNotifier {
  AuthController({
    required AuthApiClient authApiClient,
    required AuthSessionStorage sessionStorage,
    required GoogleIdentityService googleIdentityService,
  }) : _authApiClient = authApiClient,
       _sessionStorage = sessionStorage,
       _googleIdentityService = googleIdentityService;

  final AuthApiClient _authApiClient;
  final AuthSessionStorage _sessionStorage;
  final GoogleIdentityService _googleIdentityService;

  AuthState _state = const AuthState.initial();
  StreamSubscription<GoogleSignInAuthenticationEvent>?
  _googleEventsSubscription;
  bool _didBootstrap = false;
  bool _isDisposed = false;

  AuthState get state => _state;

  Future<void> bootstrap() async {
    if (_didBootstrap) {
      return;
    }

    // Google SDK initialization and session restoration are both async, so we
    // guard bootstrap to avoid racing duplicate startup work.
    _didBootstrap = true;
    _updateState(_state.withBusy(true).clearError());

    try {
      await _googleIdentityService.initialize();
      _bindGoogleAuthenticationEvents();

      final AuthSession? storedSession = await _sessionStorage.read();

      if (storedSession != null) {
        final AuthSession restoredSession = await _restoreSession(
          storedSession,
        );
        _updateState(_state.withSession(restoredSession));
      }
    } catch (error) {
      _setError(error);
    } finally {
      _updateState(_state.withBusy(false));
    }
  }

  Future<void> signInWithGoogle() async {
    if (_state.isBusy) {
      return;
    }

    _updateState(_state.withBusy(true).clearError());

    try {
      await _googleIdentityService.authenticate();
    } catch (error) {
      if (isCanceledGoogleSignInError(error)) {
        _updateState(_state.clearError().withBusy(false));
        return;
      }

      _setError(error);
      _updateState(_state.withBusy(false));
    }
  }

  Future<void> refreshSession() async {
    final AuthSession? currentSession = _state.session;

    if (currentSession == null) {
      return;
    }

    _updateState(_state.withBusy(true).clearError());

    try {
      final AuthSession refreshedSession = await _authApiClient.refreshSession(
        currentSession,
      );
      final AuthenticatedUser currentUser = await _authApiClient.getCurrentUser(
        refreshedSession.accessToken,
      );
      final AuthSession persistedSession = refreshedSession.copyWith(
        user: currentUser,
      );

      await _sessionStorage.write(persistedSession);
      _updateState(_state.withSession(persistedSession));
    } catch (error) {
      _setError(error);
    } finally {
      _updateState(_state.withBusy(false));
    }
  }

  Future<void> logout() async {
    final AuthSession? currentSession = _state.session;

    _updateState(_state.withBusy(true).clearError());

    try {
      if (currentSession != null) {
        await _authApiClient.logout(currentSession.accessToken);
      }
    } catch (_) {
      // Best-effort logout. Local state is cleared in the finally block.
    } finally {
      await _sessionStorage.clear();
      await _googleIdentityService.signOut();
      _updateState(
        const AuthState(session: null, isBusy: false, errorMessage: null),
      );
    }
  }

  Future<void> updateProfile({required String name}) async {
    final AuthSession? currentSession = _state.session;
    if (currentSession == null) {
      return;
    }

    final AuthenticatedUser updatedUser = await _authApiClient
        .updateCurrentUserProfile(
          currentSession.accessToken,
          name: name,
        );
    final AuthSession nextSession = currentSession.copyWith(
      user: updatedUser,
    );

    await _sessionStorage.write(nextSession);
    _updateState(_state.withSession(nextSession));
  }

  @override
  void dispose() {
    _isDisposed = true;
    _googleEventsSubscription?.cancel();
    super.dispose();
  }

  void _bindGoogleAuthenticationEvents() {
    // The Google SDK can emit sign-in results after `authenticate()` returns, so
    // the controller listens once and keeps backend exchange in one place.
    _googleEventsSubscription ??= _googleIdentityService.authenticationEvents
        .listen(_handleGoogleAuthenticationEvent, onError: _setError);
  }

  Future<void> _handleGoogleAuthenticationEvent(
    GoogleSignInAuthenticationEvent event,
  ) async {
    switch (event) {
      case GoogleSignInAuthenticationEventSignIn():
        await _exchangeGoogleLogin(event.user);
      case GoogleSignInAuthenticationEventSignOut():
        break;
    }
  }

  Future<AuthSession> _restoreSession(AuthSession storedSession) async {
    try {
      final AuthenticatedUser currentUser = await _authApiClient.getCurrentUser(
        storedSession.accessToken,
      );
      final AuthSession restoredSession = storedSession.copyWith(
        user: currentUser,
      );
      await _sessionStorage.write(restoredSession);
      return restoredSession;
    } catch (_) {
      // If the access token expired while the app was closed, we fall back to a
      // refresh before giving up on the persisted session.
      final AuthSession refreshedSession = await _authApiClient.refreshSession(
        storedSession,
      );
      final AuthenticatedUser currentUser = await _authApiClient.getCurrentUser(
        refreshedSession.accessToken,
      );
      final AuthSession persistedSession = refreshedSession.copyWith(
        user: currentUser,
      );

      await _sessionStorage.write(persistedSession);
      return persistedSession;
    }
  }

  Future<void> _exchangeGoogleLogin(GoogleSignInAccount user) async {
    _updateState(_state.withBusy(true).clearError());

    try {
      final String idToken = await _googleIdentityService.getIdToken(user);
      final AuthSession nextSession = await _authApiClient.loginWithGoogle(
        idToken,
      );

      await _sessionStorage.write(nextSession);
      _updateState(_state.withSession(nextSession));
    } catch (error) {
      // Keep the Google session and backend session aligned. If token exchange
      // fails, signing out avoids leaving the SDK in a half-signed-in state.
      await _googleIdentityService.signOut();
      _setError(error);
    } finally {
      _updateState(_state.withBusy(false));
    }
  }

  void _setError(Object error) {
    _updateState(_state.withError(mapAuthErrorMessage(error)));
  }

  void _updateState(AuthState nextState) {
    if (_isDisposed) {
      return;
    }

    _state = nextState;
    notifyListeners();
  }
}
