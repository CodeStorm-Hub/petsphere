# PetSphere — Project Guidelines for Copilot

These instructions apply to **all** work in this repository.

## What you’re working on

PetSphere is a Flutter app (Material 3) using:

- **State management:** Riverpod (Notifier-based)
- **Routing:** `go_router`
- **Backend:** Supabase (Auth + PostgREST + Storage + Realtime)

Architecture is intentionally layered:

**Views (`lib/views/**`) → Controllers (`lib/controllers/**`) → Repositories (`lib/repositories/**`) → Supabase**

See:
- `README.md` (verified local setup + run commands)
- `CODEBASE_ANALYSIS.md` (deep architecture + feature inventory)

## Build / run / quality (Windows-friendly defaults)

Prefer these commands unless a task requires otherwise:

- Install deps: `flutter pub get`
- Static checks: `flutter analyze`
- Run (web): `flutter run -d chrome --dart-define-from-file=.env`
- Run (web-server): `flutter run -d web-server --web-port=8080 --dart-define-from-file=.env`

Notes:
- iOS cannot be built on Windows (requires macOS + Xcode).
- Android emulators may not be configured by default; if Android is required, follow the README guidance.

## Configuration & secrets

- **Do not hardcode secrets**. This repo supports compile-time env config via `--dart-define-from-file=.env`.
- Use `.env.example` → `.env` and set:
  - `SUPABASE_URL`
  - `SUPABASE_ANON_KEY`
- Keep config centralized in `lib/utils/supabase_config.dart`.
- Never introduce / request / commit Supabase **service-role** keys.

If you add new env vars:
- update `.env.example`
- update `README.md`
- keep names consistent with `String.fromEnvironment(...)`

## Riverpod controller conventions (important)

Controllers in `lib/controllers/**` follow a strict Notifier pattern:

- `build()` must **return an initial state synchronously**.
- **Do not mutate state during `build()`**.
- Defer initial async work using a microtask (e.g., `Future.microtask(...)`) or equivalent so the provider is fully initialized before state changes.

This pattern prevents provider lifecycle crashes and keeps UI predictable.

Also:
- keep providers top-level `final` variables (don’t dynamically create providers)
- keep ephemeral widget state inside widgets (controllers/text controllers/animations), not in global providers

Upstream references:
- Riverpod DO/DON’T: https://riverpod.dev/docs/root/do_dont
- Riverpod testing: https://riverpod.dev/docs/how_to/testing

## Repositories & Supabase usage

- Repositories own Supabase calls (`supabase.from(...)`, auth, storage, realtime).
- Controllers orchestrate, manage UI state, and call repositories.
- Prefer explicit filtering in queries (don’t rely solely on RLS for performance).

### Database schema / migrations

- Treat `supabase/migrations/*.sql` as the source of truth for schema.
- Avoid “dashboard-only” schema changes unless you immediately capture them as a migration.
- When adding tables in `public`, **enable RLS and add policies**.

Upstream references:
- RLS guide: https://supabase.com/docs/guides/database/postgres/row-level-security
- DB migrations: https://supabase.com/docs/guides/deployment/database-migrations
- Auth sessions: https://supabase.com/docs/guides/auth/sessions
- Realtime authorization (channels): https://supabase.com/docs/guides/realtime/authorization

## Routing conventions (go_router)

- Routes and redirects are defined in `lib/utils/routes.dart`.
- Auth gating is enforced via redirects (splash/login/register/home).
- Preserve existing redirect behavior unless a change explicitly requires altering navigation flows.

Upstream references:
- go_router redirection: https://pub.dev/documentation/go_router/latest/topics/Redirection-topic.html
- go_router web: https://pub.dev/documentation/go_router/latest/topics/Web-topic.html

## “Link, don’t embed” documentation rule

- If guidance already exists in `README.md` or `CODEBASE_ANALYSIS.md`, link to it instead of duplicating.
- Only add new inline docs here for **agent-critical** gotchas that aren’t documented elsewhere.

## When you change code

- Keep diffs small and focused.
- Preserve existing public APIs and patterns unless refactoring is explicitly requested.
- Run `flutter analyze` after meaningful changes.
