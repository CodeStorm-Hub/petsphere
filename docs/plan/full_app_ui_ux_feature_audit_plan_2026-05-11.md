# PetFolio Full App UI, UX, Architecture, Security, and Feature Remediation Plan

Date: 2026-05-11  
Scope: Flutter app in `lib/`, Supabase-backed data/auth flows, Android emulator UI traversal, runtime logs, user-story docs, and current online best practices.

## Evidence Reviewed

- Source screen inventory from `lib`: 50+ screens across auth, home, discovery/matching, pet profile, social, messaging, notifications, settings, care, health, marketplace, services, and community.
- Router inventory from `lib/app/router.dart`: authenticated shell tabs plus standalone routes for post/story creation, add pet, pet care, notifications, liked pets, pet/user profiles, messages/chat, product/cart/orders, settings, search, followers/following, achievements, health, services, and community routes.
- User stories and requirements:
  - `docs/USER_STORIES_platform_social_matching_commerce_care.md`
  - `docs/02_FEATURES_REQUIREMENTS_BEST_PRACTICES.md`
  - `docs/01_CODEBASE_ARCHITECTURE_REVIEW.md`
- Emulator traversal with real signed-in session:
  - `docs/logs/ux-audit-2026-05-11/`
  - `docs/logs/ux-audit-2026-05-11-pass2/`
  - `docs/logs/ux-audit-2026-05-11-pass3/`
- Runtime logcat:
  - `docs/logs/ux-audit-2026-05-11/runtime-logcat.txt`
  - `docs/logs/ux-audit-2026-05-11-pass2/runtime-logcat-pass2.txt`
- Current web research:
  - Flutter architecture guide: https://docs.flutter.dev/app-architecture/guide
  - Flutter adaptive design guide: https://docs.flutter.dev/ui/adaptive-responsive/general
  - Flutter adaptive best practices: https://docs.flutter.dev/ui/adaptive-responsive/best-practices
  - Flutter accessibility guide: https://docs.flutter.dev/ui/accessibility
  - Supabase RLS guide: https://supabase.com/docs/guides/database/postgres/row-level-security
  - Supabase Data API hardening guide: https://supabase.com/docs/guides/api/securing-your-api
  - Supabase MFA guide: https://supabase.com/docs/guides/auth/auth-mfa
  - Supabase changelog: https://supabase.com/changelog
  - Firebase Cloud Messaging Flutter setup: https://firebase.google.com/docs/cloud-messaging/flutter/get-started
  - Firebase FCM token freshness guidance: https://firebase.google.com/docs/cloud-messaging/manage-tokens
  - Material 3 adaptive layout guidance: https://m3.material.io/foundations/layout/applying-layout/window-size-classes
  - Apple HIG Activity Rings guidance: https://developer.apple.com/design/human-interface-guidelines/activity-rings

## 2026-05-11 Codex Follow-Up Evidence

Evidence folder:

- `docs/logs/full-ui-audit-2026-05-11-codex/`

Actions performed:

- Loaded the requested Flutter UI/UX, adaptive UI, Dart code review, responsive layout, architecture, frontend-design, frontend app builder, Supabase, Firebase, and Android emulator QA workflows.
- Ran `flutter analyze`: no issues found.
- Used Firebase MCP against active project `petfolio-197e6`.
- Launched the app on connected emulator `emulator-5554` (`1080x2424`, density `420`).
- Logged in with the supplied account after adb input correction for the `@` character.
- Accepted the Android notification permission prompt.
- Traversed Home, Discovery, Marketplace, Profile, and Pet Care; scrolled Pet Care to the end and captured UI XML/screenshot evidence.
- Rechecked runtime logs after traversal.
- Corrected app display branding in code:
  - Android label: `PetFolio`
  - iOS `CFBundleDisplayName`: `PetFolio`
  - iOS `CFBundleName`: `PetFolio`
  - In-app `BrandLogo(withText: true)` semantics: `PetFolio` instead of `Pet Folio`
  - Android splash comments from `PetSphere` to `PetFolio`

Fresh runtime findings:

- The notification permission dialog still showed `Allow PetSphere to send you notifications?` before the branding fix. This was caused by `android:label="PetSphere"` and is now corrected in source.
- Firebase MCP reports Android app display name `pet_dating_app (android)` and namespace `com.example.pet_dating_app`. This should be migrated deliberately later because it affects Firebase app registration, `google-services.json`, Kotlin package paths, and potentially released app identity.
- Home exposes: `Pet Folio`, Search, New Post, Notifications, Messages, greeting, story tray, Home, Discover, Pet Care, Marketplace, Profile.
- Discovery exposes: `Breeding Discovery`, Liked Pets, New Listing, Discover/Nearby/My Listings tabs, Try Again, and still shows `Failed to load matches.`
- Marketplace exposes: Good Morning Pet Parent, Order History, cart/action button, Search Products, promo banner, category chips, and `No items found in this category`.
- Profile exposes pet profile content, not owner profile content: Montu, species/breed, hardcoded `2.4k Fans`, bio, Edit Profile, New Post, Photos/Awards/Health tabs.
- Pet Care top exposes: Back, Pet Care, active pet chip, Care Diary/Health/Feeding tabs, setup prompt, Today's Overview, Edit Goals, streak, checklist tasks.
- Pet Care end exposes the full resource grid: Vet Booking, Emergency, Nutrition, Expenses, Growth, Insurance, Training, Adoption, Places, Events, Medical, Sitters, Timeline, Identifier, Knowledge, Reviews, Groups, Lost/Found, Memorial.
- Runtime logs still reproduce:
  - `match_requests.rejected_at does not exist`
  - `pet_care_gamification.best_streak_days` missing from schema cache
  - `pet_medication_doses.scheduled_for does not exist`
