import "package:flutter/material.dart";

abstract final class EditorialColors {
  static const Color surface = Color(0xFFF9F9F9);
  static const Color surfaceLowest = Color(0xFFFFFFFF);
  static const Color surfaceLow = Color(0xFFF2F4F4);
  static const Color surfaceContainer = Color(0xFFEBEEEF);
  static const Color surfaceDim = Color(0xFFD4DBDD);
  static const Color primary = Color(0xFF5F5E5E);
  static const Color primaryDim = Color(0xFF535252);
  static const Color onPrimary = Color(0xFFFAF7F6);
  static const Color onSurface = Color(0xFF2D3435);
  static const Color onSurfaceMuted = Color(0xFF5E6668);
  static const Color outline = Color(0xFF757C7D);
  static const Color outlineVariant = Color(0xFFADB3B4);
  static const Color error = Color(0xFF9F403D);
  static const Color reflectionGlow = Color(0x14D4DBDD);
}

abstract final class EditorialSpacing {
  static const double xSmall = 8;
  static const double small = 16;
  static const double medium = 24;
  static const double large = 32;
  static const double xLarge = 48;
  static const double mobileGutter = 24;
}

abstract final class EditorialRadius {
  static const double medium = 6;
  static const double large = 18;
  static const double xLarge = 28;
}

abstract final class EditorialShadows {
  static const List<BoxShadow> ambient = <BoxShadow>[
    BoxShadow(
      color: Color(0x0A2D3435),
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
  ];
}
