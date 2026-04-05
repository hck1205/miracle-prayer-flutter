import "package:flutter/material.dart";

import "../../auth/auth_models.dart";
import "../../design/editorial_tokens.dart";

Future<void> showFeedAccountSheet(
  BuildContext context, {
  required AuthSession session,
  required VoidCallback onLogout,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: EditorialColors.surfaceLowest,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                session.user.name ?? session.user.email,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: EditorialColors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                session.user.email,
                style: const TextStyle(
                  fontSize: 14,
                  color: EditorialColors.onSurfaceMuted,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onLogout();
                  },
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text("Log out"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: EditorialColors.onSurface,
                    side: const BorderSide(
                      color: EditorialColors.outlineVariant,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
