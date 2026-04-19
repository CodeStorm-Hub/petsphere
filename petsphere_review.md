# PetSphere — Comprehensive Project Audit

**Date:** 2026-04-19  
**Project:** `pet_dating_app` (PetSphere)  
**Stack:** Flutter 3 · Riverpod 3 · GoRouter 17 · Supabase (PostgreSQL 17, Auth, Storage, Realtime)  
**Supabase Project:** `foubokcqaxyqgjhtgzsx` (ap-southeast-1, ACTIVE_HEALTHY)

---

## 1. Architecture Overview

### Structure

```
lib/
  controllers/   # Riverpod Notifiers (business logic)
  models/        # Plain Dart data classes
  repositories/  # Supabase data access layer
  views/         # Flutter screens & components
  theme/         # Centralised ThemeData
  utils/         # Router, Supabase config
```

### Pattern in Use
The project follows a **layered MVVM / Repository** architecture:
- **Repository** – raw Supabase calls (data access)
- **Controller / Notifier** – business logic, state management via `Notifier<T>` (Riverpod)
- **View** – ConsumerWidget / ConsumerStatefulWidget

### What Works Well
- Consistent use of `Notifier<T>` (not deprecated `StateNotifier`)
- Load generation guard (`_loadGeneration`) in `MatchController` and `PetNotifier` prevents race conditions
- Optimistic updates in `ChatController.sendMessage` with rollback on failure
- `activePetProvider` derived provider is a clean pattern for the "acting-as" pet concept
- GoRouter `refreshListenable` pattern for auth-driven navigation is correct
- Centralised `AppTheme` with Material 3 and Google Fonts

---

## 2. 🔴 Critical Issues

### 2.1 API Credentials Hardcoded in Source Code

**File:** `lib/utils/supabase_config.dart`

```dart
const String supabaseUrl = 'https://foubokcqaxyqgjhtgzsx.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJI...'; // FULL KEY HARDCODED
```

**Problem:** The Supabase URL and anon key are hardcoded as compile-time constants and will be visible in:
- Git history (if committed)
- Decompiled APK/IPA binaries
- Any clone of the repository

**The `.env` file exists** but it's a template only — it's NOT actually being consumed by `supabase_config.dart`. The `--dart-define-from-file` mechanism suggested in `.env` is documented but never wired up.

**Fix:** Replace the constants with `--dart-define` or `flutter_dotenv`:
```dart
// Use dart-define
const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
```

> [!CAUTION]
> While the anon key is designed to be safe to expose in client apps (protected by RLS), hardcoding it in source code means every contributor can see it, and rotating it requires a code change. Use compile-time defines to decouple.

---

### 2.2 `uploadAvatar` Uses the Wrong Bucket

**File:** `lib/repositories/auth_repository.dart` line 99

```dart
await supabase.storage.from(kBucketPetImages).upload(path, imageFile);
```

Profile avatars (for **users**) are being uploaded to `pet-images` instead of a user-specific bucket. This is architecturally wrong—user avatars and pet images are co-mingled in the same bucket under `avatars/` prefix. There is no dedicated avatar bucket. This also means avatar images could appear in pet image listings.

---

### 2.3 No `match_requests` Uniqueness Constraint

**Database:** `match_requests` table

A user can send multiple "like" requests from the same pet to the same receiver pet. The repository uses `upsert` but there is **no unique constraint** on `(sender_pet_id, receiver_pet_id)`:

```dart
// match_repository.dart line 47
await supabase.from('match_requests').upsert({
  'sender_pet_id': senderPetId,
  'receiver_pet_id': receiverPetId,
  'status': 'pending',
});
```

Without `onConflict: 'sender_pet_id,receiver_pet_id'` specified on `upsert`, and without a DB-level unique constraint, this will **insert a new row** instead of updating. Rapid taps can create duplicate requests.

**Fix:**
```sql
ALTER TABLE public.match_requests 
  ADD CONSTRAINT match_requests_unique_pair 
  UNIQUE (sender_pet_id, receiver_pet_id);
```

---

### 2.4 N+1 Query in `ChatRepository.fetchThreads`

**File:** `lib/repositories/chat_repository.dart` lines 25-31

