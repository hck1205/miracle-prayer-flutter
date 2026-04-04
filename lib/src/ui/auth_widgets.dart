import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

import "../auth/auth_models.dart";
import "../design/editorial_components.dart";
import "../design/editorial_tokens.dart";
import "google_sign_in_button.dart";

class PrayerIntro extends StatelessWidget {
  const PrayerIntro({
    super.key,
    required this.isAuthenticated,
    required this.user,
  });

  final bool isAuthenticated;
  final AuthenticatedUser? user;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String title = isAuthenticated
        ? "A quieter place for reflection, now connected."
        : "A living page for prayer, reflection, and stillness.";
    final String summary = isAuthenticated
        ? "${user?.name ?? user?.email ?? "Your account"} is signed in and the session has been restored through miracle-prayer-backend."
        : "Google identity opens the door, and the backend shapes that trust into an app session built for continuity.";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const EditorialGlassBar(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              EditorialMetaText("Miracle Prayer"),
              SizedBox(width: 12),
              Text(
                "Editorial Serenity",
                style: TextStyle(
                  color: EditorialColors.onSurfaceMuted,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: EditorialSpacing.xLarge),
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: EditorialColors.surfaceLowest,
            borderRadius: BorderRadius.circular(EditorialRadius.xLarge),
            boxShadow: EditorialShadows.ambient,
          ),
          child: const Icon(
            Icons.auto_stories_outlined,
            size: 36,
            color: EditorialColors.primary,
          ),
        ),
        const SizedBox(height: EditorialSpacing.xLarge),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Text(title, style: textTheme.displayMedium),
        ),
        const SizedBox(height: EditorialSpacing.medium),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Text(
            summary,
            style: textTheme.bodyLarge?.copyWith(
              color: EditorialColors.onSurfaceMuted,
            ),
          ),
        ),
        const SizedBox(height: EditorialSpacing.xLarge),
        const EditorialSheet(
          tone: EditorialSheetTone.subtle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              EditorialMetaText("What this flow already does"),
              SizedBox(height: EditorialSpacing.medium),
              FeatureLine(
                title: "Identity",
                text: "Exchanges Google sign-in for a backend-authenticated session.",
              ),
              EditorialDivider(),
              FeatureLine(
                title: "Continuity",
                text: "Restores the session with refresh token rotation on app launch.",
              ),
              EditorialDivider(),
              FeatureLine(
                title: "Clarity",
                text: "Loads the authenticated profile from /api/v1/auth/me after login.",
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FeatureLine extends StatelessWidget {
  const FeatureLine({
    super.key,
    required this.title,
    required this.text,
  });

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: EditorialSpacing.small),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Icon(
              Icons.remove,
              size: 18,
              color: EditorialColors.outlineVariant,
            ),
          ),
          const SizedBox(width: EditorialSpacing.small),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: textTheme.bodyLarge?.copyWith(
                    color: EditorialColors.onSurfaceMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LoginCard extends StatelessWidget {
  const LoginCard({
    super.key,
    required this.isBusy,
    required this.errorMessage,
    required this.backendBaseUrl,
    required this.googleClientIdConfigured,
    required this.supportsAuthenticate,
    required this.onGoogleSignIn,
  });

  final bool isBusy;
  final String? errorMessage;
  final String backendBaseUrl;
  final bool googleClientIdConfigured;
  final bool supportsAuthenticate;
  final VoidCallback onGoogleSignIn;

  @override
  Widget build(BuildContext context) {
    return EditorialSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const EditorialMetaText("Authentication"),
          const SizedBox(height: EditorialSpacing.medium),
          Text(
            "Sign in gently.",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: EditorialSpacing.small),
          Text(
            "Start a calm, backend-authenticated session with Google and keep the experience attached to your account.",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: EditorialColors.onSurfaceMuted,
            ),
          ),
          const SizedBox(height: EditorialSpacing.large),
          const EditorialDivider(),
          EditorialFactRow(label: "Backend", value: backendBaseUrl),
          const EditorialDivider(),
          if (isBusy)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: EditorialSpacing.large),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (!googleClientIdConfigured)
            const EditorialStatusMessage(
              message:
                  "GOOGLE_CLIENT_ID is missing. Start Flutter with the correct dart define before testing login.",
              color: EditorialColors.error,
            )
          else ...<Widget>[
            const SizedBox(height: EditorialSpacing.medium),
            SizedBox(
              width: double.infinity,
              child: supportsAuthenticate
                  ? EditorialPrimaryButton(
                      label: "Continue with Google",
                      onPressed: onGoogleSignIn,
                      icon: Icons.arrow_outward,
                    )
                  : kIsWeb
                  ? const GoogleWebSignInButton()
                  : const SizedBox.shrink(),
            ),
          ],
          if (errorMessage case final String message) ...<Widget>[
            const SizedBox(height: EditorialSpacing.medium),
            EditorialStatusMessage(
              message: message,
              color: EditorialColors.error,
            ),
          ],
          const SizedBox(height: EditorialSpacing.medium),
          const EditorialStatusMessage(
            message:
                "For local web development, a fixed localhost port keeps Google OAuth origins and backend CORS aligned.",
            color: EditorialColors.onSurfaceMuted,
          ),
        ],
      ),
    );
  }
}

class SessionCard extends StatelessWidget {
  const SessionCard({
    super.key,
    required this.session,
    required this.isBusy,
    required this.errorMessage,
    required this.backendBaseUrl,
    required this.onRefreshSession,
    required this.onLogout,
  });

  final AuthSession session;
  final bool isBusy;
  final String? errorMessage;
  final String backendBaseUrl;
  final VoidCallback onRefreshSession;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final AuthenticatedUser user = session.user;
    final String leading = (user.name ?? user.email).trim().characters.first
        .toUpperCase();

    return EditorialSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const EditorialMetaText("Authenticated Session"),
          const SizedBox(height: EditorialSpacing.medium),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: EditorialColors.surfaceLow,
                  borderRadius: BorderRadius.circular(EditorialRadius.large),
                ),
                alignment: Alignment.center,
                child: Text(
                  leading,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: EditorialColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: EditorialSpacing.small),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      user.name ?? "Authenticated reader",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: EditorialColors.onSurfaceMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: EditorialSpacing.large),
          const EditorialDivider(),
          EditorialFactRow(label: "User Id", value: user.id),
          const EditorialDivider(),
          EditorialFactRow(label: "Token Type", value: session.tokenType),
          const EditorialDivider(),
          EditorialFactRow(label: "Backend", value: backendBaseUrl),
          const EditorialDivider(),
          EditorialFactRow(
            label: "Refresh Expires In",
            value: "${session.refreshExpiresIn} seconds",
          ),
          if (errorMessage case final String message) ...<Widget>[
            const SizedBox(height: EditorialSpacing.medium),
            EditorialStatusMessage(
              message: message,
              color: EditorialColors.error,
            ),
          ],
          const SizedBox(height: EditorialSpacing.large),
          Wrap(
            spacing: EditorialSpacing.small,
            runSpacing: EditorialSpacing.small,
            children: <Widget>[
              EditorialPrimaryButton(
                label: "Refresh session",
                onPressed: isBusy ? null : onRefreshSession,
                icon: Icons.refresh,
              ),
              EditorialSecondaryButton(
                label: "Log out",
                onPressed: isBusy ? null : onLogout,
                icon: Icons.logout,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
