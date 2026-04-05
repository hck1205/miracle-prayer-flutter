import "package:flutter/material.dart";
import "package:google_sign_in_web/google_sign_in_web.dart";
import "package:google_sign_in_web/web_only.dart" as google_web;

class GoogleWebSignInButton extends StatelessWidget {
  const GoogleWebSignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    return google_web.renderButton(
      configuration: GSIButtonConfiguration(
        theme: GSIButtonTheme.outline,
        size: GSIButtonSize.large,
        text: GSIButtonText.signinWith,
        shape: GSIButtonShape.rectangular,
      ),
    );
  }
}