```dart
for (final thread in threads) {
  final lastMsg = await _fetchLastMessage(thread.id); // N separate DB round-trips
  enriched.add(thread.copyWith(lastMessage: lastMsg));
}
```

For a user with 20 chat threads, this fires **21 sequential database calls**. This is a classic N+1 problem. At scale this will cause noticeable latency.

**Fix:** Use a Postgres window function or a single `LATERAL` join query via Supabase RPC, or fetch all last messages in one query using `IN (thread_ids)` + deduplication.

---

### 2.5 `matches` Table Disconnected from App Flow

The `matches` table exists in the database (0 rows) but there is **no code path in the Flutter app that writes to it**. When a match request is accepted (`updateRequestStatus` sets status to `'matched'`), no corresponding row is created in `matches`. The chat thread creation is also not triggered automatically on match acceptance.

This means:
- The `matches` table is purely decorative
- Accepting a match does NOT automatically open a chat thread
- There is no "you have a new match!" trigger

---

### 2.6 `ChatScreen` Crashes When Thread Not in Cache

**File:** `lib/views/chat_screen.dart` lines 65-69

```dart
final threadList = chatState.threads.where((t) => t.id == widget.threadId);
if (threadList.isEmpty) {
  return const Scaffold(body: Center(child: CircularProgressIndicator())); // INFINITE SPINNER
}
```

If a user navigates directly to `/chat/:threadId` (e.g., from a deep link or notification) before `chatProvider` has loaded threads, the screen shows an infinite loading indicator with **no recovery**. There is no timeout, no fetch-by-ID fallback, and no error state.

---

## 3. 🟠 High-Priority Issues

### 3.1 Leaked Password Protection Disabled

**Supabase Security Advisory**

HaveIBeenPwned.org password checking is disabled. Users can register with known-compromised passwords.

**Fix:** Enable in Supabase Dashboard → Authentication → Password → enable "Leaked Password Protection".  
Reference: https://supabase.com/docs/guides/auth/password-security#password-strength-and-leaked-password-protection

---

### 3.2 `set_updated_at` Function Has Mutable `search_path`

**Supabase Security Advisory**

The `public.set_updated_at` database function does not have a fixed `search_path`, making it vulnerable to search path injection attacks.

**Fix:**
```sql
ALTER FUNCTION public.set_updated_at() 
  SET search_path = public;
```

---

### 3.3 Public Storage Buckets Allow Directory Listing

**Supabase Security Advisory**

Both `pet-images` and `post-media` have broad `SELECT` policies that allow any client to **enumerate all files** in the bucket. This exposes file paths for all users.

**Fix:** The public `SELECT` policy should restrict to `USING (bucket_id = 'pet-images')` which already prevents access by URL without the path, but the overly-broad policy also grants `STORAGE.OBJECTS` listing capabilities. Consider replacing with storage path restrictions using `(storage.foldername(name))[1] = auth.uid()::text`.

---

### 3.4 Massive RLS Policy Duplication (Multiple Permissive Policies)

**Supabase Performance Advisory — affects ALL tables**

Nearly every table has **2-3 duplicate overlapping RLS policies** for the same role and action. This is the result of migrations being applied incrementally without removing older policies.

Affected tables (partial list):
- `pets` → 3 overlapping INSERT policies, 3 SELECT policies, 3 UPDATE policies
- `profiles` → 3 SELECT policies, 3 UPDATE policies, 2 INSERT policies  
- `match_requests` → 3 SELECT policies, 2 INSERT policies, 2 UPDATE policies
- `messages` → 2 SELECT policies, 2 INSERT policies
- `post_likes`, `posts`, `comments`, `products`, `pet_listings` → all have 2+ conflicting policies

Every query must evaluate ALL permissive policies and passes if ANY is true. This multiplies RLS evaluation overhead unnecessarily.

**Fix:** Audit and consolidate policies: keep ONE policy per (table, role, action) combination.

---

### 3.5 `auth.uid()` Called Per-Row in All RLS Policies

**Supabase Performance Advisory — 30+ affected policies**

All RLS policies call `auth.uid()` directly (triggers a new function call per row evaluation). The correct pattern is to wrap it in a subquery so PostgreSQL evaluates it once:

