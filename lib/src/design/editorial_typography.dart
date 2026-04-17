import "package:flutter/material.dart";

abstract final class EditorialTypography {
  static const String displayFontFamily = "Inter";
  static const String koreanContentFontFamily = "NotoSansKR";

  static const List<String> sansFallback = <String>[
    koreanContentFontFamily,
    "Malgun Gothic",
    "Segoe UI",
    "Arial",
    "Apple SD Gothic Neo",
    "Nanum Gothic",
    "sans-serif",
  ];

  static TextStyle? withSansFallback(TextStyle? style) {
    return style?.copyWith(
      fontFamily: displayFontFamily,
      fontFamilyFallback: sansFallback,
    );
  }

  static TextStyle withKoreanContent(TextStyle style) {
    return style.copyWith(
      fontFamily: koreanContentFontFamily,
      fontFamilyFallback: sansFallback,
    );
  }

  static TextStyle? contentStyle(TextStyle? style, {required bool isKorean}) {
    if (style == null) {
      return null;
    }

    if (!isKorean) {
      return style;
    }

    return withKoreanContent(style);
  }

  static TextStyle? trackedStyle(
    TextStyle? style, {
    required bool isKorean,
    required Color color,
    required double englishLetterSpacing,
    required double koreanLetterSpacing,
    required FontWeight fontWeight,
  }) {
    return contentStyle(style, isKorean: isKorean)?.copyWith(
      color: color,
      letterSpacing: isKorean ? koreanLetterSpacing : englishLetterSpacing,
      fontWeight: fontWeight,
    );
  }
}
