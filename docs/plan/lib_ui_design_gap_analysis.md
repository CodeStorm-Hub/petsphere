# PetFolio `lib/` UI, Feature, and Data Gap Analysis

**Date:** 2026-05-11  
**Scope:** `lib/`, `redesign_stitch/`, Stitch project `9043096397543633864`, checked-in Supabase schema/migrations  
**Review lenses:** Flutter adaptive UI, Flutter UI/UX, Flutter/Dart code review, responsive layout, architecture best practices, mobile app UI design, frontend design, Supabase/Postgres best practices, Android emulator QA readiness

## Executive Summary

The application has a broad implemented feature surface, but the current Stitch redesign only covers the primary social/product/account flows. Several routed and database-backed features have no corresponding redesign screen, and some implemented flows are still placeholders or no-op interactions. The strongest technical risk is not analyzer correctness: `mcp__dart__.analyze_files` reported no errors for `lib`. The larger gap is product/design/data alignment.

Supabase MCP tools were requested. On the first pass, no Supabase MCP namespace/tools were exposed in the session, so the review used local schema docs, migrations, and table references in repositories. On a second pass, Supabase MCP tools still were not exposed, but the configured Supabase Management API token worked against the linked project, so the database section below now includes a live read-only schema/security snapshot from project `foubokcqaxyqgjhtgzsx`.

## Stitch Design Inventory

Live Stitch project: `PetFolio - Modern Pet Platform Redesign`  
Project URL: `https://stitch.withgoogle.com/projects/9043096397543633864`

Design system returned by Stitch: **Kinship Modern**

- Light-first premium corporate-modern style.
- Primary blue `#2563EB`, soft blue-tinted background, white cards, ambient shadows.
- Inter typography, bold headings, 8px rhythm, 24px mobile gutter.
- Floating glassmorphic mobile bottom navigation.

### Local Redesign Gallery

| Design | Local asset | Current app mapping |
|---|---|---|
| Splash | `redesign_stitch/petfolio_splash_screen/screen.png` | `SplashScreen`, `/splash` |
| Onboarding | `redesign_stitch/petfolio_onboarding_1/screen.png` | `OnboardingScreen`, `/onboarding` |
| Login | `redesign_stitch/petfolio_login/screen.png` | `LoginScreen`, `/login` |
| Home feed | `redesign_stitch/petfolio_home_feed_1/screen.png`, `petfolio_home_feed_2/screen.png` | `HomeScreen`, `/home` |
| Dark feed | `redesign_stitch/petfolio_home_feed_dark_mode/code.html` | `HomeScreen` dark theme |
| Discover | `redesign_stitch/petfolio_discover/screen.png` | `DiscoveryScreen`, `/discover` |
| Shop | `redesign_stitch/petfolio_shop/screen.png` | `MarketplaceScreen`, `/shop` |
| Messages | `redesign_stitch/petfolio_messages/screen.png` | `MessagesListScreen`, `/messages` |
| New post | `redesign_stitch/new_post/screen.png` | `CreatePostScreen`, `/create_post` |
| Notifications | `redesign_stitch/notifications/screen.png` | `NotificationsScreen`, `/notifications` |
| Owner profile | `redesign_stitch/owner_profile/screen.png` | `OwnerProfileScreen`, `/profile` |
| Pet profile | `redesign_stitch/pet_profile_buddy/screen.png` | `PetProfileScreen`, `/pet/:id` |
| Add pet | `redesign_stitch/add_pet/screen.png` | `AddPetScreen`, `/add_pet` |
| Pet care dashboard | `redesign_stitch/pet_care_dashboard/screen.png` | `PetCareScreen`, `/pet/:id/care` |
| Health records | `redesign_stitch/health_records/screen.png` | `PetHealthRecordScreen`, `/pet/:id/medical_records` |
| Settings | `redesign_stitch/settings/screen.png` | `SettingsScreen`, `/settings` |
| Logo | `redesign_stitch/petfolio_paw_logo/screen.png` | `BrandLogo`, app icon/brand surfaces |

Stitch also returned duplicate/variant screens for Home Feed, Shop, Add Pet, Pet Profile, Owner Profile, Login, Messages, Notifications, New Post, Health Records, Settings, Splash, Onboarding, Discover, Pet Care Dashboard, and an ecosystem flow. There are no Stitch screens for many secondary routes listed below.

