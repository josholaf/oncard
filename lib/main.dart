import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/app_data.dart';
import 'services/home_widget_sync.dart';
import 'screens/create_screen.dart';
import 'screens/home_screen.dart';
import 'screens/library_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/quick_add_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/stats_screen.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(OncardApp(prefs: prefs));
}

class OncardApp extends StatefulWidget {
  final SharedPreferences prefs;
  const OncardApp({super.key, required this.prefs});

  @override
  State<OncardApp> createState() => _OncardAppState();
}

class _OncardAppState extends State<OncardApp> {
  late final AppData _data = AppData(widget.prefs);

  @override
  void initState() {
    super.initState();
    _data.addListener(_syncHomeWidget);
    unawaited(updateHomeWidget(_data));
  }

  @override
  void dispose() {
    _data.removeListener(_syncHomeWidget);
    super.dispose();
  }

  void _syncHomeWidget() {
    unawaited(updateHomeWidget(_data));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppData>.value(
      value: _data,
      child: Consumer<AppData>(
        builder: (context, data, _) {
          final light = buildLightTheme(ThemeData.light().textTheme);
          final dark = buildDarkTheme(ThemeData.dark().textTheme);
          return MaterialApp(
            title: 'Oncard',
            debugShowCheckedModeBanner: false,
            theme: light,
            darkTheme: dark,
            themeMode: data.themeMode,
            home: data.onboarded
                ? const RootShell()
                : const OnboardingScreen(),
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

class _RootShellState extends State<RootShell> with WidgetsBindingObserver {
  int _index = 0;
  bool _quickAddOpen = false;
  static const _channel = MethodChannel('oncard/share');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Native pushes when PROCESS_TEXT / Share arrives while app is alive.
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onSelectedText') {
        final text = call.arguments as String?;
        if (text != null && text.trim().isNotEmpty && mounted) {
          await _openQuickAdd(text.trim());
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_pollSelectedText());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _channel.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When returning from another app after "Share to Oncard" / PROCESS_TEXT.
    if (state == AppLifecycleState.resumed) {
      unawaited(_pollSelectedText());
    }
  }

  Future<void> _pollSelectedText() async {
    try {
      final text = await _channel.invokeMethod<String>('getSelectedText');
      if (text != null && text.trim().isNotEmpty && mounted) {
        await _openQuickAdd(text.trim());
      }
    } catch (_) {
      // Not Android or channel or channel not wired.
    }
  }

  Future<void> _openQuickAdd(String text) async {
    if (_quickAddOpen || !mounted) return;
    _quickAddOpen = true;
    try {
      await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute<void>(
          builder: (_) => QuickAddScreen(selectedText: text),
        ),
      );
    } finally {
      _quickAddOpen = false;
    }
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