- Attempting a top-right profile action opened the Android share sheet with text `Check out Montu on PetFolio! Persian looking for friends.`, confirming profile share is wired, but settings was not discoverable from the current profile UI hierarchy.

Static code mapping from `lib`:

- App code references these Supabase tables: `adoption_applications`, `adoption_listings`, `care_badge_definitions`, `chat_threads`, `comments`, `community_group_members`, `community_groups`, `follows`, `gear_reviews`, `knowledge_base_articles`, `lost_and_found_reports`, `match_requests`, `messages`, `notifications`, `orders`, `pet_activity_logs`, `pet_allergies`, `pet_breed_scans`, `pet_care_badge_unlocks`, `pet_care_gamification`, `pet_care_logs`, `pet_care_onboarding`, `pet_dental_logs`, `pet_event_rsvps`, `pet_events`, `pet_expenses`, `pet_friendly_places`, `pet_insurance_claims`, `pet_medication_doses`, `pet_medications`, `pet_memorial_entries`, `pet_nutrition_logs`, `pet_parasite_prevention`, `pet_sitter_jobs`, `pet_symptoms`, `pet_training_progress`, `pet_vaccinations`, `pet_vet_appointments`, `pet_weight_logs`, `pets`, `post_likes`, `posts`, `products`, `profiles`, `stories`, `user_fcm_tokens`, `vaccination_schedules`.
- Storage buckets referenced by app code: `avatars`, `pet-images`, `post-media`, `product-images`.
- Firebase/notification code path:
  - `PushNotificationService` initializes Firebase, registers background and opened-message handlers, requests notification permission, stores FCM tokens, listens to token refresh, and deletes token on logout.
  - `push-fcm` Edge Function exists under `supabase/functions/push-fcm`.
  - Firebase best practice gap: token rows should include freshness timestamps and server-side stale-token pruning. Firebase recommends storing registration tokens with timestamps and periodically refreshing/removing stale tokens.

Source-level frontend review deltas:

- `flutter analyze` is clean, but static action scan still finds visible no-op or placeholder actions in shared async retry, search share actions, chat attachments/voice, post detail comments/share, pet social timeline, memorial, community groups, adoption, lost/found, training, nutrition, expenses, events, article share/bookmark, insurance claims, places map/detail, sitters, emergency care, growth charts, and health records.
- Architecture has a feature-first shape with `data`, `presentation`, models, controllers, and repositories, which mostly aligns with Flutter's official separation-of-concerns guidance. The main issue is scale: very large screens such as `health_tab.dart` and `pet_care_screen.dart` carry too many concerns and should be split into feature widgets and route-level subflows.
- Adaptive shell exists (`PetFolioNavBar`, `PetFolioNavRail`), but the primary product IA still needs a clearer owner/pet identity model and more large-screen two-pane layouts.

## Current Product Reality

The app has a broad feature surface, but the UI currently behaves more like a pet profile app with partial social, care, marketplace, and services modules than a complete pet-owner platform.

The most important product mismatch is identity hierarchy. The user stories describe a Pet Owner who can own multiple Pets. The current main profile UI is a pet profile for one active pet, not an owner profile with pet management. The bottom tab says "Profile, Your profile and pets", but the visited UI shows Montu's pet profile, hardcoded fans, pet tabs, and no clear owner account profile, family/member context, or complete pet list management.

## High-Priority Findings

### P0 - Runtime Data Contract Breakage

Observed in logcat:

- `pet_medication_doses.scheduled_for does not exist`
- `pet_care_gamification.best_streak_days` missing from schema cache
- `pet_care_badge_unlocks.user_id does not exist`
- `match_requests.rejected_at does not exist`
- Discovery screen displays `Failed to load matches.`

Impact:

- Discovery/matching is unusable for the tested account.
- Health and care features are reading columns that are not present in the live schema.
- User trust is harmed because key tabs fail with generic errors.

Plan:

1. Freeze new UI work until app code and Supabase migrations are reconciled.
2. Create a schema contract checklist from repositories/controllers that call Supabase.
3. Add missing migrations or update repository queries to the current schema.
4. Add integration tests that run the same queries used by discovery, medication, gamification, and badge unlocks.
5. Add a startup schema-health check in debug builds that warns when required tables/columns are missing.

### P0 - Supabase RLS Helper Bug And Security Definer Placement

`supabase/migrations/20260509100000_comprehensive_rls_schema_fix.sql` recreates `public.user_owns_pet(pet_id uuid, user_id uuid)` with:

```sql
AND user_id = user_id
```

Impact:

- The function does not compare the pet owner's column to the function argument.
- It can make ownership checks wrong, and policies using it become unreliable.
- The function is a `SECURITY DEFINER` helper in the exposed `public` schema, which Supabase guidance warns against for privileged functions.

