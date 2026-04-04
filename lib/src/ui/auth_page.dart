import "dart:async";

import "package:flutter/material.dart";

import "../app_config.dart";
import "../auth/auth_api_client.dart";
import "../auth/auth_controller.dart";
import "../auth/auth_models.dart";
import "../auth/auth_session_storage.dart";
import "../auth/auth_state.dart";
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
  late final AuthController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AuthController(
      authApiClient: AuthApiClient(baseUrl: AppConfig.normalizedBackendBaseUrl),
      sessionStorage: AuthSessionStorage(),
      googleIdentityService: GoogleIdentityService(
        clientId: AppConfig.googleClientId,
        serverClientId: AppConfig.googleServerClientId,
      ),
    );
    unawaited(_controller.bootstrap());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, _) {
        final AuthState state = _controller.state;
        final AuthSession? session = state.session;

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
                          builder:
                              (BuildContext context, BoxConstraints constraints) {
                                final bool stacked = constraints.maxWidth < 900;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Align(
                                      alignment: Alignment.topCenter,
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 640,
                                        ),
                                        child: EditorialGlassBar(
                                          child: Row(
                                            children: <Widget>[
                                              const EditorialMetaText(
                                                "Reflection Header",
                                              ),
                                              const Spacer(),
                                              Text(
                                                session == null
                                                    ? "Google identity is waiting"
                                                    : "Session is active",
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.bodyMedium,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: EditorialSpacing.xLarge,
                                    ),
                                    if (stacked)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          PrayerIntro(
                                            isAuthenticated:
                                                state.isAuthenticated,
                                            user: session?.user,
                                          ),
                                          const SizedBox(
                                            height: EditorialSpacing.large,
                                          ),
                                          _AuthPanel(
                                            state: state,
                                            backendBaseUrl:
                                                AppConfig.normalizedBackendBaseUrl,
                                            googleClientIdConfigured:
                                                AppConfig.googleClientId.isNotEmpty,
                                            supportsAuthenticate:
                                                _controller.supportsAuthenticate,
                                            onGoogleSignIn:
                                                _controller.signInWithGoogle,
                                            onRefreshSession:
                                                _controller.refreshSession,
                                            onLogout: _controller.logout,
                                          ),
                                        ],
                                      )
                                    else
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Expanded(
                                            flex: 6,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                top: EditorialSpacing.large,
                                                right: EditorialSpacing.xLarge,
                                              ),
                                              child: PrayerIntro(
                                                isAuthenticated:
                                                    state.isAuthenticated,
                                                user: session?.user,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 5,
                                            child: _AuthPanel(
                                              state: state,
                                              backendBaseUrl:
                                                  AppConfig.normalizedBackendBaseUrl,
                                              googleClientIdConfigured:
                                                  AppConfig.googleClientId.isNotEmpty,
                                              supportsAuthenticate:
                                                  _controller.supportsAuthenticate,
                                              onGoogleSignIn:
                                                  _controller.signInWithGoogle,
                                              onRefreshSession:
                                                  _controller.refreshSession,
                                              onLogout: _controller.logout,
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
      },
    );
  }
}

class _AuthPanel extends StatelessWidget {
  const _AuthPanel({
    required this.state,
    required this.backendBaseUrl,
    required this.googleClientIdConfigured,
    required this.supportsAuthenticate,
    required this.onGoogleSignIn,
    required this.onRefreshSession,
    required this.onLogout,
  });

  final AuthState state;
  final String backendBaseUrl;
  final bool googleClientIdConfigured;
  final bool supportsAuthenticate;
  final VoidCallback onGoogleSignIn;
  final VoidCallback onRefreshSession;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return state.session == null
        ? LoginCard(
            isBusy: state.isBusy,
            errorMessage: state.errorMessage,
            backendBaseUrl: backendBaseUrl,
            googleClientIdConfigured: googleClientIdConfigured,
            supportsAuthenticate: supportsAuthenticate,
            onGoogleSignIn: onGoogleSignIn,
          )
        : SessionCard(
            session: state.session!,
            isBusy: state.isBusy,
            errorMessage: state.errorMessage,
            backendBaseUrl: backendBaseUrl,
            onRefreshSession: onRefreshSession,
            onLogout: onLogout,
          );
  }
}
