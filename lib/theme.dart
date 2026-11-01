import 'package:flutter/material.dart';

/// Oncard 2.0 palette: restrained, editorial, warm.
class AppPalette {
  static const Color background = Color(0xFFF8F7F3);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF6750A4);
  static const Color secondary = Color(0xFFA69BCB);
  static const Color textMain = Color(0xFF25242A);
  static const Color textMuted = Color(0xFF777580);
  static const Color success = Color(0xFF39845B);
  static const Color warning = Color(0xFFD99A42);

  // Dark mode: deep charcoal surfaces, never pure black.
  static const Color darkBackground = Color(0xFF1C1B1F);
  static const Color darkSurface = Color(0xFF26252A);
  static const Color darkTextMain = Color(0xFFECEAF4);
  static const Color darkTextMuted = Color(0xFFA9A7B4);
}

const deckPalette = <Color>[
  Color(0xFF6750A4),
  Color(0xFF386A20),
  Color(0xFF9C4146),
  Color(0xFF1565C0),
  Color(0xFFE65100),
  Color(0xFF00897B),
];

const deckIcons = <String>[
  '📚', '🧠', '🫀', '🧬', '💻', '🎯',
  '🇫🇷', '🇯🇵', '🌱', '⚗️', '🧪', '📝',
];

/// Builds the light theme. Callers pass the Inter text theme from main.dart.
ThemeData buildLightTheme(TextTheme base) {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppPalette.primary,
    surface: AppPalette.background,
  ).copyWith(
    primary: AppPalette.primary,
    secondary: AppPalette.secondary,
    onSurface: AppPalette.textMain,
    onSurfaceVariant: AppPalette.textMuted,
    surfaceContainerLowest: AppPalette.background,
    surfaceContainerLow: AppPalette.background,
    surfaceContainer: AppPalette.surface,
    surfaceContainerHigh: AppPalette.surface,
    surfaceContainerHighest: const Color(0xFFEDEBE4),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppPalette.background,
    textTheme: base.copyWith(
      displaySmall:
          base.displaySmall?.copyWith(fontWeight: FontWeight.w700),
      headlineMedium:
          base.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
      headlineSmall:
          base.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w600),
    ),
    cardTheme: const CardTheme(
      elevation: 0,
      color: AppPalette.surface,
      surfaceTintColor: AppPalette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    ),
  );
}

/// Builds the dark theme with charcoal surfaces.
ThemeData buildDarkTheme(TextTheme base) {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppPalette.primary,
    brightness: Brightness.dark,
    surface: AppPalette.darkBackground,
  ).copyWith(
    onSurface: AppPalette.darkTextMain,
    onSurfaceVariant: AppPalette.darkTextMuted,
    surfaceContainerLowest: AppPalette.darkBackground,
    surfaceContainerLow: AppPalette.darkBackground,
    surfaceContainer: AppPalette.darkSurface,
    surfaceContainerHigh: AppPalette.darkSurface,
    surfaceContainerHighest: const Color(0xFF322F38),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppPalette.darkBackground,
    textTheme: base,
    cardTheme: const CardTheme(
      elevation: 0,
      color: AppPalette.darkSurface,
      surfaceTintColor: AppPalette.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    ),
  );
}