Plan:

1. Replace the helper with a correctly named argument and qualified column comparison.
2. Move privileged helper functions to a private schema such as `private` or `app_private`.
3. Use an explicit `SET search_path = ''` and fully qualified table names in security definer functions.
4. Revoke broad execute access and grant only the roles that need it.
5. Add RLS tests for owner, non-owner, matched pet participant, anonymous user, and service role paths.
6. Run Supabase advisors after the migration.

### P0 - Authentication Is Incomplete For A Production Pet Platform

Observed:

- Email/password login and registration exist.
- Google and Apple buttons show "coming soon".
- MFA user stories are not represented in Settings or login challenge flows.
- Password reset exists in backend docs/code but is not fully represented as a complete route-driven user journey.
- Account deletion rollback is still marked unfinished in auth repository.

Plan:

1. Add email verification and resend verification screens.
2. Add password reset request, reset deep-link callback, and change-password screens.
3. Add OAuth sign-in only when configured end to end, otherwise remove visible fake buttons.
4. Add optional MFA enrollment, factor management, and MFA challenge screens. Supabase MFA requires enrollment, unenroll, challenge, and enforcement flows.
5. Add session/device management in Settings.
6. Implement server-side self-delete or account-deletion Edge Function with data retention rules.

## UI Traversal Findings

### Home

Observed:

- Home loads with "Pet Folio" branding, greeting, stories, and one post by Montu.
- Accessibility tree exposes app-bar buttons and bottom nav labels.
- Scroll did not reveal additional content for the tested dataset.

Issues:

- Brand mismatch: app label is `PetSphere`, UI title is `Pet Folio`, package is `com.example.pet_dating_app`.
- Greeting says "Pet" rather than the owner name.
- The empty or light dataset state is not guided enough for a first real user.

Plan:

1. Standardize brand name, logo, package naming, splash, launcher icon, app label, and in-app copy.
2. Add owner-aware greeting and active pet context.
3. Add feed empty states that guide the owner to add pets, follow pets, join groups, or create a first post.

### Discovery And Matching

Observed:

- Screen title: `Breeding Discovery`.
- Tabs: Discover, Nearby, My Listings.
- Actions: Liked Pets, New Listing.
- All tabs in the tested state show `Failed to load matches.`

Issues:

- Database schema drift blocks core matching.
- "Breeding Discovery" is too narrow and may be inappropriate as the primary discovery label if the product includes playdates, adoption, social following, and general pet discovery.
- No visible safety path: report, block, consent status, verification, or breed/health disclaimers.

Plan:

1. Fix `match_requests.rejected_at` contract.
2. Split discovery intent into modes: Social, Playdate, Breeding, Adoption, Nearby.
3. Add filters for species, breed, distance, age, gender, vaccination/health verification, and intent.
4. Add clear consent status and mutual-match gating before chat.
5. Add report/block and "not interested" explanations.

### Pet Care

Observed:

- Pet Care has duplicated `Montu` chips.
- Tabs: Care Diary, Health, Feeding.
- Care Diary has checklist and progress.
- Health tab has weight, medications, appointments, and time range chips.
- Feeding tab has meals, treats, water intake, and nutrition goal UI.

Issues:

- Duplicate active pet chips are confusing.
- Some controls are visible but route to no-op or unverified backend paths.
- Runtime errors show health/care schema drift.
- Care setup appears incomplete but not clearly tied to a step-by-step setup flow.

Plan:

1. Replace duplicate chips with one reusable `ActivePetSwitcher`.
2. Add "Manage pets" entry point from the switcher.
3. Make onboarding status explicit: complete setup, update goals, edit reminders.
4. Fix medication, gamification, and badge schema contracts.
5. Add reminder permission and notification preference integration.

### Marketplace

Observed:

- Marketplace has search, category chips, order history action, promo banner, and empty state `No items found in this category`.
- Cart/order icon hit targets were unclear in automated traversal.

Issues:

- No product inventory was visible for the tested account.
- Empty state is generic and does not explain whether the issue is inventory, filter, network, region, or seller availability.
- Commerce user stories require product detail reviews, shipping, cart variants, promos, checkout, order tracking, returns, seller onboarding, merchant listings, fulfillment, and admin catalog workflows. The current UI does not expose that complete journey.

Plan:

1. Add seeded production-like product data for development/test environments.
2. Add strong empty states with reset filters and browse categories actions.
3. Complete product search and filters.
4. Complete Product Detail Page: gallery, price, variants, reviews, stock, delivery estimate, seller, return policy.
5. Complete cart: variants, quantities, promo codes, taxes, shipping, live totals.
6. Complete checkout through a server-side payment intent Edge Function.
7. Add order detail, tracking, cancellation, returns, disputes, and support screens.
8. Add seller dashboard, product listing CRUD, inventory, fulfillment, and payouts.

### Profile

Observed:

- Bottom `Profile` opens a pet profile for Montu.
- Header shows `Montu`, `Cat - Persian`, `2.4k Fans`, bio, age, Edit Profile, New Post.
- Tabs: Photos, Awards, Health.
- No owner profile was visible.

Issues:

