# Connecting Firebase sign-in

The account UI (provider picker, profile, guest mode) is already wired.
Sign-in activates after these steps. No app code changes beyond the flag.

## 1. Create the Firebase project

1. Go to the [Firebase console](https://console.firebase.google.com/) and create a project, e.g. `oncard`.
2. Add an Android app with package name `com.example.oncard` (the one CI generates with `flutter create`; change in the same step if you rename it).
3. Download `google-services.json` and commit it to `android_override/app/google-services.json` so CI copies it over the generated folder.

## 2. Enable providers

In **Authentication → Sign-in method**, enable:

- Google
- GitHub (paste the OAuth app credentials from GitHub Developer settings)
- Apple (requires Apple Developer Program membership)
- Microsoft (paste the Azure app registration client ID)

## 3. Add the Flutter packages

```bash
flutter pub add firebase_core firebase_auth
dart pub global activate flutterfire_cli
flutterfire configure
```

This generates `lib/firebase_options.dart` from your project.

## 4. Flip the flag

In `lib/auth.dart`:

```dart
const kAuthEnabled = true;
```

Then implement the sign-in call in `showProviderSheet` where the
`TODO(firebase)` marker sits, and store the result with
`AppData.setAccount(provider, email)`.

## Notes

- Guest mode stays the default. Sign-in is optional.
- Guest data stays local-only; no cloud account is created silently.
- The Android build also needs the `google-services` Gradle plugin;
  add it in `android_override/app/build.gradle` and the root build file.
