import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../data/app_data.dart';

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

  Future<void> _pickPhoto(BuildContext context, AppData data) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, maxWidth: 512, imageQuality: 85);
    if (picked == null) return;
    // Copy into the app documents dir so it survives temp cleanups.
    final dir = await getApplicationDocumentsDirectory();
    final dest = File(dir.path + '/profile-photo.jpg');
    await File(picked.path).copy(dest.path);
    data.setPhoto(dest.path);
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final cs = Theme.of(context).colorScheme;
    final hasPhoto =
        data.photoPath != null && File(data.photoPath!).existsSync();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          const SizedBox(height: 16),
          Center(
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => _pickPhoto(context, data),
                  child: hasPhoto
                      ? CircleAvatar(
                          radius: 40,
                          backgroundImage: FileImage(File(data.photoPath!)),
                        )
                      : CircleAvatar(
                          radius: 40,
                          backgroundColor: cs.primary,
                          child: Text(
                            (data.displayName.isEmpty
                                    ? 'G'
                                    : data.displayName[0])
                                .toUpperCase(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () => _pickPhoto(context, data),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cs.primary,
                        border: Border.fromBorderSide(BorderSide(
                            color: Theme.of(context)
                                .scaffoldBackgroundColor,
                            width: 2)),
                      ),
                      child: const Icon(Icons.photo_camera_rounded,
                          size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
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
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: Text(hasPhoto ? 'Change photo' : 'Add photo'),
                  subtitle: const Text('Shown on your profile and the home screen'),
                  onTap: () => _pickPhoto(context, data),
                ),
                if (hasPhoto)
                  ListTile(
                    leading: Icon(Icons.delete_outline_rounded, color: cs.error),
                    title: const Text('Remove photo'),
                    onTap: () => data.setPhoto(null),
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
