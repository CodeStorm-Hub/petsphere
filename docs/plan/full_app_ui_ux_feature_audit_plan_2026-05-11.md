# PetSphere Full App UI, UX, Architecture, Security, and Feature Remediation Plan

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
  - Flutter accessibility guide: https://docs.flutter.dev/ui/accessibility
  - Supabase RLS guide: https://supabase.com/docs/guides/database/postgres/row-level-security
  - Supabase MFA guide: https://supabase.com/docs/guides/auth/auth-mfa
  - Supabase changelog: https://supabase.com/changelog
  - Material 3 adaptive layout guidance: https://m3.material.io/foundations/layout/applying-layout/window-size-classes

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
