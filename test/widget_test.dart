import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:flutter_svg/flutter_svg.dart";

import "package:miracle_prayer_flutter/src/design/editorial_theme.dart";
import "package:miracle_prayer_flutter/src/ui/login/login_view.dart";

void main() {
  testWidgets("login card renders backend sign-in entry point", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: EditorialTheme.buildTheme(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: LoginView(
              isBusy: false,
              errorMessage: null,
              googleClientIdConfigured: true,
              onGoogleSignIn: _noop,
              onContinueAsGuest: _noop,
            ),
          ),
        ),
      ),
    );

    expect(find.text("Join the Silence"), findsOneWidget);
    expect(find.text("Sign in with Google"), findsOneWidget);
    expect(find.byType(SvgPicture), findsOneWidget);
    expect(find.text("Continue as Guest"), findsOneWidget);
  });
}

void _noop() {}
