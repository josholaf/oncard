import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_data.dart';
import 'screens/create_screen.dart';
import 'screens/home_screen.dart';
import 'screens/library_screen.dart';
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

  /// Nunito when Google Fonts can load it; otherwise the platform
  /// default, which is San Francisco on iOS and Roboto on Android.
  TextTheme _nunito(TextTheme fallback) {
    try {
      return GoogleFonts.nunitoTextTheme(fallback);
    } catch (_) {
      return fallback;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppData(prefs),
      child: Consumer<AppData>(
        builder: (context, data, _) {
          final light =
              buildLightTheme(_nunito(ThemeData.light().textTheme));
          final dark =
              buildDarkTheme(_nunito(ThemeData.dark().textTheme));
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
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.library_books_outlined),
              selectedIcon: Icon(Icons.library_books_rounded),
              label: 'Library'),
          NavigationDestination(
              icon: Icon(Icons.add_circle_outline),
              selectedIcon: Icon(Icons.add_circle_rounded),
              label: 'Create'),
          NavigationDestination(
              icon: Icon(Icons.insights_outlined),
              selectedIcon: Icon(Icons.insights_rounded),
              label: 'Stats'),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'Settings'),
        ],
      ),
    );
  }
}
