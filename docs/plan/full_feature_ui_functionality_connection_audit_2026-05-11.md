# PetFolio Full Feature ↔ UI ↔ Functionality Audit (2026-05-11)

## 1) Scope and method

This audit maps app features, screens, controllers, repositories, and reusable components, then flags missing/disconnected/improper connections.

Reviewed sources:
- Routing and navigation: `lib/app/router.dart`, `lib/app/main_layout.dart`, `lib/core/constants/app_routes.dart`
- Feature modules under `lib/features/**`
- Shared UI components under `lib/core/widgets/**`
- Data/repository wiring under `lib/features/**/data/**`

Validation note:
- Local lint/test/build tooling could not be executed in this environment because `dart` and `flutter` CLIs were unavailable.
- Follow-up recommended: re-run `dart format --set-exit-if-changed .`, `flutter analyze`, and `flutter test` in a Flutter-enabled CI/dev environment before implementation work starts.

---

## 2) Feature map (what exists and where it connects)

| Feature | Primary screens | Key controllers/providers | Data layer | Key UI components |
|---|---|---|---|---|
| Auth & Bootstrap | `splash_screen`, `onboarding_screen`, `login_screen`, `registration_screen` | `auth_controller`, `bootstrap_controller` | `auth_repository` | `brand_logo`, app theme shell |
| Home | `home_screen` | `feed_controller`, `pet_controller`, `notification_controller` | social + pet repos | cards/feed blocks from social widgets |
| Pet Profile | `pet_profile_screen`, `visitor_pet_profile_screen`, `add_pet_screen`, `manage_pets_screen`, `owner_profile_screen` | `pet_controller` | `pet_repository`, `breed_repository` | `pet_avatar`, `active_pet_switcher_modal`, `pill_button` |
| Discovery/Match | `discovery_screen`, `liked_pets_screen`, `search_screen` | `match_controller`, `match_requests_controller`, `search_controller` | `match_repository`, `search_repository` | swipe cards, list cards, empty states |
| Social | `create_post_screen`, `post_detail_screen`, `create_story_screen`, `story_viewer_screen`, `pet_social_timeline_screen`, `pet_followers_screen`, memorial screens | `feed_controller`, `follow_controller`, `pet_memorial_controller` | `feed_repository`, `follow_repository`, `memorial_repository` | `post_card`, `post_media` |
| Messaging | `messages_list_screen`, `chat_screen` | `chat_controller`, `threadMessagesProvider` | `chat_repository` | `message_bubble`, thread list UI |
| Notifications | `notifications_screen` | `notification_controller`, `push_notification_coordinator` | `notification_repository`, `push_token_repository` | notification list tiles |
| Care | `pet_care_screen`, onboarding, nutrition/training/expenses/gamification screens | `care_log_controller`, `care_goals_controller`, `care_gamification_controller`, expense/training/nutrition controllers | `pet_care_repository`, `training_repository`, expense data | `care_task_card`, `care_goal_progress_ring`, `care_streak_banner`, `care_mood_selector` |
| Health | `health_tab`, `vet_booking`, `emergency_care`, growth/records/export | vitals + medication + appointment + vaccination + parasite + dental + allergy controllers | `health_repository` (+ related models) | health cards/sections |
| Marketplace | `marketplace_screen`, `product_detail_screen`, `cart_screen`, `checkout_screen`, order screens, `pet_gear_reviews_screen` | `marketplace_controller`, `cart_controller`, `gear_reviews_controller` | `marketplace_repository`, `gear_reviews_repository` | `product_card`, `cart_item_tile` |
| Services/Community | `adoption_center`, `adoption_detail`, `lost_and_found`, events, places, sitters, insurance hub, knowledge base, breed identifier | services controllers for events/places/insurance/sitter/knowledge | services/community repositories | cards/lists/sheets |
| Settings | `settings_screen`, edit profile, password/privacy/security/blocked/notification prefs | settings screen actions + `bootstrapProvider.syncAllData` | mostly auth/profile/follow data | settings tiles/layout |

---

## 3) Missing / not connected / improper connections

### A. Definite improper connections (functional bugs)

1. **Broken discovery route from one Liked Pets screen**
   - File: `lib/features/pet/presentation/screens/liked_pets_screen.dart` (Go to Discovery CTA)
   - Uses `context.go('/discovery')`, but router defines discover as `/discover` (`AppRoutes.discover`).
   - Impact: button can navigate to invalid path/error page.

