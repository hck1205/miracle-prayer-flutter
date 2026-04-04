import "dart:ui";

import "package:flutter/material.dart";

import "editorial_tokens.dart";

enum EditorialSheetTone { elevated, subtle, grounded }

class EditorialSheet extends StatelessWidget {
  const EditorialSheet({
    super.key,
    required this.child,
    this.tone = EditorialSheetTone.elevated,
    this.padding = const EdgeInsets.all(EditorialSpacing.large),
  });

  final Widget child;
  final EditorialSheetTone tone;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final Color background = switch (tone) {
      EditorialSheetTone.elevated => EditorialColors.surfaceLowest,
      EditorialSheetTone.subtle => EditorialColors.surfaceLow,
      EditorialSheetTone.grounded => EditorialColors.surfaceContainer,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(EditorialRadius.xLarge),
        boxShadow: tone == EditorialSheetTone.elevated
            ? EditorialShadows.ambient
            : const <BoxShadow>[],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class EditorialGlassBar extends StatelessWidget {
  const EditorialGlassBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(EditorialRadius.xLarge),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: EditorialColors.surface.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(EditorialRadius.xLarge),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: EditorialSpacing.medium,
              vertical: EditorialSpacing.small,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class EditorialMetaText extends StatelessWidget {
  const EditorialMetaText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium,
    );
  }
}

class EditorialDivider extends StatelessWidget {
  const EditorialDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 1,
        color: EditorialColors.outlineVariant.withValues(alpha: 0.3),
      ),
    );
  }
}

class EditorialPrimaryButton extends StatelessWidget {
  const EditorialPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(color: EditorialColors.onPrimary);

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
              padding: const EdgeInsets.symmetric(
                horizontal: EditorialSpacing.medium,
                vertical: EditorialSpacing.small,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (icon != null) ...<Widget>[
                    Icon(icon, size: 18, color: EditorialColors.onPrimary),
                    const SizedBox(width: 10),
                  ],
                  Flexible(child: Text(label, style: style)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EditorialSecondaryButton extends StatelessWidget {
  const EditorialSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

class EditorialFactRow extends StatelessWidget {
  const EditorialFactRow({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: EditorialSpacing.small),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          EditorialMetaText(label),
          const SizedBox(height: 6),
          Text(value, style: textTheme.bodyLarge?.copyWith(height: 1.5)),
        ],
      ),
    );
  }
}

class EditorialStatusMessage extends StatelessWidget {
  const EditorialStatusMessage({
    super.key,
    required this.message,
    required this.color,
  });

  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: color, height: 1.6),
          ),
        ),
      ],
    );
  }
}
