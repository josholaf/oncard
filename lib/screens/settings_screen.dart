import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_data.dart';
import '../import_export.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final cs = Theme.of(context).colorScheme;

    Widget option(String title, String subtitle, ThemeMode value) {
      final selected = value == data.themeMode;
      return ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        leading: Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: selected ? cs.primary : cs.onSurfaceVariant),
        onTap: () => data.setThemeMode(value),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Appearance',
              style: Theme.of(context).textTheme.titleMedium),
          option('System', 'Follow the device setting', ThemeMode.system),
          option('Light', 'Warm paper light', ThemeMode.light),
          option('Dark', 'Deep charcoal dark', ThemeMode.dark),
          const Divider(height: 32),

          Text('Study',
              style: Theme.of(context).textTheme.titleMedium),
          ListTile(
            title: const Text('Daily goal'),
            subtitle: Text('${data.dailyGoal} cards per day'),
          ),
          Slider(
            value: data.dailyGoal.toDouble(),
            min: 5,
            max: 100,
            divisions: 19,
            label: '${data.dailyGoal}',
            onChanged: (v) => data.setDailyGoal(v.round()),
          ),
          SwitchListTile(
            title: const Text('Text to speech'),
            subtitle: const Text(
                'Read card answers aloud during study sessions'),
            value: data.ttsEnabled,
            onChanged: data.setTtsEnabled,
          ),
          const Divider(height: 32),

          Text('Backup',
              style: Theme.of(context).textTheme.titleMedium),
          ListTile(
            leading: const Icon(Icons.save_rounded),
            title: const Text('Export backup'),
            subtitle: const Text('Save all decks and history as JSON'),
            onTap: () async {
              final file = await writeBackupFile(data);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Backup saved to ${file.path}')));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.restore_rounded),
            title: const Text('Restore backup'),
            subtitle:
                const Text('Replace current data with a backup file'),
            onTap: () => restoreBackupFile(context, data),
          ),
          ListTile(
            leading: Icon(Icons.delete_forever_rounded, color: cs.error),
            title: const Text('Reset all data'),
            subtitle:
                const Text('Delete everything and restore sample decks'),
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Reset all data?'),
                  content: const Text(
                      'Every deck, card and statistic will be replaced with the sample decks. This cannot be undone.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel')),
                    FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Reset')),
                  ],
                ),
              );
              if (ok == true) data.resetAll();
            },
          ),
          const Divider(height: 32),

          Text('About',
              style: Theme.of(context).textTheme.titleMedium),
          Card(
            elevation: 0,
            color: cs.surfaceContainerHighest,
            child: const ListTile(
              title: Text('Oncard'),
              subtitle: Text(
                  'Study smarter, remember longer. Offline-first flashcards with spaced repetition. v2.0.0'),
            ),
          ),
        ],
      ),
    );
  }
}