## Existing Feature Surface

### Core Navigation

| Feature | Route | Screen/component | Data surface |
|---|---|---|---|
| Splash | `/splash` | `SplashScreen` | Supabase auth state |
| Onboarding | `/onboarding` | `OnboardingScreen` | Local state only |
| Login | `/login` | `LoginScreen` | `auth.users`, `profiles` |
| Register | `/register` | `RegistrationScreen` | `auth.users`, `profiles` |
| Main shell | `/home`, `/discover`, `/shop`, `/profile` | `MainLayout`, `PetFolioNavBar`, `PetFolioNavRail` | auth/pet state |

### Primary Tabs

| Feature | Route | Screen/component | Main tables |
|---|---|---|---|
| Home feed | `/home` | `HomeScreen`, `PostCard`, stories | `posts`, `stories`, `pets`, `post_likes`, `comments`, `follows` |
| Discover/match | `/discover` | `DiscoveryScreen`, `MatchPetCard` | `pets`, `match_requests`, `follows` |
| Marketplace | `/shop` | `MarketplaceScreen`, product cards | `products`, `orders`, `gear_reviews` |
| Owner profile | `/profile` | `OwnerProfileScreen`, pet grid, posts | `profiles`, `pets`, `posts`, `follows` |

### Secondary Screens

| Feature | Route | Screen/component | Main tables | Stitch coverage |
|---|---|---|---|---|
| Create post | `/create_post` | `CreatePostScreen` | `posts`, storage | Covered |
| Create story | `/create_story` | `CreateStoryScreen` | `stories`, storage | Not covered |
| Add/edit pet | `/add_pet` | `AddPetScreen` | `pets`, storage | Covered |
| Notifications | `/notifications` | `NotificationsScreen` | `notifications` | Covered |
| Liked pets | `/liked_pets` | `LikedPetsScreen` | `match_requests`, `pets` | Not covered |
| Pet profile | `/pet/:id` | Own/visitor pet profile split | `pets`, `posts`, `follows` | Partially covered |
| Pet care | `/pet/:id/care` | `PetCareScreen` | care + health tables | Covered |
| Care onboarding | `/pet/:id/care/onboarding` | `PetCareOnboardingScreen` | `pet_care_onboarding` | Not covered |
| Achievements | `/pet/:id/achievements` | `GamificationScreen` | care gamification tables | Not covered |
| Health records | `/pet/:id/medical_records` | `PetHealthRecordScreen` | health tables | Covered |
| Export records | `/pet/:id/medical_records/export` | `PetHealthRecordExportScreen` | health tables | Not covered |
| Expenses | `/pet/:id/expenses` | `PetExpenseTrackerScreen` | `pet_expenses` | Not covered |
| Growth | `/pet/:id/growth` | `PetGrowthChartScreen` | `pet_weight_logs` | Not covered |
| Nutrition planner | `/pet/:id/nutrition` | `PetNutritionPlannerScreen` | `pet_nutrition_logs` | Not covered |
| Training | `/pet/:id/training` | `PetTrainingScreen` | `pet_training_progress` | Not covered |
| Vet booking | `/pet/:id/vet_booking` | `VetBookingScreen` | `pet_vet_appointments` | Not covered |
| Emergency care | `/pet/:id/emergency_care` | `EmergencyCareScreen` | mostly static/launcher | Not covered |
| Insurance | `/pet/:id/insurance` | `PetInsuranceHubScreen` | `pet_insurance_claims` | Not covered |
| Memorial | `/pet/:id/memorial` | `PetMemorialScreen` | `pet_memorial_entries` | Not covered |
| Messages | `/messages`, `/chat/:threadId` | messages list/chat | `chat_threads`, `messages` | List covered, chat not covered |
| Product detail/cart/orders | `/product/:id`, `/cart`, `/orders` | commerce screens | `products`, `orders` | Shop covered, details/cart/orders not covered |
| Services/community | several top-level routes | groups, lost/found, adoption, places, events, sitters, breed ID, knowledge base | many service tables | Not covered |
| Settings | `/settings` | `SettingsScreen` | auth/profile/preferences implied | Covered |

## Database Table Mapping

### Live Supabase Snapshot