```sql
-- Slow (current)
USING (auth.uid() = user_id)

-- Fast (fix)
USING ((SELECT auth.uid()) = user_id)
```

This affects all 30+ policies across all tables and compounds with the duplicate policy issue above.

---

### 3.6 Missing Database Indexes on Foreign Keys (13 total)

**Supabase Performance Advisory**

The following foreign key columns lack covering indexes, causing sequential scans on JOINs:

| Table | Missing Index Column |
|---|---|
| `chat_threads` | `pet_id_2` |
| `comments` | `pet_id` |
| `matches` | `created_by_user_id`, `pet_id_1`, `pet_id_2` |
| `messages` | `sender_pet_id` |
| `notifications` | `actor_pet_id` |
| `order_items` | `product_id` |
| `pet_listings` | `listed_by_user_id` |
| `pets` | `user_id` |
| `post_likes` | `pet_id` |
| `posts` | `pet_id` |
| `products` | `vendor_id` |

**Fix:**
```sql
CREATE INDEX ON public.pets (user_id);
CREATE INDEX ON public.posts (pet_id);
CREATE INDEX ON public.comments (pet_id);
CREATE INDEX ON public.post_likes (pet_id);
CREATE INDEX ON public.messages (sender_pet_id);
CREATE INDEX ON public.chat_threads (pet_id_2);
CREATE INDEX ON public.notifications (actor_pet_id);
CREATE INDEX ON public.matches (pet_id_1, pet_id_2, created_by_user_id);
CREATE INDEX ON public.order_items (product_id);
CREATE INDEX ON public.pet_listings (listed_by_user_id);
CREATE INDEX ON public.products (vendor_id);
```

---

### 3.7 `signUp` — Profile Upsert May Silently Fail

**File:** `lib/repositories/auth_repository.dart` lines 37-45

```dart
try {
  await supabase.from('profiles').upsert({'id': user.id, 'name': name});
} catch (e) {
  debugPrint('Profile upsert during signup failed (non-fatal): $e'); // SILENTLY IGNORED
}
```

If the profile row is not created during registration (e.g., RLS blocks it, network timeout), the user ends up authenticated but with no profile row. This causes failures in all downstream queries that join to `profiles`. The error is completely silent to the user.

**Fix:** Use a Supabase database trigger `AFTER INSERT ON auth.users` to auto-create the profile row server-side, removing the race condition entirely.

---

### 3.8 No Email Verification Enforced

Registration completes and immediately grants `AuthStatus.authenticated` even if email verification is required. The `signUp` method doesn't check `response.session == null` (which indicates email confirmation is pending). Users who haven't confirmed their email get full app access.

---

## 4. 🟡 Medium-Priority Issues

### 4.1 No Dark Theme

The `AppTheme` class only defines `lightTheme`. `MaterialApp.router` has `theme: AppTheme.lightTheme` but no `darkTheme`. The rules file explicitly requires "Light and Dark Themes."

**Fix:** Add `AppTheme.darkTheme` and pass it to `MaterialApp.router(darkTheme: AppTheme.darkTheme, themeMode: ThemeMode.system)`.

---

### 4.2 `pubspec.yaml` Description Still Default

```yaml
description: "A new Flutter project."
```

This should be updated to reflect the actual app for any distribution or CI metadata.

---

### 4.3 Breed Filter is Hardcoded

**File:** `lib/views/discovery_screen.dart` lines 109-137

Breed chips (Golden Retriever, Siberian Husky, etc.) are hardcoded. When users add pets of other breeds, their pets never appear in the breed filter chips. This is especially limiting as the user base grows.

**Fix:** Derive the breed list dynamically from `pets` table distinct values.

---

### 4.4 `matchRepository.fetchDiscoveryPets` Doesn't Filter Already-Liked Pets

**File:** `lib/repositories/match_repository.dart` lines 19-32

Discovery only excludes pets owned by the same user (`neq('user_id', userId)`), but does **not** exclude pets that the active pet has already sent a like request to. When the match list reloads (e.g., filter change), previously liked pets will reappear.

**Fix:** Add a NOT IN subquery excluding pets already in `match_requests` sent by this pet.

---

### 4.5 `pet_listings` Table is Unused

