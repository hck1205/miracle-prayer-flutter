import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:miracle_prayer_flutter/src/ui/auth_widgets.dart";

void main() {
  testWidgets("login card renders backend sign-in entry point", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LoginCard(
            isBusy: false,
            errorMessage: null,
            backendBaseUrl: "http://127.0.0.1:3000/api",
            googleClientIdConfigured: true,
            supportsAuthenticate: true,
            onGoogleSignIn: _noop,
          ),
        ),
      ),
    );

    expect(find.text("Sign in"), findsOneWidget);
    expect(find.textContaining("Google"), findsWidgets);
  });
}

void _noop() {}