- Owner profile is missing as a first-class screen.
- Multi-pet ownership is not reflected in the primary profile UI.
- `2.4k Fans` is hardcoded in source and visible in the UI.
- Pet profile and account profile are mixed.

Plan:

1. Add `OwnerProfileScreen` as the bottom Profile root.
2. Add owner header: avatar, display name, location, bio, follower/following counts, verification, privacy state.
3. Add "My Pets" section with all owned pets, active pet selection, add pet, edit pet, archive/deceased/memorial states.
4. Move pet-specific tabs into `PetProfileScreen`.
5. Replace hardcoded fan count with real follower count query.
6. Add profile completeness prompts for owner and each pet.

### Settings

Observed:

- Settings contains only Dark mode, signed-in email, and Sign out.

Issues:

- Settings is incomplete for the user stories and for a production social/commerce/care app.

Plan:

Add settings sections:

- Account: edit owner profile, email, phone, password, linked providers.
- Security: MFA, active sessions, trusted devices.
- Pets: manage pets, active pet, pet visibility, health sharing permissions.
- Notifications: push, email, in-app, reminders, digest frequency, marketing opt-in.
- Privacy: profile visibility, location sharing, search visibility, blocked users.
- Safety: report history, moderation appeals, content filters.
- Commerce: shipping addresses, payment methods, order preferences.
- Care data: export records, share with vet, retention, delete data.
- App: theme, language, accessibility preferences, units, cache.
- Legal: terms, privacy policy, licenses.

## Static Screen Inventory And Status

### Auth

- `splash_screen.dart`: Exists.
- `login_screen.dart`: Exists, but OAuth buttons are fake/coming soon.
- `registration_screen.dart`: Exists, but email verification/MFA/onboarding are incomplete.

Missing:

- Email verification pending screen.
- Resend verification screen.
- Forgot password screen.
- Password reset callback/update password screen.
- MFA enroll/challenge/manage factors screens.
- Progressive onboarding and permissions screens.

### Main Shell

- `home_screen.dart`: Exists.
- `discovery_screen.dart`: Exists, blocked by schema error.
- `marketplace_screen.dart`: Exists, no inventory in tested state.
- `pet_care_screen.dart`: Exists, partial.
- `pet_profile_screen.dart`: Exists, currently used as bottom Profile root.
- `settings_screen.dart`: Exists, minimal.

Missing:

- Owner profile root screen.
- Manage pets screen.
- Responsive large-screen shell with NavigationRail.
- Route-level smoke test harness for all shell and standalone routes.

### Social And Messaging

Exists:

- Create post/story, timeline, post detail, story viewer, pet/user visitor profiles, followers, messages, chat.

Gaps:

- Several share/more/action buttons are no-op.
- Chat attachments and voice messages show "coming soon".
- Report/block/safety flows are missing or not visible.
- Moderation queue user/admin UI is missing.

### Care And Health

Exists:

- Pet care, onboarding, expense tracker, nutrition planner, training, gamification, health record, growth chart, export, emergency care, vet booking.

Gaps:

- Many health/service action buttons are no-op.
- Medication/gamification schema contract is broken.
- Health sharing/privacy with professionals is incomplete.
- Reminders and notification preferences are not end-to-end.

### Marketplace

Exists:

- Marketplace, product detail, cart, order history, gear reviews.

Gaps:

- No visible test inventory.
- Product detail journey was not reachable from empty marketplace state.
- Seller/admin/returns/disputes workflows are missing or not exposed.

### Services And Community

Exists:

- Pet friendly places, events, insurance, sitter dashboard, knowledge base, article detail, breed identifier, lost/found, adoption.

Gaps:

- Many unfinished route comments and no-op actions remain.
- Duplicate lost/found and adoption screens exist under both `features/services` and `features/community`.
- Detail/map/filter/post-job/apply/contact flows are incomplete.

## User Story Traceability

| Epic | Expected | Current UI Status | Fix Priority |
| --- | --- | --- | --- |
| E1 Identity and onboarding | Account, auth, MFA, onboarding, multiple pets | Partial auth, no owner root, no MFA, incomplete settings | P0/P1 |
| E2 Social feed and stories | Feed, create, reactions, comments, follow, moderation | Feed exists, but safety/moderation/no-op gaps remain | P1/P2 |
| E3 Discovery, matching, messaging | Filters, swipe/nearby/listings, mutual match, chat, block/report | Discovery fails from schema drift; safety gaps | P0/P1 |
| E4 Commerce | Search, PDP, cart, checkout, orders, seller, returns | Marketplace shell exists but tested state has no inventory | P1/P2 |
| E5 Care and health | Logs, reminders, vitals, export/share, privacy | Strong UI base, broken schema and incomplete actions | P0/P1 |
| E6 Notifications and integrity | Granular prefs, digests, fraud/safety | Notifications page exists; settings prefs missing | P1 |
| E7 Accessibility and i18n | Screen reader, contrast, text scale, localization | Some semantics exist; no complete checklist/tests | P1/P2 |

## Deep Action And Database Cross-Validation Update

Additional pass date: 2026-05-11  
Evidence folder: `docs/logs/ux-audit-2026-05-11-deep-actions/`

### Tooling Constraints Found

