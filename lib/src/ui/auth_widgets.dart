import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

import "../auth/auth_models.dart";
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: const Color(0xFF5E4633),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x225E4633),
                blurRadius: 24,
                offset: Offset(0, 16),
              ),
            ],
          ),
          child: const Icon(
            Icons.auto_awesome,
            color: Color(0xFFFFF7EF),
            size: 40,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          isAuthenticated
              ? "Your prayer journey is connected"
              : "Sign in with Google to begin",
          style: textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          isAuthenticated
              ? "${user?.name ?? user?.email ?? "User"} is now connected to the backend session."
              : "The app exchanges a Google ID token for backend access and refresh tokens through miracle-prayer-backend.",
          style: textTheme.titleMedium?.copyWith(
            color: const Color(0xFF5F5146),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: const Color(0x33FFFFFF),
            border: Border.all(color: const Color(0x66FFFFFF)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FeatureLine(
                icon: Icons.verified_user_outlined,
                text:
                    "Google sign-in exchanges for backend access and refresh tokens",
              ),
              SizedBox(height: 12),
              FeatureLine(
                icon: Icons.sync_lock_outlined,
                text: "Stored refresh token restores the session on app launch",
              ),
              SizedBox(height: 12),
              FeatureLine(
                icon: Icons.person_outline,
                text: "Authenticated profile loads from /api/v1/auth/me",
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FeatureLine extends StatelessWidget {
  const FeatureLine({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 18, color: const Color(0xFF6E553F)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: const Color(0xFF4A3D33)),
          ),
        ),
      ],
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
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Sign in",
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(
            "Start a backend-authenticated session with Google login.",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF63554A),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          InfoChip(label: "Backend", value: backendBaseUrl),
          const SizedBox(height: 24),
          if (isBusy)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (!googleClientIdConfigured)
            const StatusMessage(
              message:
                  "GOOGLE_CLIENT_ID is missing. Start Flutter with --dart-define=GOOGLE_CLIENT_ID=...",
              tone: StatusTone.warning,
            )
          else ...<Widget>[
            if (supportsAuthenticate)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onGoogleSignIn,
                  icon: const Icon(Icons.login),
                  label: const Text("Continue with Google"),
                ),
              )
            else if (kIsWeb)
              const GoogleWebSignInButton(),
          ],
          if (errorMessage case final String message) ...<Widget>[
            const SizedBox(height: 20),
            StatusMessage(message: message, tone: StatusTone.error),
          ],
          const SizedBox(height: 20),
          const StatusMessage(
            message:
                "For web development, a fixed localhost port is the safest setup for both Google OAuth authorized origins and backend CORS.",
            tone: StatusTone.info,
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

    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFF5E4633),
                child: Text(
                  (user.name ?? user.email)
                      .trim()
                      .characters
                      .first
                      .toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      user.name ?? "Anonymous user",
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF63554A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          InfoChip(label: "User ID", value: user.id),
          const SizedBox(height: 12),
          InfoChip(label: "Token Type", value: session.tokenType),
          const SizedBox(height: 12),
          InfoChip(label: "Backend", value: backendBaseUrl),
          const SizedBox(height: 12),
          InfoChip(
            label: "Refresh Expires In",
            value: "${session.refreshExpiresIn} seconds",
          ),
          if (errorMessage case final String message) ...<Widget>[
            const SizedBox(height: 20),
            StatusMessage(message: message, tone: StatusTone.error),
          ],
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              FilledButton.icon(
                onPressed: isBusy ? null : onRefreshSession,
                icon: const Icon(Icons.refresh),
                label: const Text("Refresh session"),
              ),
              OutlinedButton.icon(
                onPressed: isBusy ? null : onLogout,
                icon: const Icon(Icons.logout),
                label: const Text("Log out"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GlassPanel extends StatelessWidget {
  const GlassPanel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: const Color(0xF4FFF9F4),
        border: Border.all(color: const Color(0x66FFFFFF)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x1D3A2A16),
            blurRadius: 40,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: child,
    );
  }
}

class InfoChip extends StatelessWidget {
  const InfoChip({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFFF2E6D8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: const Color(0xFF7A6757),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF342A23),
            ),
          ),
        ],
      ),
    );
  }
}

enum StatusTone { info, warning, error }

class StatusMessage extends StatelessWidget {
  const StatusMessage({super.key, required this.message, required this.tone});

  final String message;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final ({Color background, Color foreground, IconData icon}) palette =
        switch (tone) {
          StatusTone.info => (
            background: const Color(0xFFE8F0FF),
            foreground: const Color(0xFF234A92),
            icon: Icons.info_outline,
          ),
          StatusTone.warning => (
            background: const Color(0xFFFFF2D9),
            foreground: const Color(0xFF8B5B00),
            icon: Icons.warning_amber_rounded,
          ),
          StatusTone.error => (
            background: const Color(0xFFFDE7E7),
            foreground: const Color(0xFF992B2B),
            icon: Icons.error_outline,
          ),
        };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: palette.background,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(palette.icon, size: 18, color: palette.foreground),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: palette.foreground,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
