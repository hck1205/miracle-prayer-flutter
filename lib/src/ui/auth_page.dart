import "dart:async";

import "package:flutter/material.dart";
import "package:google_sign_in/google_sign_in.dart";

import "../app_config.dart";
import "../auth/auth_api_client.dart";
import "../auth/auth_models.dart";
import "../auth/auth_session_storage.dart";
import "../auth/google_identity_service.dart";
import "../design/editorial_components.dart";
import "../design/editorial_tokens.dart";
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
          color: EditorialColors.surface,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              EditorialColors.surface,
              EditorialColors.surfaceLow,
              EditorialColors.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: <Widget>[
              Positioned(
                top: -80,
                right: -40,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: <Color>[
                        EditorialColors.reflectionGlow,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(EditorialSpacing.mobileGutter),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraints) {
                        final bool stacked = constraints.maxWidth < 900;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Align(
                              alignment: Alignment.topCenter,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 640),
                                child: EditorialGlassBar(
                                  child: Row(
                                    children: <Widget>[
                                      const EditorialMetaText("Reflection Header"),
                                      const Spacer(),
                                      Text(
                                        session == null
                                            ? "Google identity is waiting"
                                            : "Session is active",
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: EditorialSpacing.xLarge),
                            if (stacked)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  PrayerIntro(
                                    isAuthenticated: session != null,
                                    user: session?.user,
                                  ),
                                  const SizedBox(height: EditorialSpacing.large),
                                  _AuthPanel(
                                    session: session,
                                    isBusy: _isBusy,
                                    errorMessage: _errorMessage,
                                    backendBaseUrl:
                                        AppConfig.normalizedBackendBaseUrl,
                                    googleClientIdConfigured:
                                        AppConfig.googleClientId.isNotEmpty,
                                    supportsAuthenticate:
                                        _googleIdentityService.supportsAuthenticate,
                                    onGoogleSignIn: _signInWithGoogle,
                                    onRefreshSession: _refreshSession,
                                    onLogout: _logout,
                                  ),
                                ],
                              )
                            else
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    flex: 6,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        top: EditorialSpacing.large,
                                        right: EditorialSpacing.xLarge,
                                      ),
                                      child: PrayerIntro(
                                        isAuthenticated: session != null,
                                        user: session?.user,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 5,
                                    child: _AuthPanel(
                                      session: session,
                                      isBusy: _isBusy,
                                      errorMessage: _errorMessage,
                                      backendBaseUrl:
                                          AppConfig.normalizedBackendBaseUrl,
                                      googleClientIdConfigured:
                                          AppConfig.googleClientId.isNotEmpty,
                                      supportsAuthenticate:
                                          _googleIdentityService.supportsAuthenticate,
                                      onGoogleSignIn: _signInWithGoogle,
                                      onRefreshSession: _refreshSession,
                                      onLogout: _logout,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
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

class _AuthPanel extends StatelessWidget {
  const _AuthPanel({
    required this.session,
    required this.isBusy,
    required this.errorMessage,
    required this.backendBaseUrl,
    required this.googleClientIdConfigured,
    required this.supportsAuthenticate,
    required this.onGoogleSignIn,
    required this.onRefreshSession,
    required this.onLogout,
  });

  final AuthSession? session;
  final bool isBusy;
  final String? errorMessage;
  final String backendBaseUrl;
  final bool googleClientIdConfigured;
  final bool supportsAuthenticate;
  final VoidCallback onGoogleSignIn;
  final VoidCallback onRefreshSession;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return session == null
        ? LoginCard(
            isBusy: isBusy,
            errorMessage: errorMessage,
            backendBaseUrl: backendBaseUrl,
            googleClientIdConfigured: googleClientIdConfigured,
            supportsAuthenticate: supportsAuthenticate,
            onGoogleSignIn: onGoogleSignIn,
          )
        : SessionCard(
            session: session!,
            isBusy: isBusy,
            errorMessage: errorMessage,
            backendBaseUrl: backendBaseUrl,
            onRefreshSession: onRefreshSession,
            onLogout: onLogout,
          );
  }
}
