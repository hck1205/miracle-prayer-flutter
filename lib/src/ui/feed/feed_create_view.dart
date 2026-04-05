import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "../../design/editorial_components.dart";
import "../../design/editorial_tokens.dart";

class FeedCreateView extends StatelessWidget {
  const FeedCreateView({
    super.key,
    required this.title,
    required this.identityLabel,
    required this.bodyController,
    required this.isAnonymous,
    required this.isSubmitting,
    required this.onAnonymousChanged,
    required this.primaryActionLabel,
    required this.onPrimaryAction,
    required this.secondaryActionLabel,
    required this.onSecondaryAction,
    required this.onTagTap,
    required this.onQuoteTap,
  });

  static const int maxBodyLength = 3500;

  final String title;
  final String identityLabel;
  final TextEditingController bodyController;
  final bool isAnonymous;
  final bool isSubmitting;
  final ValueChanged<bool> onAnonymousChanged;
  final String primaryActionLabel;
  final VoidCallback onPrimaryAction;
  final String secondaryActionLabel;
  final VoidCallback onSecondaryAction;
  final VoidCallback onTagTap;
  final VoidCallback onQuoteTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool useCompactFooter = MediaQuery.sizeOf(context).width < 640;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          0,
          28,
          0,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: EditorialCenteredViewport(
          maxWidth: 620,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontSize: 32,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                  color: EditorialColors.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              const EditorialDivider(),
              const SizedBox(height: 40),
              EditorialSheet(
                tone: EditorialSheetTone.subtle,
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: _IdentitySummary(identityLabel: identityLabel),
                        ),
                        const SizedBox(width: 16),
                        _AnonymousToggle(
                          value: isAnonymous,
                          enabled: !isSubmitting,
                          onChanged: onAnonymousChanged,
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 260),
                      child: TextField(
                        controller: bodyController,
                        enabled: !isSubmitting,
                        minLines: 10,
                        maxLines: null,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 18,
                          height: 1.75,
                          color: EditorialColors.onSurface,
                        ),
                        inputFormatters: <TextInputFormatter>[
                          LengthLimitingTextInputFormatter(maxBodyLength),
                        ],
                        decoration: InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText: "Write your prayer...",
                          hintStyle: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 18,
                            height: 1.75,
                            color: EditorialColors.outlineVariant.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      height: 1,
                      color: EditorialColors.outlineVariant.withValues(
                        alpha: 0.16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Typing only rebuilds the footer state instead of the full
                    // screen, which keeps the composer responsive on long text.
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: bodyController,
                      builder:
                          (BuildContext context, TextEditingValue value, _) {
                            final int characterCount = value.text.length;
                            final bool canSubmit =
                                !isSubmitting && value.text.trim().isNotEmpty;

                            if (useCompactFooter) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  _CreateMetaRow(
                                    characterCount: characterCount,
                                    onTagTap: onTagTap,
                                    onQuoteTap: onQuoteTap,
                                  ),
                                  const SizedBox(height: 18),
                                  _CreateActionRow(
                                    canSubmit: canSubmit,
                                    isSubmitting: isSubmitting,
                                    primaryActionLabel: primaryActionLabel,
                                    onPrimaryAction: onPrimaryAction,
                                    secondaryActionLabel: secondaryActionLabel,
                                    onSecondaryAction: onSecondaryAction,
                                  ),
                                ],
                              );
                            }

