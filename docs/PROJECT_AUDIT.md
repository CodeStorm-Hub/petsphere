# PetSphere Project Audit

Generated: 2026-04-26  
Repository: `g:\Pet\petsphere`  
Primary deliverable: comprehensive technical review of the Flutter PetSphere application.

## Executive Summary

PetSphere is a Flutter social-commerce app for pet owners. It combines an Instagram-style feed, pet profiles, pet discovery/matching, chat, notifications, and a marketplace backed by Supabase Auth, Postgres, Storage, and Realtime.

The app is more complete than the default README suggests: it has a meaningful Riverpod state layer, Supabase repositories, route guards, polished screens, real schema/policy files, and a live Supabase project. Static analysis currently passes. The largest risks are production readiness gaps: no automated tests, hardcoded Supabase configuration, overly broad Storage policies, Android release networking/signing issues, incomplete social auth/attachments, weak environment documentation, and schema drift between local SQL files and the remote database.

Top priorities:

1. Add a minimal test suite and CI gates for `flutter analyze` and `flutter test`.
2. Fix Android release configuration: release `AndroidManifest.xml` lacks `INTERNET`, the application ID is still `com.example.pet_dating_app`, and release builds are signed with the debug key.
3. Move Supabase URL/key to documented build-time config and rotate the currently committed anon JWT.
4. Tighten Supabase Storage policies so public buckets do not allow broad object listing and authenticated users cannot overwrite/delete arbitrary bucket files.
5. Reconcile database schema/migrations with the live project, especially duplicate match/message triggers and storage policies.
6. Complete or hide unfinished flows: Google/Apple auth, chat attachments, production terms/privacy URLs, and deeper order/payment/admin flows.

## Evidence Collected

Local files inspected:

- `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml`, `README.md`
- `lib/main.dart`, `lib/utils/routes.dart`, `lib/utils/supabase_config.dart`
- `lib/controllers/*`, `lib/repositories/*`, `lib/models/*`
- Key screens under `lib/views/*` and reusable widgets under `lib/views/components/*`
- `supabase/*.sql`
- `android/*`, `ios/*`, `web/*`
- `.github/workflows/ios-build.yml`
- Existing docs: `docs/cursor-flutter-priority-tasks.md`, `rules.md`, `research_notes.txt`

Tooling results:

- `flutter --version`: Flutter `3.41.6` stable, Dart `3.11.4`
- `flutter analyze`: passed, no issues found
- `flutter test`: failed because `test/` does not exist
- `flutter pub outdated`: 3 direct dependencies are behind latest/resolvable versions (`go_router`, `share_plus`, `supabase_flutter`), with several transitive updates available
- Supabase MCP:
  - Project `petsphere`, ref `foubokcqaxyqgjhtgzsx`, region `ap-southeast-1`, status `ACTIVE_HEALTHY`
  - Postgres `17.6.1.084`
  - Remote table/schema listing, RLS policy listing, triggers, and security/performance advisors were inspected

Official references used:

