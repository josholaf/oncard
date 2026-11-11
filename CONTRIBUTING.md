# Contributing to Oncard

Thanks for helping improve Oncard. The app stays **offline-first** and avoids new package dependencies unless they are clearly necessary.

## Setup

```bash
git clone https://github.com/josholaf/oncard.git
cd oncard
flutter pub get
flutter analyze
flutter test
flutter run
```

Requires Flutter 3.24+.

## Branch naming

| Prefix | Use |
|--------|-----|
| `fix/` | Bug fixes |
| `feat/` | New behaviour |
| `docs/` | Documentation only |
| `test/` | Tests only |
| `chore/` | Tooling, cleanup |

Keep branches short: `feat/study-progress-hint`, not `my-cool-feature-branch-final`.

## Pull requests

1. One concern per PR. Prefer small, reviewable changes.
2. Run `flutter analyze` and `flutter test` before opening the PR.
3. Write a clear title and a short body describing *why* the change exists.
4. CI must be green before merge.

## Code style

- Match the existing layout under `lib/data`, `lib/services`, `lib/ui`, `lib/screens`.
- Prefer `const` constructors where possible.
- Do not introduce network calls for core study flows.
- Keep sample decks and offline storage behaviour intact unless the PR is specifically about them.

## Reporting bugs

Open an issue with:

- Device / Android version
- Steps to reproduce
- Expected vs actual behaviour
- Screenshots if UI-related

## License

By contributing you agree that your contributions are licensed under the MIT license of this repository.