The `pet_listings` table was designed for a richer breeding listing feature (with `title`, `description`, `preferred_animal_type`, `min_age`, `max_age`, etc.) but the app uses a simpler `is_breeding_listed` boolean flag on the `pets` table directly. The entire `pet_listings` table has 0 rows and no code references it.

---

### 4.6 `orders.items` JSONB Column is Redundant

The `orders` table has both an `items JSONB` column AND a separate `order_items` table. This denormalization without a clear migration plan will lead to inconsistent data. The app's `OrderHistoryScreen` appears to use the `order_items` join, but `orders.items` will always be empty.

---

### 4.7 Realtime Chat Subscription Leaks

**File:** `lib/controllers/chat_controller.dart` lines 14-22

```dart
class ThreadMessagesNotifier extends Notifier<List<MessageModel>> {
  RealtimeChannel? _channel;
  ...
  // Provider is intentionally NOT auto-disposed
```

The `threadMessagesProvider` is not auto-disposed by design, but if the user opens multiple chat threads in a session, old channels are unsubscribed via `_channel?.unsubscribe()` when `init()` is called again. However, only ONE thread's realtime subscription can be active at any time per the current design. This means switching back to a thread requires `init()` to re-subscribe, causing a small loading delay each time.

---

### 4.8 `AuthRepository` Uses Global Singleton Pattern

```dart
final authRepository = AuthRepository();
final matchRepository = MatchRepository();
// etc.
```

All repositories are module-level singletons. This makes unit testing very difficult (cannot inject mocks) and violates the dependency injection principle. The `Notifier` classes directly reference the global singletons rather than receiving them via constructor injection.

---

### 4.9 Missing `created_at` in `pet_listings`

The `pet_listings` table marks `created_at` and `updated_at` as NOT NULL without defaults visible in the local SQL, though the live schema shows `default now()`. More critically, there is no `expires_at` column — listings never expire and there's no archival mechanism.

---

### 4.10 Notifications System is Incomplete

The `notifications` table exists (4 rows) with types `match_request`, `match_accepted`, `message`, `order_status`, `system`, but:
- There is **no push notification integration** (no FCM, APNs, or Supabase Edge Function to send notifications)
- The `NotificationsScreen` displays in-app notifications but they are populated manually — no database trigger creates them on match/message events
- The notification bell icon in the app bar is static (no badge/counter for unread count)

---

### 4.11 `post_likes` Realtime DELETE Payload May Be Empty

**File:** `lib/repositories/feed_repository.dart` lines 169-174

```dart
callback: (payload) {
  final postId = payload.oldRecord['post_id'] as String? ?? '';
```

Supabase Realtime `DELETE` events only include `oldRecord` data if the table has `REPLICA IDENTITY FULL` set. Without it, `oldRecord` is empty and `postId` will always be `''`, making the unlike realtime event silently non-functional.

**Fix:**
```sql
ALTER TABLE public.post_likes REPLICA IDENTITY FULL;
ALTER TABLE public.comments REPLICA IDENTITY FULL;
```

---

### 4.12 No Input Validation / Sanitization

No field validation exists at the controller or repository level. For example:
- Pet `age` could be negative or unrealistically large
- `bio` and `caption` fields have no max-length enforcement in Flutter (only DB-level text)
- No XSS risk in Flutter native, but SQL injection is handled by Supabase's parameterized queries — this is fine

---

## 5. 🟢 Minor Issues & Best Practice Violations

### 5.1 `debugPrint` Used for Logging

The rules file explicitly states: _"Use `dart:developer` `log` instead of `print`."_ The codebase uses `debugPrint` throughout (e.g., `match_controller.dart`, `auth_controller.dart`). `debugPrint` is stripped in release builds, but `dart:developer log` is the recommended API as it integrates with the DevTools timeline.

### 5.2 Models Not Using `json_serializable`

The rules file specifies: _"Use `json_serializable` and `json_annotation`."_ All 9 models use hand-written `fromJson/toJson` methods. This is functional but error-prone on schema changes and violates the project rules.

### 5.3 Theme Is Incomplete

