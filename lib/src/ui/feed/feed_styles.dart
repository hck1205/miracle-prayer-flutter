import "package:flutter/material.dart";

import "../../design/editorial_tokens.dart";
import "../../design/editorial_typography.dart";

abstract final class FeedStyles {
  static const TextStyle headerTitle = TextStyle(
    fontSize: 32,
    height: 1.15,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.6,
    color: EditorialColors.onSurface,
  );

  static const TextStyle headerBody = TextStyle(
    fontSize: 17,
    height: 1.75,
    color: EditorialColors.onSurfaceMuted,
  );

  static const TextStyle authorLabel = TextStyle(
    fontSize: 11,
    letterSpacing: 1.4,
    fontWeight: FontWeight.w700,
    fontFamily: EditorialTypography.displayFontFamily,
    fontFamilyFallback: EditorialTypography.sansFallback,
    color: EditorialColors.onSurfaceMuted,
  );

  static const TextStyle publishedLabel = TextStyle(
    fontSize: 10,
    letterSpacing: 1.3,
    fontFamily: EditorialTypography.displayFontFamily,
    fontFamilyFallback: EditorialTypography.sansFallback,
    color: EditorialColors.outline,
  );

  static const TextStyle footerLabel = TextStyle(
    fontSize: 10,
    letterSpacing: 2.0,
    color: EditorialColors.outline,
  );

  static TextStyle prayerBody({required bool lined}) {
    return EditorialTypography.withKoreanContent(
      TextStyle(
        fontSize: 19,
        height: 1.8,
        fontWeight: FontWeight.w300,
        fontStyle: lined ? FontStyle.normal : FontStyle.italic,
        color: EditorialColors.onSurface,
      ),
    );
  }

  static BoxDecoration prayerBodyDecoration({required bool lined}) {
    return BoxDecoration(
      color: lined ? EditorialColors.surfaceLowest : EditorialColors.surfaceLow,
      border: lined
          ? const Border(
              left: BorderSide(color: EditorialColors.outlineVariant, width: 2),
            )
          : null,
      borderRadius: lined ? null : BorderRadius.circular(12),
    );
  }

  static TextStyle reactionLabel(Color color) {
    return TextStyle(
      fontSize: 10,
      letterSpacing: 1.1,
      fontWeight: FontWeight.w600,
      fontFamily: EditorialTypography.displayFontFamily,
      color: color,
    );
  }

  static TextStyle expandAction({required bool hovered}) {
    return TextStyle(
      fontSize: 11,
      letterSpacing: 1.1,
      fontWeight: FontWeight.w700,
      fontFamily: EditorialTypography.displayFontFamily,
      fontFamilyFallback: EditorialTypography.sansFallback,
      color: hovered ? EditorialColors.primary : EditorialColors.outline,
      decoration: hovered ? TextDecoration.underline : TextDecoration.none,
    );
  }

  static const TextStyle trayLabel = TextStyle(
    fontSize: 8,
    letterSpacing: 0.9,
    fontWeight: FontWeight.w700,
    fontFamily: EditorialTypography.displayFontFamily,
    color: EditorialColors.outline,
  );

  static const TextStyle trayCount = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w600,
    fontFamily: EditorialTypography.displayFontFamily,
    color: EditorialColors.onSurfaceMuted,
  );

  static BoxDecoration reactionTrayDecoration() {
    return BoxDecoration(
      color: EditorialColors.surfaceLowest,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(
        color: EditorialColors.outlineVariant.withValues(alpha: 0.35),
      ),
      boxShadow: const <BoxShadow>[
        BoxShadow(
          color: Color(0x122D3435),
          blurRadius: 24,
          offset: Offset(0, 10),
        ),
      ],
    );
  }

  static BoxDecoration reactionSummaryDecoration() {
    return BoxDecoration(
      color: EditorialColors.surfaceLowest,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(
        color: EditorialColors.outlineVariant.withValues(alpha: 0.25),
      ),
      boxShadow: const <BoxShadow>[
        BoxShadow(
          color: Color(0x082D3435),
          blurRadius: 12,
          offset: Offset(0, 3),
        ),
      ],
    );
  }

  static BoxDecoration reactionCountBadgeDecoration() {
    return BoxDecoration(
      color: EditorialColors.surface.withValues(alpha: 0.96),
      borderRadius: BorderRadius.circular(999),
    );
  }

  static const TextStyle reactionCountValue = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    fontFamily: EditorialTypography.displayFontFamily,
    color: EditorialColors.outline,
  );
}
