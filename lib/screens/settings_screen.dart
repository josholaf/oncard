import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_data.dart';
import '../import_export.dart';
import '../theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  /// Small uppercase section label, like a grouped settings list header.
  Widget _header(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 8),
      child: Text(text.toUpperCase(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          _header(context, 'Appearance'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                    value: ThemeMode.system,
                    label: Text('Auto'),
                    icon: Icon(Icons.brightness_auto_rounded)),
                ButtonSegment(
                    value: ThemeMode.light,
                    label: Text('Light'),
                    icon: Icon(Icons.light_mode_rounded)),
                ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text('Dark'),
                    icon: Icon(Icons.dark_mode_rounded)),
              ],
              selected: {data.themeMode},
              onSelectionChanged: (selection) =>
                  data.setThemeMode(selection.first),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<AppThemeStyle>(
              segments: const [
                ButtonSegment(
                    value: AppThemeStyle.standard,
                    label: Text('Default'),
                    icon: Icon(Icons.colorize_rounded)),
                ButtonSegment(
                    value: AppThemeStyle.green,
                    label: Text('Green'),
                    icon: Icon(Icons.eco_rounded)),
              ],
              selected: {data.themeStyle},
              onSelectionChanged: (selection) =>
                  data.setThemeStyle(selection.first),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<AppFontStyle>(
              segments: const [
                ButtonSegment(
                    value: AppFontStyle.systemDefault,
                    label: Text('Default'),
                    icon: Icon(Icons.text_fields_rounded)),
                ButtonSegment(
                    value: AppFontStyle.sanFrancisco,
                    label: Text('SF'),
                    icon: Icon(Icons.abc_rounded)),
                ButtonSegment(
                    value: AppFontStyle.nunito,
                    label: Text('Nunito'),
                    icon: Icon(Icons.font_download_rounded)),
              ],
              selected: {data.fontStyle},
              onSelectionChanged: (selection) =>
                  data.setFontStyle(selection.first),
            ),
          ),

          _header(context, 'Study'),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  title: const Text('Daily goal'),
                  subtitle: Text('${data.dailyGoal} cards per day'),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Slider(
                    value: data.dailyGoal.toDouble(),
                    min: 5,
                    max: 100,
                    divisions: 19,
                    label: '${data.dailyGoal}',
                    onChanged: (v) => data.setDailyGoal(v.round()),
                  ),
                ),
                ListTile(
                  title: const Text('Text to speech'),
                  subtitle: const Text(
                      'Read card answers aloud during study sessions'),
                  trailing: CupertinoSwitch(
                    value: data.ttsEnabled,
                    onChanged: data.setTtsEnabled,
                  ),
                  onTap: () =>
                      data.setTtsEnabled(!data.ttsEnabled),
                ),
              ],
            ),
          ),

          _header(context, 'Backup'),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
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
              ],
            ),
          ),

          _header(context, 'About'),
          Card(
            margin: EdgeInsets.zero,
            color: cs.surfaceContainerHighest,
            child: const ListTile(
              title: Text('Oncard'),
              subtitle: Text(
                  'Study smarter, remember longer. Offline-first flashcards with spaced repetition. v1.0.05'),
            ),
          ),
        ],
      ),
    );
  }
}

