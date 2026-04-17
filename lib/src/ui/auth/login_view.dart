import "package:flutter/material.dart";

import "../../design/editorial_components.dart";
import "../../design/editorial_tokens.dart";
import "../../localization/app_strings.dart";
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
    final AppStrings strings = context.strings;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool hasBoundedHeight = constraints.hasBoundedHeight;
        final double minHeight = hasBoundedHeight ? constraints.maxHeight : 0;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            vertical: EditorialSpacing.mobileGutter,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: Center(
              child: EditorialCenteredViewport(
                maxWidth: 460,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const PresenceWordmark(),
                    const SizedBox(height: 88),
                    LoginHero(
                      title: strings.authHeroTitle,
                      subtitle: strings.authHeroSubtitle,
                    ),
                    const SizedBox(height: 56),
                    if (isBusy)
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: EditorialSpacing.large,
                        ),
                        child: EditorialInlineLoader(),
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
                    if (!googleClientIdConfigured)
                      LoginStatusNote(
                        message: strings.authGoogleClientMissing,
                        color: EditorialColors.error,
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