- `ColorScheme` is created with `ColorScheme.light(...)` directly instead of `ColorScheme.fromSeed(seedColor: ...)`. This misses harmonious color generation.
- No `CardTheme`, `SnackBarTheme`, `TabBarTheme`, or `BottomNavigationBarTheme` in `AppTheme`.
- Several screens use hardcoded `Colors.white`, `Colors.grey.shade200` etc. instead of `Theme.of(context).colorScheme.*` values.

### 5.4 `routerProvider` Is a `Provider` (Not `NotifierProvider`)

The router is created inside a `Provider`, which rebuilds the entire GoRouter on auth state changes via `ref.listen`. This is a common workaround but means the router instance is recreated when it shouldn't be. Consider using a persistent `NotifierProvider` or keeping the router construction outside the provider tree.

### 5.5 `MatchController.build` Calls `_load` Synchronously

```dart
@override
MatchState build() {
  final activePet = ref.watch(activePetProvider);
  if (activePet != null) {
    _load(activePet.id); // async, unawaited
  }
  return MatchState(isLoading: true);
}
```

Calling async methods from `build()` is an anti-pattern in Riverpod. The `_load` call is not awaited and the initial state is always `isLoading: true`. The recommended pattern is `ref.keepAlive()` + `FutureProvider`, or using `ref.invalidate()` + `AsyncNotifier`.

### 5.6 Unused Index: `posts_created_at_idx`, `messages_thread_created_at_idx`

These indexes exist in the database but have never been queried. They consume disk space and slow down writes without benefit. Since queries order by `created_at` after filtering by `pet_id` / `thread_id`, composite indexes like `(pet_id, created_at)` would be more useful.

### 5.7 `orders` Table References `auth.users` Directly

```sql
-- storage_policies.sql line 98
user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
```

But the `public.orders` table foreign key should reference `public.profiles` (which already does), not `auth.users` directly. Direct references to `auth` schema tables from `public` schema are discouraged by Supabase.

### 5.8 No Error Boundaries in UI

No global error handling exists. If a repository throws an unexpected error, the controller sets `state.error` but many screens don't display it. Example: `messages_list_screen.dart` doesn't check `chatState.error` at all.

### 5.9 `LikedPetsScreen` Uses Old-Style Switch

```dart
switch (status) {
  case 'matched': ...
  case 'rejected': ...
```

Flutter rules recommend Dart pattern matching / switch expressions instead of statement-based switch.

---

## 6. Missing / Incomplete Features

| Feature | Status | Notes |
|---|---|---|
| **Push Notifications** | ❌ Missing | No FCM/APNs setup, no Edge Function to send notifications |
| **Match → Auto Chat Thread** | ❌ Missing | Accepting a match request does not create a chat thread |
| **Match list / Matched Pets screen** | ❌ Missing | No screen to view all matched pets |
| **Image attachments in chat** | ❌ Placeholder | `message_type = 'image'` schema exists but no send-image UI |
| **Marketplace checkout** | ⚠️ Partial | Cart + OrderHistoryScreen exist but no payment integration |
| **Vendor management** | ❌ Missing | No UI for vendors to add/edit/delete products |
| **Follow system** | ⚠️ Partial | `follow_repository.dart` and `follows_table.sql` exist, but `FollowController` isn't connected to any meaningful UI screen |
| **Dark mode** | ❌ Missing | Only light theme defined |
| **Password reset / forgot password** | ❌ Missing | No UI flow for `supabase.auth.resetPasswordForEmail()` |
| **Profile deletion / account deletion** | ❌ Missing | GDPR concern |
| **Pet deletion** | ❌ Missing | No UI to remove a pet from the profile |
| **Pet image gallery editing** | ⚠️ Partial | `images` array exists on `PetModel` but no UI to add/remove gallery photos |
| **Block / Report user** | ❌ Missing | `matches.status = 'blocked'` enum value exists but no UI |
| **Comment deletion** | ❌ Missing | Users can post comments but not delete them |
| **Pagination / infinite scroll** | ❌ Missing | Feed fetches a hard-capped 50 posts; no cursor-based pagination |
| **Search** | ❌ Missing | No way to search for pets or users by name |

---

## 7. Database Schema Summary

