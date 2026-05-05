# PetSphere Flutter Application - Comprehensive Codebase Review

**Review Date:** May 5, 2026  
**Application Name:** PetSphere (PetFolio / pet_dating_app)  
**Platform:** Flutter Mobile (iOS/Android)  
**Backend:** Supabase (PostgreSQL + Realtime + Storage)  
**State Management:** Riverpod 3.3.1  

---

## Executive Summary

PetSphere is a **feature-rich pet-centric social and marketplace platform** built with Flutter. The application demonstrates a mature architecture with clear separation of concerns, comprehensive state management via Riverpod, and extensive integration with Supabase for backend services.

**Key Strengths:**
- Well-organized layered architecture (Models → Repositories → Controllers → Views)
- Advanced Riverpod state management with proper async handling
- Comprehensive pet care tracking with gamification
- Real-time social features (feed, chat, notifications)
- Extensive health/wellness tracking capabilities
- FCM push notification integration

**Critical Issues Identified:**
- 12 screens are mock/stub implementations with no backend integration
- In-memory cart has no persistence (data loss on app kill)
- Missing order payment processing integration
- No offline support except care logs
- Database schema not version-controlled in repository
- Cross-ownership of appointment state between controllers

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture Analysis](#architecture-analysis)
3. [Feature Inventory](#feature-inventory)
4. [Database Schema Validation](#database-schema-validation)
5. [Authentication & Security](#authentication--security)
6. [UI/UX Assessment](#uiux-assessment)
7. [Package Integrations](#package-integrations)
8. [Issues & Gaps](#issues--gaps)
9. [Code Quality Metrics](#code-quality-metrics)
10. [Recommendations](#recommendations)

---

## Project Overview

### Project Structure

```
petsphere/
├── lib/
│   ├── main.dart                          # Entry point
│   ├── controllers/                       # State management (16 controllers)
│   ├── models/                            # Data models (18 models)
│   ├── repositories/                      # Data access layer (13 repositories)
│   ├── views/                             # UI screens (50+ screens)
│   ├── services/                          # FCM push notifications
│   ├── theme/                             # Design system
│   ├── utils/                             # Utilities & helpers
│   ├── widgets/                           # Reusable components
│   └── firebase_options.dart              # Firebase config
├── docs/                                  # Documentation
├── pubspec.yaml                           # Dependencies
└── analysis_options.yaml                  # Linting rules
```

### Technology Stack

| Component | Version | Purpose |
|-----------|---------|---------|
| **Flutter** | 3.0+ | UI Framework |
| **Dart** | 3.0+ | Language |
| **flutter_riverpod** | 3.3.1 | State Management |
| **supabase_flutter** | 2.8.4 | Backend API |
| **go_router** | 17.1.0 | Navigation |
| **firebase_messaging** | 16.2.0 | Push Notifications (FCM) |
| **google_fonts** | 8.0.2 | Typography |
| **cached_network_image** | 3.4.1 | Image Caching |
| **fl_chart** | 0.70.2 | Data Visualization |
| **image_picker** | 1.1.2 | Media Selection |
| **shared_preferences** | 2.3.5 | Local Storage |
| **video_player** | 2.11.1 | Video Playback |

### Package Naming Inconsistency

⚠️ **Issue:** `pubspec.yaml` declares `name: pet_dating_app`, but in-app branding uses "PetFolio". This creates confusion in:
- Generated platform configuration
- Firebase project settings
- App package identification

**Recommendation:** Standardize on a single name across pubspec.yaml, platform config, and in-app references.

---

## Architecture Analysis

### Layered Architecture Pattern

The codebase follows a **clean, well-defined layered architecture**:

```
┌─────────────────────────────────────┐
│           Views (UI)                │
│   (ConsumerWidget / Screens)        │
└────────────────┬────────────────────┘
                 │ watches
┌────────────────▼────────────────────┐
│       Controllers (State)           │
│  (Riverpod NotifierProvider)        │
└────────────────┬────────────────────┘
                 │ calls
┌────────────────▼────────────────────┐
│      Repositories (Data)            │
│    (Supabase API + Storage)         │
└────────────────┬────────────────────┘
                 │ queries
┌────────────────▼────────────────────┐
│     Database (Supabase)             │
│    (PostgreSQL + Realtime)          │
└─────────────────────────────────────┘
```

### State Management with Riverpod

**Pattern Used:** `Notifier<T>` with `NotifierProvider`

```dart
// 1. State Class (immutable)
class PetState {
  final List<PetModel> myPets;
  final bool isLoading;
  final String? error;
  
  PetState copyWith({...}) => ...;
}

// 2. Notifier Class
class PetNotifier extends Notifier<PetState> {
  @override
  PetState build() { ... }
  
  Future<void> loadPets() async { ... }
}

// 3. Provider
final petProvider = NotifierProvider<PetNotifier, PetState>(PetNotifier.new);
```

**Strengths:**
- ✅ Immutable state with `copyWith()` pattern
- ✅ Clear separation of concerns
- ✅ Tree-shakeable (avoids over-fetching)
- ✅ Proper async handling with FutureProvider

**Issues:**
- ⚠️ No state invalidation mechanism in some controllers
- ⚠️ Care logs load from SharedPreferences cache before network (race condition potential)

### Repository Pattern

Each feature has a dedicated repository with:
- Database queries (select, insert, update, delete)
- Image/file uploads to Supabase Storage
- Error handling and exception propagation

**Example:** `pet_repository.dart`

```dart
class PetRepository {
  Future<List<PetModel>> fetchMyPets(String userId) async { ... }
  Future<PetModel> createPet(PetModel pet) async { ... }
  Future<String> uploadPetImage(String petId, File imageFile) async { ... }
}
```

---

## Feature Inventory

### Core Features (Production-Ready)

#### 1. **Authentication & Profiles**
- Email/password authentication via Supabase Auth
- User profile creation and editing
- Avatar upload to `pet-images/avatars/` storage bucket
- Public profile viewing
- Session persistence via Supabase JWT

**Status:** ✅ **COMPLETE**  
**Files:** `auth_controller.dart`, `auth_repository.dart`, `UserModel`

---

#### 2. **Pet Management**
- Create, read, update, delete pet profiles
- Multiple pet profiles per user
- Pet image upload (primary + gallery)
- Active pet selection (used across app)
- Pet metadata: breed, age, bio, weight, calorie goals

**Status:** ✅ **COMPLETE**  
**Files:** `pet_controller.dart`, `pet_repository.dart`, `PetModel`

---

#### 3. **Social Feed**
- Create posts with images/videos
- Post captions and location tagging
- Like/unlike posts (optimistic updates)
- Comments on posts
- Stories (ephemeral, 24h expiry)
- Real-time updates via Supabase Realtime

**Status:** ✅ **COMPLETE**  
**Files:** `feed_controller.dart`, `feed_repository.dart`, `PostModel`, `StoryModel`

**Real-Time Subscriptions:**
- `public.post_likes` channel for live like counts
- `public.comments` channel for comment streams

---

#### 4. **Pet Care Tracking & Gamification**
- Daily care logs (feeding, water, tasks)
- 7-day food/water/exercise progress tracking
- Streak calculation (best streak, weekly completion mask)
- Achievement badges (6 predefined badges)
- Points system (10 daily points cap)
- 30-day care challenges
- Streak freezes (2 per user per week)
- Care personalization onboarding (species, diet, activity, living situation, etc.)

**Status:** ✅ **COMPLETE**  
**Files:** `pet_care_controller.dart`, `pet_care_repository.dart`, `PetCareLogModel`, `CareGamificationLogic`

**Local Caching:** Care logs load from `CareCache` (SharedPreferences) before network response to avoid blank UI.

---

#### 5. **Health Tracking**
- Medications with dosage schedules
- Daily medication dose tracking (given/skipped)
- Allergies (food, environmental, drug, insect)
- Parasite prevention records
- Dental logs
- Weight logs with Body Condition Score (BCS 1-9)
- Vet appointments with type (routine, emergency, dental, surgery, follow-up)
- Vaccinations with next due dates
- Symptoms tracking (severity: mild/moderate/severe)
- Health record export UI

**Status:** ✅ **COMPLETE** (except export backend)  
**Files:** `health_controller.dart`, `health_repository.dart`, `pet_health_models.dart`, `pet_health_extended_models.dart`

---

#### 6. **Matching & Discovery**
- Browse all non-owned pets with filters
- Filter by animal type and breed
- Send/receive match requests
- Accept/reject matches
- Auto-create chat thread on match acceptance
- View sent/received match requests

**Status:** ✅ **COMPLETE**  
**Files:** `match_controller.dart`, `match_repository.dart`, `MatchRequestModel`

---

#### 7. **Messaging & Chat**
- Create chat threads between two pets
- Real-time message synchronization
- Optimistic message sending (rollback on failure)
- Mark messages as read
- Typing indicators (schema ready, UI not implemented)
- Message types: text, image, system

**Status:** ✅ **COMPLETE**  
**Files:** `chat_controller.dart`, `chat_repository.dart`, `MessageModel`, `ChatThreadModel`

---

#### 8. **Notifications**
- In-app notification center with types: match_request, match_accepted, message, order_status, post_like, post_comment, profile_follow, pet_follow
- Mark notifications as read/unread
- Unread count tracking
- Real-time notification subscription
- Auto-send notifications on: likes, comments, new followers, match requests, match acceptances

**Status:** ✅ **COMPLETE**  
**Files:** `notification_controller.dart`, `notification_repository.dart`, `NotificationModel`

---

#### 9. **Push Notifications (FCM)**
- Firebase Cloud Messaging integration
- Background message handler
- Foreground notification listening
- Token registration and persistence in `user_fcm_tokens` table
- Token refresh on app session
- Token cleanup on logout

**Status:** ⚠️ **PARTIAL** (no deep-link navigation from tapped notifications)  
**Files:** `push_notification_service.dart`, `push_notification_coordinator.dart`, `firebase_options.dart`

---

#### 10. **Marketplace**
- Product listing with pagination
- Product filtering by category
- Product search
- Product detail view with rating/reviews
- Shopping cart (in-memory only)
- Checkout and order creation
- Order history with status tracking

**Status:** ⚠️ **INCOMPLETE** (no payment processing, no cart persistence)  
**Files:** `marketplace_controller.dart`, `marketplace_repository.dart`, `cart_controller.dart`, `ProductModel`, `OrderModel`

---

#### 11. **Follow System**
- Follow/unfollow individual pets
- Follow/unfollow pet owners
- Follower/following counts and lists
- Separate tracking for owner vs pet followers

**Status:** ✅ **COMPLETE**  
**Files:** `follow_controller.dart`, `follow_repository.dart`

---

#### 12. **Expense Tracking**
- Log pet expenses by category (food, health, toys, grooming, insurance, training, other)
- View expense history
- Calculate total spent per pet
- Expense notes and dates

**Status:** ✅ **COMPLETE**  
**Files:** `pet_expense_controller.dart`, `pet_expense_repository.dart`, `PetExpenseModel`

---

### Mock/Stub Features (No Backend Integration)

These screens exist with complete UI but **zero Supabase integration**:

1. **Vet Booking** (`vet_booking_screen.dart`)
   - Hardcoded vet list
   - No booking backend
   - No appointment sync with health records

2. **Community Groups** (`community_groups_screen.dart`)
   - Hardcoded group list
   - Join/leave buttons are no-ops
   - No group ownership or membership tracking

3. **Lost & Found** (`lost_and_found_screen.dart`)
   - Hardcoded lost pet cards
   - No report/claim functionality
   - Separate from health "missing pet" tracking

4. **Adoption Center** (`adoption_center_screen.dart`)
   - Hardcoded adoption listings
   - Animated swipe UI but no backend
   - No application tracking

5. **Pet Training** (`pet_training_screen.dart`)
   - Static training program cards
   - Badges/progress are mocked
   - No progress persistence

6. **Pet Insurance Hub** (`pet_insurance_hub_screen.dart`)
   - Hardcoded insurance plans
   - Claim form UI only
   - No claim submission or tracking

7. **Pet Sitter Dashboard** (`pet_sitter_dashboard_screen.dart`)
   - Static sitter list
   - Booking UI only
   - No booking backend

8. **Pet Friendly Places** (`pet_friendly_places_screen.dart`)
   - Hardcoded location list
   - No map integration
   - No filtering or search

9. **Pet Events** (`pet_event_discovery_screen.dart`)
   - Hardcoded event list
   - No RSVP or event creation

10. **Pet Memorial** (`pet_memorial_screen.dart`)
    - Static memorial page
    - No pet archival or CRUD

11. **Pet Nutrition Planner** (`pet_nutrition_planner_screen.dart`)
    - Static nutrition advice
    - No personalized plans

12. **Pet Breed Identifier** (`pet_breed_identifier_screen.dart`)
    - Fake scan with `Future.delayed(4 seconds)`
    - Returns hardcoded breed results
    - No actual breed recognition

---

## Database Schema Validation

### Complete Table Inventory (Cross-Validated)

**Total Tables:** 33  
**RLS Enabled:** ✅ All tables (26/26)  
**Total Rows:** ~200 (test data)

### Core Tables

#### `profiles` (User Profiles)
- PK: `id` (FK → auth.users.id)
- Fields: name, email, bio, location, profile_image_url, created_at
- Special: `public_care_badge_slugs[]`, `show_care_badges_on_profile`
- RLS: ✅ Enabled
- Rows: 5

#### `pets` (Pet Profiles)
- PK: `id` (UUID)
- FK: `user_id` → profiles.id
- Fields: name, breed, animal_type, age, bio, profile_image_url, images[], weight_lbs, daily_calorie_goal, daily_water_goal_cups, monthly_budget
- Flags: is_public_owner, is_breeding_listed, is_verified, is_vaccinated, is_care_listed
- RLS: ✅ Enabled
- Rows: 16
- **FK References:** 28 other tables

### Social Tables

#### `posts`
- Fields: id, pet_id, media_url, caption, created_at
- RLS: ✅ Enabled
- Rows: 12
- Related: post_likes (14), comments (16)

#### `stories`
- Fields: id, pet_id, media_url, caption, created_at, expires_at
- Expiry: 24 hours after creation
- RLS: ✅ Enabled
- Rows: 5

#### `post_likes`
- PK: (post_id, pet_id) composite
- RLS: ✅ Enabled
- Rows: 14

#### `comments`
- Fields: id, post_id, pet_id, text, created_at
- RLS: ✅ Enabled
- Rows: 16

### Matching & Chat Tables

#### `match_requests`
- Fields: id, sender_pet_id, receiver_pet_id, status (pending/matched/rejected), created_at, rejected_at
- Check: status enum
- RLS: ✅ Enabled
- Rows: 39

#### `chat_threads`
- Fields: id, pet_id_1, pet_id_2, created_at, updated_at
- RLS: ✅ Enabled
- Rows: 13

#### `messages`
- Fields: id, thread_id, sender_pet_id, text, is_read, created_at
- Extended: message_type (text/image/system), media_url, edited_at, delivered_at
- RLS: ✅ Enabled
- Rows: 29

### Care & Health Tables

#### `pet_care_logs` (16 columns)
- Feeding: breakfast_fed, dinner_fed, snack_fed with kcal tracking
- Hydration: water_cups with goal
- Mood: optional mood field
- Tasks: JSONB array of DailyTask (key, title, subtitle, icon, done)
- Goals: daily_calorie_goal, daily_water_goal_cups, daily_exercise_goal_minutes
- Unique: pet_id + log_date
- RLS: ✅ Enabled
- Rows: 15

#### `pet_care_gamification`
- Tracking: total_care_points, best_streak_days, week_completed_mask (7-bit)
- Challenge: 30-day challenge progress (0-30)
- Freeze: streak_freezes_available (2 default), streak_freezes_used_this_week, streak_freeze_reset_on
- Idempotent: last_care_point_awarded_on, daily_point_award_date/accrued
- RLS: ✅ Enabled
- Rows: 12

#### `care_badge_definitions` (Read-only Reference)
- PK: slug (string)
- Fields: title, description, icon_emoji, sort_order
- RLS: ✅ Enabled
- Rows: 6 (hardcoded badges)

#### `pet_care_badge_unlocks`
- Fields: id, pet_id, user_id, badge_slug, unlocked_at
- FK: badge_slug → care_badge_definitions.slug
- RLS: ✅ Enabled
- Rows: 1

#### `pet_medications`
- Fields: id, pet_id, name, dose, frequency (enum), times_of_day[], start_date, end_date, purpose, notes, status (active/paused/completed)
- RLS: ✅ Enabled
- Rows: 2

#### `pet_medication_doses`
- Fields: id, medication_id, pet_id, scheduled_for, given_at, skipped, notes
- Supports dose tracking (given vs scheduled vs skipped)
- RLS: ✅ Enabled
- Rows: 1

#### `pet_allergies`
- Fields: id, pet_id, allergen, allergen_type (food/environmental/drug/insect/other), severity (mild/moderate/severe/life_threatening), reaction, diagnosed_on, is_active, notes
- RLS: ✅ Enabled
- Rows: 2

#### `pet_parasite_prevention`
- Fields: id, pet_id, product_name, product_type (flea/tick/flea_tick/heartworm/dewormer/other), administered_on, next_due_date, notes
- RLS: ✅ Enabled
- Rows: 2

#### `pet_dental_logs`
- Fields: id, pet_id, log_date, cleaning_type (home_brushing/dental_chew/professional_cleaning/water_additive), notes
- RLS: ✅ Enabled
- Rows: 2

#### `pet_weight_logs`
- Fields: id, pet_id, log_date, weight_lbs, notes, bcs_score (1-9), unit (lbs/kg)
- Check: bcs_score 1-9 constraint
- RLS: ✅ Enabled
- Rows: 9

#### `pet_vet_appointments`
- Fields: id, pet_id, title, doctor, scheduled_at, notes, status (scheduled/completed/cancelled), appointment_type (routine/emergency/specialist/dental/surgery/follow_up), location, cost
- RLS: ✅ Enabled
- Rows: 1

#### `pet_vaccinations`
- Fields: id, pet_id, vaccine_name, status (scheduled/completed), scheduled_for, completed_on, next_due_date, administered_by, batch_number, notes
- RLS: ✅ Enabled
- Rows: 2

#### `pet_symptoms`
- Fields: id, pet_id, observed_at, symptom_type, severity (mild/moderate/severe), notes, resolved_at
- RLS: ✅ Enabled
- Rows: 0

#### `pet_activity_logs`
- Referenced in code but not queried
- Fields: id, pet_id, log_date, activity_type, duration_minutes, intensity, notes
- RLS: ✅ Enabled
- Rows: 0 (in schema but unused)

#### `pet_care_onboarding`
- Fields: pet_id (PK), data (JSONB), completed_at, updated_at
- Contains: species, age_band, activity, diet_type, multi_pet_home, health_focus, custom_checklist, personality, living_situation, gender, neutered, primary_goal, grooming_frequency, exercise_preferences, known_conditions
- RLS: ✅ Enabled
- Rows: 5

#### `pet_care_ai_plans`
- Fields: id, pet_id, user_id, animal_type, breed, weight_lbs, age_years, is_vaccinated, ai_plan (JSONB), is_active, created_at, updated_at
- Purpose: Placeholder for AI-generated care plans
- RLS: ✅ Enabled
- Rows: 0 (not used in current controllers)

### Marketplace Tables

#### `products`
- Fields: id, vendor_id, name, price, description, images[], stock, category, created_at, rating, review_count, tags[], is_bestseller
- FK: vendor_id → profiles.id
- RLS: ✅ Enabled
- Rows: 15

#### `orders`
- Fields: id, user_id, items (JSONB), total, status (pending/confirmed/shipped/delivered/cancelled), created_at, updated_at
- Items stored as JSONB (immutable snapshot, not separate table)
- RLS: ✅ Enabled
- Rows: 6

#### `order_items`
- Fields: id, order_id, product_id, product_name, unit_price, quantity, line_total (generated)
- Redundant: items also in orders.items JSONB
- RLS: ✅ Enabled
- Rows: 0 (used by generated column only)

### Notification Table

#### `notifications`
- Fields: id, user_id, actor_pet_id, type (enum), title, body, entity_type, entity_id, is_read, created_at
- Type values: match_request, match_accepted, message, order_status, system, post_like, post_comment, profile_follow, pet_follow
- RLS: ✅ Enabled
- Rows: 60

### Other Tables

#### `follows`
- Fields: id, follower_user_id, followed_user_id?, followed_pet_id?, created_at
- Polymorphic: either followed_user_id OR followed_pet_id is set
- Check: ensures at least one followed_* is non-null
- RLS: ✅ Enabled
- Rows: 11

#### `matches`
- Fields: id, request_id (FK → match_requests.id, unique), pet_id_1, pet_id_2, status (active/archived/blocked), created_by_user_id, matched_at, created_at, updated_at
- Purpose: Tracks accepted matches separately from requests
- RLS: ✅ Enabled
- Rows: 6

#### `pet_listings`
- Fields: id, pet_id (unique), listed_by_user_id, status (active/paused/closed), title, description, preferred_animal_type, preferred_breed, min_age, max_age, location_text, created_at, updated_at
- Purpose: Breeding/sale listings
- RLS: ✅ Enabled
- Rows: 0

#### `pet_expenses`
- Fields: id, pet_id, user_id, title, amount, date, category (enum), notes, created_at
- RLS: ✅ Enabled
- Rows: 0

#### `user_fcm_tokens`
- Fields: user_id, fcm_token
- Composite PK: (user_id, fcm_token)
- RLS: ✅ Enabled
- Rows: Not queried directly in code

### Schema Validation Results

| Aspect | Status | Notes |
|--------|--------|-------|
| **Table RLS** | ✅ | All 26 user tables have RLS enabled |
| **Primary Keys** | ✅ | All tables have PKs |
| **Foreign Keys** | ✅ | 40+ FK constraints properly defined |
| **Check Constraints** | ✅ | Enums enforced (status, severity, type, etc.) |
| **Defaults** | ✅ | Created_at, updated_at, UUIDs generated |
| **Nullability** | ⚠️ | Many nullable fields; should validate in Flutter code |
| **Indexing** | ❓ | Not checked; likely missing on frequently-queried columns |
| **JSONB Efficiency** | ⚠️ | tasks, items, ai_plan, onboarding.data as JSONB; consider separate tables |

---

## Authentication & Security

### Authentication Flow

```
User → LoginScreen
  ↓
Supabase.auth.signInWithPassword()
  ↓
  ├─ Success: AuthNotifier.state = authenticated
  ├─ FCM token registered
  └─ bootstrap() hydrates all controllers
  ↓
GoRouter redirect → /home
```

### Session Management

- **Token Type:** JWT (Supabase default)
- **Token Storage:** Supabase SDK (encrypted)
- **Refresh:** Automatic via `onAuthStateChange` stream
- **Logout:** Calls `supabase.auth.signOut()` + clears cache

### Security Observations

#### ✅ Strengths
- Supabase handles cryptography (JWT signing, token storage)
- RLS policies enforced on all tables
- No hardcoded credentials (except debug fallback)
- Auth stream listener prevents TOCTOU races
- Email verification flow supported (sign_up options)

#### ⚠️ Issues

1. **Anon Key in Source Code** (DEBUG FALLBACK)
   - `supabase_config.dart` lines 18-21 contain hardcoded debug credentials
   - This is intended, but any non-release build will embed these in the APK
   - **Mitigation:** `assertValidReleaseSupabaseConfig()` guard in `main.dart` prevents release builds without proper defines

   ```dart
   // Debug fallback (acceptable for local development)
   const String _debugFallbackUrl = 'https://foubokcqaxyqgjhtgzsx.supabase.co';
   const String _debugFallbackAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
   ```

2. **Profile Upsert Non-Fatal Error**
   - `AuthRepository.signUp` wraps profile creation in try-catch with "non-fatal" comment
   - User can register successfully but have no profile if RLS INSERT fails
   - **Risk:** User logs in with incomplete data; subsequent `fetchProfile()` returns minimal `UserModel`

3. **Cart Has No Stock Validation**
   - Client-side cart check only: `product.stock > cartItem.quantity`
   - No server-side validation before `placeOrder()`
   - **Risk:** User can purchase out-of-stock items if UI check fails

4. **FCM Token Management**
   - Token deletion on logout only removes the current device token
   - Other device tokens for the same user remain (acceptable)
   - No token encryption or rotation strategy

5. **No Client-Side RLS Verification**
   - Code assumes RLS policies are configured on Supabase
   - No audit of actual RLS policies in this repo (they're server-side only)
   - **Risk:** If RLS is misconfigured server-side, client has no defense

### Recommended Security Hardening

- [ ] Implement per-feature RLS audit
- [ ] Add server-side stock validation for orders
- [ ] Encrypt sensitive fields (allergies, symptoms) at rest
- [ ] Implement rate-limiting on auth endpoints
- [ ] Add email verification for signups
- [ ] Implement session revocation on suspicious activity

---

## UI/UX Assessment

### Design System

**Theme:** "Amber Whisker" (PawSync theme)

```dart
Primary:      #D4845A (Warm Amber)
Secondary:    #4A7C59 (Sage Green)
Background:   #0F0E0C (Near-Black)
Surface:      #1A1814 (Dark Charcoal)
Text Primary: #F2EDE4 (Off-White)
Text Secondary: #B8B0A4 (Warm Gray)
```

**Typography:**
- Headlines: Playfair Display (Google Fonts)
- Body: DM Sans (Google Fonts)
- Playfair renders at 24px, weight 700, letter-spacing -0.5
- DM Sans renders at 14px, weight 500

### Screen Quality Assessment

#### ✅ Complete & Production-Ready (40 screens)

1. **Auth Screens**
   - LoginScreen: email/password + password reset
   - RegistrationScreen: signup form + profile setup
   - SplashScreen: session check + loading

2. **Core Navigation (MainLayout)**
   - 5 bottom-tab layout
   - Home (feed)
   - Discovery (matching)
   - Pet Care (center FAB)
   - Marketplace
   - Pet Profile

3. **Social Features**
   - HomeScreen (feed)
   - CreatePostScreen
   - CreateStoryScreen
   - StoryViewerScreen
   - PostDetailScreen
   - FeedComponents (PostCard, etc.)

4. **Pet Management**
   - AddPetScreen
   - PetProfileScreen (dual-mode: own/visited)
   - PetFollowersScreen
   - LikedPetsScreen

5. **Care & Health** (Most Complex)
   - PetCareScreen (main care hub)
   - HealthTab (medications, allergies, vaccinations)
   - PetHealthRecordScreen (full medical history)
   - PetGrowthChartScreen (fl_chart visualization)
   - EmergencyCareScreen (static, acceptable)

6. **Chat & Notifications**
   - MessagesListScreen
   - ChatScreen (real-time)
   - NotificationsScreen

7. **Marketplace**
   - MarketplaceScreen
   - ProductDetailScreen
   - CartScreen
   - OrderHistoryScreen

8. **Settings**
   - SettingsScreen (theme, badges, privacy)
   - SearchScreen (multi-domain search)

#### ⚠️ Mock/Stub UI (12 screens)

All have beautiful UI but **zero backend**:

- VetBookingScreen
- CommunityGroupsScreen
- LostAndFoundScreen
- AdoptionCenterScreen
- PetTrainingScreen
- PetInsuranceHubScreen
- PetSitterDashboardScreen
- PetFriendlyPlacesScreen
- PetEventDiscoveryScreen
- PetMemorialScreen
- PetNutritionPlannerScreen
- PetBreedIdentifierScreen (fake scan)
- PetGearReviewsScreen (static)
- PetKnowledgeBaseScreen (static)

### UI/UX Issues

1. **Care Log Race Condition**
   - Loads from SharedPreferences immediately, then fetches from server
   - If network response returns different data, UI flickers
   - **Fix:** Use proper invalidation after server response

2. **Appointment State Split**
   - Appointments loaded in `PetCareController.upcomingAppointments`
   - But created in `HealthController.upsertAppointment` without state sync
   - UI in PetCareScreen won't reflect new appointments until next refresh

3. **Follow Count N+1**
   - `getPetFollowerCount` makes 3 sequential Supabase calls per pet
   - If discovery screen shows 10 pets, that's 30 calls
   - **Fix:** Use Supabase count() aggregation

4. **No Offline UI State**
   - Only PetCareScreen has cache fallback
   - Feed, chat, health, marketplace show loading spinners when offline
   - **Fix:** Implement cache layer for all features

---

## Package Integrations

### Firebase/FCM Integration

**Status:** ✅ **CONFIGURED** (foreground works, background works, deep-linking not implemented)

**Files:**
- `firebase_options.dart` — Generated config
- `push_notification_service.dart` — FCM wrapper
- `push_notification_coordinator.dart` — Auth-triggered registration

**Flow:**

```
App Start
  ↓
FirebaseMessaging.instance.getInitialMessage()
  (handles cold-start tap on notification)
  ↓
FirebaseMessaging.onMessage.listen()
  (handles foreground notification)
  └─ Logs title but doesn't navigate
  ↓
FirebaseMessaging.onBackgroundMessage()
  (handles background/killed state)
  └─ Just logs the message
```

**Issues:**
- [ ] No deep-link navigation from tapped notifications
- [ ] Background handler doesn't update app state
- [ ] No notification deduplication

### Supabase Integration

**Status:** ✅ **COMPREHENSIVE**

**Auth:** Email/password, session management  
**Database:** 26 user tables, 1M+ schema complexity  
**Realtime:** Post likes, comments, messages, notifications channels  
**Storage:** 3 buckets (pet-images, post-media, product-images)

### Image Handling

**Caching:** `cached_network_image` (3.4.1) with default duration  
**Upload:** `image_picker` (1.1.2) for gallery/camera selection  
**Storage:** Paths like `$petId/$timestamp.jpg`

---

## Issues & Gaps

### Critical

| Issue | Severity | Impact | Files |
|-------|----------|--------|-------|
| **Cart No Persistence** | 🔴 Critical | Data loss on app kill | `cart_controller.dart` |
| **No Payment Processing** | 🔴 Critical | Orders can't be paid | `marketplace_repository.dart` |
| **12 Mock Screens** | 🔴 Critical | 25% of screens are non-functional | Various screens |
| **Schema Not Version-Controlled** | 🔴 Critical | DB drift risk, no audit trail | N/A |
| **No Offline Support (except care)** | 🔴 Critical | App breaks on poor connections | All controllers except pet_care |

### High

| Issue | Severity | Impact | Mitigation |
|-------|----------|--------|-----------|
| **Appointment State Split** | 🟠 High | New appointments not visible | Use single source of truth |
| **Profile Upsert Non-Fatal** | 🟠 High | Silent user data loss | Handle or throw error |
| **Follow Count N+1** | 🟠 High | Performance issue at scale | Use Supabase count() |
| **Care Cache Race Condition** | 🟠 High | UI flicker and potential stale data | Proper cache invalidation |
| **FCM No Deep-Linking** | 🟠 High | Notifications don't navigate to content | Implement route handling |
| **Anon Key in Source (Debug)** | 🟠 High | Compromised if APK leaked | Use --dart-define for releases |

### Medium

| Issue | Severity | Impact |
|-------|----------|--------|
| Package Name Mismatch (pet_dating_app vs PetFolio) | 🟡 Medium | Confusion in platform config |
| Health Appointment Disconnect | 🟡 Medium | Two controllers managing same entity |
| Stock Validation Client-Only | 🟡 Medium | Inventory errors possible |
| Stream Listener Race in Auth | 🟡 Medium | Potential TOCTOU on rapid auth changes |

### Low

| Issue | Severity | Impact |
|-------|----------|--------|
| No Comment Author Details | 🟢 Low | Can't identify commenter in feed |
| `pet_activity_logs` Unused | 🟢 Low | Dead code in schema |
| `pet_care_ai_plans` Unused | 🟢 Low | Placeholder never populated |
| `order_items` Redundant | 🟢 Low | Orders also stores items as JSONB |
| Missing `location` in posts | 🟢 Low | Post says "location" but schema has no column |

---

## Code Quality Metrics

### Architecture Quality: 8/10

✅ **Strengths:**
- Clear separation of concerns (MVC-inspired)
- Consistent naming (snake_case files, PascalCase classes, camelCase methods)
- Immutable state with copyWith()
- Proper async handling

⚠️ **Weaknesses:**
- Some controllers do too much (pet_care_controller: 500+ lines)
- No dependency injection (hardcoded repositories)
- Limited abstraction in repositories (direct Supabase calls)

### State Management Quality: 8/10

✅ **Strengths:**
- Proper use of Riverpod Notifier pattern
- FutureProvider for async operations
- Watch/listen patterns used correctly

⚠️ **Weaknesses:**
- No state invalidation strategy documented
- Cache-first loading in care logs (hard to reason about)
- No loading progress reporting (just isLoading boolean)

### Test Coverage: 0/10

⚠️ **CRITICAL:** No unit or integration tests found in repository

**Recommendation:** Implement:
- [ ] Unit tests for all controllers and models (target: 80%+ coverage)
- [ ] Integration tests for key user flows
- [ ] E2E tests using `flutter_driver` + `marionette_flutter`

### Code Consistency: 8/10

✅ **Strengths:**
- Consistent error handling patterns
- Consistent comment style
- Lint rules enforced (flutter_lints)

⚠️ **Weaknesses:**
- Some controllers use dev.log, others use print()
- Inconsistent null coalescing patterns
- Some hardcoded strings not in theme

---

## Recommendations

### Priority 1: Critical Production Issues (Q2 2026)

1. **Implement Cart Persistence**
   ```dart
   // Add cart_items table to Supabase
   // Or serialize cart to SharedPreferences with expiry
   ```

2. **Add Payment Processing**
   - Integrate Stripe or similar payment provider
   - Validate stock server-side before order creation
   - Add payment status tracking to orders table

3. **Create Supabase Migration System**
   - Version-control all schema migrations
   - Use `flyway` or custom migration runner
   - Document breaking changes

4. **Implement FCM Deep-Linking**
   ```dart
   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
     if (message.data['entityType'] == 'post') {
       context.go('/post/${message.data['entityId']}');
     }
   });
   ```

### Priority 2: High-Impact Improvements (Q3 2026)

1. **Add Test Suite**
   - Unit tests for all controllers (using mocktail)
   - Integration tests for critical flows
   - E2E tests using flutter_driver + marionette

2. **Implement Offline Support**
   - Add Hive or Isar for local database
   - Cache feeds, chat messages, products
   - Sync strategy: optimistic updates + eventual consistency

3. **Fix Appointment State Management**
   - Single source of truth in `pet_care_controller`
   - Or move to separate `appointment_controller`
   - Ensure notifications trigger state updates

4. **Optimize Follow Count Queries**
   ```dart
   // Instead of fetching all and counting
   final count = await supabase
     .from('follows')
     .count(CountOption.exact)
     .eq('followed_user_id', userId);
   ```

### Priority 3: Feature Completions (Q4 2026)

1. **Implement Mock Screens**
   - Start with highest-value: vet_booking, adoption_center
   - Add Supabase tables for each
   - Wire up CRUD operations

2. **Add AI Care Plans**
   - Populate `pet_care_ai_plans` table
   - Integrate with OpenAI API for personalized recommendations
   - Store in JSONB, display in nutrition planner

3. **Implement Breed Identifier**
   - Replace fake scan with ML Kit vision (on-device)
   - Or call Google Lens API / Clarifai
   - Store identification history

4. **Add Real-Time Typing Indicators**
   - Schema supports message_type='system'
   - Emit typing notifications on message entry
   - Display in chat bubble

---

## Summary Checklist

| Category | Status | Notes |
|----------|--------|-------|
| **Architecture** | ✅ Mature | Clean MVC with Riverpod |
| **Auth** | ✅ Secure | Supabase + JWT, RLS enabled |
| **Database** | ⚠️ Incomplete | Schema not version-controlled |
| **API Integration** | ✅ Comprehensive | Supabase + Firebase |
| **State Management** | ✅ Proper | Riverpod NotifierProvider |
| **Testing** | 🔴 Missing | 0% coverage |
| **Documentation** | ⚠️ Partial | CLAUDE.md exists, no API docs |
| **Performance** | ⚠️ Sub-optimal | N+1 queries, no offline support |
| **UI/UX** | ✅ Polished | 40 complete screens, 12 stubs |
| **Security** | ✅ Good | RLS + JWT, minor issues remain |

---

## Appendix: Key Files Reference

### Controllers (State Management)
- `auth_controller.dart` — Session + auth state
- `bootstrap_controller.dart` — Data hydration orchestration
- `pet_controller.dart` — Pet list + active pet
- `feed_controller.dart` — Social feed + realtime
- `pet_care_controller.dart` — Care + gamification (most complex)
- `health_controller.dart` — Health records
- `match_controller.dart` — Pet discovery
- `chat_controller.dart` — Messaging
- `notification_controller.dart` — Notifications
- `marketplace_controller.dart` — Products
- `cart_controller.dart` — Shopping cart (client-side)
- `follow_controller.dart` — Follow relationships
- `search_controller.dart` — Multi-domain search
- `pet_expense_controller.dart` — Expenses
- `push_notification_coordinator.dart` — FCM registration

### Models (Data)
- `user_model.dart` — User profile
- `pet_model.dart` — Pet profile
- `post_model.dart` — Social post
- `story_model.dart` — Ephemeral story
- `pet_care_log_model.dart` — Daily care tracking
- `pet_health_models.dart` — Medications, allergies, etc.
- `pet_health_extended_models.dart` — Vet appointments, vaccinations
- `message_model.dart` — Chat message
- `chat_thread_model.dart` — Chat thread
- `match_request_model.dart` — Matching
- `notification_model.dart` — Notification
- `product_model.dart` — Marketplace product
- `order_model.dart` — Order
- `cart_item_model.dart` — Cart item
- `care_badge_model.dart` — Gamification badge
- `pet_activity_log_model.dart` — Activity tracking
- `pet_expense_model.dart` — Expense tracking

### Repositories (Data Access)
- `auth_repository.dart` — Auth + profiles
- `pet_repository.dart` — Pet CRUD
- `feed_repository.dart` — Posts + stories
- `health_repository.dart` — Health records
- `pet_care_repository.dart` — Care logs + gamification
- `match_repository.dart` — Matching
- `chat_repository.dart` — Messages
- `notification_repository.dart` — Notifications
- `marketplace_repository.dart` — Products + orders
- `follow_repository.dart` — Follow relationships
- `pet_expense_repository.dart` — Expenses
- `search_repository.dart` — Multi-domain search
- `push_token_repository.dart` — FCM tokens

### Views (UI)
- `main_layout.dart` — Bottom nav shell
- `home_screen.dart` — Feed
- `discovery_screen.dart` — Pet matching
- `pet_care_screen.dart` — Care hub
- `marketplace_screen.dart` — Products
- `pet_profile_screen.dart` — Pet details
- `add_pet_screen.dart` — New pet
- `health_tab.dart` — Health records

---

**Report Generated:** May 5, 2026  
**Next Review:** August 2026  
**Prepared by:** Claude Code Analysis Agent
