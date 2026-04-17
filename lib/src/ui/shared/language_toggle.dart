import "package:flutter/material.dart";

import "../../design/editorial_tokens.dart";
import "../../localization/app_locale.dart";
import "../../localization/app_locale_controller.dart";
import "../../localization/app_locale_scope.dart";
import "../../localization/app_strings.dart";

class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final AppLocaleController controller = AppLocaleScope.controllerOf(context);
    final AppStrings strings = context.strings;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: EditorialColors.surfaceLowest,
        borderRadius: BorderRadius.circular(compact ? 14 : 16),
        border: Border.all(
          color: EditorialColors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: AppLocale.values.map((AppLocale locale) {
          final bool selected = controller.appLocale == locale;
          final String label = locale == AppLocale.ko
              ? strings.localeLabelKo
              : strings.localeLabelEn;

          return Padding(
            padding: const EdgeInsets.all(2),
            child: Semantics(
              button: true,
              selected: selected,
              label: strings.localeSwitchSemantics(label),
              child: InkWell(
                borderRadius: BorderRadius.circular(compact ? 12 : 14),
                onTap: () => controller.setLocale(locale),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOut,
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 10 : 12,
                    vertical: compact ? 6 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? EditorialColors.surfaceContainer
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(compact ? 12 : 14),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: compact ? 11 : 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: selected
                          ? EditorialColors.onSurface
                          : EditorialColors.onSurfaceMuted,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(growable: false),
      ),
    );
  }
}
