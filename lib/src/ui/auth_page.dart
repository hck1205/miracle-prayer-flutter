import "dart:async";

import "package:flutter/material.dart";
import "package:google_sign_in/google_sign_in.dart";

import "../app_config.dart";
import "../auth/auth_api_client.dart";
import "../auth/auth_models.dart";
import "../auth/auth_session_storage.dart";
import "../auth/google_identity_service.dart";
import "auth_widgets.dart";

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final AuthApiClient _authApiClient = AuthApiClient(
    baseUrl: AppConfig.normalizedBackendBaseUrl,
  );
  final AuthSessionStorage _sessionStorage = AuthSessionStorage();
  final GoogleIdentityService _googleIdentityService = GoogleIdentityService(
    clientId: AppConfig.googleClientId,
    serverClientId: AppConfig.googleServerClientId,
  );

  StreamSubscription<GoogleSignInAuthenticationEvent>?
  _googleEventsSubscription;
  AuthSession? _session;
  bool _isBusy = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    unawaited(_bootstrap());
  }

  @override
  void dispose() {
    _googleEventsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });

    try {
      await _googleIdentityService.initialize();
      _googleEventsSubscription ??= _googleIdentityService.authenticationEvents
          .listen(
            _handleGoogleAuthenticationEvent,
            onError: _handleGoogleError,
          );

      final AuthSession? storedSession = await _sessionStorage.read();

      if (storedSession != null) {
        final AuthSession restoredSession = await _restoreSession(
          storedSession,
        );

        if (!mounted) {
          return;
        }

        setState(() {
          _session = restoredSession;
        });
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = _friendlyErrorMessage(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
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

  void _handleGoogleError(Object error) {
    if (!mounted) {
      return;
    }

    setState(() {
      _errorMessage = _friendlyErrorMessage(error);
    });
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
    if (!mounted) {
      return;
    }

    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });

    try {
      final String idToken = await _googleIdentityService.getIdToken(user);
      final AuthSession nextSession = await _authApiClient.loginWithGoogle(
        idToken,
      );

      await _sessionStorage.write(nextSession);

      if (!mounted) {
        return;
      }

      setState(() {
        _session = nextSession;
      });
    } catch (error) {
      await _googleIdentityService.signOut();

      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = _friendlyErrorMessage(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    if (_isBusy) {
      return;
    }

    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });

    try {
      await _googleIdentityService.authenticate();
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isBusy = false;
        _errorMessage = _friendlyErrorMessage(error);
      });
    }
  }

  Future<void> _refreshSession() async {
    final AuthSession? currentSession = _session;

    if (currentSession == null) {
      return;
    }

    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });

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

      if (!mounted) {
        return;
      }

      setState(() {
        _session = persistedSession;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = _friendlyErrorMessage(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    final AuthSession? currentSession = _session;

    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });

    try {
      if (currentSession != null) {
        await _authApiClient.logout(currentSession.accessToken);
      }
    } catch (_) {
      // Best-effort logout. The client session is cleared below either way.
    } finally {
      await _sessionStorage.clear();
      await _googleIdentityService.signOut();

      if (mounted) {
        setState(() {
          _session = null;
          _isBusy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthSession? session = _session;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFFF9F2E6),
              Color(0xFFF2E5D3),
              Color(0xFFE7D7C1),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 360,
                      child: PrayerIntro(
                        isAuthenticated: session != null,
                        user: session?.user,
                      ),
                    ),
                    SizedBox(
                      width: 420,
                      child: session == null
                          ? LoginCard(
                              isBusy: _isBusy,
                              errorMessage: _errorMessage,
                              backendBaseUrl:
                                  AppConfig.normalizedBackendBaseUrl,
                              googleClientIdConfigured:
                                  AppConfig.googleClientId.isNotEmpty,
                              supportsAuthenticate:
                                  _googleIdentityService.supportsAuthenticate,
                              onGoogleSignIn: _signInWithGoogle,
                            )
                          : SessionCard(
                              session: session,
                              isBusy: _isBusy,
                              errorMessage: _errorMessage,
                              backendBaseUrl:
                                  AppConfig.normalizedBackendBaseUrl,
                              onRefreshSession: _refreshSession,
                              onLogout: _logout,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _friendlyErrorMessage(Object error) {
    final String rawMessage = error.toString().replaceFirst("Exception: ", "");

    if (rawMessage.contains("XMLHttpRequest error")) {
      return "Backend request failed. Make sure miracle-prayer-backend is running.";
    }

    if (rawMessage.contains("not initialized")) {
      return "Google sign-in could not initialize. Check GOOGLE_CLIENT_ID.";
    }

    return rawMessage;
  }
}
