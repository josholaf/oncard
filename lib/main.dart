import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_data.dart';
import 'screens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(OncardApp(prefs: prefs));
}

class OncardApp extends StatelessWidget {
  final SharedPreferences prefs;
  const OncardApp({super.key, required this.prefs});

  TextTheme _inter(TextTheme fallback) {
    try {
      return GoogleFonts.interTextTheme(fallback);
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
          final light = ThemeData(
            useMaterial3: true,
            colorSchemeSeed: const Color(0xFF6750A4),
            textTheme: _inter(ThemeData.light().textTheme),
          );
          final dark = ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorSchemeSeed: const Color(0xFF6750A4),
            textTheme: _inter(ThemeData.dark().textTheme),
          );
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
