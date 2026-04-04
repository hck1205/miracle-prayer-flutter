import "package:flutter/material.dart";

import "../../design/editorial_tokens.dart";
import "login_components.dart";

class LoginView extends StatelessWidget {
  const LoginView({
    super.key,
    required this.isBusy,
    required this.errorMessage,
    required this.googleClientIdConfigured,
    required this.onGoogleSignIn,
    required this.onContinueAsGuest,
  });

  final bool isBusy;
  final String? errorMessage;
  final bool googleClientIdConfigured;
  final VoidCallback onGoogleSignIn;
  final VoidCallback onContinueAsGuest;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool hasBoundedHeight = constraints.hasBoundedHeight;
        final double minHeight = hasBoundedHeight ? constraints.maxHeight : 0;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: EditorialSpacing.mobileGutter,
            vertical: EditorialSpacing.mobileGutter,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const PresenceWordmark(),
                    const SizedBox(height: 88),
                    const LoginHero(
                      title: "Join the Silence",
                      subtitle: "Take a breath. Enter your quiet space.",
                    ),
                    const SizedBox(height: 56),
                    if (isBusy)
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: EditorialSpacing.large,
                        ),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else if (!googleClientIdConfigured)
                      const LoginStatusNote(
                        message:
                            "GOOGLE_CLIENT_ID is missing. Start Flutter with the correct dart define before testing login.",
                        color: EditorialColors.error,
                      )
                    else
                      Column(
                        children: <Widget>[
                          SizedBox(
                            width: double.infinity,
                            child: GoogleLoginButton(onPressed: onGoogleSignIn),
                          ),
                          const SizedBox(height: EditorialSpacing.large),
                          const LoginOrDivider(),
                          const SizedBox(height: EditorialSpacing.large),
                          SizedBox(
                            width: double.infinity,
                            child: GuestLoginButton(
                              onPressed: onContinueAsGuest,
                            ),
                          ),
                        ],
                      ),
                    if (errorMessage case final String message) ...<Widget>[
                      const SizedBox(height: EditorialSpacing.medium),
                      LoginStatusNote(
                        message: message,
                        color: EditorialColors.error,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
