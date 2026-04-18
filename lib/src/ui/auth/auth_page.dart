import "dart:async";

import "package:flutter/material.dart";

import "../../app_config.dart";
import "../../auth/auth_api_client.dart";
import "../../auth/auth_controller.dart";
import "../../auth/auth_models.dart";
import "../../auth/auth_session_storage.dart";
import "../../auth/auth_state.dart";
import "../../auth/google_identity_service.dart";
import "../../design/editorial_tokens.dart";
import "../../localization/app_strings.dart";
import "../feed/feed_page.dart";
import "../shared/language_toggle.dart";
import "login_view.dart";

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
        final AppStrings strings = context.strings;

        if (session == null) {
          return Scaffold(
            body: DecoratedBox(
              decoration: const BoxDecoration(
                color: EditorialColors.surface,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Color(0xFFF7F7F7),
                    EditorialColors.surface,
                    Color(0xFFF4F4F4),
                  ],
                ),
              ),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    left: -120,
                    bottom: -140,
                    child: Container(
                      width: 360,
                      height: 360,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: <Color>[
                            Color(0x0CD4DBDD),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Stack(
                      children: <Widget>[
                        LoginView(
                          isBusy: state.isBusy,
                          errorMessage: state.errorMessage == null
                              ? null
                              : strings.localizeAuthError(state.errorMessage!),
                          googleClientIdConfigured:
                              AppConfig.googleClientId.isNotEmpty,
                          onGoogleSignIn: _controller.signInWithGoogle,
                          onContinueAsGuest: _showGuestModeNotice,
                        ),
                        const Positioned(
                          top: 20,
                          right: 24,
                          child: LanguageToggle(compact: true),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return FeedPageShell(
          session: session,
          onLogout: _controller.logout,
          onUpdateProfileName: _controller.updateProfile,
        );
      },
    );
  }

  void _showGuestModeNotice() {
    final AppStrings strings = context.strings;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(strings.authGuestModeUnavailable),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
