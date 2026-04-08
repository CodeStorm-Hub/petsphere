# PetSphere

PetSphere is a Flutter social + matchmaking + chat + marketplace app for pet owners.

## Verified local environment (Windows)

This repository was validated on the current machine with:

- Flutter `3.41.6` (stable)
- Dart `3.11.4`
- Android SDK `36.1.0`
- Chrome + Edge web targets

Validation commands executed successfully:

- Flutter/Dart version checks
- `flutter doctor -v`
- `flutter devices`
- `flutter pub get`
- `flutter run -d web-server --web-port=8081` (launch confirmed)

## Prerequisites

- Flutter SDK (stable)
- Dart SDK (bundled with Flutter)
- Android Studio + Android SDK (for Android builds)
- Chrome or Edge (for web)
- Supabase project credentials

## Environment configuration

The app now supports compile-time environment values using `--dart-define-from-file`.

1. Copy `.env.example` to `.env`.
2. Fill values:

```env
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

## Install dependencies

```bash
flutter pub get
```

## Run the app

### Web (Chrome)

```bash
flutter run -d chrome --dart-define-from-file=.env
```

### Web (web-server)

```bash
flutter run -d web-server --web-port=8080 --dart-define-from-file=.env
```

### Windows desktop

```bash
flutter run -d windows --dart-define-from-file=.env
```

## Analyze and quality checks

```bash
flutter analyze
```

Current status: `flutter analyze` reports **No issues found**.

## Android on Windows

Android toolchain is installed and healthy on this machine, but no emulator is currently configured (`flutter emulators` returned no entries).

To run Android locally:

1. Open Android Studio → Device Manager.
2. Create an Android Virtual Device (AVD).
3. Start the emulator.
4. Run:

```bash
flutter devices
flutter run -d <emulator_id> --dart-define-from-file=.env
```

## iOS note (important)

You **cannot build or run iOS apps on Windows**.

For iOS, use:

- macOS + Xcode + CocoaPods
- same project repo and `.env` values
- run from Mac:

```bash
flutter run -d ios --dart-define-from-file=.env
```

## Supabase schema/migrations

A production-facing schema migration was applied:

- `expand_core_domain_schema_v2`

It adds/extends matchmaking listings, canonical matches, notifications, and normalized order items. See `CODEBASE_ANALYSIS.md` for full schema + ERD + rollout notes.

## Helpful references

- Flutter docs: https://docs.flutter.dev/
- Riverpod docs: https://riverpod.dev/
- Supabase docs: https://supabase.com/docs
- go_router docs: https://pub.dev/packages/go_router