Source: Supabase Management API read-only database query endpoint for linked project `foubokcqaxyqgjhtgzsx` on 2026-05-11.

| Metric | Live result |
|---|---:|
| Public tables | 46 |
| Public tables with RLS enabled | 46 |
| Public RLS policies | 78 |
| Public indexes | 100 |
| Storage buckets | 4 |
| Deployed Edge Functions | 3 |

Live public tables and column counts:

| Table | Columns | RLS |
|---|---:|---|
| `adoption_applications` | 6 | enabled |
| `adoption_listings` | 15 | enabled |
| `care_badge_definitions` | 5 | enabled |
| `chat_threads` | 5 | enabled |
| `comments` | 5 | enabled |
| `community_group_members` | 5 | enabled |
| `community_groups` | 9 | enabled |
| `follows` | 5 | enabled |
| `gear_reviews` | 6 | enabled |
| `knowledge_base_articles` | 9 | enabled |
| `lost_and_found_reports` | 15 | enabled |
| `match_requests` | 7 | enabled |
| `messages` | 8 | enabled |
| `notifications` | 8 | enabled |
| `orders` | 6 | enabled |
| `pet_activity_logs` | 9 | enabled |
| `pet_allergies` | 7 | enabled |
| `pet_breed_scans` | 6 | enabled |
| `pet_care_badge_unlocks` | 5 | enabled |
| `pet_care_gamification` | 22 | enabled |
| `pet_care_logs` | 17 | enabled |
| `pet_care_onboarding` | 5 | enabled |
| `pet_dental_logs` | 6 | enabled |
| `pet_event_rsvps` | 5 | enabled |
| `pet_events` | 11 | enabled |
| `pet_expenses` | 9 | enabled |
| `pet_insurance_claims` | 9 | enabled |
| `pet_medication_doses` | 7 | enabled |
| `pet_medications` | 11 | enabled |
| `pet_memorial_entries` | 11 | enabled |
| `pet_nutrition_logs` | 9 | enabled |
| `pet_parasite_prevention` | 9 | enabled |
| `pet_sitter_jobs` | 8 | enabled |
| `pet_symptoms` | 8 | enabled |
| `pet_training_progress` | 6 | enabled |
| `pet_vaccinations` | 9 | enabled |
| `pet_vet_appointments` | 9 | enabled |
| `pet_weight_logs` | 6 | enabled |
| `pets` | 19 | enabled |
| `post_likes` | 3 | enabled |
| `posts` | 8 | enabled |
| `products` | 13 | enabled |
| `profiles` | 8 | enabled |
| `stories` | 9 | enabled |
| `user_fcm_tokens` | 4 | enabled |
| `waitlist` | 6 | enabled |

Live storage buckets:

| Bucket | Public | Limit | MIME groups |
|---|---:|---:|---|
| `avatars` | yes | 5 MB | JPEG, PNG, WebP |
| `pet-images` | yes | 10 MB | JPEG, PNG, WebP, GIF |
| `post-media` | yes | 50 MB | JPEG, PNG, WebP, GIF, MP4, QuickTime, WebM |
| `product-images` | yes | 10 MB | JPEG, PNG, WebP |

Live deployed Edge Functions:

| Function | JWT required | Status | Local file present |
|---|---:|---|---|
| `ai-pet-care-plan` | yes | active | no |
| `moderate-content` | yes | active | no |
| `create-payment-intent` | no | active | yes |

Local-only Edge Function directories:

| Local function | Live deployment found |
|---|---:|
| `push-fcm` | no |
| `waitlist-signup` | no |

This confirms the earlier finding that local documentation is stale, but it also improves it: the live project has 46 public tables, not merely the 30 documented in `DATABASE_SCHEMA.md`.

Tables referenced from `lib`/functions:

`adoption_applications`, `adoption_listings`, `care_badge_definitions`, `chat_threads`, `comments`, `community_group_members`, `community_groups`, `follows`, `gear_reviews`, `knowledge_base_articles`, `lost_and_found_reports`, `match_requests`, `messages`, `notifications`, `orders`, `pet_activity_logs`, `pet_allergies`, `pet_breed_scans`, `pet_care_badge_unlocks`, `pet_care_gamification`, `pet_care_logs`, `pet_care_onboarding`, `pet_dental_logs`, `pet_event_rsvps`, `pet_events`, `pet_expenses`, `pet_friendly_places`, `pet_insurance_claims`, `pet_medication_doses`, `pet_medications`, `pet_memorial_entries`, `pet_nutrition_logs`, `pet_parasite_prevention`, `pet_sitter_jobs`, `pet_symptoms`, `pet_training_progress`, `pet_vaccinations`, `pet_vet_appointments`, `pet_weight_logs`, `pets`, `post_likes`, `posts`, `products`, `profiles`, `stories`, `user_fcm_tokens`, `vaccination_schedules`.

