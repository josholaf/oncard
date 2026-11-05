# Oncard

Offline-first flashcard app with spaced repetition. Built with Flutter.

No account, no ads, no network access required. All data stays on the device.

## Features

- Spaced repetition scheduler with Again / Hard / Good / Easy grades, per-card due dates, adaptive intervals and ease factors
- Three study modes: flip cards, multiple choice, type the answer
- Image cards, tags, notes
- Cloze cards with Anki-style numbered deletions (`{{c1::text}}`); each deletion becomes its own card
- Text to speech (optional)
- Statistics: accuracy, learned cards, weekly activity, 12-week heatmap
- Deck management: rename, delete, color, emoji or Lucide icon
- Create cards from text selected in any other app (Android text selection menu)
- CSV / TSV import, CSV export, full JSON backup and restore
- Daily goal and streak tracking
- Light and dark themes

## Download

Prebuilt APKs are on the [releases page](https://github.com/josholaf/oncard/releases).

Every push to `main` builds an APK with GitHub Actions. Tagged versions publish a release.

## Install

The APK is unsigned by CI. Enable install from unknown sources, then install `Oncard.apk`. Requires Android 6.0 or newer.

## Build from source

Requires Flutter 3.24 or newer.

```bash
git clone https://github.com/josholaf/oncard.git
cd oncard
flutter pub get
flutter run
```

Run the tests and analyzer:

```bash
flutter analyze
flutter test
```

Build a release APK:

```bash
flutter create --platforms=android --project-name=oncard .
python3 scripts/setup_process_text.py
flutter build apk --release
```

The `android/` folder is generated, not committed. `scripts/setup_process_text.py` patches the generated manifest for the text selection feature. CI does the same.

## Import format

CSV and TSV use these columns in order:

```
question,answer,note,tags
```

Header rows are detected and skipped. Separate multiple tags with `;`. Note and tags are optional.

## Adding cards from other apps (Android)

Select text in any app, tap Oncard in the selection menu, edit the card, pick a deck, save.

## Project layout

```
lib/main.dart            App bootstrap and navigation shell
lib/models.dart         Flashcard, Deck, DayLog
lib/scheduler.dart      Spaced repetition scheduler
lib/app_data.dart       State, persistence, goals, streaks
lib/import_export.dart  CSV/TSV import, CSV export, JSON backup
lib/screens/            App screens
lib/lucide_icons.dart   Embedded Lucide icon set (ISC license)
test/                   Model, migration, scheduler and widget tests
```

## Scheduling model

Card content and review state are stored separately. Review state holds due date, stability, ease, reps and lapses. Stability is the expected number of days a memory survives. It grows on Good and Easy, resets on Again. A card is considered mastered at 21 days stability and keeps resurfacing for review.

## Contributing

Bug reports and pull requests are welcome. Keep the app offline-first and avoid new package dependencies unless necessary.

## License

MIT
