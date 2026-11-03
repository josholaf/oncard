import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_data.dart';

/// Amber bar shown at the top of Home when a newer release is known.
/// Hidden entirely while [AppData.updateVersion] is null, so the app
/// looks exactly as before until the update checker reports something.
class UpdateBar extends StatelessWidget {
  const UpdateBar({super.key, this.onUpdate});

  /// Runs when the user taps Update. Wired to the downloader and
  /// in-app installer once those steps ship. Defaults to a hint.
  final VoidCallback? onUpdate;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final version = data.updateVersion;
    if (version == null || version.isEmpty) return const SizedBox.shrink();

    return Material(
      color: const Color(0x59FFD54F),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.system_update_alt_rounded),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Oncard $version is available',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text('Update to keep decks, stats and streaks in sync.',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonal(
              onPressed: onUpdate ??
                  () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Download and install ship with the updater build.'))),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
