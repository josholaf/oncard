# Oncard

**Study smarter, remember longer.**

Beautiful offline-first flashcard app built with **Flutter** — single codebase for **Android, iOS, Web, Windows, macOS & Linux**.

## Features

- **Home** — Streak tracker, Quick Start, My Decks, motivational quote
- **Library** — All Decks, progress %, add card / import CSV / delete
- **Study mode** — Smooth flip cards, Know / Again, notes, related topics, mastery tracking
- **Create Card** — Question, Answer, optional Note
- **Import from CSV** — Pick CSV with Question / Answer / Note / Tags columns
- **Icon Picker** — Colorful icon grid for decks
- **Dark mode** — Light / Dark / System (Settings → Appearance)
- **Offline-first** — SharedPreferences persistence
- Sample decks: Anaesthesia Basics, Medical Physiology, Programming (Dart), French, Japanese, Agriculture

## CSV format

Rows with a `question` / `answer` header are detected and skipped. Columns are, in order:

```
question,answer,note,tags
```

Separate multiple tags with `;`. The note and tags columns are optional.

## Run / Build for Android

```bash
# Prerequisites: Flutter 3.24+ installed
git clone https://github.com/josholaf/oncard.git
cd oncard
flutter pub get

# Run on connected device / emulator
flutter devices
flutter run

# Build APK for installation
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

Install the APK on your phone (enable “Install from unknown sources” if needed).

## Project structure

```
lib/main.dart          # App bootstrap, Material 3 theme, Provider wiring
lib/models.dart        # Deck + Flashcard domain model, JSON serialization
lib/app_data.dart      # AppData state: decks, streak, theme mode, persistence
lib/sample_decks.dart  # Starter decks seeded on first run
lib/screens.dart       # Home, Library, Deck, Study, Create Card, Import, Settings
pubspec.yaml
```

## Tech

Flutter • Dart • Provider • SharedPreferences • Google Fonts (Inter) • Material 3

## License

MIT