2. **Messaging CTA uses `userId` as `threadId`**
   - Files:
     - `lib/features/social/presentation/screens/visitor_user_profile_screen.dart` (Message button action)
     - `lib/features/pet/presentation/screens/visitor_pet_profile_screen.dart` (Message button action)
   - Both do `context.push('/chat/<userId>')` / `AppRoutes.chatByThreadId(pet.userId)`.
   - Chat route expects an actual thread ID (`/chat/:threadId` in router).
   - `chat_controller.createOrGetThread(...)` exists but is not used by UI.
   - Impact: users can land on chat screens for non-existent threads.

### B. Missing feature-function ↔ UI wiring

3. **Follow controller mutation methods are not used by UI**
   - `toggleFollowOwner` / `toggleFollowPet` exist in `follow_controller.dart` but screens directly call repository methods instead.
   - Current direct calls:
     - `visitor_user_profile_screen.dart` (follow/unfollow owner)
     - `visitor_pet_profile_screen.dart` (follow/unfollow pet)
   - Impact: duplicated logic, weaker state consistency, provider invalidation spread across UI.

4. **Unused or parallel controller paths indicate partial/abandoned wiring**
   - Unreferenced controller files detected:
     - `lib/features/match/presentation/controllers/match_discovery_controller.dart`
     - `lib/features/pet/presentation/controllers/pet_breed_controller.dart`
   - Impact: maintenance overhead and ambiguity on canonical code path.

### C. Duplicate modules with ambiguous ownership (improper architecture connections)

5. **Duplicate screen classes with same names in different features**
   - `SearchScreen` in both discovery and match modules.
   - `LikedPetsScreen` in both pet and match modules.
   - `AdoptionCenterScreen` in both community and services modules.
   - Impact: easy to import wrong implementation; architecture drift.

6. **Duplicate repositories/models/controllers for same domain concepts**
   - Examples: insurance, nutrition, memorial, search, events, places, training, breed-identification artifacts exist in parallel locations.
   - Impact: split logic and risk of inconsistent behavior/data mapping.

7. **Offline repositories not integrated**
   - `offline_health_repository.dart` and `offline_marketplace_repository.dart` present but not wired into active controllers.
   - Impact: offline-first behavior appears incomplete.

8. **Large set of shared `core/widgets` appear unused by imports**
   - Examples include `action_tile`, `app_header`, `search_text_field`, `notification_tile`, `vitals_bar`, etc.
   - Impact: dead design-system surface and UI inconsistency risk.

---

## 4) CRUD capability audit by feature

Legend: ✅ implemented in app flow, ⚠️ partial, ❌ missing in primary UX.

| Feature domain | Main entities | Create | Read | Update | Delete |
|---|---|---|---|---|---|
| Auth/Profile | user profile, session | ✅ register/login | ✅ profile fetch | ✅ profile update | ⚠️ no clear account deletion UX |
| Pet | pet profile, photos, active pet | ✅ add pet | ✅ pet profile/list | ✅ edit/toggle listing/set active | ⚠️ limited explicit delete pet UX |
| Discovery/Match | match requests/listings | ✅ send like/list listing | ✅ discovery/feed/liked | ✅ accept/decline/filters | ⚠️ unlist exists; no full request-history cleanup UX |
| Social Feed | posts/stories/comments | ✅ create post/story/comment | ✅ feeds, details, timelines | ✅ update post, like/unlike | ✅ delete post/story |
| Social Follow | owner/pet follow edges | ✅ follow owner/pet | ✅ follower/following counts/lists | ⚠️ handled as toggle only | ✅ unfollow via toggle |
| Messaging | threads/messages | ⚠️ thread creation API exists but not used by profile CTA | ✅ threads/messages | ⚠️ read-state updates only | ❌ no thread/message delete/archive UX |
| Notifications | notification items | ⚠️ system-generated | ✅ list/read status | ✅ mark read/all read | ❌ no dismiss/delete UX |
| Care | daily logs/goals/tasks | ✅ create/append logs | ✅ today/history stats | ✅ goals/tasks/mood/food/water updates | ⚠️ limited explicit deletion of logs |
| Health | vitals, meds, appointments, allergies, etc. | ✅ add records | ✅ list/history | ✅ update/upsert key records | ✅ delete in several submodules (not uniform) |
| Marketplace | cart/orders/reviews | ✅ add cart/place order/review | ✅ products/orders/reviews | ✅ quantity/filter/status updates | ✅ remove cart item/clear cart; ⚠️ limited order cancel/return UX |
| Services/Community | adoption listings, lost/found, events, places, sitter jobs, insurance claims | ✅ some creates (claims/jobs/reports) | ✅ browse/read/details | ⚠️ selective updates only | ⚠️ selective delete only |
| Settings | privacy/security/preferences | ✅ preference updates | ✅ setting state read | ✅ password/privacy/notification updates | ⚠️ partial security lifecycle actions |

