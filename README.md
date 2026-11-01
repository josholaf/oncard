# Oncard

**Study smarter, remember longer.**

Beautiful offline-first flashcard app built with **Flutter** — single codebase for **Android, iOS, Web, Windows, macOS & Linux**.

## Features

- **Home** — Streak tracker, Quick Start, My Decks, motivational quote
- **Library** — All Decks, progress %, add deck with icon & color picker
- **Deck view** — Card list with mastery dots, edit / delete cards, import & export CSV, delete deck
- **Study mode** — Smooth flip cards, Know / Again, notes, related topics, mastery tracking, session summary
- **Create / Edit Card** — Question, Answer, optional Note
- **Import from CSV** — Pick CSV with Question / Answer / Note / Tags columns
- **Export to CSV** — Save any deck back out as CSV
- **Icon Picker** — Colorful icon grid for decks
- **Dark mode** — Light / Dark / System (Settings → Appearance)
- **Offline-first** — SharedPreferences persistence
- Sample decks: Anaesthesia Basics, Medical Physiology, Programming (Dart), French, Japanese, Agriculture

## Test APK

Every push to main builds a release APK with GitHub Actions. Download it from the [Actions tab](https://github.com/josholaf/oncard/actions) — open the latest "Build APK" run and grab the `oncard-release-apk` artifact. Install it on your phone with "Install from unknown sources" enabled.

## CSV format

Rows with a `question` / `answer` header are detected and skipped. Columns are, in order:

```
question,answer,note,tags
```

Separate multiple tags with `;`. The note and tags columns are optional.

## Run / Build locally

```bash
# Prerequisites: Flutter 3.24+ installed
git clone https://github.com/josholaf/oncard.git
cd oncard
flutter pub get

# Run on connected device / emulator
flutter devices
flutter run

# Analyze, test, and build APK
flutter analyze
flutter test
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

## Project structure

```
lib/main.dart          # App bootstrap, Material 3 theme, Provider wiring
lib/models.dart        # Deck + Flashcard domain model, JSON serialization
lib/app_data.dart      # AppData state: decks, streak, theme mode, persistence
lib/sample_decks.dart  # Starter decks seeded on first run
lib/screens.dart       # Home, Library, Deck, Study, Create Card, Import/Export, Settings
test/models_test.dart  # Round-trip and progress tests
pubspec.yaml
```

## Tech

Flutter • Dart • Provider • SharedPreferences • Google Fonts (Inter) • Material 3

## License

MIT
