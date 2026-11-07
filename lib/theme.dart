import 'package:flutter/material.dart';

/// Theme accent presets selectable in Settings.
enum AppThemeStyle { standard, green }

class _Accent {
  final Color primary;
  final Color secondary;
  const _Accent(this.primary, this.secondary);
}

const _standardAccent = _Accent(Color(0xFF6750A4), Color(0xFFA69BCB));
const _greenAccent = _Accent(Color(0xFF2E7D32), Color(0xFF81C784));

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

  // Dark mode: true black background so the app blends with the
  // Android system navigation area; cards sit one step lighter.
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF141414);
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

/// One builder shared by light and dark themes. Only the color set
/// and a couple of behavioral flags differ between the two.
ThemeData _buildTheme(
  TextTheme base, {
  required Brightness brightness,
  required Color background,
  required Color surface,
  required Color containerHighest,
  required Color textMain,
  required Color textMuted,
  required Color navBarColor,
  required _Accent accent,
  required Color focusColor,
  required bool boldTitles,
}) {
  final scheme = ColorScheme.fromSeed(
    seedColor: accent.primary,
    brightness: brightness,
    surface: background,
  ).copyWith(
    primary: accent.primary,
    secondary: accent.secondary,
    onSurface: textMain,
    onSurfaceVariant: textMuted,
    surfaceContainerLowest: background,
    surfaceContainerLow: background,
    surfaceContainer: surface,
    surfaceContainerHigh: surface,
    surfaceContainerHighest: containerHighest,
  );
  final titles = boldTitles
      ? base.copyWith(
          displaySmall: base.displaySmall?.copyWith(fontWeight: FontWeight.w700),
          headlineMedium: base.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          headlineSmall: base.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        )
      : base;
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: background,
    textTheme: titles,
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
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: textMain),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      color: surface,
      surfaceTintColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.card)),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: surface,
      modalBackgroundColor: surface,
      surfaceTintColor: surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: surface,
      surfaceTintColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.dialog)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.field)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: containerHighest,
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(AppRadius.field),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(AppRadius.field),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: focusColor, width: 1.5),
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
            BorderSide(color: focusColor.withOpacity(0.5))),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: _pillButton(
          const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
    ),
    listTileTheme: const ListTileThemeData(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.tile)),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.field)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 64,
      backgroundColor: navBarColor,
      surfaceTintColor: navBarColor,
      indicatorColor: Colors.transparent,
      elevation: 0,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
    dividerTheme: DividerThemeData(
      color: textMuted.withOpacity(0.2),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      linearTrackColor: containerHighest,
    ),
  );
}

/// Builds the light theme. Callers pass the Nunito text theme from main.dart.
ThemeData buildLightTheme(TextTheme base,
    {AppThemeStyle style = AppThemeStyle.standard}) {
  final accent =
      style == AppThemeStyle.green ? _greenAccent : _standardAccent;
  return _buildTheme(
    base,
    brightness: Brightness.light,
    background: AppPalette.background,
    surface: AppPalette.surface,
    containerHighest: const Color(0xFFEDEBE4),
    textMain: AppPalette.textMain,
    textMuted: AppPalette.textMuted,
    navBarColor: AppPalette.surface,
    accent: accent,
    focusColor: accent.primary,
    boldTitles: true,
  );
}

/// Builds the dark theme. True black background matches the Android
/// navigation area so buttons and gesture bar blend into the app.
ThemeData buildDarkTheme(TextTheme base,
    {AppThemeStyle style = AppThemeStyle.standard}) {
  final accent =
      style == AppThemeStyle.green ? _greenAccent : _standardAccent;
  return _buildTheme(
    base,
    brightness: Brightness.dark,
    background: AppPalette.darkBackground,
    surface: AppPalette.darkSurface,
    containerHighest: const Color(0xFF232329),
    textMain: AppPalette.darkTextMain,
    textMuted: AppPalette.darkTextMuted,
    navBarColor: AppPalette.darkBackground,
    accent: accent,
    focusColor: accent.secondary,
    boldTitles: false,
  );
}