- Supabase CLI is not installed in this workspace, so `supabase db` and `supabase db advisors` could not be run locally.
- The app is linked to project ref `foubokcqaxyqgjhtgzsx` in `supabase/.temp/project-ref`.
- The Android manifest has only a launcher intent filter. There is no deep-link/app-link intent filter, so `adb am start` cannot open `/settings`, `/orders`, `/pet/:id`, or other GoRouter paths directly.
- Several routes require `state.extra` objects, for example `/article_detail`; those cannot be opened by raw URL/path even inside GoRouter without a seeded object.
- UI automation has no stable widget keys/test IDs. A coordinate-based deep action run missed app targets and ended up on Android launcher/calendar surfaces. This is a QA blocker: route traversal needs integration tests with stable keys and an app-only guard.

### Live Supabase REST Checks

Using the app's debug fallback Supabase URL and anon key, direct REST checks reproduced the same schema errors seen in logcat:

| Live REST Check | Result |
| --- | --- |
| `pet_medication_doses?select=id,scheduled_for` | `400`, `column pet_medication_doses.scheduled_for does not exist` |
| `pet_care_gamification?select=pet_id,total_care_points,best_streak_days` | `400`, `column pet_care_gamification.best_streak_days does not exist` |
| `pet_care_badge_unlocks?select=id,user_id` | `400`, `column pet_care_badge_unlocks.user_id does not exist` |
| `match_requests?select=id,rejected_at` | `400`, `column match_requests.rejected_at does not exist` |
| `pet_care_gamification?select=pet_id,total_care_points,current_streak` | `200`, confirms the table exists but the app expects at least one wrong/missing column |
| `pet_care_badge_unlocks?select=pet_id,badge_slug,unlocked_at` | `200`, confirms the table exists but the app expects `user_id` that is not in live schema |
| `products?select=id,name,price` | `200 []`, anon can query shape but receives no rows |
| `pets?select=id,name,user_id` | `200 []`, anon can query shape but receives no rows |

Conclusion:

- The runtime errors are not only client-side parsing mistakes. The live Supabase schema does not match the repository queries.
- The repo contains standalone SQL files such as `supabase/health_tab_v2.sql`, `supabase/pet_care_tables.sql`, and `supabase/pet_care_gamification_onboarding_v1.sql` that define important tables/policies, but many are not in `supabase/migrations/`. They may not have been applied consistently to the linked project.
- `supabase/migrations/20260503160000_match_requests_rejected_at.sql` exists locally, but the live REST API still reports `match_requests.rejected_at` missing. Either the migration was not applied to the active project, the app is pointing at a different database than expected, or a later migration/schema reset removed it.

### CRUD Coverage Cross-Validation

Static repository scan found 47 Supabase tables used by app code. The app has wide CRUD intent, but database/migration coverage is uneven.

High-risk gaps where app repositories use tables but migrations/RLS/policies are not consistently represented in `supabase/migrations/`:

| Feature Area | Tables Used By App | App CRUD Intent | Database Risk |
| --- | --- | --- | --- |
| Adoption | `adoption_listings`, `adoption_applications` | Listings read/create; applications create/update | No migration/RLS evidence in migrations; UI create/apply flow needs DB verification |
| Community groups | `community_groups`, `community_group_members` | Create/read/update/delete/toggle membership | No migration/RLS evidence in migrations |
| Lost and found | `lost_and_found_reports` | Create/read/update/delete | No migration/RLS evidence in migrations |
| Knowledge base | `knowledge_base_articles` | Read | No migration/RLS evidence in migrations |
| Gear reviews | `gear_reviews` | Create/read | No migration/RLS evidence in migrations |
| Events | `pet_events`, `pet_event_rsvps` | Events read/create/update; RSVP upsert | No migration/RLS evidence in migrations |
| Expenses | `pet_expenses` | Create/read/delete | No migration/RLS evidence in migrations |
| Insurance | `pet_insurance_claims` | Create/read | No migration/RLS evidence in migrations |
| Memorial | `pet_memorial_entries` | Create/read | No migration/RLS evidence in migrations |
| Nutrition | `pet_nutrition_logs` | Create/read/delete | No migration/RLS evidence in migrations |
| Sitter jobs | `pet_sitter_jobs` | Create/read | No migration/RLS evidence in migrations |
| Training | `pet_training_progress` | Create/read/update/delete | No migration/RLS evidence in migrations |
| Breed scans | `pet_breed_scans` | Create/read | No migration/RLS evidence in migrations |
| Notifications | `notifications` | Create/read/update | Table appears in docs/history but migration/RLS evidence is incomplete in current migration folder |
| Gamification | `pet_care_gamification`, `care_badge_definitions`, `pet_care_badge_unlocks` | Create/read/update | Live schema mismatch; standalone SQL/docs differ from app queries |

Important CRUD incompleteness:

- Pet profiles support create/read/update but no pet delete/archive operation exists in `PetRepository`; storage photo delete exists.
- Owner profiles support create/read/update but no self-delete/account deletion flow exists client-side; auth repository explicitly notes this requires a server-side function.
- Marketplace products are read-only in the app repository; seller/admin product create/update/delete is not present.
- Orders support create/read and limited update policy, but no full buyer cancellation/return/dispute CRUD exists in UI.
- Chat supports threads and messages create/read/update in repositories, but attachment/voice actions are fake or no-op.
- Most service/community modules have repository CRUD but incomplete UI action wiring and uncertain database migrations.

