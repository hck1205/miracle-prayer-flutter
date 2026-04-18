import "package:flutter/material.dart";

import "../../auth/auth_models.dart";
import "../../core/network/api_exception.dart";
import "../../design/editorial_components.dart";
import "../../design/editorial_tokens.dart";
import "../../design/editorial_typography.dart";
import "../../localization/app_strings.dart";

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.session,
    required this.onUpdateProfileName,
  });

  final AuthSession session;
  final Future<void> Function({required String name}) onUpdateProfileName;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _displayName;

  @override
  void initState() {
    super.initState();
    _displayName = widget.session.user.name ?? "";
  }

  @override
  void didUpdateWidget(covariant SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.session.user.name != widget.session.user.name) {
      _displayName = widget.session.user.name ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppStrings strings = context.strings;
    final String resolvedName = _displayName.isEmpty
        ? widget.session.user.email
        : _displayName;

    return Scaffold(
      backgroundColor: EditorialColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            EditorialCenteredViewport(
              maxWidth: 620,
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 8),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                    ),
                    color: EditorialColors.onSurface,
                    splashRadius: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    strings.settingsTitle,
                    style:
                        EditorialTypography.contentStyle(
                          Theme.of(context).textTheme.titleMedium,
                          isKorean: strings.isKorean,
                        )?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: EditorialColors.onSurface,
                        ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
                child: EditorialCenteredViewport(
                  maxWidth: 620,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const EditorialDivider(),
                        const SizedBox(height: 28),
                        Text(
                          strings.settingsProfileSection.toUpperCase(),
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
                        EditorialSheet(
                          tone: EditorialSheetTone.elevated,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                strings.settingsProfileTitle,
                                style:
                                    EditorialTypography.contentStyle(
                                      Theme.of(context).textTheme.titleMedium,
                                      isKorean: strings.isKorean,
                                    )?.copyWith(
                                      color: EditorialColors.onSurface,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                strings.settingsProfileBody,
                                style:
                                    EditorialTypography.contentStyle(
                                      Theme.of(context).textTheme.bodyMedium,
                                      isKorean: strings.isKorean,
                                    )?.copyWith(
                                      color: EditorialColors.onSurfaceMuted,
                                      height: 1.7,
                                    ),
                              ),
                              const SizedBox(height: 18),
                              _SettingsFactRow(
                                label: strings.settingsNameLabel,
                                value: resolvedName,
                              ),
                              const SizedBox(height: 10),
                              _SettingsFactRow(
                                label: strings.settingsEmailLabel,
                                value: widget.session.user.email,
                              ),
                              const SizedBox(height: 18),
                              _SettingsMenuRow(
                                icon: Icons.person_outline_rounded,
                                label: strings.settingsEditProfile,
                                onTap: _handleEditProfile,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleEditProfile() async {
    final AppStrings strings = context.strings;
    final String? nextName = await showSettingsProfileSheet(
      context,
      initialName: _displayName,
      email: widget.session.user.email,
    );
    if (nextName == null) {
      return;
    }

    try {
      await widget.onUpdateProfileName(name: nextName);
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
      return;
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _displayName = nextName.trim();
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(strings.settingsProfileUpdated)));
  }
}

class _SettingsFactRow extends StatelessWidget {
  const _SettingsFactRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final AppStrings strings = context.strings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label.toUpperCase(),
          style: EditorialTypography.trackedStyle(
            Theme.of(context).textTheme.labelSmall,
            isKorean: strings.isKorean,
            color: EditorialColors.outline,
            englishLetterSpacing: 1.1,
            koreanLetterSpacing: 0.2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: EditorialTypography.contentStyle(
            Theme.of(context).textTheme.bodyMedium,
            isKorean: strings.isKorean,
          )?.copyWith(color: EditorialColors.onSurface, height: 1.6),
        ),
      ],
    );
  }
}

class _SettingsMenuRow extends StatelessWidget {
  const _SettingsMenuRow({
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

Future<String?> showSettingsProfileSheet(
  BuildContext context, {
  required String initialName,
  required String email,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return _EditProfileSheet(initialName: initialName, email: email);
    },
  );
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({required this.initialName, required this.email});

  final String initialName;
  final String email;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final AppStrings strings = context.strings;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 16),
      child: EditorialSheet(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                strings.settingsEditProfile,
                style:
                    EditorialTypography.contentStyle(
                      Theme.of(context).textTheme.titleLarge,
                      isKorean: strings.isKorean,
                    )?.copyWith(
                      color: EditorialColors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 18),
              _SettingsSheetField(
                label: strings.settingsNameLabel,
                child: TextField(
                  controller: _nameController,
                  style: EditorialTypography.contentStyle(
                    Theme.of(context).textTheme.bodyMedium,
                    isKorean: strings.isKorean,
                  )?.copyWith(color: EditorialColors.onSurface),
                  decoration: _settingsDecoration(
                    context,
                    strings.settingsNameHint,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _SettingsSheetField(
                label: strings.settingsEmailLabel,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: EditorialColors.surfaceLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    widget.email,
                    style: EditorialTypography.contentStyle(
                      Theme.of(context).textTheme.bodyMedium,
                      isKorean: strings.isKorean,
                    )?.copyWith(color: EditorialColors.onSurfaceMuted),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: EditorialPrimaryButton(
                  label: strings.settingsSaveProfile,
                  onPressed: () {
                    Navigator.of(context).pop(_nameController.text.trim());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSheetField extends StatelessWidget {
  const _SettingsSheetField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final AppStrings strings = context.strings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label.toUpperCase(),
          style: EditorialTypography.trackedStyle(
            Theme.of(context).textTheme.labelSmall,
            isKorean: strings.isKorean,
            color: EditorialColors.outline,
            englishLetterSpacing: 1.1,
            koreanLetterSpacing: 0.2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

InputDecoration _settingsDecoration(BuildContext context, String hintText) {
  final AppStrings strings = context.strings;

  return InputDecoration(
    hintText: hintText,
    hintStyle: EditorialTypography.contentStyle(
      Theme.of(context).textTheme.bodyMedium,
      isKorean: strings.isKorean,
    )?.copyWith(color: EditorialColors.onSurfaceMuted),
    filled: true,
    fillColor: EditorialColors.surfaceLow,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: EditorialColors.outline, width: 0.8),
    ),
  );
}
