# AGENTS.md — PetFolio Development Guide

## Architecture

The codebase is organized by **feature**, not by layer type:

```
lib/
├── main.dart                 # Entry point; initializes Supabase, Stripe, Marionette
├── app/                      # App shell: router, bootstrap, main layout
│   ├── app.dart              # PetFolioApp root widget
│   ├── bootstrap_controller.dart
│   ├── router.dart           # GoRouter config (auth guards)
│   └── main_layout.dart
├── core/                     # Cross-cutting concerns
│   ├── constants/             # supabase_config.dart, routes, strings
│   ├── services/             # Push notifications, offline cache, storage
│   ├── theme/                # Colors, typography, spacing, app_theme.dart
│   ├── utils/                # Image upload, video compression, logging, etc.
│   └── widgets/              # Shared widgets (pet_avatar, skeleton_loader, etc.)
└── features/                  # Feature modules
    └── [feature]/            # auth, care, health, marketplace, pet, social, etc.
        ├── data/              # Repositories + data models
        ├── presentation/
        │   ├── controllers/  # Riverpod Notifiers + State classes
        │   ├── screens/     # UI screens
        │   └── widgets/     # Feature-specific widgets
        └── utils/            # Feature helpers
```

**Each feature is self-contained**: its own data layer, controllers, screens, and widgets.

## Key Commands

```bash
# Dev setup
flutter pub get
flutter run -d chrome          # Web
flutter run -d emulator-5554    # Android

# CI order: format → analyze → test → build
dart format --set-exit-if-changed .
flutter analyze
flutter test --coverage

# APK build with secrets
flutter build apk --debug --dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
```

## Critical Conventions

### State Management (Riverpod)
- Controllers use `Notifier<State>` + `NotifierProvider` pattern
- State classes are immutable with `copyWith()`
- Providers are declared at the **end** of each controller file
- Use `ref.watch(provider.select(...))` for selective rebuilding
- Use `ref.listen(...)` for side effects (toasts, navigation)

### Adding Features
Work **bottom-up**: `data/` (model + repository) → `presentation/controllers/` (state) → `presentation/screens/` (UI) → `router.dart` (navigation)

### Supabase Config
Location: `lib/core/constants/supabase_config.dart`
Credentials passed via `--dart-define` in CI; locally via `supabase/.env.local.example`

### Tests
- Integration tests use `marionette_flutter` binding (enabled in debug unless `FLUTTER_DRIVER_TEST=true` or `INTEGRATION_TEST=true`)
- Run single test: `flutter test test/path/to/test.dart`

### Linting
`analysis_options.yaml` excludes generated files (`*.g.dart`, `*.freezed.dart`, `*.mocks.dart`, `lib/generated_plugin_registrant.dart`)

## Important File Locations

| Concern | Path |
|---------|------|
| GoRouter config | `lib/app/router.dart` |
| Theme | `lib/core/theme/app_theme.dart` |
| Supabase client | `lib/core/constants/supabase_config.dart` |
| Push notifications | `lib/core/services/push_notification_service.dart` |
| Offline cache | `lib/core/services/offline_cache.dart` |
| Auth controller | `lib/features/auth/presentation/controllers/auth_controller.dart` |
| Pet controller | `lib/features/pet/presentation/controllers/pet_controller.dart` |
| Marketplace | `lib/features/marketplace/` |
| Social/Feed | `lib/features/social/` |

## Secrets & Environment

- `.env` is gitignored; create locally if needed
- `supabase/.env.local.example` for local Supabase dev
- GitHub Actions secrets: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `CODECOV_TOKEN`
- `STRIPE_PUBLISHABLE_KEY` passed via `--dart-define` for payments

## CI/CD

- Flutter 3.24.3, Java 17 (Zulu)
- Android build runs on `main`/`develop` pushes
- iOS build runs on `main` pushes only
- CodeQL security scan on every PR
- Codecov upload on every PR

## What to Avoid

- Do not use `print()` — use `developer.log()` from `dart:developer`
- Do not mutate state directly — always use `copyWith()`
- Do not hardcode colors/strings — use `AppTheme` tokens
- Do not perform async work in `build()` methods