- Flutter architecture overview: [https://docs.flutter.dev/resources/architectural-overview](https://docs.flutter.dev/resources/architectural-overview)
- Flutter testing overview: [https://docs.flutter.dev/testing/overview](https://docs.flutter.dev/testing/overview)
- Flutter accessibility testing: [https://docs.flutter.dev/ui/accessibility/accessibility-testing](https://docs.flutter.dev/ui/accessibility/accessibility-testing)
- Flutter Android release guide: [https://docs.flutter.dev/deployment/android](https://docs.flutter.dev/deployment/android)
- Flutter iOS release guide: [https://docs.flutter.dev/deployment/ios](https://docs.flutter.dev/deployment/ios)
- Dart `pub outdated`: [https://dart.dev/tools/pub/cmd/pub-outdated](https://dart.dev/tools/pub/cmd/pub-outdated)
- go_router redirection: [https://pub.dev/documentation/go_router/latest/topics/Redirection-topic.html](https://pub.dev/documentation/go_router/latest/topics/Redirection-topic.html)
- Riverpod 3 changes: [https://riverpod.dev/docs/whats_new](https://riverpod.dev/docs/whats_new)
- Supabase Flutter quickstart: [https://supabase.com/docs/guides/getting-started/quickstarts/flutter](https://supabase.com/docs/guides/getting-started/quickstarts/flutter)
- Supabase Dart/Flutter reference: [https://supabase.com/docs/reference/dart/introduction](https://supabase.com/docs/reference/dart/introduction)
- Supabase RLS: [https://supabase.com/docs/guides/database/postgres/row-level-security](https://supabase.com/docs/guides/database/postgres/row-level-security)
- Supabase Storage access control: [https://supabase.com/docs/guides/storage/security/access-control](https://supabase.com/docs/guides/storage/security/access-control)
- Supabase password security: [https://supabase.com/docs/guides/auth/password-security](https://supabase.com/docs/guides/auth/password-security)

## Project Overview and Tech Stack

### Application Type

PetSphere is a Flutter app for:

- Pet owner profiles and pet profiles
- Social feed posts, likes, and comments
- Discovery/matching for listed pets
- Chat between matched/selected pets
- Notifications
- Marketplace browsing, cart, checkout, and order history

### Flutter and Dart Expectations

`pubspec.yaml` declares:

- Dart SDK constraint: `>=3.0.0 <4.0.0`
- Package name: `pet_dating_app`
- App version: `1.0.0+1`

`pubspec.lock` currently resolves:

- Dart SDK: `>=3.11.0 <4.0.0`
- Flutter SDK: `>=3.38.4`

Local SDK used for audit:

- Flutter `3.41.6`
- Dart `3.11.4`

Recommendation: update `pubspec.yaml` to reflect the actual minimum SDK required by the lockfile and current dependency set, or regenerate the lockfile with the intended lower SDK. Today the declared lower bound (`3.0.0`) is misleading.

### Main Dependencies

Direct runtime dependencies:

- `go_router` for routing and auth redirects
- `flutter_riverpod` for state management
- `supabase_flutter` for Auth, Postgres, Storage, and Realtime
- `image_picker` for image selection/camera
- `cached_network_image` for network image caching
- `google_fonts` for typography
- `share_plus` for platform sharing
- `url_launcher` for terms/privacy/support links
- `intl` for formatting
- `cupertino_icons`

Dev dependencies:

- `flutter_test`
- `flutter_lints`

### State Management

The project standardizes on Riverpod `NotifierProvider`, `FutureProvider.family`, and reactive selectors. The controller layer owns app state:

- `AuthNotifier`
- `PetNotifier`
- `FeedNotifier`
- `MarketplaceController`
- `CartController`
- `MatchController`
- `ChatController`
- `NotificationController`
- `FollowController`

This is coherent and preferable to mixing multiple state-management systems. The main gaps are testability and lifecycle hardening. Most repositories are global singletons, which makes unit testing harder than provider-injected repositories or repository interfaces.

### Routing

Routing is centralized in `lib/utils/routes.dart` with `GoRouter`.

Strengths:

- Auth state drives redirects through `refreshListenable`
- `/splash`, `/login`, `/register`, `/home`, entity-detail routes, and error route are configured
- Unknown route page exists
- `/post/:id` and `/product/:id` can fetch by ID if cached state is empty

Gaps:

- Auth redirect does not preserve intended destination after login
- All non-auth routes are protected, so share links require login and then land on `/home` rather than the original path
- Route paths use a mix of snake case (`/create_post`, `/add_pet`) and REST-like paths (`/post/:id`, `/product/:id`)

Official `go_router` docs recommend top-level redirects for auth and `refreshListenable` or similar mechanisms so redirects react to auth changes: [https://pub.dev/documentation/go_router/latest/topics/Redirection-topic.html](https://pub.dev/documentation/go_router/latest/topics/Redirection-topic.html)

### Networking, Storage, and Backend

All backend access goes through Supabase client APIs:

- Auth: `supabase.auth.signInWithPassword`, `signUp`, `signOut`, `resetPasswordForEmail`, `onAuthStateChange`
- Database: direct table queries through `supabase.from(...)`
- Storage: public URL uploads to `pet-images`, `post-media`, and likely remote `avatars`
- Realtime: channel subscriptions on likes, comments, messages, and notifications

There is no custom server/API layer. That makes Supabase RLS the primary authorization boundary.

### Environment and Configuration Management

Current config is hardcoded in `lib/utils/supabase_config.dart`:

- Supabase URL: `https://foubokcqaxyqgjhtgzsx.supabase.co`
- A legacy JWT anon key
- Storage bucket names

Supabase publishable/anon keys are intended for public clients when RLS is correct, but committing environment-specific keys still creates rotation, environment separation, and accidental production-coupling problems. Supabase docs also note newer publishable key formats: [https://supabase.com/docs/guides/getting-started/quickstarts/flutter](https://supabase.com/docs/guides/getting-started/quickstarts/flutter)

Recommendation: use `String.fromEnvironment` with `--dart-define` or `--dart-define-from-file`, document required values, and rotate the currently committed anon JWT.

### Platform Targets

The Flutter project includes:

- Android
- iOS
- Web

Observed production issues:

- Android main manifest lacks `android.permission.INTERNET`; debug/profile manifests include it, but release builds likely cannot reach Supabase.
- Android label and application ID are still default/demo (`pet_dating_app`, `com.example.pet_dating_app`).
- Android release signing uses debug signing config.
- iOS display name is `Pet Dating App`, not PetSphere.
- iOS `Info.plist` lacks `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription`, even though `image_picker` uses camera/gallery flows.
- Web manifest and meta tags still say `pet_dating_app` and "A new Flutter project."

Flutter's Android release docs explicitly call out manifest review, app signing, versioning, and release build configuration: [https://docs.flutter.dev/deployment/android](https://docs.flutter.dev/deployment/android)

## Architecture Review

### Folder Structure

Current top-level code layout:

- `lib/controllers`: Riverpod notifiers and state classes
- `lib/repositories`: Supabase data access
- `lib/models`: hand-written DTO/domain models
- `lib/views`: screens
- `lib/views/components`: reusable widgets
- `lib/theme`: centralized theme
- `lib/utils`: router, Supabase config, upload helper, navigation helpers

This layer-based layout is understandable for the current app size, but it is starting to strain. Features such as feed, matching, chat, marketplace, and profile each touch models, repositories, controllers, screens, components, and SQL. As the app grows, a feature-first structure would improve navigation and ownership:

- `lib/core/config`
- `lib/core/routing`
- `lib/core/supabase`
- `lib/features/auth`
- `lib/features/feed`
- `lib/features/pets`
- `lib/features/matching`
- `lib/features/chat`
- `lib/features/marketplace`
- `lib/features/notifications`

The official Flutter architecture overview emphasizes clear composition, layering, and testable boundaries: [https://docs.flutter.dev/resources/architectural-overview](https://docs.flutter.dev/resources/architectural-overview)

### Module Boundaries and Data Flow

Current data flow:

1. UI widgets read Riverpod providers.
2. Controllers mutate provider state and call repositories.
3. Repositories call Supabase directly.
4. Models parse Supabase response maps by hand.
5. Supabase RLS policies enforce access.

Strengths:

- UI is mostly separated from Supabase calls.
- Repositories are named by feature.
- Controllers expose high-level actions like `toggleLike`, `createPet`, `placeOrder`, `acceptRequest`.
- Realtime channels are encapsulated in repositories/controllers.

Weaknesses:

- Repository singletons (`final authRepository = AuthRepository()`) make tests and dependency replacement difficult.
- Models use manual `fromJson` casts and assume required keys. A schema mismatch can crash the UI at runtime.
- Error handling often converts errors to raw strings and exposes backend details to users.
- Some important domain rules are split between UI, repository, and DB policies with no single source of truth.
- Some actions are optimistic but silently roll back or swallow errors.

### Separation of Concerns

Good:

- Auth guard is centralized.
- Theme is centralized in `AppTheme`.
- Upload helper centralizes image content-type detection.
- Most screens use providers rather than calling repositories directly.

Needs improvement:

- `login_screen.dart` calls `supabase.auth.resetPasswordForEmail` directly instead of going through `AuthRepository`.
- `pet_profile_screen.dart` imports Supabase config and contains a large amount of profile, share, edit, upload, and UI logic.
- `main_layout.dart` keeps tab index locally, which is fine, but route URLs do not reflect selected tabs.
- Domain concepts such as "active pet", "listed for breeding", and "matched pets can chat" are spread across providers and DB triggers.

### Naming and Style

The code passes `flutter analyze`. Naming is generally readable, but there is a product-name mismatch:

- Package/app defaults: `pet_dating_app`
- UI brand: `PetSphere`, `The Nurtured Atelier`, `The Nurtured Nest`
- Android/iOS/web metadata: default names

Recommendation: choose one production brand and update package metadata, manifests, CI, README, and share URLs accordingly.

### Testing Strategy

There is no `test/` directory. `flutter test` fails with:

```text
Test directory "test" not found.
```

This is the largest maintainability gap. Flutter's official testing overview recommends unit, widget, and integration tests with enough integration coverage for important flows: [https://docs.flutter.dev/testing/overview](https://docs.flutter.dev/testing/overview)

Highest-value initial tests:

- Unit/provider tests for auth state transitions, pet loading, cart checkout, matching accept/decline, and feed optimistic likes
- Repository tests with a fake Supabase boundary or wrapper
- Widget tests for login/register validation, empty/error/loading states, post cards, marketplace cart, and no-pet states
- One integration smoke test for login -> home shell -> add pet -> create post, using a test Supabase project or mocked backend

## Authentication Review

### Provider and Flow

Auth provider: Supabase Auth through `supabase_flutter`.

Implemented:

- Email/password login
- Email/password registration
- Session bootstrap through `supabase.auth.currentUser`
- Auth change listener through `onAuthStateChange`
- Logout
- Password reset email
- Auth-protected routes
- Profile row upsert after signup

Partially implemented:

- Google and Apple buttons exist, but only show "coming soon" snackbars.
- Email confirmation handling is not explicit. If Supabase email confirmation is enabled, registration may return a user/session state that the UI treats as authenticated before confirmation UX is clear.
- Password reset sends email, but there is no deep-link handling for recovery callbacks.
- Terms and privacy links point to public URLs that may not exist or may be placeholders.

Missing:

- Social login implementation
- MFA or account security flows
- Account deletion
- Email verification UX
- Re-authentication for sensitive actions
- Guest/visitor mode
- Post-login redirect to intended route
- Formal session expiration/offline handling

### Session Lifecycle

`AuthNotifier` starts a Supabase auth-state subscription in `_init()` and performs `_checkCurrentSession()`. This generally works. However:

- The auth stream subscription is not stored and cancelled by provider disposal. If the provider is ever rebuilt beyond app lifetime patterns, this can leak.
- `_isPerformingAuthAction` suppresses listener updates during login/register. This avoids overwrites, but it can hide auth events such as email confirmation requirements or refresh events.
- Profile fetch failures are swallowed and converted to a bare `UserModel`, which may hide RLS/schema issues.

### Route Guards

The `GoRouter` redirect is correct in principle:

- `initial` -> `/splash`
- `unauthenticated` -> `/login`
- `authenticated` on auth/splash -> `/home`

Main gap: no destination preservation. If a user opens `/product/:id`, they are sent to `/login`, then `/home`, not back to `/product/:id`.

### Logout

Logout calls `supabase.auth.signOut()` and resets auth state. Providers mostly react to auth changes, but verify that all user-scoped providers clear data on sign-out. `PetNotifier` clears, but feed/marketplace are public-to-authenticated and may keep cached state. That may be okay if the next user sees the same public data, but profile/notifications/chat should be verified.

## Security Review

### Secrets and API Keys

Findings:

- No `.env` files were found.
- No service role key was found in source.
- A Supabase URL and legacy anon JWT are committed in `lib/utils/supabase_config.dart`.

Risk:

- The anon key is public by design, but hardcoding it ties every build to one Supabase project and makes key rotation noisy.
- If RLS policies are wrong, the public client key becomes a practical exploit path.

Recommendation:

- Rotate the committed anon key.
- Use build-time config.
- Document dev/staging/prod Supabase refs separately.
- Never add service role keys to the Flutter client.

### Supabase RLS and Authorization

Confirmed remote project:

- All inspected public tables have RLS enabled.
- RLS policies mostly use `auth.uid()` checks for ownership.
- Public-ish tables like `pets`, `posts`, `comments`, `products`, `profiles`, and `post_likes` are readable by any authenticated user.

Potential risks:

- The product model appears to be "authenticated community" rather than public visitor browsing. If public browsing is desired, anon policies are missing.
- `matches`, `chat_threads`, and `messages` allow insert if the user owns any involved pet. This means one participant may create a chat thread involving another pet without first being matched unless application logic prevents it. The UI currently has paths that can create or get threads from pet profiles.
- `match_requests.update` allows either sender or receiver pet owner to update status. The sender may be able to mark a pending request as `matched` unless additional DB constraints/triggers prevent it. This is a high-impact authorization rule to review.
- `notifications` insert allows users to insert notifications for themselves. If notifications should only be system-generated, client insert should be removed and triggers/functions should write them.
- `products` has "Vendors can manage products" but the Flutter app has no seller/admin role model. Any authenticated user whose ID matches `vendor_id` may manage products if a client path is added.

Supabase RLS guidance: [https://supabase.com/docs/guides/database/postgres/row-level-security](https://supabase.com/docs/guides/database/postgres/row-level-security)

### Storage Policies

Local SQL and remote advisors show storage as a key issue.

Local `supabase/storage_policies.sql`:

- Creates public `pet-images` and `post-media` buckets.
- Allows any authenticated user to upload to those buckets.
- Allows any authenticated user to update/delete any object in those buckets.
- Adds broad public SELECT policies.

Remote Supabase security advisor warnings:

- Public bucket `avatars` allows broad listing.
- Public bucket `pet-images` allows broad listing.
- Public bucket `post-media` allows broad listing.
- Leaked password protection is disabled.

Remote policies also show duplicate/open policies for `pet-images` and `post-media`, plus better folder-scoped avatar policies for `avatars`.

Risk:

- Users can potentially overwrite or delete other users' pet/post media.
- Public bucket listing can expose file paths and metadata.
- Public URLs are fine for intentionally public assets, but listing should be restricted.

Recommendation:

- Scope storage paths to `auth.uid()` or owned pet IDs, e.g. `pet-images/<user_id>/<pet_id>/...`.
- Use `storage.foldername(name)` policies for INSERT/UPDATE/DELETE.
- Remove broad public SELECT object listing policies when buckets are public and URL access is enough.
- Add file-size/type restrictions at upload and possibly via storage settings.
- Enable Supabase leaked password protection.

Supabase Storage docs confirm upsert requires INSERT plus SELECT and UPDATE, but policies should still be scoped to ownership: [https://supabase.com/docs/guides/storage/security/access-control](https://supabase.com/docs/guides/storage/security/access-control)

### Input Validation

Present:

- Login/register form validation is basic.
- Add pet validates required name/breed/age.
- Some image quality/width constraints exist.
- DB check constraints exist for statuses and some numeric fields.

Gaps:

- Email validation is only `contains('@')`.
- Password policy is only `>= 6` characters.
- Pet age and product/cart quantities need stronger domain bounds.
- Post/comment/message text length and content restrictions are not visible.
- Uploaded file extension drives content type, but MIME/content sniffing and max size are not enforced in client code.
- Checkout trusts client-computed prices and item snapshots.

High-risk commerce issue:

- `MarketplaceRepository.placeOrder` sends product name, price, quantity, and total from the client. A malicious client can submit altered prices/totals unless the database or server recomputes totals from `products`.

Recommendation: use an Edge Function or database RPC for checkout that validates stock, reads product prices server-side, computes totals, and writes order/order_items transactionally.

### Logging

Many `debugPrint` calls remain, including user IDs, matching filters, profile update fields, and raw exceptions. `debugPrint` is less dangerous than `print`, but production logs should avoid PII and raw backend details.

Recommendation: introduce a small logging abstraction with levels and redaction, and disable verbose logs in release.

### Transport and Platform Security

Supabase URLs use HTTPS. No cleartext HTTP endpoints were found in app code.

Platform issues:

- Android release manifest lacks `INTERNET`; release networking may fail.
- iOS lacks camera/photo usage descriptions required by image picker flows.
- Android/iOS branding and signing remain default.
- No deep link URL schemes are configured for Supabase password recovery/OAuth callbacks.

## Dependency Package Review

### Current Direct Dependencies

From `pubspec.yaml` and lockfile:

- `go_router`: constraint `^17.1.0`, locked `17.1.0`, latest/resolvable `17.2.2`
- `flutter_riverpod`: constraint `^3.3.1`, locked package stack includes `riverpod 3.2.1`
- `google_fonts`: constraint `^8.0.2`, locked `8.0.2`
- `intl`: constraint `^0.20.2`
- `supabase_flutter`: constraint `^2.8.4`, locked `2.12.2`, latest/resolvable `2.12.4`
- `image_picker`: constraint `^1.1.2`, locked `1.2.1`
- `share_plus`: constraint `^10.1.4`, locked `10.1.4`, latest/resolvable `13.1.0`
- `url_launcher`: constraint `^6.3.1`, locked `6.3.2`
- `cached_network_image`: constraint `^3.4.1`

### Outdated Packages

`flutter pub outdated` reported:

- `go_router` can upgrade from `17.1.0` to `17.2.2`
- `supabase_flutter` can upgrade from `2.12.2` to `2.12.4`
- `share_plus` is constrained to `10.1.4`, but `13.1.0` is resolvable/latest with a constraint update
- Several transitive packages are behind due to lockfile or constraints

Dart's official guidance is to use `dart pub outdated`, update constraints where needed, rerun the command, then test behavior: [https://dart.dev/tools/pub/cmd/pub-outdated](https://dart.dev/tools/pub/cmd/pub-outdated)

Recommendation:

- First run `flutter pub upgrade` for compatible patch/minor updates.
- Upgrade `share_plus` in a dedicated change because it crosses major versions.
- Add `flutter pub outdated` output review to periodic maintenance.
- Consider `custom_lint` and Riverpod linting after tests are in place.

### Duplicated or Unused Functionality

- `share_plus` is included and used in product/profile sharing paths, but some share behavior still appears to rely on app-specific URLs and should be verified.
- `cached_network_image` is used in some widgets, while many screens still use `Image.network`/`NetworkImage`. Standardize image loading/error/caching.
- `ImageUploadHelper`, `PetRepository.uploadPetImage`, and `AuthRepository.uploadAvatar` overlap. Consolidate upload behavior and policy expectations.

## UI/UX Review

### Strengths

- The app has a polished visual language with warm colors and custom typography.
- Main navigation uses an `IndexedStack`, preserving tab state.
- Most major screens have loading, empty, and error states.
- Pull-to-refresh exists on feed, discovery, marketplace, notifications, messages, and profile-related screens.
- Login/register screens are visually complete.
- Detail routes exist for products, posts, and pets.

### Product and UX Gaps

- Branding is inconsistent: PetSphere, pet_dating_app, The Nurtured Atelier, and The Nurtured Nest all appear.
- Social auth buttons are visible but nonfunctional.
- Chat attachment button is visible but nonfunctional.
- Terms/privacy URLs may be placeholders and are not verified in app.
- No localization setup; all strings are hardcoded English.
- No explicit onboarding after registration, even though "add a pet" is central.
- No theme toggle despite light/dark themes.
- No offline/poor network UX beyond generic errors.
- Cart is in-memory only; it is lost on app restart.
- Checkout lacks payment, address, shipping, inventory confirmation, tax, refunds, or seller/admin handling.

### Accessibility

Strengths:

- Many `IconButton`s include tooltips.
- Forms use labels.
- Most touch targets appear large enough.

Gaps:

- Custom gesture buttons in login/register may not expose ideal semantic button roles compared with `FilledButton`.
- Bottom nav uses `InkResponse` and icons/avatar without text labels or explicit semantics.
- Image-only pet/post content often lacks semantic labels.
- No accessibility tests exist.
- Dense custom UI should be tested under large text scale and screen readers.

Flutter's accessibility testing docs recommend `androidTapTargetGuideline`, `iOSTapTargetGuideline`, `labeledTapTargetGuideline`, and `textContrastGuideline`: [https://docs.flutter.dev/ui/accessibility/accessibility-testing](https://docs.flutter.dev/ui/accessibility/accessibility-testing)

### Responsive Behavior

The app is mobile-first. It includes web support in the Flutter scaffold, but many screens are not obviously optimized for tablets/desktop/web widths. Review large-screen layouts for:

- Bottom navigation behavior
- Feed column width
- Product grid density
- Dialog widths
- Text scaling and overflow

## Database Schema Review

### Local SQL Files

Local `supabase/` contains:

- `table_policies.sql`: RLS policies for pets, profiles, posts, post_likes, comments, match_requests, chat_threads, messages
- `storage_policies.sql`: storage bucket policies plus local `orders` table creation
- `follows_table.sql`: follows table and policies
- `add_breeding_column.sql`: adds `is_breeding_listed`

These are policy/setup scripts, not a full migration history. There is no `supabase/config.toml`, no timestamped migrations, and no generated typed client.

### Confirmed Remote Schema

Confirmed through Supabase MCP `list_tables` against project `foubokcqaxyqgjhtgzsx`.

Tables:

- `profiles`: user profile rows linked to `auth.users`
- `pets`: owned pets with profile image, images array, `is_public_owner`, `is_breeding_listed`, `is_verified`
- `posts`: pet posts
- `post_likes`: composite PK (`post_id`, `pet_id`)
- `comments`: pet-authored comments on posts
- `match_requests`: sender/receiver pet, status `pending|matched|rejected`
- `chat_threads`: two pet participants, timestamps
- `messages`: thread messages, sender pet, read state, message type/media/edit/delivery metadata
- `products`: marketplace products with vendor, stock, rating, tags, bestseller
- `orders`: order summary with JSONB items, total, status, timestamps
- `order_items`: normalized order lines, currently unused by Flutter checkout
- `pet_listings`: richer listing table, currently unused by Flutter discovery implementation
- `matches`: accepted match records, currently not directly consumed by Flutter UI
- `notifications`: user notifications

All listed public tables have RLS enabled.

### Schema Drift

Important drift between local SQL and remote schema:

- Remote has `matches`, `pet_listings`, `order_items`, message metadata columns, notification policies, and triggers not represented in local SQL files.
- Local `storage_policies.sql` creates `orders` with FK to `auth.users`, but remote `orders.user_id` references `profiles.id`.
- Flutter checkout writes JSONB `orders.items`; remote also has `order_items`, currently unused.
- Flutter discovery uses `pets.is_breeding_listed`; remote also has richer `pet_listings` table with status and preferences.
- Local policies do not fully document remote duplicate policies/triggers.

Recommendation: convert schema management to proper Supabase migrations and generate a complete baseline migration from the current remote schema, then apply future changes through migrations.

### Triggers and Functions

Remote triggers include:

- `set_chat_threads_updated_at`
- `on_match_request_accepted`
- `trg_match_accepted_notifications`
- `trg_match_accepted_side_effects`
- `trg_notify_match_accepted`
- `set_matches_updated_at`
- `trg_notify_new_message`
- `trg_notify_on_new_message`
- `set_orders_updated_at`
- `trg_notify_order_status_change`
- `set_pet_listings_updated_at`

Risk:

- There are duplicate-looking triggers for match accepted and new message notifications. This can create duplicate matches, duplicate chat side effects, or duplicate notifications unless the functions are idempotent.

Recommendation:

- Inspect function definitions.
- Keep one trigger per side effect.
- Add unique constraints/idempotency where required, e.g. one chat thread per unordered pet pair.

### Supabase Advisors

Security warnings:

- Public buckets `avatars`, `pet-images`, and `post-media` allow broad object listing.
- Leaked password protection is disabled.

Performance warnings:

- Many unused indexes, likely because the app has little data/traffic.
- Multiple permissive SELECT policies on `pet_listings` and `products`.

Do not remove indexes solely because of low-traffic advisor output. Revisit after realistic load and query analysis.

## Actors and User Stories

### Actors

Based on implemented code:

- Visitor: unauthenticated user, can only see login/register.
- Pet owner: authenticated user who creates pets, posts, likes, comments, follows, matches, chats, and shops.
- Pet persona: user's active pet, used as actor for likes, comments, match requests, and messages.
- Product vendor/seller: implied by `products.vendor_id` and vendor RLS, but no seller UI exists.
- Admin/operator: implied by product/order/status management needs and DB setup, but no admin UI exists.

### Current User Stories

Implemented or mostly implemented:

- As a visitor, I can register with email/password.
- As a visitor, I can log in with email/password.
- As a user, I can request a password reset email.
- As a user, I can log out.
- As a user, I can create a pet profile.
- As a user, I can switch or view my active pet.
- As a pet owner, I can create posts for my pet with media.
- As a pet owner, I can browse posts.
- As a pet owner, I can like and comment on posts as my active pet.
- As a pet owner, I can list a pet for discovery/matching.
- As a pet owner, I can browse listed pets, filter/search, and send like requests.
- As a pet owner, I can accept/decline match requests.
- As a pet owner, I can open chat threads and send text messages.
- As a user, I can receive/view notifications.
- As a user, I can browse marketplace products and product details.
- As a user, I can add products to an in-memory cart.
- As a user, I can place a basic order and view order history.
- As a user, I can view liked/sent pet requests.
- As a user, I can open settings and external terms/privacy/support links.

Partially implemented:

- As a user, I can sign in with Google/Apple: buttons only, no auth flow.
- As a user, I can attach media in chat: button only.
- As a seller, I can manage products: DB policy implies it, but no UI.
- As an admin/operator, I can manage order status/products/users: no UI.
- As a user, I can recover password through a complete deep-link flow: reset email exists, callback handling is absent.

Missing:

- Email verification flow
- Account deletion/data export
- Payments
- Shipping/address management
- Push notifications
- Moderation/reporting/blocking
- Privacy controls beyond basic pet/profile fields
- Public visitor browsing
- Admin/seller console
- Localization

## Functionality and Feature Analysis

### Feed

Strengths:

- Fetches posts with pet, likes, and comments joins.
- Realtime likes/comments.
- Optimistic like updates.
- Post detail route exists.

Risks:

- Feed fetches 50 posts without pagination.
- Comment text validation/length limits are unclear.
- Realtime subscriptions may run even before auth has settled.
- Public feed is available to authenticated users only.

### Pets and Profiles

Strengths:

- User can create pets.
- Active pet concept is central and reused.
- Profile screen is feature-rich.

Risks:

- No pet deletion UI found in core review.
- Pet profile code is large and mixes responsibilities.
- Image upload policy is too broad.
- `PetModel.fromJson` assumes non-null required fields.

### Discovery and Matching

Strengths:

- Discovery filters by listed pets not owned by current user.
- Match requests are represented and statused.
- Accepting a request triggers chat refresh.

Risks:

- Repository comment says it excludes already-requested pets, but implementation only excludes same owner and filters `is_breeding_listed`.
- Sender may be able to update request status through RLS.
- Duplicate remote match triggers may create repeated side effects.
- App has both `is_breeding_listed` and remote `pet_listings`; product model is split.

### Chat

Strengths:

- Thread list, message list, send message, mark read, and Realtime subscription exist.

Risks:

- Attachment support is a visible placeholder.
- `threadMessagesProvider` is intentionally not auto-disposed, so old threads/subscriptions should be tested carefully.
- Chat creation may not require an accepted match at DB level.
- Duplicate message notification triggers exist remotely.

### Marketplace and Orders

Strengths:

- Products, product details, cart, checkout, order history exist.
- UI has empty/loading/error states.

Risks:

- Cart is ephemeral only.
- Checkout trusts client prices and totals.
- No payment/address/shipping/tax/stock reservation.
- `order_items` exists remotely but checkout writes JSONB `orders.items`.
- Seller/vendor/admin flows are not implemented.

### Notifications

Strengths:

- Notifications are user-scoped by RLS.
- Realtime notification inserts are subscribed.
- Mark read/all read exists.

Risks:

- Client insert policy exists for own notifications.
- Duplicate triggers may create duplicates.
- Push notifications are absent.

### Build and Deploy

Strengths:

- iOS build workflow exists.
- Flutter analyze passes.

Risks:

- CI does not run analyze/test as a normal PR gate.
- iOS workflow defaults to Debug and can create unsigned IPA artifacts.
- Android release signing is debug.
- Android release manifest likely lacks internet permission.
- Platform package names and app display names are default.
- Web metadata is default.

## Issues by Severity

### Critical

1. No automated tests.
  - Impact: high regression risk across auth, RLS-dependent data, chat, matching, and checkout.
  - Fix: add `test/`, unit/provider tests, widget tests, CI gates.
2. Android release networking/signing is not production-ready.
  - Evidence: `android/app/src/main/AndroidManifest.xml` lacks `INTERNET`; `build.gradle.kts` uses debug signing for release and default application ID.
  - Fix: add main manifest internet permission, production package ID, release signing config, and release build verification.
3. Storage RLS policies allow broad update/delete/list behavior.
  - Impact: users may overwrite/delete other users' media or enumerate bucket contents.
  - Fix: path-scope policies to owner IDs and remove broad listing policies.
4. Checkout trusts client totals and prices.
  - Impact: financial/inventory integrity risk.
  - Fix: use server-side RPC/Edge Function to compute orders from product IDs and quantities.

### High

1. Hardcoded Supabase URL and anon key.
  - Fix: rotate current key and use build-time config.
2. Schema drift between local SQL and remote DB.
  - Fix: create baseline migrations, document triggers/functions, generate types.
3. Match/chat authorization needs stricter DB rules.
  - Fix: ensure only receivers can accept requests; enforce chat creation only for matched pets or clearly allow open messaging.
4. Duplicate remote triggers for match accepted and new messages.
  - Fix: remove duplicates after inspecting functions and constraints.
5. iOS image picker permissions are missing.
  - Fix: add camera/photo library usage descriptions.
6. Visible unfinished UI for Google/Apple auth and chat attachments.
  - Fix: implement or hide until supported.

### Medium

1. No post-login redirect to original deep link.
2. Product/app branding is inconsistent across UI and platform metadata.
3. Error handling exposes raw backend details in some UI paths.
4. Logging may leak PII or internal errors in release.
5. Manual JSON parsing is fragile and untested.
6. Feed and marketplace lack pagination/infinite loading.
7. Cart is not persisted.
8. No localization.
9. No accessibility tests or screen-reader pass.
10. No README setup instructions for Supabase, build flags, platform permissions, or CI.

### Low

1. Several direct dependencies need minor/major upgrades.
2. Some remote unused-index advisor warnings should be revisited after real usage.
3. Product URL/share URLs point to `petsphere.app` but route hosting/deep linking is not configured.
4. Default web metadata and mobile labels remain.

## Recommended Implementation Plan

### Phase 0: Stabilize and Document

- Create `README.md` setup instructions:
  - Flutter/Dart version
  - Supabase project setup
  - Required `--dart-define` values
  - Platform permission requirements
  - Analyze/test/build commands
- Add `test/` with a smoke widget test so `flutter test` no longer fails due to missing directory.
- Add GitHub Actions for:
  - `flutter pub get`
  - `flutter analyze`
  - `flutter test`
- Update brand metadata in Android, iOS, web, and README.

### Phase 1: Production Security Fixes

- Move Supabase config to build-time environment:
  - `SUPABASE_URL`
  - `SUPABASE_ANON_KEY` or publishable key
- Rotate the committed anon JWT.
- Add Android release `INTERNET` permission.
- Add iOS `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription`.
- Replace debug Android release signing.
- Tighten Storage policies:
  - owner-scoped paths
  - no broad public object listing
  - no arbitrary authenticated update/delete
- Enable Supabase leaked password protection.

### Phase 2: Schema and Authorization

- Pull/baseline remote schema into proper Supabase migrations.
- Document or remove unused remote concepts: `pet_listings`, `matches`, `order_items`.
- Inspect and deduplicate triggers/functions.
- Fix match request RLS so only the receiver can accept/decline if that is the product rule.
- Enforce chat creation rules in DB.
- Add unique constraints for unordered chat pairs and match pairs where needed.
- Generate typed schema artifacts or introduce typed repository DTO validation.

### Phase 3: Feature Completion

- Implement or hide Google/Apple sign-in.
- Implement password reset callback/deep link flow.
- Implement chat attachments or remove the attachment button.
- Add a real onboarding flow after registration: create first pet, add photo, choose privacy/listing.
- Add server-side checkout order creation and inventory validation.
- Add seller/admin/order management flows or remove implied seller language.
- Persist cart locally or remotely.

### Phase 4: Quality, UX, and Performance

- Add unit tests for controllers/notifiers.
- Add widget tests for auth forms, empty/error/loading states, feed cards, cart, and discovery.
- Add accessibility guideline tests from Flutter docs.
- Add pagination for feed and marketplace.
- Standardize cached image usage.
- Replace raw error strings with user-safe failure types.
- Add localization (`flutter gen-l10n`) if multi-region use is planned.
- Add structured logging/redaction.

## Limitations

- The audit did not run full Android/iOS/web release builds.
- The audit did not inspect Supabase function bodies because only trigger names/statements were queried.
- The audit did not manually test the UI in a browser/device session.
- Dependency health was based on `flutter pub outdated` and official package docs, not a full package source audit.
- Remote Supabase data row counts and advisor outputs reflect the current project state at audit time and may change.

## Verification Performed

- Source and config review completed.
- `flutter analyze` passed.
- `flutter test` attempted and failed because `test/` is missing.
- `flutter pub outdated` reviewed.
- Supabase remote schema, policies, triggers, and advisors reviewed through MCP.