### Debug Log Errors From Action Pass

Repeated app-owned errors:

- `[MedicationNotifier] Failed to load health data`
- `PostgrestException(message: column pet_medication_doses.scheduled_for does not exist, code: 42703)`
- `Failed to sync gamification`
- `PostgrestException(message: Could not find the 'best_streak_days' column of 'pet_care_gamification' in the schema cache, code: PGRST204/42703)`
- Earlier stable pass also logged `match_requests.rejected_at does not exist`.

Non-app/device noise observed:

- Android XR package flag errors from emulator.
- Google Calendar/launcher logs after the coordinate automation left the app.
- Glide generated module warning.
- SVG loader warnings for unsupported SVG elements.

Action:

1. Filter log review by app PID/package in future runs.
2. Add an app foreground assertion before every automated tap.
3. Add `Key`/semantic identifiers for all primary route controls.
4. Build route smoke tests with `integration_test` instead of coordinate-only traversal.

### Required Navigation Test Harness

To genuinely visit every screen, tab, scroll state, and action without brittle coordinates, add a test-only route harness:

1. Add `integration_test/route_smoke_test.dart`.
2. Seed or fetch test IDs for one pet, one user, one post, one product, one chat thread, and one article.
3. For every route in `AppRoutes`, pump or navigate with GoRouter and assert the screen landmark.
4. For routes requiring `state.extra`, pass seeded model objects.
5. For CRUD screens, perform reversible operations with test-prefixed data:
   - create/update/delete pet draft or archive test pet
   - create/update/delete post
   - create/delete comment
   - like/unlike post
   - follow/unfollow pet/user
   - create/update/delete care log
   - create/update/delete weight log
   - create/update/delete appointment
   - create/delete expense
   - create/delete lost-found report
   - create/delete adoption application
   - create/delete community group membership
   - create/delete order in staging only
6. Capture logcat per route and fail on `PostgrestException`, schema cache errors, `RenderFlex overflowed`, and uncaught Dart exceptions.

## Fresh-Start Android QA Update

Additional pass date: 2026-05-11  
Evidence folders:

- `docs/logs/fresh-start-qa-2026-05-11/`
- `docs/logs/fresh-start-qa-2026-05-11-normal-debug/`

### Fresh Install/Data Reset Result

Steps performed:

1. Cleared app logs with `adb logcat -c`.
2. Cleared package data with `adb shell pm clear com.example.pet_dating_app`.
3. Rebuilt a normal debug APK from `lib/main.dart`.
4. Installed with `adb install -r`.
5. Launched from the Android launcher intent.
6. Captured UI hierarchy, screenshot, and app-PID logcat.

Result:

- The normal debug app starts from clean data and lands on the Login screen.
- Visible fresh-start UI:
  - `Pet Folio`
  - `Welcome Back`
  - Email field
  - Password field
  - `Forgot Password?`
  - `Sign In`
  - `Google`
  - `Apple`
  - `Register`
- Startup app logs show Supabase initialization succeeded.
- No app-owned `PostgrestException`, `RenderFlex overflowed`, uncaught Dart exception, or Flutter framework error appeared during the unauthenticated fresh-start action pass.

### Fresh-Start Actions Tested

| Action | Result |
| --- | --- |
| Empty `Sign In` | Inline validation appears: `Enter email`, `Password must be at least 6 characters` |
| `Forgot Password?` | Opens `Reset Password` dialog with email field, `Cancel`, and `Send Reset Link` |
| `Google` | Shows snackbar: `Google Sign-In coming soon!` |
| `Apple` | Shows snackbar: `Apple Sign-In coming soon!` |
| `Register` | Opens `Create Account` screen with full name, email, password, confirm password, terms checkbox, terms/privacy links, and create account button |
| Register screen scroll | Screen is scrollable and content remains present |

Fresh-start UX issues:

- OAuth buttons are visible as real sign-in choices but only show "coming soon". These should be hidden behind feature flags or implemented end to end.
- Password reset opens a dialog, but the app still needs deep-link recovery handling and a change-password screen.
- Registration has terms/privacy buttons, but the audit did not verify that they open real legal documents; this remains a required action check.
- The app brand still appears as `Pet Folio` while Android label/docs use `PetSphere`.

### Existing Integration Test Finding

`integration_test/petsphere_journey_test.dart` was run from a cleared app-data state with credentials sourced from the existing driver test file. The test command exited with success, but the log shows:

- `[AuthNotifier] Login failed`
- `AuthApiException(message: Invalid login credentials, statusCode: 400, code: invalid_credentials)`

The test still passed because it returns early when login fails and the main shell is not reached. This is a false-positive test gap.

Required fix:

1. If `E2E_EMAIL` and `E2E_PASSWORD` are provided, login failure must fail the test.
2. The test must assert either:
   - logged-in shell is reached after login, or
   - no credentials were supplied and unauthenticated flow is intentionally being tested.
3. Test credentials must not be hardcoded in committed test files.
4. Split tests into:
   - `fresh_start_auth_smoke_test`
   - `authenticated_shell_smoke_test`
   - `route_crud_smoke_test`

## Architecture Remediation Plan

