import 'package:flutter/material.dart';

/// Social sign-in providers the account system supports.
/// Stored as lowercase strings in AppData ('guest', 'google', ...).
const List<String> kAuthProviders = <String>[
  'google',
  'github',
  'apple',
  'microsoft',
];

/// Human-readable label for a provider name.
String providerLabel(String provider) {
  switch (provider) {
    case 'google':
      return 'Google';
    case 'github':
      return 'GitHub';
    case 'apple':
      return 'Apple';
    case 'microsoft':
      return 'Microsoft';
    default:
      return 'Guest';
  }
}

/// Short badge text shown inside a small avatar circle.
String providerBadge(String provider) {
  switch (provider) {
    case 'google':
      return 'G';
    case 'github':
      return 'GH';
    case 'apple':
      return 'AP';
    case 'microsoft':
      return 'MS';
    default:
      return '?';
  }
}

/// Flip to true once the Firebase project is connected, see
/// docs/AUTH_SETUP.md. Until then the picker explains it is offline.
const kAuthEnabled = false;

/// Opens the provider picker. This is the seam where Firebase
/// sign-in calls land; the resulting account is stored through
/// AppData.setAccount.
Future<void> showProviderSheet(BuildContext context) {
  if (!kAuthEnabled) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign-in not connected yet'),
        content: const Text(
            'This build is not linked to an identity provider yet. '
            'Follow docs/AUTH_SETUP.md to connect Firebase, and Google, '
            'GitHub, Apple and Microsoft sign-in activate here.'),
        actions: [
          FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Got it')),
        ],
      ),
    );
  }
  return showModalBottomSheet<void>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Continue with', style: Theme.of(ctx).textTheme.titleMedium),
            const SizedBox(height: 16),
            for (final provider in kAuthProviders)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonal(
                    onPressed: () {
                      // TODO(firebase): sign in, then store the account:
                      //   context.read<AppData>()
                      //       .setAccount(provider, userEmail);
                      Navigator.pop(ctx);
                    },
                    child: Text('Continue with ${providerLabel(provider)}'),
                  ),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Continue as guest'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
