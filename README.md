<div align="center">

<img src="assets/logo.svg" width="140" alt="Oncard logo"/>

# Oncard

**Study smarter, remember longer.**

Offline-first flashcards with spaced repetition. No account, no ads, no network required.

<img src="https://img.shields.io/badge/Flutter-3.24-02569B?logo=flutter&logoColor=white" alt="Flutter 3.24"/>
<img src="https://img.shields.io/badge/Dart-3.5-0175C2?logo=dart&logoColor=white" alt="Dart 3.5"/>
<img src="https://img.shields.io/badge/platform-Android-green" alt="Android"/>
<img src="https://img.shields.io/badge/license-MIT-black" alt="MIT license"/>
<img src="https://img.shields.io/github/v/release/josholaf/oncard?logo=github" alt="latest release"/>

[Download](#download) · [Features](#features) · [Build from source](#build-from-source) · [Contributing](#contributing)

</div>

---

## Features

- **Spaced repetition** with Again / Hard / Good / Easy grades, per-card due dates, adaptive intervals and ease factors
- **Tap-to-reveal study** — show the answer when ready, then grade your recall
- **Rich answers** — bullet lists, numbered lists, indentation
- **Image and audio cards** — attach pictures and recorded audio, play audio while studying
- **Cloze cards** with Anki-style numbered deletions (`{{c1::text}}`); each deletion becomes its own card
- **2,000+ searchable icons** — full Lucide set for every deck
- **Statistics** — accuracy, mastered cards, full-year heatmap, streaks and daily goals
- **Text to speech** (optional)
- **Create cards from anywhere** — select text in any Android app and send it to Oncard
- **Import / export** — CSV and TSV import, CSV export, full JSON backup and restore
- **Light and dark themes**

Everything stays on your device. Oncard works fully offline.

## Download

Prebuilt binaries are on the [releases page](https://github.com/josholaf/oncard/releases):

| File | Platform |
| --- | --- |
| `Oncard.apk` | Android (requires 6.0 or newer) |

Every push to `main` is built by GitHub Actions. Release branches publish a versioned release.

The Android APK is unsigned by CI. Enable **Install unknown apps** for your browser or file manager, then install `Oncard.apk`.

> Tip: if you already have an older build installed, uninstall it first or allow updates from the same signing source.

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

## Project layout

```
lib/main.dart            App bootstrap and navigation shell
lib/data/                Models, scheduler, app state, sample decks
lib/services/            Audio, sharing, import/export, widget sync
lib/ui/                  Theme, shared widgets, rich text, icons
lib/screens/             App screens
test/                    Model, migration, scheduler and widget tests
```

## Scheduling model

Card content and review state are stored separately. Review state holds due date, stability, ease, reps and lapses. Stability is the expected number of days a memory survives. It grows on Good and Easy, resets on Again. A card is considered mastered at 21 days stability and keeps resurfacing for review.

## Contributing

Bug reports and pull requests are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) when present. Keep the app offline-first and avoid new package dependencies unless necessary.

## License

[MIT](LICENSE) — free to use, modify and distribute.
