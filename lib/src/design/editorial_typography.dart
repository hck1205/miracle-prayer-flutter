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
}
