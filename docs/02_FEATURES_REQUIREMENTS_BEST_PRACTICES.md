# PetSphere Flutter - Features, Requirements & Best Practices Guide

**Document Version:** 1.0  
**Last Updated:** May 5, 2026  
**Target Audience:** Developers, Product Managers, QA Engineers  

---

## Table of Contents

1. [Feature Specifications](#feature-specifications)
2. [User Stories & Acceptance Criteria](#user-stories--acceptance-criteria)
3. [Functional & Non-Functional Requirements](#functional--non-functional-requirements)
4. [Implementation Issues & Fixes](#implementation-issues--fixes)
5. [Flutter Best Practices Applied](#flutter-best-practices-applied)
6. [Supabase Best Practices](#supabase-best-practices)
7. [UI/UX Best Practices](#uiux-best-practices)
8. [Security Best Practices](#security-best-practices)
9. [Testing Strategy](#testing-strategy)
10. [Automated Testing Blueprint](#automated-testing-blueprint)

---

## Feature Specifications

### Core Feature 1: User Authentication & Profiles

#### Specification Document

**Epic:** Identity & Onboarding  
**Priority:** P0 (Critical)  
**Complexity:** High  

**Feature Description:**
Allow users to create accounts, log in securely, and manage their public-facing profiles with avatar uploads and profile customization.

#### User Stories

**US-001: User Registration**

As a new pet owner,  
I want to sign up with an email and password,  
So that I can create an account and start managing my pets.

**Acceptance Criteria:**
- [ ] User can enter email and password on registration screen
- [ ] Email format is validated (must be valid email)
- [ ] Password must be ≥ 8 characters and contain uppercase + lowercase + digit
- [ ] Success shows "Account created" toast and navigates to home
- [ ] Duplicate email shows error: "Email already registered"
- [ ] Network error shows retry button
- [ ] User is auto-logged-in after successful registration

**Functional Requirements:**
- Email uniqueness validated via Supabase Auth
- Password hashed via bcrypt (Supabase handles)
- User profile row created atomically
- Welcome email sent (if configured in Supabase)

**Non-Functional Requirements:**
- Registration completes in <2 seconds on 4G
- Supports 50+ sign-ups/minute burst
- Email validation latency: <100ms

---

**US-002: User Login**

As a registered user,  
I want to log in with my email and password,  
So that I can access my pet data and social features.

**Acceptance Criteria:**
- [ ] Login screen shows email and password fields
- [ ] Credentials validated against Supabase Auth
- [ ] Success navigates to home, shows user's pets
- [ ] Incorrect password shows: "Invalid credentials"
- [ ] Non-existent email shows: "Account not found"
- [ ] Network timeout shows: "Connection failed - retry?"
- [ ] Session persists across app restarts
- [ ] Logout clears session and returns to login

**Functional Requirements:**
- JWT tokens stored securely by Supabase SDK
- Token auto-refresh on expiry
- Session invalidated on logout
- FCM token deregistered on logout

**Non-Functional Requirements:**
- Login <1.5 seconds on 4G
- Session valid for 24 hours (or per Supabase policy)
- Support 1000+ concurrent sessions

---

**US-003: Profile Management**

As a logged-in user,  
I want to edit my profile (name, bio, location, avatar),  
So that other users can learn about me.

**Acceptance Criteria:**
- [ ] User can edit name, bio, location
- [ ] User can upload avatar (up to 5MB JPEG/PNG)
- [ ] Avatar preview shown immediately
- [ ] Save button disabled until changes made
- [ ] Success shows "Profile saved" toast
- [ ] Profile appears on own pet's profile immediately
- [ ] Profile visible to other users within 2 seconds

**Functional Requirements:**
- Avatar uploaded to `pet-images/avatars/$userId/$timestamp.jpg`
- Avatar resized to 500x500 before upload
- Profile image URL stored in profiles.profile_image_url
- RLS policy ensures only user can modify own profile

**Non-Functional Requirements:**
- Avatar upload: <3 seconds on 4G
- Image resize: <500ms on device
- Profile sync to other devices: <2 seconds

---

#### Implementation Assessment

**Current Status:** ✅ **COMPLETE**

**Strengths:**
- Proper session management with Supabase Auth stream
- `_isPerformingAuthAction` guard prevents TOCTOU race
- Avatar upload handles retries
- Non-fatal profile upsert gracefully degrades

**Issues Found:**
1. ⚠️ Profile upsert marked "non-fatal" — silently fails if RLS INSERT fails
   - **Fix:** Throw error and show user: "Failed to create profile. Please try again."
   
2. ⚠️ No email verification flow for signups
   - **Fix:** Add `signUpOptions(emailRedirectTo: supabaseRedirectUrl)` for confirmation
   
3. ⚠️ Password reset flow exists but not wired to UI
   - **Fix:** Add "Forgot Password?" link in LoginScreen

**Recommended Improvements:**

```dart
// BEFORE (silent failure)
try {
  await supabase.from('profiles').upsert([profileData]);
} on Exception {
  // non-fatal
  developer.log('Profile upsert failed', level: 800);
}

// AFTER (proper error handling)
try {
  await supabase.from('profiles').upsert([profileData]);
} catch (e) {
  state = state.copyWith(error: 'Failed to save profile. Please try again.');
  rethrow; // Let caller decide how to handle
}
```

---

### Core Feature 2: Pet Management

#### Specification Document

**Epic:** Pet Profiles & Data  
**Priority:** P0 (Critical)  
**Complexity:** High  

**Feature Description:**
Allow users to create, manage, and display multiple pet profiles with images, metadata, and breed information.

#### User Stories

**US-004: Create Pet Profile**

As a pet owner,  
I want to create a profile for my pet with name, breed, age, and photos,  
So that my pet's information is complete and visible to others.

**Acceptance Criteria:**
- [ ] User can enter pet name, breed (autocomplete), animal type, age
- [ ] User can upload up to 5 photos (drag-and-drop or gallery pick)
- [ ] First photo becomes profile image
- [ ] Age measured in years (decimal allowed: 1.5 years)
- [ ] Save creates pet record and navigates to pet profile
- [ ] Photos optimized and uploaded to `pet-images/$petId/`
- [ ] Pet immediately appears in user's pet list

**Functional Requirements:**
- Breed autocomplete via hardcoded list or API
- Animal type restricted enum: Dog, Cat, Bird, Rabbit, Guinea Pig, Hamster, Fish, Other
- Age validation: 0 to 50 years
- Photo upload: max 5MB each, auto-resize to 1024x1024
- `is_verified` flag remains false until admin verification

**Non-Functional Requirements:**
- Pet creation: <2 seconds for 5 photos
- Photo upload parallelization: upload 3 photos concurrently
- Pet appears in feed within 1 second

---

**US-005: Edit Pet Profile**

As a pet owner,  
I want to update my pet's information and photos,  
So that their profile stays current.

**Acceptance Criteria:**
- [ ] User can edit name, breed, age, bio, weight, calorie goal
- [ ] User can add/remove photos
- [ ] Changes saved immediately on "Save" tap
- [ ] "Save" button disabled when no changes
- [ ] Network error shows retry option

**Functional Requirements:**
- Breed change triggers related content refresh (e.g., nutrition tips)
- Weight update appends to `pet_weight_logs` table
- Photos are versioned (new upload = new filename)
- Old photos not deleted (keep for history)

**Non-Functional Requirements:**
- Edit save: <1.5 seconds
- Changes visible to other users: <2 seconds

---

**US-006: Select Active Pet**

As a multi-pet owner,  
I want to select which pet is "active" for creating posts and care logs,  
So that content is attributed to the correct pet.

**Acceptance Criteria:**
- [ ] Active pet selector visible on home screen
- [ ] Tapping selector shows dropdown of owned pets
- [ ] Selected pet highlighted visually
- [ ] Selection persists across app sessions (or until manually changed)
- [ ] All subsequent posts/care logs use active pet

**Functional Requirements:**
- `activePetProvider` in Riverpod tracks selected pet
- Selection stored in memory (no DB persistence required)
- Default to first pet on login

**Non-Functional Requirements:**
- Selection change: instant (<50ms)
- No network calls on active pet change

---

#### Implementation Assessment

**Current Status:** ✅ **COMPLETE**

**Strengths:**
- Proper pet image upload with retry logic
- Active pet pattern correctly implemented with `activePetProvider`
- RLS ensures users can only view/edit own pets

**Issues Found:**
1. ⚠️ Breed field is free-text, not autocomplete
   - **Fix:** Add breed autocomplete list or API endpoint
   
2. ⚠️ No photo ordering/reordering UI
   - **Fix:** Allow drag-to-reorder images; save order to images[] array

3. ⚠️ Photo deletion doesn't clean up storage
   - **Fix:** Call `supabase.storage.from('pet-images').remove(path)` on delete

**Recommended Improvements:**

```dart
// Add breed autocomplete
final breedSuggestions = [
  'Labrador Retriever', 'Golden Retriever', 'German Shepherd',
  'French Bulldog', 'Bulldog', 'Poodle', 'Beagle', 'Yorkshire Terrier',
  // ... 100+ breeds from AKC or Breed API
];

// Add photo reordering
Future<void> reorderPhotos(List<String> newOrder) async {
  await petRepository.updatePetImages(activePet!.id, newOrder);
  state = state.copyWith(activePet: state.activePet!.copyWith(images: newOrder));
}
```

---

### Core Feature 3: Social Feed

#### Specification Document

**Epic:** Social Engagement  
**Priority:** P0 (Critical)  
**Complexity:** Very High  

**Feature Description:**
Allow users to post content (images/videos), like/comment, and see a real-time feed of other pets' activities.

#### User Stories

**US-007: Create Social Post**

As a pet owner,  
I want to post a photo/video with a caption and location,  
So that I can share my pet's activities with the community.

**Acceptance Criteria:**
- [ ] User can select image/video from gallery or camera
- [ ] User can add caption (up to 500 chars, emoji support)
- [ ] User can add location (text input or location picker)
- [ ] User can tag other pets (autocomplete search)
- [ ] Preview shown before posting
- [ ] Post created and appears in feed immediately
- [ ] Post visible to other users within 2 seconds
- [ ] Media uploaded to `post-media/$postId/`

**Functional Requirements:**
- Media validation: JPEG/PNG <10MB (photos), MP4 <100MB (videos)
- Caption text supports emoji, hashtags, @mentions
- Tag mentions stored in `tagged_pet_ids` and `tagged_pet_names`
- Post RLS: visible to all (unless future private mode)
- Posted timestamp: server-side `now()` (prevent client clock skew)

**Non-Functional Requirements:**
- Post creation: <3 seconds (includes photo upload)
- Feed refresh: <1 second
- Real-time like/comment updates: <200ms

---

**US-008: Like & Comment on Posts**

As a user scrolling the feed,  
I want to like posts and add comments,  
So that I can engage with other pets.

**Acceptance Criteria:**
- [ ] Tapping heart icon likes post (visual feedback: red heart + animation)
- [ ] Double-tap image also likes post
- [ ] Already-liked post shows red heart
- [ ] Like count updates in real-time
- [ ] User can add comment via comment box
- [ ] Comments appear immediately (optimistic update)
- [ ] Comment count increases instantly
- [ ] Liking generates notification for post owner

**Functional Requirements:**
- Like optimistic update: visual feedback before server response
- Rollback on failure: revert visual state + show error
- Comment submitted to `comments` table
- Notifications auto-sent to post owner (unless muted)
- Like/comment Realtime subscriptions via Supabase channels

**Non-Functional Requirements:**
- Like response: <100ms
- Comment posting: <1 second
- Real-time updates: <200ms latency

---

**US-009: Browse & Share Stories**

As a user,  
I want to view ephemeral stories from pets I follow,  
So that I can see daily moments in a Instagram-like feed.

**Acceptance Criteria:**
- [ ] Stories display in a ring at top of home screen
- [ ] Tapping story opens full-screen viewer
- [ ] Stories auto-advance every 5 seconds
- [ ] Tap right side to advance, left to rewind
- [ ] Tap X to close
- [ ] Stories expire 24 hours after creation
- [ ] Expired stories grayed out in ring
- [ ] Story creator and timestamp visible

**Functional Requirements:**
- Stories expire via `expires_at = now() + interval '24 hours'`
- Expired stories filtered out on fetch
- Story table: `id`, `pet_id`, `media_url`, `caption`, `created_at`, `expires_at`
- VideoPlayer used for MP4 stories
- Video muted by default (tap unmute button)

**Non-Functional Requirements:**
- Story viewer loads: <1 second
- Story advance: <50ms
- Real-time story delivery: <2 seconds from creation

---

#### Implementation Assessment

**Current Status:** ✅ **COMPLETE**

**Strengths:**
- Optimistic updates for likes and comments
- Real-time subscriptions properly implemented
- Post and story models fully functional
- Feed pagination ready

**Issues Found:**
1. ⚠️ Comment author details not returned (can't show commenter name/avatar in feed)
   - **Fix:** Join comments with pets table to fetch commenter pet data

2. ⚠️ Post model missing `location` column (schema has no location field)
   - **Fix:** Add `location` text column to posts table

3. ⚠️ Story expiry not enforced in list query (expired stories shown with visual indicator only)
   - **Fix:** Filter: `.lt('expires_at', 'now()')`

4. ⚠️ No Realtime subscription cleanup on screen exit
   - **Fix:** Use `RealtimeChannel.unsubscribe()` in dispose

**Recommended Improvements:**

```dart
// Fix comment author details
final comments = await supabase
  .from('comments')
  .select('''
    id, post_id, pet_id, text, created_at,
    pets(id, name, profile_image_url)
  ''')
  .eq('post_id', postId)
  .order('created_at', ascending: false);

// Proper expiry filtering
final stories = await supabase
  .from('stories')
  .select()
  .gt('expires_at', 'now()')
  .order('created_at', descending: true);

// Cleanup on dispose
@override
void dispose() {
  _likeChannel?.unsubscribe();
  _commentChannel?.unsubscribe();
  super.dispose();
}
```

---

### Core Feature 4: Pet Care & Gamification

#### Specification Document

**Epic:** Pet Health & Wellness  
**Priority:** P0 (Critical)  
**Complexity:** Very High  

**Feature Description:**
Track daily pet care (feeding, hydration, exercise), maintain streaks, earn achievements, and gamify care with badges and points.

#### User Stories

**US-010: Log Daily Pet Care**

As a responsible pet owner,  
I want to log daily meals, water, and exercises,  
So that I can track and optimize my pet's health.

**Acceptance Criteria:**
- [ ] Home screen shows daily care checklist for active pet
- [ ] Checklist items: breakfast, lunch, dinner, water, exercise, medications, grooming
- [ ] User can toggle items as complete
- [ ] Progress bar shows meals vs daily calorie goal
- [ ] Progress bar shows water vs daily water goal
- [ ] Save button creates/updates care log
- [ ] Today's log loads from cache first (SharedPreferences)
- [ ] Network sync happens in background
- [ ] Yesterday's logs show in history tab

**Functional Requirements:**
- Care log model: `pet_care_logs` table with pet_id + log_date (unique)
- Feeding: breakfast_kcal, dinner_kcal, snack_kcal tracked
- Water: water_cups (cumulative per day)
- Tasks: JSONB array of `{key, done, title, subtitle, icon}`
- Onboarding: first pet logs load custom tasks from `pet_care_onboarding`
- Cache layer: care logs in SharedPreferences before network

**Non-Functional Requirements:**
- Care log save: <1 second (optimistic on cache)
- Calorie/water progress: real-time (no refresh)
- History loads: <500ms from cache

---

**US-011: Maintain Care Streaks**

As a pet owner,  
I want to see my pet's care streak (days in a row with complete care),  
So that I'm motivated to maintain consistent pet health.

**Acceptance Criteria:**
- [ ] Streak display shows: "7 day streak 🔥"
- [ ] Streak increments when daily care is marked complete
- [ ] Streak resets if a day is missed
- [ ] Can use "streak freeze" 2x per week to skip one day
- [ ] Streak freeze resets on Monday
- [ ] Best streak shown in achievements screen
- [ ] Weekly progress shows which days are complete (7 checkbox grid)

**Functional Requirements:**
- `pet_care_gamification` table tracks:
  - `best_streak_days`: all-time best
  - `week_completed_mask`: 7-bit bitmask (0-127) for week's days
  - `streak_freezes_available`: 2 (reset on Monday)
  - `week_start_monday`: date of current week start
- Streak calculated as: consecutive days with `isCompleteForStreak=true`
- Freeze used: decrements `streak_freezes_available`, sets day as complete

**Non-Functional Requirements:**
- Streak calculation: <100ms
- Freeze application: <500ms (one API call)

---

**US-012: Earn & Display Achievement Badges**

As a pet owner,  
I want to earn badges for care milestones,  
So that I feel rewarded for my efforts.

**Acceptance Criteria:**
- [ ] Badges awarded automatically on milestone:
  - 7-day streak → "On Fire" badge
  - 30-day streak → "Care Champion" badge
  - 100 total care points → "Pet Parent" badge
  - All medications taken on schedule → "Medic Master" badge
  - All vaccinations completed → "Vax Guardian" badge
  - 0 overdue care tasks for 14 days → "Perfect Pet" badge
- [ ] Badge display on pet profile (user-selected subset)
- [ ] Badge showcase screen shows all unlocked + next unlock condition
- [ ] Badges are public (visible on public profile if user enables)

**Functional Requirements:**
- `care_badge_definitions` table (read-only, 6 hardcoded badges)
- `pet_care_badge_unlocks` table tracks unlock timestamp
- Badge slug: 'on_fire', 'care_champion', 'pet_parent', 'medic_master', 'vax_guardian', 'perfect_pet'
- Unlock logic in `CareGamificationLogic.buildNext()`
- User can pin badges to public profile via Settings

**Non-Functional Requirements:**
- Badge unlock check: <200ms
- Badge display load: <100ms

---

**US-013: Accumulate Care Points**

As a pet owner,  
I want to earn points for daily care,  
So that I'm motivated to maintain consistency.

**Acceptance Criteria:**
- [ ] Daily care completion awards +10 points (once per calendar day)
- [ ] Points capped at +10/day (no bonus for over-completion)
- [ ] Points display on profile and gamification screen
- [ ] Total points never decrease (no deductions)
- [ ] Points tracked per pet (not user-wide)

**Functional Requirements:**
- `pet_care_gamification.total_care_points` accumulates
- Idempotent: `last_care_point_awarded_on` prevents double-award same day
- Daily point award logic in controller: check if `today != lastAwardDate`, then `+10`
- Points persisted to DB on save

**Non-Functional Requirements:**
- Points award: instant (<50ms)
- Points display refresh: <100ms

---

**US-014: Complete Pet Care Onboarding**

As a new pet owner,  
I want to answer care questions about my pet,  
So that the app can personalize care recommendations.

**Acceptance Criteria:**
- [ ] Onboarding shown first time pet created
- [ ] Multi-step flow (6-8 screens):
  1. Species & breed
  2. Age & weight
  3. Diet type (dry kibble, wet food, raw, mixed)
  4. Activity level (low, moderate, high)
  5. Living situation (apartment, house, farm)
  6. Health focus (general wellness, weight management, allergies, senior care)
- [ ] Save answers to `pet_care_onboarding.data` (JSONB)
- [ ] Answers used to customize care checklist and nutrition tips
- [ ] "Skip" button available but recommended to complete

**Functional Requirements:**
- Onboarding data structure (JSONB):
  ```json
  {
    "species": "dog",
    "breed": "labrador",
    "age_band": "adult",
    "diet_type": "dry_kibble",
    "activity": "high",
    "multi_pet_home": false,
    "health_focus": "general",
    "living_situation": "house",
    "gender": "male",
    "is_neutered": true,
    "primary_goal": "maintain_health",
    "grooming_frequency": "weekly"
  }
  ```
- Completed onboarding populates custom care tasks (not hardcoded)

**Non-Functional Requirements:**
- Onboarding flow: <5 minutes for user to complete
- Load customized tasks: <500ms after answering

---

#### Implementation Assessment

**Current Status:** ✅ **COMPLETE** (with issues)

**Strengths:**
- Sophisticated gamification with streaks and badges
- Proper cache-first loading (SharedPreferences)
- Comprehensive JSONB data structures for flexibility
- Idempotent point awards (prevents double-award)

**Issues Found:**
1. 🔴 Care Cache Race Condition
   - Loads from SharedPreferences immediately, then fetches from server
   - If server returns different data, UI flickers
   - **Fix:** Proper cache invalidation after server response

   ```dart
   // CURRENT (race condition)
   PetCareState build() {
     state = CareCache.getTodayLog(activePetId) ?? PetCareState(...);
     refresh(); // Network fetch in background
   }
   
   // FIXED (cache-aside pattern)
   @override
   PetCareState build() {
     ref.listen<AsyncValue>(todayCareLogProvider, (prev, next) {
       next.whenData((log) {
         CareCache.saveTodayLog(log); // Update cache after server
       });
     });
     final cached = CareCache.getTodayLog(activePetId);
     return cached ?? PetCareState.loading();
   }
   ```

2. ⚠️ Appointment State Not Synced
   - `HealthController.upsertAppointment` saves to DB but doesn't update `PetCareController.upcomingAppointments`
   - New appointments not visible until full refresh
   - **Fix:** Emit notification or use shared provider

3. ⚠️ Care Task Customization Not Fully Implemented
   - Onboarding saves to JSONB but tasks always use hardcoded defaults
   - **Fix:** Load tasks from onboarding.data if available

**Recommended Improvements:**

```dart
// Fix race condition: proper cache invalidation
class PetCareNotifier extends Notifier<PetCareState> {
  @override
  PetCareState build() {
    _setupListeners();
    final cached = _loadFromCache();
    _fetchAndSync(); // Don't await, let listener handle update
    return cached;
  }
  
  void _setupListeners() {
    // Listen for any changes to active pet
    ref.listen(activePetProvider, (prev, next) {
      if (prev?.id != next?.id) invalidate();
    });
  }
  
  Future<void> _fetchAndSync() async {
    try {
      final fresh = await petCareRepository.fetchCareLog(...);
      CareCache.saveTodayLog(fresh);
      state = state.copyWith(
        todayLog: fresh,
        isLoading: false,
        error: null
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

// Fix appointment sync: shared provider
final todaysAppointmentsProvider = 
  FutureProvider.family((ref, String petId) async {
    return await healthRepository.fetchAppointmentsForDate(petId, today);
  });

// Use in both health and pet_care controllers
```

---

### Core Feature 5: Health Tracking

#### Specification Document

**Epic:** Pet Health & Medical Records  
**Priority:** P0 (Critical)  
**Complexity:** Very High  

**Feature Description:**
Track medications, allergies, vaccinations, vet appointments, and symptoms. Maintain comprehensive health records.

#### User Stories

**US-015: Manage Pet Medications**

As a pet owner with a medicated pet,  
I want to track medications (name, dose, frequency, schedule),  
So that I never miss a dose.

**Acceptance Criteria:**
- [ ] User can add medication with: name, dose, frequency (once/twice/thrice daily, weekly, monthly, as-needed)
- [ ] User can set times of day for medication
- [ ] Start date and optional end date
- [ ] Purpose (optional): heartworm, antibiotic, pain management, etc.
- [ ] Medication list shows status (active, paused, completed)
- [ ] User can pause/resume medications
- [ ] Daily medication doses appear in care checklist
- [ ] Mark dose as given/skipped with timestamp
- [ ] Overdue doses marked in red with alert

**Functional Requirements:**
- `pet_medications` table: id, pet_id, name, dose, frequency, times_of_day[], start_date, end_date, status
- `pet_medication_doses` table: id, medication_id, pet_id, scheduled_for, given_at, skipped, notes
- Frequency enum: 'once_daily', 'twice_daily', 'three_times_daily', 'weekly', 'monthly', 'as_needed', 'other'
- Doses generated in advance (e.g., 30 days) based on frequency
- Overdue dose: `scheduled_for < now() AND given_at IS NULL AND NOT skipped`

**Non-Functional Requirements:**
- Add medication: <2 seconds
- Dose mark as given: <1 second
- Overdue alert calculation: <100ms

---

**US-016: Track Allergies & Reactions**

As a pet owner,  
I want to document my pet's allergies (food, environmental, drug),  
So that I can avoid triggers and warn vets.

**Acceptance Criteria:**
- [ ] User can add allergy: allergen, type (food/environmental/drug/insect/other), severity (mild/moderate/severe/life-threatening)
- [ ] User can document reaction symptoms
- [ ] Diagnosed date tracked
- [ ] Allergies marked active/inactive
- [ ] Allergy list shows severity with visual indicator (colors)
- [ ] Mark allergy as resolved (toggle active flag)

**Functional Requirements:**
- `pet_allergies` table: id, pet_id, allergen, allergen_type, severity, reaction, diagnosed_on, is_active, notes
- Severity color-coding: mild=yellow, moderate=orange, severe=red, life_threatening=deep-red
- Allergies exported in health records
- Shared with vets (future: QR code share)

**Non-Functional Requirements:**
- Add allergy: <1.5 seconds
- Allergies visible in export: <2 seconds

---

**US-017: Log Vaccinations & Due Dates**

As a pet owner,  
I want to track vaccinations (type, date, next due),  
So that I stay on top of immunizations.

**Acceptance Criteria:**
- [ ] Vaccination list shows: vaccine name, status (scheduled/completed), completion/due date
- [ ] User can add scheduled vaccination (future date)
- [ ] Mark vaccination as completed with date
- [ ] Next due date auto-calculated (e.g., rabies = annual, DHPP = 3-year)
- [ ] Overdue vaccinations highlighted in red
- [ ] Vet name and batch number optional

**Functional Requirements:**
- `pet_vaccinations` table: id, pet_id, vaccine_name, status, scheduled_for, completed_on, next_due_date, administered_by, batch_number, notes
- Vaccination schedules hardcoded (or fetched from reference table)
- Overdue: `next_due_date < today() AND status='scheduled'`

**Non-Functional Requirements:**
- Add vaccination: <1 second
- Overdue alert check: <50ms

---

**US-018: Schedule & Track Vet Appointments**

As a pet owner,  
I want to schedule vet appointments and track their outcomes,  
So that I stay proactive about pet health.

**Acceptance Criteria:**
- [ ] User can schedule appointment: title, vet name, date/time, location, notes
- [ ] Appointment type: routine, emergency, specialist, dental, surgery, follow-up
- [ ] Appointment list shows upcoming (sorted by date)
- [ ] Completed appointments archived
- [ ] Appointment reminders 24 hours before (in-app notification)
- [ ] Cost tracking optional
- [ ] Link to pet care/health records after appointment

**Functional Requirements:**
- `pet_vet_appointments` table: id, pet_id, title, doctor, scheduled_at, notes, status (scheduled/completed/cancelled), appointment_type, location, cost
- Reminders triggered via background scheduler (or local notification at day-before)
- Completed appointments don't display in "upcoming" list

**Non-Functional Requirements:**
- Schedule appointment: <2 seconds
- Appointment reminder: deliver 24h before (±10 min accuracy)

---

#### Implementation Assessment

**Current Status:** ✅ **COMPLETE**

**Strengths:**
- Comprehensive medication tracking with dose scheduling
- Flexible allergy documentation with severity levels
- Vaccination scheduling with auto-due dates
- Full appointment CRUD

**Issues Found:**
1. ⚠️ Medication Dose Generation Not Automated
   - `pet_medication_doses` rows created manually, not generated based on frequency
   - **Fix:** Create scheduled doses in batch when medication is created

2. ⚠️ Appointment Overdue Alerts Not Implemented
   - No Realtime check for overdue appointments
   - **Fix:** Add alert in health_controller.build()

3. ⚠️ Vaccination Recurrence Rules Hardcoded
   - No configurable schedule (e.g., rabies every 3 years)
   - **Fix:** Create `vaccination_schedules` reference table

**Recommended Improvements:**

```dart
// Fix medication dose generation
Future<void> addMedication(PetMedication med) async {
  // Save medication
  final medId = await repository.addMedication(med);
  
  // Generate doses for next 30 days based on frequency
  final doses = _generateDoses(medId, med.frequency, med.timesOfDay);
  await Future.forEach(doses, (dose) => 
    repository.addMedicationDose(dose)
  );
}

// Fix appointment overdue alert
@override
HealthState build() {
  final appointments = ref.watch(upcomingAppointmentsProvider);
  
  appointments.whenData((appts) {
    final overdue = appts.where((a) => 
      a.scheduledAt.isBefore(DateTime.now()) &&
      a.status == 'scheduled'
    ).toList();
    
    if (overdue.isNotEmpty) {
      state = state.copyWith(
        appointmentAlerts: overdue,
        alertCount: overdue.length
      );
    }
  });
  
  return state;
}
```

---

### Core Feature 6: Marketplace

#### Specification Document

**Epic:** Commerce & Pet Products  
**Priority:** P1 (High)  
**Complexity:** High  

**Feature Description:**
Browse pet products, manage shopping cart, place orders, and track purchase history.

#### User Stories

**US-019: Browse & Filter Products**

As a pet owner,  
I want to browse pet products by category (food, toys, gear, etc.),  
So that I can find items for my pet.

**Acceptance Criteria:**
- [ ] Marketplace shows product grid with image, name, price, rating
- [ ] Filter by category: food, toys, grooming, health, accessories
- [ ] Search box searches product names/descriptions
- [ ] Results paginated (20 per page)
- [ ] Product cards show: thumbnail, name, price, rating, review count
- [ ] Bestsellers marked with badge

**Functional Requirements:**
- `products` table: id, vendor_id, name, price, description, images[], stock, category, rating, review_count, tags[], is_bestseller
- Images stored in `product-images/` bucket
- Pagination: skip/limit params

**Non-Functional Requirements:**
- Product list loads: <1 second
- Filter/search response: <500ms
- Images lazy-loaded with placeholder

---

**US-020: Add to Cart & Checkout**

As a shopper,  
I want to add products to cart and checkout,  
So that I can purchase pet items.

**Acceptance Criteria:**
- [ ] Add product to cart (client-side only, no cart table)
- [ ] Cart shows: items, quantities, subtotal, estimated shipping
- [ ] Increment/decrement quantity
- [ ] Remove items
- [ ] Checkout button creates order and shows confirmation
- [ ] Order saved to `orders` table
- [ ] Order history accessible from settings

**Functional Requirements:**
- `cart_controller` in-memory only (no persistence)
- ⚠️ **Issue:** Cart lost on app kill
- Order model: id, user_id, items (JSONB), total, status, created_at
- Order status: pending → confirmed → shipped → delivered

**Non-Functional Requirements:**
- Add to cart: <100ms
- Checkout: <2 seconds
- Order appears in history: <1 second

---

**US-021: Track Order Status**

As a customer,  
I want to see my order status (pending, shipped, delivered),  
So that I know when to expect delivery.

**Acceptance Criteria:**
- [ ] Order history shows all past orders
- [ ] Each order shows items, total, order date, status
- [ ] Status updates in real-time when vendor ships
- [ ] Delivered orders marked complete with checkmark

**Functional Requirements:**
- Order status flow: pending → confirmed → shipped → delivered
- Vendor updates status (admin feature, not in this app)
- No payment processing integration (⚠️ TODO)

**Non-Functional Requirements:**
- Order history loads: <500ms
- Status update propagation: <2 seconds

---

#### Implementation Assessment

**Current Status:** ⚠️ **INCOMPLETE**

**Critical Issues:**

1. 🔴 **Cart Not Persisted**
   - `CartController` is entirely in-memory
   - User loses cart on app kill, low battery, OS cleanup
   - **Fix:** Persist to SharedPreferences or cart_items table

2. 🔴 **No Payment Processing**
   - `placeOrder()` only creates order record in DB
   - No actual payment capture, no Stripe integration
   - **Fix:** Integrate payment provider (Stripe, Square, PayPal)

3. 🔴 **No Stock Validation Server-Side**
   - Check happens client-side only
   - User can checkout with out-of-stock items if UI fails
   - **Fix:** Server-side validation before order creation

**Recommended Implementations:**

```dart
// Fix cart persistence
class CartController extends StateNotifier<CartState> {
  CartController() : super(CartState.empty()) {
    _loadCart();
  }
  
  Future<void> _loadCart() async {
    final json = _prefs.getString('cart_items');
    if (json != null) {
      final items = (jsonDecode(json) as List)
        .map((e) => CartItemModel.fromJson(e))
        .toList();
      state = state.copyWith(items: items);
    }
  }
  
  Future<void> addProduct(ProductModel product) async {
    state = state.copyWith(items: [...state.items, CartItemModel(...)]);
    await _prefs.setString('cart_items', jsonEncode(state.items));
  }
  
  Future<void> checkout() async {
    try {
      // 1. Stripe payment
      final paymentResult = await _stripeService.charge(state.total);
      if (!paymentResult.success) throw paymentResult.error!;
      
      // 2. Create order
      final order = await marketplaceRepository.placeOrder(...);
      
      // 3. Clear cart
      state = CartState.empty();
      await _prefs.remove('cart_items');
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

// Fix stock validation
Future<OrderModel> placeOrder(CartState cart) async {
  // Validate stock on server
  for (final item in cart.items) {
    final product = await supabase
      .from('products')
      .select('stock')
      .eq('id', item.product.id)
      .single();
    
    if (product['stock'] < item.quantity) {
      throw OrderError('${item.product.name} out of stock');
    }
  }
  
  // Create order
  return await supabase.from('orders').insert(...);
}
```

---

## Functional & Non-Functional Requirements

### Functional Requirements Summary

| Feature | Requirements |
|---------|--------------|
| **Auth** | Email/password, session persistence, logout |
| **Pets** | Create/edit/delete, multi-pet, active selection, image upload |
| **Social** | Posts, stories (24h expiry), comments, likes, real-time updates |
| **Care** | Daily logs, streaks, badges, points, onboarding |
| **Health** | Medications, allergies, vaccinations, vet appointments, symptoms |
| **Matching** | Discovery, match requests, chat thread creation, acceptance |
| **Chat** | Real-time messages, read status, typing indicators (UI pending) |
| **Notifications** | In-app, real-time, multiple types, notification center |
| **FCM** | Push notifications, background handler, token management |
| **Follow** | Follow users/pets, follower lists, counts |
| **Search** | Multi-domain (posts, pets, products) cross-search |
| **Marketplace** | Product browse, cart (in-memory), checkout (no payment), order history |
| **Expenses** | Log expenses by category, history, totals |

### Non-Functional Requirements Summary

| Requirement | Target |
|-------------|--------|
| **Performance** | Pages load <1.5s, API responses <500ms |
| **Reliability** | 99.5% uptime, graceful error handling |
| **Security** | RLS on all tables, JWT auth, no hardcoded secrets (except debug) |
| **Scalability** | Support 100K+ users, 1M+ pets, 10M+ posts |
| **Accessibility** | WCAG 2.1 AA compliance, alt text on images |
| **Maintainability** | <20% test coverage, code comments for complex logic |
| **Offline** | Cache first 48 hours of data (except chat) |
| **Localization** | English primary, prepare for i18n |

---

## Implementation Issues & Fixes

### Critical Issues

#### Issue #1: Cart Persistence
**Severity:** 🔴 Critical  
**Impact:** User loses cart on app kill

**Root Cause:**
```dart
class CartController extends StateNotifier<CartState> {
  // In-memory only, no persistence
}
```

**Solution:**
- Option A: Add `cart_items` table to Supabase (persist server-side)
- Option B: Serialize to SharedPreferences with expiry (24h)
- Recommended: **Option B** (faster, no server cost)

**Estimated Effort:** 2 hours

---

#### Issue #2: Payment Processing Missing
**Severity:** 🔴 Critical  
**Impact:** Orders can't be paid for

**Root Cause:**
```dart
Future<OrderModel> placeOrder(CartState cart) async {
  // Only creates order record, no payment captured
  return await supabase.from('orders').insert(orderData);
}
```

**Solution:**
- Integrate Stripe Flutter SDK
- Implement payment flow: cart → payment form → Stripe charge → order creation
- Handle webhooks for payment status updates
- Store `stripe_payment_intent_id` in orders table

**Estimated Effort:** 8-10 hours (including testing)

---

#### Issue #3: 12 Mock Screens
**Severity:** 🔴 Critical  
**Impact:** 25% of screens are non-functional

**Root Cause:**
UI-first development without backend integration

**Solution:**
Prioritize by business value:
1. **High:** Vet booking (health feature), adoption center (growth)
2. **Medium:** Community groups, pet events
3. **Low:** Pet memorial, pet sitter dashboard

**Estimated Effort:** 40-50 hours (full implementation + tests)

---

#### Issue #4: Database Schema Not Version-Controlled
**Severity:** 🔴 Critical  
**Impact:** DB drift risk, no migration audit trail

**Root Cause:**
No `migrations/` folder; schema only exists in Supabase console

**Solution:**
- Create `/migrations/` directory
- Use Supabase CLI: `supabase migration pull`
- Version migrations: `001_initial_schema.sql`, `002_add_notifications.sql`
- Document breaking changes in each migration
- Add CI check to validate migration compatibility

**Estimated Effort:** 4 hours (initial), <1 hour per future migration

---

### High-Priority Issues

#### Issue #5: Care Cache Race Condition
**Severity:** 🟠 High  
**Impact:** UI flicker, potential stale data

**Root Cause:**
```dart
@override
PetCareState build() {
  state = CareCache.getTodayLog(petId) ?? initial; // Immediate cache
  refresh(); // Async network fetch
  // UI renders with cache, then updates with network = flicker
}
```

**Solution:**
Use proper cache-aside pattern with listener:
```dart
@override
PetCareState build() {
  ref.listen<AsyncValue>(networkCareLogProvider, (prev, next) {
    next.whenData((log) {
      CareCache.saveTodayLog(log); // Update cache AFTER network
    });
  });
  return CareCache.getTodayLog(petId) ?? loading();
}
```

**Estimated Effort:** 3 hours

---

#### Issue #6: Appointment State Not Synced
**Severity:** 🟠 High  
**Impact:** New appointments not visible until refresh

**Root Cause:**
```dart
// HealthController creates appointment
Future<void> upsertAppointment(...) async {
  await repository.upsertAppointment(...);
  // Doesn't update PetCareController.upcomingAppointments!
}

// PetCareController loads separately
final upcomingAppointments = await repository.fetchUpcomingAppointments();
```

**Solution:**
- Single source of truth: move appointments to `pet_care_controller`
- Or: emit notification that triggers state refresh
- Or: use shared `FutureProvider.family` for appointments

**Estimated Effort:** 2-3 hours

---

#### Issue #7: Follow Count N+1 Query
**Severity:** 🟠 High  
**Impact:** 30+ database calls per 10 pets in discovery

**Root Cause:**
```dart
Future<int> getPetFollowerCount(String petId) async {
  // 3 sequential calls per pet!
  final owner = await supabase.from('pets').select('user_id').eq('id', petId);
  final directFollows = await supabase.from('follows')
    .select().eq('followed_pet_id', petId); // Call 1
  final ownerFollows = await supabase.from('follows')
    .select().eq('followed_user_id', owner.user_id); // Call 2
  return directFollows.length + ownerFollows.length;
}
```

**Solution:**
Use Supabase count() aggregation:
```dart
Future<int> getPetFollowerCount(String petId) async {
  final owner = await supabase.from('pets')
    .select('user_id', const FetchOptions(count: CountOption.exact))
    .eq('id', petId)
    .single();
  
  final direct = await supabase.from('follows')
    .select('*', const FetchOptions(count: CountOption.exact))
    .eq('followed_pet_id', petId);
  
  final indirect = await supabase.from('follows')
    .select('*', const FetchOptions(count: CountOption.exact))
    .eq('followed_user_id', owner['user_id']);
  
  return (direct.count ?? 0) + (indirect.count ?? 0);
}
```

**Estimated Effort:** 1 hour

---

## Flutter Best Practices Applied

### State Management (Riverpod)

#### ✅ Best Practice: Immutable State with copyWith()

```dart
class PetState {
  final List<PetModel> myPets;
  final bool isLoading;
  final String? error;
  
  PetState({required this.myPets, this.isLoading = false, this.error});
  
  PetState copyWith({
    List<PetModel>? myPets,
    bool? isLoading,
    String? error,
  }) => PetState(
    myPets: myPets ?? this.myPets,
    isLoading: isLoading ?? this.isLoading,
    error: error ?? this.error,
  );
}
```

**Benefits:**
- Immutability prevents accidental mutations
- `copyWith()` creates new instances (reference equality works)
- Riverpod detects changes via `==` operator

---

#### ✅ Best Practice: Notifier Pattern for Complex Logic

```dart
class PetNotifier extends Notifier<PetState> {
  @override
  PetState build() {
    // Initialize, setup listeners
    ref.listen(authProvider, (prev, next) {
      if (next.status == AuthStatus.unauthenticated) {
        state = PetState.empty(); // Clear on logout
      }
    });
    return PetState.empty();
  }
  
  Future<void> loadPets() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final userId = ref.read(authProvider).userId!;
      final pets = await petRepository.fetchMyPets(userId);
      state = state.copyWith(myPets: pets, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}
```

**Benefits:**
- Methods encapsulate state mutations
- Async operations properly handled with try-catch
- Error state propagated to UI

---

#### ⚠️ Issue: No State Selection / Over-watching

**Current:**
```dart
final petState = ref.watch(petProvider); // Watches entire state
```

**Better:**
```dart
final myPets = ref.watch(
  petProvider.select((state) => state.myPets) // Watch only myPets
);
```

**Benefit:** Only rebuilds when `myPets` changes, not on every error or loading state change.

---

### Navigation (GoRouter)

#### ✅ Best Practice: Type-Safe Routes with Path Parameters

```dart
GoRoute(
  path: '/pet/:id',
  builder: (context, state) {
    final petId = state.pathParameters['id']!;
    return PetProfileScreen(petId: petId);
  },
),
```

**Benefits:**
- URL-based routing enables deep linking
- Path parameters are type-safe
- Automatic query parameter parsing

---

#### ✅ Best Practice: Auth Guard with Redirect

```dart
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  
  return GoRouter(
    redirect: (context, state) {
      if (authState.status == AuthStatus.initial) return '/splash';
      if (authState.status == AuthStatus.unauthenticated) return '/login';
      return null; // Stay on current route
    },
    routes: [...],
  );
});
```

**Benefit:** Prevents unauthenticated users from viewing protected routes.

---

### Null Safety & Error Handling

#### ✅ Best Practice: Nullable vs Non-Nullable Fields

```dart
class PetModel {
  final String id; // Non-nullable, always required
  final String name; // Non-nullable, required
  final String? bio; // Nullable, optional
  final String? profileImageUrl; // Nullable, optional
}
```

**Benefit:** Compiler enforces null checks at call sites.

---

#### ⚠️ Issue: Over-use of Try-Catch with Silent Failure

**Current (Bad):**
```dart
try {
  await supabase.from('profiles').upsert([profileData]);
} on Exception {
  // Silent failure — user doesn't know profile wasn't saved
  developer.log('Profile upsert failed', level: 800);
}
```

**Better:**
```dart
try {
  await supabase.from('profiles').upsert([profileData]);
} catch (e) {
  state = state.copyWith(error: 'Failed to save profile. Please retry.');
  rethrow; // Let caller handle or bubble to UI
}
```

---

### Async & Realtime

#### ✅ Best Practice: FutureProvider for Async Data

```dart
final postByIdProvider = FutureProvider.family<PostModel, String>((ref, postId) async {
  return await feedRepository.fetchPostById(postId);
});

// In widget
final postAsync = ref.watch(postByIdProvider(postId));
postAsync.when(
  data: (post) => PostCard(post),
  loading: () => CircularProgressIndicator(),
  error: (error, st) => ErrorWidget(error),
);
```

**Benefit:** Separates loading/error/success states for proper UI handling.

---

#### ✅ Best Practice: Realtime Subscriptions with Cleanup

```dart
void _subscribeToLikes(String postId) {
  _likeChannel = supabase
    .channel('public:post_likes:post_id=eq.$postId')
    .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'post_likes',
      filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'post_id', value: postId),
      callback: (payload) {
        // Update UI state
      },
    )
    .subscribe();
}

@override
void dispose() {
  _likeChannel?.unsubscribe(); // Cleanup!
  super.dispose();
}
```

**Benefit:** Prevents memory leaks and excessive database subscriptions.

---

#### ⚠️ Issue: Missing Realtime Subscription Cleanup

**Current:** Some controllers subscribe to Realtime channels but don't unsubscribe in `dispose()`.

**Fix:**
```dart
@override
void dispose() {
  _feedChannel?.unsubscribe();
  _notificationChannel?.unsubscribe();
  _chatChannel?.unsubscribe();
  super.dispose();
}
```

---

### Image Handling & Caching

#### ✅ Best Practice: Cached Network Images

```dart
CachedNetworkImage(
  imageUrl: pet.profileImageUrl,
  placeholder: (context, url) => PetAvatar.placeholder(),
  errorWidget: (context, url, error) => PetAvatar.error(),
  cacheManager: DefaultCacheManager(), // Automatic disk cache
  fit: BoxFit.cover,
)
```

**Benefit:** Avoids re-downloading images; reduces bandwidth.

---

#### ✅ Best Practice: Image Compression Before Upload

```dart
Future<String> uploadPetImage(String petId, File imageFile) async {
  // Compress image
  final compressedPath = await FlutterImageCompress.compressAndGetFile(
    imageFile.absolute.path,
    '${Directory.systemTempDirectory.path}/$petId.jpg',
    quality: 85,
    minWidth: 1024,
    minHeight: 1024,
  );
  
  // Upload
  final path = '$petId/${DateTime.now().millisecondsSinceEpoch}.jpg';
  await supabase.storage.from('pet-images').upload(path, File(compressedPath!.path));
  
  return supabase.storage.from('pet-images').getPublicUrl(path).toString();
}
```

**Benefit:** Reduces bandwidth, faster uploads, smaller storage footprint.

---

## Supabase Best Practices

### Database Design

#### ✅ Best Practice: Row-Level Security on All Tables

```sql
ALTER TABLE pets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own pets"
  ON pets FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Users can update their own pets"
  ON pets FOR UPDATE
  USING (user_id = auth.uid());
```

**Benefit:** Prevents unauthorized data access at the database level.

---

#### ✅ Best Practice: Check Constraints for Enums

```sql
CREATE TABLE pet_medications (
  ...
  frequency TEXT NOT NULL DEFAULT 'once_daily' CHECK (frequency IN (
    'once_daily', 'twice_daily', 'three_times_daily', 'weekly', 'monthly', 'as_needed', 'other'
  )),
  ...
);
```

**Benefit:** Enforces enum values at database level; prevents invalid states.

---

#### ⚠️ Issue: Lack of Database Migration Version Control

**Current:** Schema exists only in Supabase console; no SQL migrations in repo.

**Fix:**
```
migrations/
├── 001_initial_schema.sql
├── 002_add_notifications.sql
├── 003_add_pet_care_logs.sql
└── ...
```

**Setup:**
```bash
supabase migration pull # Download existing schema
supabase db push # Apply migrations to local DB
supabase db reset # Reset DB to migrations state
```

---

### Query Optimization

#### ✅ Best Practice: Selective Columns (not SELECT *)

```dart
// Bad
final data = await supabase.from('posts').select().limit(20);

// Good
final data = await supabase.from('posts').select('''
  id, pet_id, media_url, caption, created_at,
  pets(id, name, profile_image_url)
''').limit(20);
```

**Benefit:** Reduces bandwidth; faster response times.

---

#### ✅ Best Practice: Pagination with Limit & Offset

```dart
final page = 2;
final pageSize = 20;
final offset = (page - 1) * pageSize;

final posts = await supabase
  .from('posts')
  .select()
  .order('created_at', ascending: false)
  .range(offset, offset + pageSize - 1);
```

**Benefit:** Scales to large datasets; prevents loading entire table.

---

#### ⚠️ Issue: N+1 Follower Count Queries

**Current:** 3 sequential calls per pet in discovery list.

**Fix:** Use `count()` aggregation or batch queries:
```dart
final counts = await supabase
  .from('follows')
  .select(
    'followed_pet_id, count(*) as follower_count',
    const FetchOptions(count: CountOption.exact)
  )
  .in_('followed_pet_id', petIds)
  .group_by('followed_pet_id');
```

---

### Realtime Subscriptions

#### ✅ Best Practice: Targeted Realtime Channels

```dart
// Filter specific post's likes
final channel = supabase
  .channel('public:post_likes:post_id=eq.$postId')
  .onPostgresChanges(
    event: PostgresChangeEvent.all,
    schema: 'public',
    table: 'post_likes',
    filter: PostgresChangeFilter(
      type: PostgresChangeFilterType.eq,
      column: 'post_id',
      value: postId
    ),
    callback: (payload) { ... },
  )
  .subscribe();
```

**Benefit:** Only receives relevant updates; reduced bandwidth and CPU.

---

#### ✅ Best Practice: Cleanup Subscriptions

```dart
@override
void dispose() {
  supabase.channel('public:posts').unsubscribe();
  super.dispose();
}
```

**Benefit:** Prevents memory leaks; reduces server load.

---

### Storage Best Practices

#### ✅ Best Practice: Organize Files by User/Entity

```dart
// Structure
pet-images/
├── $userId/
│   └── $petId/
│       ├── profile_$timestamp.jpg (latest profile image)
│       ├── gallery_$timestamp.jpg
│       └── ...

// Upload path
final path = '$userId/$petId/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
```

**Benefit:** Easy to clean up user data on deletion; clear ownership.

---

#### ✅ Best Practice: Use Signed URLs for Temporary Access

```dart
// Temporary read access (1 hour)
final signedUrl = await supabase.storage
  .from('pet-images')
  .createSignedUrl(path, 3600); // 1 hour TTL

// Use signedUrl in email, etc.
```

**Benefit:** Prevents long-lived URLs; revocable access.

---

## UI/UX Best Practices

### Design System

#### ✅ Best Practice: Centralized Theme

```dart
// theme/app_theme.dart
class AppTheme {
  static const colorScheme = ColorScheme(
    primary: Color(0xFFD4845A),
    secondary: Color(0xFF4A7C59),
    background: Color(0xFF0F0E0C),
    // ...
  );
  
  static final theme = ThemeData(
    colorScheme: colorScheme,
    textTheme: GoogleFonts.dmSansTextTheme(),
    // ...
  );
}

// Usage
color: Theme.of(context).colorScheme.primary,
```

**Benefit:** Consistent styling; easy to change brand colors globally.

---

#### ✅ Best Practice: Responsive Design

```dart
Widget build(BuildContext context) {
  final isMobile = MediaQuery.of(context).size.width < 600;
  
  return isMobile
    ? MobileLayout()
    : DesktopLayout();
}
```

**Benefit:** App looks good on tablets and foldables.

---

### Error Handling UI

#### ✅ Best Practice: User-Friendly Error Messages

```dart
// Bad
if (state.error != null) {
  return Text(state.error!); // Shows: "PostgrestException: 42P01"
}

// Good
String _userFriendlyMessage(String error) {
  if (error.contains('42P01')) return 'Table not found. Please contact support.';
  if (error.contains('23505')) return 'This item already exists.';
  if (error.contains('PGRST')) return 'Network error. Please check your connection.';
  return 'Something went wrong. Please try again.';
}

if (state.error != null) {
  return Text(_userFriendlyMessage(state.error!));
}
```

**Benefit:** Users understand what went wrong and what to do.

---

#### ✅ Best Practice: Optimistic Updates

```dart
// Like post
void likePost(PostModel post) {
  // 1. Update UI immediately (optimistic)
  state = state.copyWith(likedPostIds: {...state.likedPostIds, post.id});
  
  // 2. Sync with server
  postRepository.toggleLike(post.id).then(
    (success) {
      if (!success) {
        // Rollback on failure
        state = state.copyWith(
          likedPostIds: {...state.likedPostIds}..remove(post.id),
          error: 'Failed to like post'
        );
      }
    }
  );
}
```

**Benefit:** App feels fast; user sees immediate feedback even on slow network.

---

### Accessibility

#### ✅ Best Practice: Semantic Labels

```dart
IconButton(
  icon: Icon(Icons.favorite),
  tooltip: 'Like this post', // Helps screen readers
  onPressed: onLikePressed,
)

// Or use Semantics
Semantics(
  label: 'Like button',
  enabled: true,
  onTap: onLikePressed,
  child: GestureDetector(
    onTap: onLikePressed,
    child: Icon(Icons.favorite),
  ),
)
```

**Benefit:** Accessible to users with screen readers.

---

#### ✅ Best Practice: Sufficient Color Contrast

```dart
// Check contrast ratio ≥ 4.5:1 for normal text
// Use https://webaim.org/resources/contrastchecker/

// Good
Text('Dark text', style: TextStyle(color: Colors.white, shadows: [
  Shadow(color: Colors.black, blurRadius: 2), // Add shadow if needed
])),
```

**Benefit:** Readable by users with color blindness or vision impairments.

---

## Security Best Practices

### Authentication

#### ✅ Best Practice: Secure Session Management

```dart
@override
Future<bool> signIn(String email, String password) async {
  final response = await supabase.auth.signInWithPassword(
    email: email,
    password: password,
  );
  
  // Token automatically stored securely by Supabase SDK
  // (platform-specific: Keychain on iOS, Keystore on Android)
  
  return response.user != null;
}
```

**Benefit:** Tokens stored securely, not in SharedPreferences.

---

#### ⚠️ Issue: Debug Supabase Credentials Hardcoded

**Current:**
```dart
const String _debugFallbackUrl = 'https://foubokcqaxyqgjhtgzsx.supabase.co';
const String _debugFallbackAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

**Note:** This is acceptable for debug builds, but:
- Never use debug Supabase project in production
- Release builds must use `--dart-define` (enforced by `assertValidReleaseSupabaseConfig()`)

**Best Practice:**
```bash
# Debug build (uses hardcoded fallback)
flutter run

# Release build (requires defines, fails if missing)
flutter build apk \
  --dart-define=SUPABASE_URL=https://prod.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=prod-key
```

---

### Data Privacy

#### ✅ Best Practice: Row-Level Security

All tables have RLS enabled. Example:

```sql
CREATE POLICY "Users can only see their own health records"
  ON pet_medications FOR SELECT
  USING (pet_id IN (SELECT id FROM pets WHERE user_id = auth.uid()));
```

**Benefit:** Even if anon key is leaked, attackers can't read other users' data.

---

#### ✅ Best Practice: Encrypt Sensitive Fields at Application Level

**Recommended for sensitive data:**
- Allergy information
- Symptom descriptions
- Vet notes

```dart
import 'package:encrypt/encrypt.dart' as encrypt;

// Encrypt sensitive field before insert
final encrypted = encrypt.Encrypted.fromBase64(
  encrypt.Encrypter(encrypt.AES(key)).encrypt(plaintext, iv: iv).base64
);

await supabase.from('pet_allergies').insert({
  'allergen': encrypted.base64,
  'reaction': encrypted.base64, // sensitive
});
```

---

### API Security

#### ✅ Best Practice: Use Publishable Keys (not Anon Keys)

Supabase recommends newer "Publishable Keys" format `sb_publishable_...` over JWT anon keys.

**Benefits:**
- Independent token rotation
- Scoped permissions per key
- Better audit trail

---

#### ✅ Best Practice: Rate Limiting

Configure in Supabase dashboard:
```
Auth API:
- Sign-up: 5 per minute per IP
- Login: 10 per minute per IP
```

---

## Testing Strategy

### Unit Testing

#### Test Controllers

```dart
test('petNotifier loads pets on build', () async {
  final container = ProviderContainer();
  final notifier = PetNotifier();
  
  // Mock repository
  final mockRepo = MockPetRepository();
  when(mockRepo.fetchMyPets(userId))
    .thenAnswer((_) async => [testPet]);
  
  // Act
  final state = notifier.build();
  
  // Assert
  expect(state.isLoading, true);
  expect(state.myPets, isEmpty);
  
  // After async
  await notifier.loadPets();
  expect(state.myPets.length, 1);
});
```

**Target:** 80%+ coverage for all controllers

---

#### Test Models

```dart
test('PetModel.fromJson parses correctly', () {
  final json = {
    'id': 'pet-123',
    'name': 'Fluffy',
    'breed': 'Golden Retriever',
    'age': 3,
  };
  
  final pet = PetModel.fromJson(json);
  
  expect(pet.id, 'pet-123');
  expect(pet.name, 'Fluffy');
  expect(pet.age, 3);
});
```

**Target:** 100% model coverage

---

#### Test Repositories

```dart
test('fetchMyPets returns list of pets', () async {
  final mockSupabase = MockSupabaseClient();
  final repo = PetRepository(mockSupabase);
  
  when(mockSupabase.from('pets').select().eq('user_id', userId))
    .thenAnswer((_) async => [...]);
  
  final pets = await repo.fetchMyPets(userId);
  
  expect(pets.length, 2);
});
```

**Target:** 70%+ coverage for critical paths

---

### Integration Testing

```dart
test('Post creation flow', () async {
  // 1. Create post
  final post = await feedRepository.createPost(
    petId: 'pet-123',
    caption: 'Test post',
    mediaUrl: 'https://example.com/image.jpg',
  );
  
  // 2. Verify in database
  final retrieved = await feedRepository.fetchPostById(post.id);
  expect(retrieved.caption, 'Test post');
  
  // 3. Like post
  await feedRepository.toggleLike('pet-456', post.id);
  
  // 4. Verify like count
  final updated = await feedRepository.fetchPostById(post.id);
  expect(updated.likeCount, 1);
});
```

---

### E2E Testing with Flutter Driver + Marionette

```dart
import 'package:flutter_driver/flutter_driver.dart';

void main() {
  group('Pet Care Flow', () {
    late FlutterDriver driver;
    
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });
    
    tearDownAll(() async {
      await driver.close();
    });
    
    test('User logs in and logs care', () async {
      // 1. Type email
      await driver.tap(find.byType('TextField').first);
      await driver.typeText('test@example.com');
      
      // 2. Type password
      await driver.tap(find.byType('TextField').last);
      await driver.typeText('Password123!');
      
      // 3. Tap login
      await driver.tap(find.byType('ElevatedButton'));
      
      // 4. Wait for home screen
      await driver.waitFor(find.byType('HomeScreen'));
      
      // 5. Check care checkbox
      await driver.tap(find.byTooltip('Mark breakfast fed'));
      
      // 6. Verify visual feedback
      final icon = find.byType('Icon');
      expect(await driver.getText(icon), contains('✓'));
    });
  });
}
```

---

## Automated Testing Blueprint

### Setup CI/CD Pipeline for Automated Testing

```yaml
# .github/workflows/test.yml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: 3.0.0
      
      # Unit tests
      - run: flutter test --coverage
      
      # Upload coverage
      - uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info
      
      # Build APK for manual testing
      - run: flutter build apk --debug

  # E2E tests
  e2e:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      
      - run: flutter drive --target=test_driver/app.dart
```

---

### Android Emulator Automation Testing Setup

**Prerequisites:**
```bash
# Install emulator
sdkmanager "system-images;android-33;default;arm64-v8a"
avdmanager create avd -n "test_avd" -k "system-images;android-33;default;arm64-v8a" -d "Pixel 4"

# Start emulator
emulator -avd test_avd
```

**Run Tests:**
```bash
# Run all tests with coverage
flutter test --coverage

# Run widget tests
flutter test test/widgets/

# Run integration tests on emulator
flutter drive --target=integration_test/app_test.dart

# Run with Marionette (vision capable)
flutter drive --target=integration_test/app_test.dart \
  --dart-define=MARIONETTE_USE_DRIVER=true
```

---

### Test Coverage Goals

| Component | Target | Current |
|-----------|--------|---------|
| Models | 100% | ~5% |
| Controllers | 80% | 0% |
| Repositories | 70% | 0% |
| Views | 50% | 0% |
| **Overall** | **70%** | **0%** |

---

### Vision-Capable Integration Test Example

Using `marionette_flutter` for visual validation:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:marionette_flutter/marionette_flutter.dart';
import 'package:petsphere/main.dart';

void main() {
  group('UI/UX Validation', () {
    testWidgets('Pet care screen layout is correct', (WidgetTester tester) async {
      // Build app
      await tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      
      await tester.pumpWidget(const PetSphereApp());
      await tester.pumpAndSettle();
      
      // Navigate to pet care
      await tester.tap(find.byIcon(Icons.favorite)); // Pet care tab
      await tester.pumpAndSettle();
      
      // Verify care log exists
      expect(find.byType(PetCareLog), findsOneWidget);
      
      // Take screenshot for vision validation
      await tester.binding.takeScreenshot('pet_care_screen');
      
      // Verify colors (accessibility)
      final careCard = find.byType(Card);
      final backgroundColor = tester.widget<Card>(careCard).color;
      expect(backgroundColor, Color(0xFF1A1814)); // Surface color
    });
  });
}
```

---

## Summary

This comprehensive guide covers:

1. ✅ **Feature Specifications** — 6 core features with user stories
2. ✅ **Functional Requirements** — 13 features with acceptance criteria
3. ✅ **Non-Functional Requirements** — Performance, security, accessibility
4. ✅ **Implementation Issues** — 7 critical/high issues with fixes
5. ✅ **Best Practices** — Flutter, Supabase, UI/UX, security
6. ✅ **Testing Strategy** — Unit, integration, E2E with CI/CD

**Estimated Implementation Effort:**
- Critical fixes: 15-20 hours
- High-priority improvements: 10-15 hours
- Feature completions: 40-50 hours
- Test coverage: 20-30 hours
- **Total: 85-115 hours (2-3 weeks)**

---

**Document prepared by:** Claude Code Analysis  
**Review Frequency:** Monthly  
**Last Updated:** May 5, 2026
