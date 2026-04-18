import "package:flutter/material.dart";

import "../../auth/auth_models.dart";
import "../../design/editorial_tokens.dart";
import "../../design/editorial_typography.dart";
import "../../localization/app_strings.dart";
import "../shared/language_toggle.dart";

class FeedSideDrawer extends StatelessWidget {
  const FeedSideDrawer({
    super.key,
    required this.session,
    required this.onOpenSettings,
    required this.onLogout,
  });

  final AuthSession session;
  final VoidCallback onOpenSettings;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final AppStrings strings = context.strings;
    final String displayName = session.user.name ?? session.user.email;

    return Drawer(
      width: 320,
      backgroundColor: EditorialColors.surfaceLowest,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.close_rounded, size: 20),
                  color: EditorialColors.onSurfaceMuted,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: EditorialColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: Text(
                  _initialOf(displayName),
                  style:
                      EditorialTypography.contentStyle(
                        Theme.of(context).textTheme.titleMedium,
                        isKorean: strings.isKorean,
                      )?.copyWith(
                        color: EditorialColors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                displayName,
                style:
                    EditorialTypography.contentStyle(
                      Theme.of(context).textTheme.titleLarge,
                      isKorean: strings.isKorean,
                    )?.copyWith(
                      color: EditorialColors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                session.user.email,
                style: EditorialTypography.contentStyle(
                  Theme.of(context).textTheme.bodyMedium,
                  isKorean: strings.isKorean,
                )?.copyWith(color: EditorialColors.onSurfaceMuted, height: 1.6),
              ),
              const SizedBox(height: 28),
              Text(
                strings.authMenuLanguage.toUpperCase(),
                style: EditorialTypography.trackedStyle(
                  Theme.of(context).textTheme.labelSmall,
                  isKorean: strings.isKorean,
                  color: EditorialColors.outline,
                  englishLetterSpacing: 1.2,
                  koreanLetterSpacing: 0.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              const LanguageToggle(),
              const SizedBox(height: 28),
              Text(
                strings.authMenuAccount.toUpperCase(),
                style: EditorialTypography.trackedStyle(
                  Theme.of(context).textTheme.labelSmall,
                  isKorean: strings.isKorean,
                  color: EditorialColors.outline,
                  englishLetterSpacing: 1.2,
                  koreanLetterSpacing: 0.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _DrawerMenuTile(
                icon: Icons.settings_rounded,
                label: strings.authMenuSettings,
                onTap: () {
                  Navigator.of(context).pop();
                  onOpenSettings();
                },
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onLogout();
                  },
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: Text(strings.authLogout),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: EditorialColors.onSurface,
                    side: const BorderSide(
                      color: EditorialColors.outlineVariant,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _initialOf(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return "?";
    }

    return trimmed.substring(0, 1).toUpperCase();
  }
}

class _DrawerMenuTile extends StatelessWidget {
  const _DrawerMenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppStrings strings = context.strings;

    return Material(
      color: EditorialColors.surfaceLow,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 20, color: EditorialColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style:
                      EditorialTypography.contentStyle(
                        Theme.of(context).textTheme.bodyMedium,
                        isKorean: strings.isKorean,
                      )?.copyWith(
                        color: EditorialColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: EditorialColors.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
