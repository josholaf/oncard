import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_data.dart';
import '../auth.dart';

/// Profile and account settings. Guests stay local-only.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Widget _header(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 28, 4, 8),
      child: Text(text.toUpperCase(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 1)),
    );
  }

  Future<void> _editName(BuildContext context, AppData data) async {
    final controller = TextEditingController(
        text: data.displayName == 'Guest' ? '' : data.displayName);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Display name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Your name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save')),
        ],
      ),
    );
    if (ok == true) data.setDisplayName(controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          const SizedBox(height: 16),
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: cs.primary,
              child: Text(
                (data.displayName.isEmpty ? 'G' : data.displayName[0])
                    .toUpperCase(),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
              child: Text(data.displayName,
                  style: Theme.of(context).textTheme.headlineSmall)),
          const SizedBox(height: 2),
          Center(
            child: Text('Guest · data stays on this device',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant)),
          ),
          _header(context, 'Appearance'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
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
          _header(context, 'You'),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline_rounded),
                  title: const Text('Display name'),
                  subtitle: Text(data.displayName),
                  trailing: const Icon(Icons.edit_rounded, size: 20),
                  onTap: () => _editName(context, data),
                ),
                if (data.interests.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.interests_rounded),
                    title: const Text('Interests'),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final interest in data.interests)
                            Chip(
                              label: Text(interest),
                              visualDensity: VisualDensity.compact,
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          _header(context, 'Account'),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                if (data.accountProvider == 'guest')
                  ListTile(
                    leading: const Icon(Icons.manage_accounts_outlined),
                    title: const Text('Sign in'),
                    subtitle: const Text(
                        'Optional. Sync across devices when connected.'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => showProviderSheet(context),
                  )
                else
                  ListTile(
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: cs.primary.withOpacity(0.12),
                      child: Text(
                        providerBadge(data.accountProvider),
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: cs.primary),
                      ),
                    ),
                    title: Text(
                        'Signed in with ${providerLabel(data.accountProvider)}'),
                    subtitle: Text(data.accountEmail ?? ''),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => showProviderSheet(context),
                  ),
                ListTile(
                  leading: Icon(Icons.logout_rounded, color: cs.error),
                  title: const Text('Sign out'),
                  subtitle: const Text(
                      'Reset profile and replay the introduction. Study data is kept.'),
                  onTap: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Sign out?'),
                        content: const Text(
                            'Your profile resets to Guest and the introduction plays again next launch. Decks and statistics are untouched.'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel')),
                          FilledButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Sign out')),
                        ],
                      ),
                    );
                    if (ok == true) {
                      data.signOutGuest();
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