---

## 5) User stories to add or strengthen (by feature)

### Auth/Profile
- As a user, I can deactivate/delete my account and export my data.
- As a user, I can manage sessions/devices and revoke old logins.

### Pet
- As an owner, I can soft-delete or archive a pet profile.
- As an owner, I can reorder and manage pet media gallery.

### Discovery/Match
- As a user, I can undo last swipe and view match request history.
- As a user, I can save advanced filters (distance, breed, intent).

### Social
- As a user, I can report/block content from post/profile surfaces.
- As a user, I can edit/delete my comments.

### Messaging
- As a user, I can start a chat from profile reliably (create/get thread first).
- As a user, I can archive, mute, or delete conversations.

### Notifications
- As a user, I can filter notifications by type and bulk-dismiss.
- As a user, I can deep-link from each notification to exact destination.

### Care/Health
- As a user, I can view longitudinal trends and export care + health bundles.
- As a user, I can set reminders/SLA alerts for meds, appointments, vaccinations.

### Marketplace
- As a buyer, I can cancel/refund eligible orders.
- As a buyer, I can save wishlist, compare products, and track shipment states.

### Services/Community
- As a user, I can edit/close my lost-and-found or adoption submissions.
- As a user, I can bookmark places/events and get reminders.

### Settings/Security
- As a user, I can configure two-factor auth and trusted devices.
- As a user, I can audit privacy permissions and consent history.

---

## 6) Component-level improvement opportunities

1. Consolidate duplicate UI components (`ProductCard`, `CareTaskCard`) into one canonical implementation each.
2. Standardize navigation calls to `AppRoutes` helpers (replace hardcoded route strings).
3. Introduce a shared “entity actions” pattern (follow/message/report/share) to avoid direct repository mutations from screen widgets.
4. Build an explicit empty-state standard (with recovery CTA, optional sample content, and telemetry hooks).
5. Add accessibility hardening pass for icons/images/buttons/semantic labels.

---

## 7) Online research findings applied to PetFolio roadmap

### Research references
- Material Design 3: Navigation bar and Search component guidance
  - https://m3.material.io/components/navigation-bar/overview
  - https://m3.material.io/components/search/overview
- Supabase Auth + RLS security model
  - https://supabase.com/docs/guides/auth
  - https://supabase.com/docs/guides/database/postgres/row-level-security
- Stripe Payment Intents best practices
  - https://stripe.com/docs/payments/payment-intents
- WCAG 2.1 quick reference
  - https://www.w3.org/WAI/WCAG21/quickref/
- Firebase Cloud Messaging overview
  - https://firebase.google.com/docs/cloud-messaging

### Practical improvements inferred from research

1. **Navigation consistency (Material 3):** keep primary destinations fixed and avoid route-string drift; enforce route helper usage and nav tests.
2. **Search quality (Material + search UX):** add autocomplete/suggestions, typo-tolerance, and stronger filters across pets/posts/products.
3. **Security baseline (Supabase):** verify all mutable tables have explicit RLS policies; add policy audit checklist for every new feature table.
4. **Payments robustness (Stripe):** ensure idempotent checkout and PaymentIntent reuse tied to cart/session to avoid duplicate charges.
5. **Accessibility (WCAG):** enforce semantic labels/text alternatives/contrast checks on all actionable icons and media-heavy screens.
6. **Notifications reliability (FCM):** separate notification-vs-data payload handling and improve topic/segment targeting strategy.

---

## 8) Priority action plan

### P0 (immediate)
1. Fix invalid `/discovery` route usage to `AppRoutes.discover`.
2. Fix messaging CTAs to call `chatProvider.notifier.createOrGetThread(...)` before navigating to chat.
3. Remove or quarantine duplicate unused screen/controller/repository paths to establish single source of truth.

### P1
4. Refactor follow actions to always go through `followController` (not direct repository calls in UI).
5. Consolidate duplicate domain artifacts (insurance/search/nutrition/memorial/events/places/training).
6. Connect offline repositories intentionally or remove them until implemented.

### P2
7. Introduce feature-level CRUD coverage checklist and user-story acceptance criteria for each major screen.
8. Add route integration tests for top journeys: discovery → pet profile → message, profile → follow, marketplace checkout, care onboarding.

---

## 9) Summary

The app has broad feature coverage and strong modular breadth, but the main risk is **connection integrity**: duplicate modules, a few broken route/message flows, and inconsistent controller-vs-repository UI wiring. Addressing the P0/P1 items will significantly improve reliability and maintainability while preparing the app for deeper UX and CRUD completeness.
