import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_data.dart';
import 'screens/create_screen.dart';
import 'screens/home_screen.dart';
import 'screens/library_screen.dart';
import 'screens/quick_add_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/stats_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(OncardApp(prefs: prefs));
}

class OncardApp extends StatelessWidget {
  final SharedPreferences prefs;
  const OncardApp({super.key, required this.prefs});

  /// Text theme for the selected font preset. Default keeps the
  /// platform font, SF falls back to system-ui on Android, Nunito
  /// loads through Google Fonts when reachable.
  TextTheme _fontTheme(AppFontStyle style, TextTheme fallback) {
    try {
      if (style == AppFontStyle.nunito) {
        return GoogleFonts.nunitoTextTheme(fallback);
      }
      if (style == AppFontStyle.sanFrancisco) {
        return fallback.apply(
            fontFamily: 'SF Pro Text',
            fontFamilyFallback: <String>['SF Pro Text', 'system-ui']);
      }
    } catch (_) {
      // Font unavailable: keep the platform default.
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppData(prefs),
      child: Consumer<AppData>(
        builder: (context, data, _) {
          final light = buildLightTheme(
              _fontTheme(data.fontStyle, ThemeData.light().textTheme),
              style: data.themeStyle);
          final dark = buildDarkTheme(
              _fontTheme(data.fontStyle, ThemeData.dark().textTheme),
              style: data.themeStyle);
          return MaterialApp(
            title: 'Oncard',
            debugShowCheckedModeBanner: false,
            theme: light,
            darkTheme: dark,
            themeMode: data.themeMode,
            home: const RootShell(),
          );
        },
      ),
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) maybeOpenQuickAdd(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const HomeScreen(),
      const LibraryScreen(),
      const CreateScreen(),
      const StatsScreen(),
      const SettingsScreen(),
    ];
    return Scaffold(
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          // Filled rounded silhouettes, matching the reference set.
          NavigationDestination(
              icon: Icon(Icons.home_rounded),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.laptop_rounded),
              selectedIcon: Icon(Icons.laptop_rounded),
              label: 'Library'),
          NavigationDestination(
              icon: Icon(Icons.library_add_rounded),
              selectedIcon: Icon(Icons.library_add_rounded),
              label: 'Create'),
          NavigationDestination(
              icon: Icon(Icons.insert_chart_rounded),
              selectedIcon: Icon(Icons.insert_chart_rounded),
              label: 'Stats'),
          NavigationDestination(
              icon: Icon(Icons.settings_rounded),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'Settings'),
        ],
      ),
    );
  }
}