| Table | Rows | RLS | Notes |
|---|---|---|---|
| `profiles` | 2 | ✅ | Duplicate policies (see §3.4) |
| `pets` | 6 | ✅ | 3 conflicting SELECT/INSERT/UPDATE policies |
| `posts` | 5 | ✅ | Missing UPDATE policy |
| `post_likes` | 3 | ✅ | Missing REPLICA IDENTITY FULL |
| `comments` | 4 | ✅ | Missing REPLICA IDENTITY FULL |
| `match_requests` | 4 | ✅ | No unique constraint on pair; 3 conflicting SELECT policies |
| `matches` | 0 | ✅ | Never written to by app code |
| `chat_threads` | 0 | ✅ | Missing `pet_id_2` index |
| `messages` | 0 | ✅ | Missing `sender_pet_id` index |
| `notifications` | 4 | ✅ | No trigger to auto-create; no push delivery |
| `pet_listings` | 0 | ✅ | Never used by app; redundant with `is_breeding_listed` flag |
| `products` | 0 | ✅ | No vendor UI |
| `orders` | 0 | ✅ | Dual schema (`items` JSONB + `order_items` table) |
| `order_items` | 0 | ✅ | Missing `product_id` index |

---

## 8. Dependency Audit

| Package | Current | Notes |
|---|---|---|
| `flutter_riverpod` | `^3.3.1` | ✅ Latest major |
| `go_router` | `^17.1.0` | ✅ Latest major |
| `supabase_flutter` | `^2.8.4` | ✅ Current stable |
| `google_fonts` | `^8.0.2` | ✅ |
| `image_picker` | `^1.1.2` | ✅ |
| `intl` | `^0.20.2` | ✅ |
| `json_serializable` | ❌ Missing | Required by rules file |
| `json_annotation` | ❌ Missing | Required by rules file |
| `flutter_dotenv` | ❌ Missing | Needed to properly load env vars |
| `firebase_messaging` | ❌ Missing | For push notifications |
| `cached_network_image` | ❌ Missing | Image caching for performance |
| `flutter_image_compress` | ❌ Missing | Should compress before upload |

---

## 9. Prioritized Action Plan

### P0 — Fix Immediately
1. Move Supabase credentials to `--dart-define` compile-time constants
2. Add DB unique constraint on `match_requests(sender_pet_id, receiver_pet_id)`
3. Enable leaked password protection in Supabase dashboard
4. Fix `set_updated_at` mutable `search_path`
5. Set `REPLICA IDENTITY FULL` on `post_likes` and `comments`

### P1 — Fix Before Beta
6. Add all missing FK indexes (11 tables)
7. Consolidate duplicate RLS policies (remove old ones)
8. Wrap `auth.uid()` in `(SELECT auth.uid())` in all RLS policies
9. Fix N+1 in `ChatRepository.fetchThreads` (use single batch query)
10. Create `profiles` row via DB trigger instead of client-side upsert
11. Wire match acceptance → auto-create `matches` + `chat_threads` rows
12. Add push notification integration (Supabase Edge Function + FCM)

### P2 — Feature Completeness
13. Add dark theme
14. Implement password reset flow
15. Add pet/account deletion
16. Implement dynamic breed filter from DB
17. Add pagination to feed
18. Build matched pets screen
19. Add image message support in chat
20. Implement notification badges (unread count)

### P3 — Code Quality
21. Migrate models to `json_serializable`
22. Replace `debugPrint` with `dart:developer log`
23. Add `cached_network_image` for performance
24. Inject repositories via constructor DI (improves testability)
25. Add input validation across forms
26. Add error display to all screens that set `state.error`

---

## 10. Positive Highlights

These parts of the codebase are well-implemented and shouldn't be changed:

- ✅ **Auth flow** — The `_isPerformingAuthAction` guard preventing the auth stream from overwriting login/register state is thoughtful
- ✅ **Router redirect logic** — Correctly handles `initial → splash → authenticated/unauthenticated` states
- ✅ **Load generation guard** — Prevents stale async results from overwriting newer state
- ✅ **Optimistic messaging** — Temp message + rollback in chat is the right UX pattern
- ✅ **`activePetProvider`** — Clean derived provider for the "acting as" concept
- ✅ **RLS is enabled on all tables** — No tables are unprotected
- ✅ **Storage upload with content-type detection** — Correct mime type handling
- ✅ **`pet_listings` status constraints** — Good use of `CHECK` constraints
