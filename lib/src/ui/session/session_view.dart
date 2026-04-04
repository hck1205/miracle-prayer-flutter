import "package:flutter/material.dart";

import "../../auth/auth_models.dart";
import "../../auth/auth_view_helpers.dart";
import "../../design/editorial_components.dart";
import "../../design/editorial_tokens.dart";
import "../login/login_components.dart";

class SessionView extends StatelessWidget {
  const SessionView({
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
    final String leading = authLeadingCharacter(user);

    return Column(
      children: <Widget>[
        const PresenceWordmark(),
        const SizedBox(height: 72),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: EditorialSheet(
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
                            authDisplayName(user),
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
                  value: formatRefreshExpiresIn(session.refreshExpiresIn),
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
          ),
        ),
      ],
    );
  }
}
