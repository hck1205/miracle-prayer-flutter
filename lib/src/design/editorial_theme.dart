import "package:flutter/material.dart";

import "editorial_tokens.dart";

abstract final class EditorialTheme {
  static ThemeData buildTheme() {
    const ColorScheme colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: EditorialColors.primary,
      onPrimary: EditorialColors.onPrimary,
      secondary: EditorialColors.surfaceContainer,
      onSecondary: EditorialColors.onSurface,
      error: EditorialColors.error,
      onError: EditorialColors.onPrimary,
      surface: EditorialColors.surface,
      onSurface: EditorialColors.onSurface,
    );

    final TextTheme textTheme = const TextTheme(
      displayLarge: TextStyle(
        fontSize: 40,
        height: 1.05,
        letterSpacing: -0.8,
        fontWeight: FontWeight.w600,
        color: EditorialColors.onSurface,
      ),
      displayMedium: TextStyle(
        fontSize: 32,
        height: 1.1,
        letterSpacing: -0.64,
        fontWeight: FontWeight.w600,
        color: EditorialColors.onSurface,
      ),
      headlineLarge: TextStyle(
        fontSize: 32,
        height: 1.12,
        letterSpacing: -0.64,
        fontWeight: FontWeight.w600,
        color: EditorialColors.onSurface,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        height: 1.18,
        letterSpacing: -0.56,
        fontWeight: FontWeight.w600,
        color: EditorialColors.onSurface,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: EditorialColors.onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        height: 1.5,
        fontWeight: FontWeight.w500,
        color: EditorialColors.onSurface,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        height: 1.75,
        color: EditorialColors.onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.65,
        color: EditorialColors.onSurfaceMuted,
      ),
      labelLarge: TextStyle(
        fontSize: 12,
        height: 1.4,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w600,
        color: EditorialColors.onSurfaceMuted,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        height: 1.4,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w600,
        color: EditorialColors.onSurfaceMuted,
      ),
    ).apply(fontFamily: "Inter");

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: EditorialColors.surface,
      textTheme: textTheme,
      dividerColor: EditorialColors.outlineVariant.withValues(alpha: 0.3),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: EditorialColors.onSurface,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: EditorialColors.onPrimary,
          backgroundColor: EditorialColors.primary,
          textStyle: textTheme.titleMedium,
          padding: const EdgeInsets.symmetric(
            horizontal: EditorialSpacing.medium,
            vertical: EditorialSpacing.small,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(EditorialRadius.medium),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: EditorialColors.onSurface,
          textStyle: textTheme.titleMedium,
          side: BorderSide(
            color: EditorialColors.outlineVariant.withValues(alpha: 0.2),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: EditorialSpacing.medium,
            vertical: EditorialSpacing.small,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(EditorialRadius.medium),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: EditorialColors.primary,
          textStyle: textTheme.titleMedium,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: EditorialColors.surfaceLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: EditorialSpacing.small,
          vertical: EditorialSpacing.small,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(EditorialRadius.large),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(EditorialRadius.large),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: EditorialColors.outline,
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(EditorialRadius.large),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(EditorialRadius.large),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: EditorialColors.error,
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(EditorialRadius.large),
        ),
        errorStyle: textTheme.bodyMedium?.copyWith(color: EditorialColors.error),
      ),
    );
  }
}
