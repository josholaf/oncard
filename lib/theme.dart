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

/// Shared soft-geometry values used across component themes.
class AppRadius {
  static const double tile = 12;
  static const double field = 14;
  static const double card = 20;
  static const double sheet = 28;
  static const double dialog = 24;
}

/// Buttons shaped like pills, with comfortable touch targets.
ButtonStyle _pillButton(TextStyle? textStyle) {
  return ButtonStyle(
    shape: const WidgetStatePropertyAll<OutlinedBorder>(StadiumBorder()),
    padding: const WidgetStatePropertyAll<EdgeInsets>(
        EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
    textStyle: WidgetStatePropertyAll<TextStyle?>(textStyle),
  );
}

/// Builds the light theme. Callers pass the Nunito text theme from main.dart.
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
      displaySmall: base.displaySmall?.copyWith(fontWeight: FontWeight.w700),
      headlineMedium: base.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
      headlineSmall: base.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w600),
    ),
    // Screens slide in from the right on every platform.
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
      },
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppPalette.textMain),
    ),
    cardTheme: const CardTheme(
      elevation: 0,
      color: AppPalette.surface,
      surfaceTintColor: AppPalette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.card)),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppPalette.surface,
      modalBackgroundColor: AppPalette.surface,
      surfaceTintColor: AppPalette.surface,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
    ),
    dialogTheme: const DialogTheme(
      backgroundColor: AppPalette.surface,
      surfaceTintColor: AppPalette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.dialog)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.field)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFEDEBE4),
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(AppRadius.field),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(AppRadius.field),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppPalette.primary, width: 1.5),
        borderRadius: BorderRadius.circular(AppRadius.field),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: _pillButton(
          const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: _pillButton(
              const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))
          .copyWith(
        side: WidgetStatePropertyAll<BorderSide?>(
            BorderSide(color: AppPalette.primary.withOpacity(0.5))),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: _pillButton(
          const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
    ),
    listTileTheme: const ListTileThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.tile)),
      ),
    ),
    popupMenuTheme: const PopupMenuThemeData(
      color: AppPalette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.field)),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      height: 64,
      backgroundColor: AppPalette.surface,
      surfaceTintColor: AppPalette.surface,
      indicatorColor: Colors.transparent,
      elevation: 0,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
    dividerTheme: DividerThemeData(
      color: AppPalette.textMuted.withOpacity(0.2),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      linearTrackColor: Color(0xFFEDEBE4),
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
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
      },
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppPalette.darkTextMain),
    ),
    cardTheme: const CardTheme(
      elevation: 0,
      color: AppPalette.darkSurface,
      surfaceTintColor: AppPalette.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.card)),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppPalette.darkSurface,
      modalBackgroundColor: AppPalette.darkSurface,
      surfaceTintColor: AppPalette.darkSurface,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
    ),
    dialogTheme: const DialogTheme(
      backgroundColor: AppPalette.darkSurface,
      surfaceTintColor: AppPalette.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.dialog)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.field)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF322F38),
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(AppRadius.field),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(AppRadius.field),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppPalette.secondary, width: 1.5),
        borderRadius: BorderRadius.circular(AppRadius.field),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: _pillButton(
          const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: _pillButton(
              const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))
          .copyWith(
        side: WidgetStatePropertyAll<BorderSide?>(
            BorderSide(color: AppPalette.secondary.withOpacity(0.5))),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: _pillButton(
          const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
    ),
    listTileTheme: const ListTileThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.tile)),
      ),
    ),
    popupMenuTheme: const PopupMenuThemeData(
      color: AppPalette.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.field)),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      height: 64,
      backgroundColor: AppPalette.darkSurface,
      surfaceTintColor: AppPalette.darkSurface,
      indicatorColor: Colors.transparent,
      elevation: 0,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
    dividerTheme: DividerThemeData(
      color: AppPalette.darkTextMuted.withOpacity(0.2),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      linearTrackColor: Color(0xFF322F38),
    ),
  );
}