Follow Flutter's recommended separation of concerns: UI layer, data layer, and optional domain/use-case layer. The existing Riverpod/repository shape is a good base, but feature completion requires stricter boundaries.

Target structure per feature:

```text
lib/features/<feature>/
  data/
    models/
    repositories/
    services/
  domain/
    entities/
    use_cases/
  presentation/
    controllers/
    screens/
    widgets/
```

Rules:

1. Screens render state and dispatch intents only.
2. Controllers own UI state and call use cases/repositories.
3. Repositories are the only code that calls Supabase tables/storage/functions.
4. Every Supabase query used by UI has a typed contract test.
5. Shared UI components live under `lib/core/widgets` or feature-local `widgets`.
6. Avoid duplicate screens between community/services. Keep one owner route and move shared widgets out.

## Responsive Redesign Plan

Follow Flutter adaptive guidance:

- Use `MediaQuery.sizeOf(context)` for app-window decisions.
- Use `LayoutBuilder` for component-level constraints.
- Use bottom navigation for widths below 600 logical pixels.
- Use NavigationRail or side navigation for 600+ logical pixels.
- Avoid device-type checks and avoid portrait-only assumptions.

Implementation:

1. Add `AdaptiveScaffold` for shell routes.
2. Add two-pane owner profile layout on tablets: owner summary + selected pet detail.
3. Convert marketplace product grids to `SliverGridDelegateWithMaxCrossAxisExtent`.
4. Constrain feed and forms to readable max widths on large screens.
5. Add golden/screenshot coverage for phone, foldable/tablet, and text scale.

## Accessibility Plan

Flutter's accessibility release checklist calls out active interactions, screen-reader labels, contrast, 48x48 tap targets, undo/error recovery, and large text scale.

Actions:

1. Replace every `onPressed: () {}` with a real action or disabled state with explanation.
2. Remove fake "coming soon" primary actions from production surfaces unless behind feature flags.
3. Audit all icon-only buttons for semantic labels and tooltips.
4. Add TalkBack traversal tests for Home, Discovery, Pet Care, Marketplace, Profile, Settings, Chat, and Checkout.
5. Verify 48x48 minimum tap targets.
6. Verify text scaling at 1.0, 1.3, and 2.0.
7. Add contrast checks for light/dark themes.
8. Add non-swipe alternatives for discovery decisions.
9. Add undo for destructive actions.

## Branding And Design System Plan

Current brand inconsistencies:

- Android label: `PetSphere`
- UI brand: `Pet Folio`
- Package/application ID: `com.example.pet_dating_app`
- Some docs use PetSphere, some UI uses PetFolio.

Plan:

1. Select one brand name. Recommended: `PetSphere`, because docs and Android label already use it and it better supports social, commerce, care, and services.
2. Create a production logo system:
   - app launcher icon
   - splash logo
   - small wordmark
   - monochrome icon
   - adaptive Android icon
3. Define brand tokens:
   - primary, secondary, success, warning, danger, surface, outline
   - typography scale
   - spacing scale
   - radius scale
   - elevation rules
4. Replace ad hoc screen styling with reusable components:
   - `AppHeader`
   - `OwnerAvatar`
   - `PetAvatar`
   - `PetSwitcher`
   - `EmptyState`
   - `ErrorState`
   - `LoadingState`
   - `SectionHeader`
   - `ActionTile`
   - `SettingsSection`
   - `ProductCard`
   - `CareMetricCard`
5. Keep the UI warm and pet-friendly, but operational screens such as settings, checkout, health, and care should be dense, calm, and scannable.

## Missing Screens And Components

Add these screens:

- Owner profile root
- Edit owner profile
- Manage pets
- Pet edit/settings
- Active pet switcher modal
- Profile completeness
- Account security
- MFA enroll/challenge/manage factors
- Email verification
- Forgot/reset password
- Notification preferences
- Privacy and visibility
- Blocked users
- Data export/delete
- Safety/report flow
- Moderation status/appeals
- Discovery filters
- Match details and consent
- Product filters
- Product reviews
- Checkout shipping
- Checkout payment
- Order detail and tracking
- Return/dispute
- Seller dashboard
- Seller listing editor
- Place detail/map
- Event detail/RSVP
- Lost/found create/detail
- Adoption create/detail/application
- Sitter job post/detail/application
- Article saved/bookmark/share
- Vet sharing permissions
- Reminder setup
- Localization/language settings

Add these components:

- Unified empty/error/loading states.
- Route error boundary with retry.
- Offline banner and retry queue.
- Form validation summary.
- Confirmation dialog patterns.
- Reusable privacy badge.
- Reusable verification badge.
- Accessible tab and filter chips.
- Skeleton loading for feed/products/pets.

## Implementation Phases

### Phase 0 - Stabilize Backend And Security

Deliverables:

- Fix RLS helper ownership comparison.
- Move security definer helpers out of exposed public schema or harden them with qualified names and safe search path.
- Fix missing columns or update queries for discovery, medication, gamification, and badge unlocks.
- Add schema contract tests.
- Remove hardcoded test credentials from committed integration tests or load from secure environment.
- Add debug logging redaction for user IDs/emails where possible.

Acceptance:

- Discovery loads without PostgREST column errors.
- Care and health load without schema-cache errors.
- RLS tests pass for owner/non-owner/anonymous paths.
- No service role keys or secrets exist in client code.