Tables used by code but missing from `DATABASE_SCHEMA.md`:

`adoption_applications`, `adoption_listings`, `community_group_members`, `community_groups`, `gear_reviews`, `knowledge_base_articles`, `lost_and_found_reports`, `pet_breed_scans`, `pet_event_rsvps`, `pet_events`, `pet_expenses`, `pet_friendly_places`, `pet_insurance_claims`, `pet_memorial_entries`, `pet_nutrition_logs`, `pet_sitter_jobs`, `pet_training_progress`, `vaccination_schedules`.

Tables documented but not directly referenced from `lib`:

`auth.users`, `waitlist`. `auth.users` is indirectly used through Supabase Auth. `waitlist` is handled by the `waitlist-signup` Edge Function, not by Flutter UI.

## Gaps and Findings

### P0: Database documentation and live database surface are out of sync

The local schema document says the app has 30 tables, while the live Supabase project has 46 public tables and `lib` references most of that wider surface. This makes UI-to-data mapping unreliable for redesign and QA. Examples missing from the schema doc include adoption, community groups, events, places, sitters, breed scans, insurance claims, expenses, nutrition logs, memorial entries, gear reviews, and vaccination schedules.

Impact: redesign screens can be produced without fields that the actual repositories require, and RLS/index review can miss active tables.

Recommended fix: regenerate `DATABASE_SCHEMA.md` from the live Supabase project, then update this UI map from the same source of truth.

### P0: Live and local Edge Functions differ

The live project has active functions `ai-pet-care-plan`, `moderate-content`, and `create-payment-intent`. The repository has local function directories for `create-payment-intent`, `push-fcm`, and `waitlist-signup`.

Impact: production behavior may depend on functions not represented locally, while local push/waitlist functions may not be deployed. This affects notification, AI care plan, content moderation, payment, and waitlist design/QA mapping.

Recommended fix: reconcile live functions with `supabase/functions/`, then document which UI flows call each function.

### P0: Several routed features have no Stitch redesign

The Stitch set covers the core social/product shell, but not the full routed app. Missing design screens include create story, chat detail, post detail, product detail, cart, orders, care onboarding, achievements, expenses, growth chart, nutrition planner, training, vet booking, emergency care, insurance, memorial flows, liked pets, followers/following, visitor user profile, and all services/community flows.

Impact: implementation will drift if teams redesign only covered screens and leave secondary workflows in the old component language.

Recommended fix: create a Stitch screen backlog by route, prioritizing high-traffic and data-heavy flows: chat detail, product detail/cart, care onboarding, health export, expenses, nutrition, vet booking, and community/services.

### P0: Care setup route is currently miswired

`PetCareScreen` pushes a route that is not registered:

- `lib/features/care/presentation/screens/pet_care_screen.dart:557` pushes `/pet_care_onboarding?petId=...`
- `lib/app/router.dart:198` registers care onboarding as nested `/pet/:id/care/onboarding`
- `AppRoutes.petCareOnboardingById(id)` already exists and should be used

Impact: tapping the care setup banner can land in a 404 instead of the onboarding flow.

### P1: Duplicate route definition

`AppRoutes.adoptionCenter` is registered twice:

- `lib/app/router.dart:407`
- `lib/app/router.dart:411`

Impact: this is low risk today because both builders are the same, but it is a routing maintenance trap and can hide future route-specific changes.

### P1: Memorial detail navigation is inconsistent with registered routes

`PetMemorialScreen` pushes `/memorial/${entry.id}` at `lib/features/social/presentation/screens/pet_memorial_screen.dart:100`, but the router defines memorial detail under `/pet/:id/memorial/:memorialId`.

Impact: memorial detail cards are likely broken unless another route exists outside the current router.

### P1: Many settings rows are visible but only show "Coming soon"

