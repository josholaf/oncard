# Oncard

**Study smarter, remember longer.**

A beautiful, offline-first flashcard app with real spaced repetition. Built with Flutter for Android (and ready for iOS, Web and Desktop).

## What's inside (v2.0)

- **Home dashboard** — greeting, due/new summary, one-tap "Start studying", streak and daily-goal progress, recently studied decks
- **Library** — search, favorites, sorting (name / recently studied / progress), grid or list view
- **Spaced repetition scheduler** — Again / Hard / Good / Easy grades, per-card due dates, adaptive intervals and ease factors (FSRS-inspired, fully offline)
- **Three study modes** — flip cards with 3D animation, multiple-choice quiz, type-the-answer
- **Image flashcards** — attach a picture to any card (great for anatomy, diagrams, maps)
- **Text to speech** — optional read-aloud for questions and answers (Settings → Study)
- **Statistics** — weekly activity chart, accuracy, cards learned, due-tomorrow preview, 12-week study heatmap
- **Card editor** — front/back, note, tags, image attachment, preview before saving
- **Import / export** — CSV and TSV import, CSV export per deck, full JSON backup and restore
- **Goals** — configurable daily card goal
- **Themes** — warm paper light theme, charcoal dark theme, system default
- **Offline-first** — everything is stored on-device; no account, no network required, no ads

## Test APK

Every push to `main` builds a release APK with GitHub Actions. Tagged versions (`v*`) also publish a GitHub Release with the APK attached. See [Releases](https://github.com/josholaf/oncard/releases).

## CSV / TSV format

Rows with a `question` / `answer` header are detected and skipped. Columns, in order:

```
question,answer,note,tags
```

Separate multiple tags with `;`. The note and tags columns are optional. TSV files use the same columns separated by tabs.

## Run / Build locally

```bash
# Prerequisites: Flutter 3.24+
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
lib/main.dart                 # App bootstrap, Inter theming, 5-tab shell
lib/models.dart               # Flashcard (content + review state), Deck, DayLog
lib/scheduler.dart            # Spaced-repetition scheduler (Again/Hard/Good/Easy)
lib/app_data.dart             # AppData: decks, goals, streak, history, backup
lib/theme.dart                # Palette and light/dark Material 3 themes
lib/widgets.dart              # Mastery dots, badges, stat cards, deck avatars
lib/import_export.dart        # CSV/TSV import, CSV export, JSON backup/restore
lib/sample_decks.dart         # Starter decks seeded on first run
lib/screens/                  # home, library, create, deck, editor, study, stats, settings
test/models_test.dart         # Model, migration and scheduler tests
test/widget_test.dart          # App smoke test
```

## Scheduling model

Card content (question, answer, note, tags, image) is stored separately from review state (due date, stability, ease, reps, lapses). Stability is the number of days a memory is expected to survive; it grows multiplicatively on Good/Easy and collapses on Again. A card counts as mastered once its stability reaches 21 days, but it keeps resurfacing for long-term review. All scheduling is deterministic and runs on-device.

## Tech

Flutter • Dart • Provider • SharedPreferences • Google Fonts (Inter) • image_picker • flutter_tts • Material 3

## License

MIT