### Phase 1 - Identity, Profile, Pets, Settings

Deliverables:

- Owner profile root as bottom Profile tab.
- Multi-pet management and active pet switcher.
- Pet profile detail remains pet-specific.
- Complete Settings structure.
- Email verification, password reset, and optional MFA flows.
- Replace hardcoded fan counts.

Acceptance:

- A pet owner can create and manage multiple pets from the UI.
- Owner and pet identities are visually distinct.
- Settings covers account, security, pets, notifications, privacy, commerce, care data, app, and legal.

### Phase 2 - Core Social, Discovery, Care

Deliverables:

- Discovery filters and working match states.
- Report/block/safety surfaces.
- Chat attachment strategy or removal of fake buttons.
- Pet Care onboarding completion path.
- Health log actions wired to real flows.
- Reminder and notification preference integration.

Acceptance:

- Owner can discover pets using real filters.
- Mutual match and chat permissions are understandable.
- Care tasks, medication, weight, appointments, and reminders work end to end.

### Phase 3 - Commerce Completion

Deliverables:

- Product inventory seed/test data.
- Product detail with variants/reviews.
- Cart with promo/shipping/tax totals.
- Checkout payment through secure server-side function.
- Order detail/tracking.
- Returns/disputes.
- Seller dashboard and listing editor.

Acceptance:

- Buyer can complete a real purchase flow in staging.
- Seller can list and fulfill products.
- Orders can be tracked and returned.

### Phase 4 - Services And Community Completion

Deliverables:

- Consolidate duplicate community/services screens.
- Complete lost/found, adoption, sitters, places, events, insurance, knowledge base, and breed identifier flows.
- Add detail pages, filters, map views, apply/contact actions, and saved content.

Acceptance:

- No visible service/community primary action is a no-op.
- Each service route has a meaningful empty/loading/error state.

### Phase 5 - Responsive, Accessibility, Localization

Deliverables:

- Adaptive shell with bottom nav and navigation rail.
- Large-screen owner/pet two-pane layouts.
- Text scale fixes.
- TalkBack traversal tests.
- Contrast and tap target audit.
- Localization foundation with at least English resource extraction.

Acceptance:

- App is usable at 2.0 text scale.
- Major flows pass TalkBack manual smoke test.
- Phone and tablet screenshots are stable.

### Phase 6 - QA Automation And Release Readiness

Deliverables:

- Route smoke tests for every GoRoute.
- Integration tests for:
  - auth login/logout
  - add/manage pet
  - owner profile edit
  - pet care checklist
  - discovery filters
  - chat happy path
  - product search/cart/checkout staging
  - settings preferences
- Log assertion: no PostgREST schema errors during smoke traversal.
- Screenshot baselines for main flows.
- Crash/error reporting setup.

Acceptance:

- `flutter test` passes.
- `flutter analyze` has no warnings and only agreed informational lints.
- Android debug build passes.
- Emulator smoke traversal completes without stuck routes, schema errors, or no-op primary actions.

## Route Smoke Checklist

Automate a smoke test for every route from `lib/app/router.dart`:

- `/splash`
- `/login`
- `/register`
- `/home`
- `/discover`
- `/shop`
- `/profile`
- `/create_post`
- `/create_story`
- `/add_pet`
- `/pet_care`
- `/pet_care_onboarding`
- `/notifications`
- `/liked_pets`
- `/pet/:id`
- `/user/:id`
- `/messages`
- `/chat/:threadId`
- `/post/:id`
- `/story/:petId`
- `/cart`
- `/orders`
- `/product/:id`
- `/settings`
- `/search`
- `/pet/:id/followers`
- `/user/:id/followers`
- `/user/:id/following`
- `/achievements`
- `/vet_booking`
- `/emergency_care`
- `/community_groups`
- `/lost_and_found`
- `/adoption_center`
- `/training`
- `/insurance`
- `/expenses`
- `/growth_charts`
- `/memorial`
- `/memorial/:id`
- `/pet_friendly_places`
- `/events`
- `/medical_records`
- `/export_records`
- `/sitters`
- `/nutrition_planner`
- `/pet_timeline`
- `/breed_identifier`
- `/knowledge_base`
- `/article_detail`
- `/gear_reviews`

Each smoke test should assert:

- Screen title or primary landmark is visible.
- Route does not show framework overflow/error screen.
- Primary scroll area can scroll or correctly reports no more content.
- Tabs can be selected when present.
- Primary actions are enabled only when functional.
- No new logcat `PostgrestException`, `NoSuchMethodError`, `RenderFlex overflowed`, or schema-cache error appears.

## Definition Of Done For The Redesign

The redesign is done when:

1. Owner and pet profiles are separate and complete.
2. A real user can manage multiple pets.
3. Settings is production-complete.
4. Discovery, care, health, and marketplace no longer fail from schema drift.
5. No visible primary action is fake, no-op, or "coming soon" in production.
6. Every route has loading, empty, error, and success states.
7. Supabase RLS policies are tested and security definer helpers are hardened.
8. Phone and tablet layouts use adaptive navigation.
9. TalkBack, text scale, contrast, and tap-target checks pass.
10. All user-story epics have traceable UI routes and acceptance tests.