`SettingsScreen` exposes many production-looking rows that do not perform the implied action: edit owner profile, linked providers, password, MFA, sessions, pet visibility, health sharing, notifications, privacy, blocked users, report history, content filters, shipping addresses, payment methods, reminders, share with vet, delete care data, language, accessibility preferences, units, and account deletion.

Evidence: `lib/features/settings/presentation/screens/settings_screen.dart:90` through `263` call `_showComingSoon` for most rows.

Impact: the screen looks feature-complete in the Stitch design but behaves like a placeholder menu. This should be separated into real flows, disabled states, or a shorter settings IA.

### P1: Post detail actions are no-ops

`PostDetailScreen` wires comment, share, pet tap, edit, and delete callbacks to empty closures:

- `lib/features/social/presentation/screens/post_detail_screen.dart:45`
- `lib/features/social/presentation/screens/post_detail_screen.dart:49`

Impact: a detail screen should complete the social interaction loop. This gap is visible in QA and accessibility because controls announce as interactive but do nothing.

### P1: Health record "scan document" is simulated

`PetHealthRecordScreen` uses a fake delay and success message:

- `lib/features/health/presentation/screens/pet_health_record_screen.dart:71`
- `lib/features/health/presentation/screens/pet_health_record_screen.dart:77`

Impact: the design implies a document capture/scan workflow, but there is no persistence, OCR, upload record, or review state.

### P1: App breakpoints are inconsistent

`MainLayout` switches to rail navigation at `width > 600` and extends at `width > 900`, while central breakpoints define tablet at `768` and desktop at `1024`.

- `lib/app/main_layout.dart:94`
- `lib/app/main_layout.dart:95`
- `lib/app/main_layout.dart:108`
- `lib/core/theme/app_breakpoints.dart:4`

Impact: screens may change navigation earlier than the app's design breakpoint model. The adaptive UI guidance recommends compact `<600`, medium `600-839`, expanded `>=840`; the project currently mixes `600/900` and `768/1024`.

### P1: Responsive implementation is uneven

Some primary pages use constraints and layout builders, but many secondary pages still use full-width `ListView`, fixed grids, or local width checks. Examples:

- `CreatePostScreen` uses `GridView.count(crossAxisCount: 2)` at `lib/features/social/presentation/screens/create_post_screen.dart:245`.
- `HealthTab` is a 2,628-line screen with a single vertical `ListView` entry point and no large-screen reflow.
- `PetCareScreen`, `HomeScreen`, `DiscoveryScreen`, `AddPetScreen`, and `HealthTab` are all large files above 800 lines.

Impact: core flows may look acceptable on mobile but are not reliably optimized for tablet/web/desktop.

### P1: Large widgets need decomposition before redesign implementation

Large files found:

| File | Lines |
|---|---:|
| `lib/features/health/presentation/screens/health_tab.dart` | 2628 |
| `lib/features/match/presentation/screens/discovery_screen.dart` | 1722 |
| `lib/features/home/presentation/screens/home_screen.dart` | 1263 |
| `lib/features/care/presentation/screens/pet_care_screen.dart` | 1278 |
| `lib/features/pet/presentation/screens/add_pet_screen.dart` | 862 |

Impact: these screens blend layout, interaction, modal composition, and subcomponents. Implementing Stitch fidelity in these files will be slow and risky unless the visible regions are split into route-level screens, section widgets, and reusable primitives.

### P2: State shape uses boolean/error fields instead of explicit async state in many controllers

The code follows the requested Riverpod `Notifier<State>` pattern, but many state classes model async status with `isLoading`, nullable data, and string errors. This is workable, but it allows mixed states and repeated UI checks.

Impact: redesigning empty/loading/error states consistently will be harder. For new/refactored feature slices, prefer `AsyncValue` or sealed states for mutually exclusive async states.

### P2: Theme mostly matches Stitch, but token discipline is not complete

The core palette matches the Stitch blue direction:

- `lib/core/theme/colors.dart:7` uses `#2563EB`
- `lib/core/theme/colors.dart:16` uses `#F7FAFF`

However, there are many local `Colors.*`, raw font sizes, and screen-level `TextStyle` overrides. Some are legitimate semantic uses; others bypass the design system. Radius also differs by design variant: Stitch's current Kinship Modern says cards should use `1.5rem`/24px, while some local components use smaller values and some design system docs mention 8px standard radius.