                            return Row(
                              children: <Widget>[
                                Expanded(
                                  child: _CreateMetaRow(
                                    characterCount: characterCount,
                                    onTagTap: onTagTap,
                                    onQuoteTap: onQuoteTap,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                _CreateActionRow(
                                  canSubmit: canSubmit,
                                  isSubmitting: isSubmitting,
                                  primaryActionLabel: primaryActionLabel,
                                  onPrimaryAction: onPrimaryAction,
                                  secondaryActionLabel: secondaryActionLabel,
                                  onSecondaryAction: onSecondaryAction,
                                ),
                              ],
                            );
                          },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Center(
                child: Column(
                  children: <Widget>[
                    Text(
                      "\"Be still, and know that I am God.\"",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        height: 1.6,
                        fontStyle: FontStyle.italic,
                        color: EditorialColors.onSurfaceMuted.withValues(
                          alpha: 0.72,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "(Psalm 46:10)",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        letterSpacing: 0.4,
                        color: EditorialColors.onSurfaceMuted.withValues(
                          alpha: 0.64,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IdentitySummary extends StatelessWidget {
  const _IdentitySummary({required this.identityLabel});

  final String identityLabel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Row(
      children: <Widget>[
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: EditorialColors.surfaceContainer,
          ),
          alignment: Alignment.center,
          child: Text(
            _identityInitial(identityLabel),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: EditorialColors.onSurfaceMuted,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "MY IDENTITY",
                style: theme.textTheme.labelMedium?.copyWith(
                  fontSize: 11,
                  letterSpacing: 2,
                  color: EditorialColors.onSurfaceMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                identityLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: EditorialColors.outline,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _identityInitial(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return "?";
    }

    return trimmed.substring(0, 1).toUpperCase();
  }
}

class _AnonymousToggle extends StatelessWidget {
  const _AnonymousToggle({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            "POST ANONYMOUSLY",
            style: theme.textTheme.labelMedium?.copyWith(
              fontSize: 11,
              letterSpacing: 1.6,
              color: EditorialColors.onSurfaceMuted,
            ),
          ),
          const SizedBox(height: 8),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeThumbColor: EditorialColors.surfaceLowest,
            activeTrackColor: EditorialColors.primary,
            inactiveThumbColor: EditorialColors.surfaceLowest,
            inactiveTrackColor: EditorialColors.outlineVariant.withValues(
              alpha: 0.45,
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}

class _CreateMetaRow extends StatelessWidget {
  const _CreateMetaRow({
    required this.characterCount,
    required this.onTagTap,
    required this.onQuoteTap,
  });

  final int characterCount;
  final VoidCallback onTagTap;
  final VoidCallback onQuoteTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        Text(
          "$characterCount / ${FeedCreateView.maxBodyLength}",
          style: theme.textTheme.labelMedium?.copyWith(
            fontSize: 12,
            letterSpacing: 1.8,
            color: EditorialColors.onSurfaceMuted,
          ),
        ),
        _MetaIconButton(icon: Icons.tag, onTap: onTagTap),
        _MetaIconButton(icon: Icons.format_quote, onTap: onQuoteTap),
      ],
    );
  }
}

class _MetaIconButton extends StatelessWidget {
  const _MetaIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 18, color: EditorialColors.outline),
        ),
      ),
    );
  }
}

class _CreateActionRow extends StatelessWidget {
  const _CreateActionRow({
    required this.canSubmit,
    required this.isSubmitting,
    required this.primaryActionLabel,
    required this.onPrimaryAction,
    required this.secondaryActionLabel,
    required this.onSecondaryAction,
  });

  final bool canSubmit;
  final bool isSubmitting;
  final String primaryActionLabel;
  final VoidCallback onPrimaryAction;
  final String secondaryActionLabel;
  final VoidCallback onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final VoidCallback? primaryAction = canSubmit ? onPrimaryAction : null;
    final VoidCallback? secondaryAction = isSubmitting
        ? null
        : onSecondaryAction;

    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        runAlignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: <Widget>[
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: EditorialColors.onSurfaceMuted,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              minimumSize: const Size(0, 40),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: BorderSide(
                color: EditorialColors.outlineVariant.withValues(alpha: 0.28),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(EditorialRadius.medium),
              ),
            ),
            onPressed: secondaryAction,
            child: Text(
              secondaryActionLabel,
              style: theme.textTheme.labelMedium?.copyWith(
                fontSize: 12,
                letterSpacing: 1.8,
                color: EditorialColors.onSurfaceMuted,
              ),
            ),
          ),
          _CompactPrimaryActionButton(
            label: isSubmitting
                ? "${primaryActionLabel.toUpperCase()}..."
                : primaryActionLabel,
            onPressed: primaryAction,
          ),
        ],
      ),
    );
  }
}

class _CompactPrimaryActionButton extends StatelessWidget {
  const _CompactPrimaryActionButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = Theme.of(
      context,
    ).textTheme.labelMedium?.copyWith(color: EditorialColors.onPrimary);

    return Opacity(
      opacity: onPressed == null ? 0.5 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(EditorialRadius.medium),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              EditorialColors.primary,
              EditorialColors.primaryDim,
            ],
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(EditorialRadius.medium),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Text(label, style: style),
            ),
          ),
        ),
      ),
    );
  }
}