Impact: visual fidelity will vary screen by screen unless component tokens are enforced.

### P2: Accessibility coverage is partial

There are good examples of `Semantics` in navigation, login, messages, and product cards. There are also many `GestureDetector`/`InkWell` uses without explicit semantic labels or button roles, especially in large screens and custom cards.

Impact: custom controls in health, discovery, social, and profile flows may not announce clearly to assistive technologies. A redesign pass should include semantics as part of component extraction.

### P2: Testing is business-logic heavy, not UI-redesign heavy

Existing tests cover controllers, models, care logic, repository behavior, and several integration journeys. There is no visible golden/screenshot test suite for the Stitch redesign, and no current emulator evidence was generated during this document-only review.

Impact: visual regressions, overflows, and broken responsive states will need manual QA unless widget/golden or emulator screenshot checks are added.

## Recommended Redesign Backlog

### Phase 1: Fix functional routing gaps

1. Replace `/pet_care_onboarding?petId=...` with `AppRoutes.petCareOnboardingById(activePet.id)`.
2. Remove the duplicate adoption route.
3. Fix memorial detail navigation to include the pet ID route context.
4. Replace no-op post detail actions with real handlers or disabled UI.
5. Decide whether simulated document scanning is a real feature, a hidden beta feature, or a removed CTA.

### Phase 2: Regenerate data source of truth

1. Export the live Supabase table/column/RLS/policy/index/storage/function snapshot into repo docs.
2. Update `DATABASE_SCHEMA.md` to include all 46 live public tables.
3. Add a feature-to-table matrix generated from repository usage.
4. Check active tables for indexes on filter/order columns and review all public-role policies for intended anon/auth exposure.
5. Reconcile local and live Edge Functions.

### Phase 3: Complete Stitch coverage

Create Stitch screens for:

1. Chat detail
2. Product detail, cart, checkout/order history
3. Create story and story viewer
4. Care onboarding, achievements, expenses, growth, nutrition, training
5. Vet booking, emergency care, insurance claims
6. Memorial list/detail/create tribute
7. Visitor user profile, followers/following, liked pets
8. Services: community groups, lost/found, adoption detail/application, pet places, events, sitters, breed ID, knowledge base

### Phase 4: Componentize for fidelity

1. Split `health_tab.dart` into overview, vitals, medication, appointments, vaccinations, parasite, dental, allergy, and symptoms widgets.
2. Split `discovery_screen.dart` into shell, pet selector, card stack, filters, requests, and modal widgets.
3. Split `home_screen.dart` into app bar, stories, composer, feed list, empty/error states, and modals.
4. Extract shared Stitch-aligned primitives: glass nav, section header, media frame, profile stat, action tile, card surface, state banner, form field, segmented control.
5. Use `AppBreakpoints` consistently across layout decisions.

### Phase 5: Add verification

1. Add widget tests for key no-op/route fixes.
2. Add responsive widget tests for compact, medium, and expanded widths.
3. Add golden/screenshot tests for redesigned core components.
4. Use Android emulator QA for the primary flows after implementation: auth, home/feed, discover, add pet, care, health records, shop, messages, settings.

## Open Questions

1. Should the app name remain `PetFolio` everywhere, or should docs and old files using `PetSphere` be renamed?
2. Which Stitch variant is canonical: `Kinship Modern`, `PetFolio Design System`, or one of the other design folders?
3. Are service/community tables live production tables, planned tables, or generated scaffolding?
4. Should settings expose unavailable features, or should settings only show implemented actions?
5. Should health records support real document upload/OCR, or only manual entry and export?

## Verification Performed

- Loaded requested skill checklists from local skill files.
- Used Stitch MCP `get_project` and `list_screens` for project `9043096397543633864`.
- Discovered MCP tools; Supabase MCP tools were not exposed in this session.
- Used Dart MCP analyzer on `lib`: no errors reported.
- Used Supabase Management API read-only queries for live table, RLS, policy, index, bucket, and Edge Function metadata after Supabase MCP tools remained unavailable.
- Inspected routes, screens, repositories, theme tokens, local Stitch assets, schema docs, and migrations.
- Did not run Android emulator QA because this request was a static review/documentation task and no feature implementation was performed.
