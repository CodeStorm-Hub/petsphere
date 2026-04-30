# PetSphere — Comprehensive Project Audit

**Generated:** 2026-04-26  
**Auditor:** AI Agent (Cursor Sonnet 4.6) with Supabase MCP, online research, and full codebase inspection  
**Repository:** `g:\Pet\petsphere`  
**Supabase Project:** `foubokcqaxyqgjhtgzsx` (ap-southeast-1, ACTIVE_HEALTHY)  
**Flutter SDK:** 3.41.6 · Dart 3.11.4

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Project Overview and Tech Stack](#2-project-overview-and-tech-stack)
3. [Architecture Review](#3-architecture-review)
4. [Authentication Analysis](#4-authentication-analysis)
5. [Security Review](#5-security-review)
6. [Database Schema Analysis](#6-database-schema-analysis)
7. [RLS Policy Analysis](#7-rls-policy-analysis)
8. [Triggers and Functions Analysis](#8-triggers-and-functions-analysis)
9. [Dependency Package Review](#9-dependency-package-review)
10. [UI/UX Analysis](#10-uiux-analysis)
11. [User Stories and Actor Analysis](#11-user-stories-and-actor-analysis)
12. [Feature and Functionality Analysis](#12-feature-and-functionality-analysis)
13. [Platform Configuration Review](#13-platform-configuration-review)
14. [CI/CD Pipeline Review](#14-cicd-pipeline-review)
15. [Performance Analysis](#15-performance-analysis)
16. [Code Quality and Testing](#16-code-quality-and-testing)
17. [Issues by Severity](#17-issues-by-severity)
18. [Implementation Plan](#18-implementation-plan)
19. [Research Notes — Latest Best Practices](#19-research-notes--latest-best-practices)

---

## 1. Executive Summary

PetSphere is a Flutter social-commerce app for pet owners combining Instagram-style social feed, pet profiles, pet discovery/matching (breeding), in-app chat, notifications, and a marketplace. It is backed by Supabase (Auth, Postgres, Storage, Realtime) and uses Riverpod 3 for state management and go_router for navigation.

The app is meaningfully complete: it has a layered Riverpod architecture, Supabase repositories, a centralized theme, polished screens with loading/empty/error states, Realtime subscriptions, and a live Supabase project. The code passes `flutter analyze` cleanly.

**However, the app has several blockers that must be resolved before any production release:**

### Most Critical Issues (Must Fix Before Launch)

| # | Issue | Impact |
|---|-------|--------|
| 1 | **Duplicate DB triggers create double notifications for every match AND every chat message** | Data corruption, spam, UX degradation |
| 2 | **RLS: The SENDER of a match request can accept their own request** | Authorization bypass |
| 3 | **Storage policies allow any authenticated user to update/delete any other user's files** | Data loss / malicious deletion |
| 4 | **Android release builds lack `INTERNET` permission → networking fails in production** | App unusable on release |
| 5 | **Checkout trusts client-computed prices — price manipulation attack vector** | Financial integrity risk |
| 6 | **Supabase credentials are hardcoded in source code** | Security / operational risk |
| 7 | **No test suite** (`flutter test` fails with "directory not found") | Zero regression safety |
| 8 | **Avatar uploads go to the wrong Storage bucket** (`pet-images` instead of `avatars`) | Broken avatar functionality |

---

## 2. Project Overview and Tech Stack

### 2.1 Application Purpose

PetSphere is a mobile + web app for pet owners that provides:
- Social media feed (posts, likes, comments per pet persona)
- Pet profiles (multi-pet per user, breeding/matching listing)
- Discovery & matching (swipe-like, match requests, accept/decline)
- In-app chat (pet-to-pet messaging after match)
- Notifications (in-app; push not yet implemented)
- Marketplace (browse products, cart, checkout, order history)

### 2.2 Tech Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| Frontend | Flutter | 3.41.6 |
| Language | Dart | 3.11.4 |
| State Management | flutter_riverpod | ^3.3.1 |
| Routing | go_router | ^17.1.0 (latest 17.2.2) |
| Backend | Supabase (Auth, Postgres, Storage, Realtime) | — |
| Supabase Client | supabase_flutter | ^2.8.4 (locked 2.12.2, latest 2.12.4) |
| Image Loading | cached_network_image | ^3.4.1 |
| Image Picking | image_picker | ^1.1.2 |
| Fonts | google_fonts | ^8.0.2 |
| Sharing | share_plus | ^10.1.4 (latest 13.1.0) |
| URL Handling | url_launcher | ^6.3.1 |
| Internationalization | intl | ^0.20.2 |
| Database | Postgres 17.6.1 (via Supabase) | — |

### 2.3 Package Identity Issues

The package/app identity is still template-default and inconsistent:

| File | Value | Should Be |
|------|-------|-----------|
| `pubspec.yaml` `name:` | `pet_dating_app` | `petsphere` |
| `pubspec.yaml` `description:` | "A new Flutter project." | Meaningful description |
| `android/app/build.gradle.kts` `applicationId` | `com.example.pet_dating_app` | `com.petsphere.app` |
| `android/AndroidManifest.xml` `android:label` | `pet_dating_app` | `PetSphere` |
| `ios/Runner/Info.plist` `CFBundleDisplayName` | `Pet Dating App` | `PetSphere` |
| `ios/Runner/Info.plist` `CFBundleName` | `pet_dating_app` | `petsphere` |
| Login screen brand text | `The Nurtured Atelier` | `PetSphere` (or settle on a brand) |

---

## 3. Architecture Review

### 3.1 Folder Structure

```
lib/
├── controllers/          # Riverpod Notifiers (state + actions)
│   ├── auth_controller.dart
│   ├── bootstrap_controller.dart
│   ├── cart_controller.dart
│   ├── chat_controller.dart
│   ├── feed_controller.dart
│   ├── follow_controller.dart
│   ├── marketplace_controller.dart
│   ├── match_controller.dart
│   ├── notification_controller.dart
│   └── pet_controller.dart
├── models/               # Hand-written DTOs
├── repositories/         # Supabase data access layer
├── views/                # Screens
│   └── components/       # Reusable widgets
├── theme/                # AppTheme (centralized)
└── utils/                # Router, config, helpers
```

**Assessment:** The layer-based structure is functional and coherent for the current app size. For future maintainability at scale, migrating to a **feature-first** structure is recommended:

```
lib/
├── core/
│   ├── config/           # supabase_config.dart, env
│   ├── routing/          # routes.dart
│   └── theme/
├── features/
│   ├── auth/             # controller, repository, models, screens
│   ├── feed/
│   ├── pets/
│   ├── discovery/
│   ├── chat/
│   ├── marketplace/
│   └── notifications/
└── shared/               # shared widgets, utils
```

### 3.2 Data Flow

```
UI Widgets
   │ ref.watch / ref.read
   ▼
Controllers (Notifiers) ──── state.copyWith ──── UI rebuild
   │ repository calls
   ▼
Repositories (Supabase calls) ──── response data
   │
   ▼
Models (manual fromJson)
   │
   ▼
Supabase RLS enforces access control
```

**Strengths:**
- Clear separation between UI and data access
- Controllers expose high-level, business-meaningful actions
- Realtime subscriptions are encapsulated in repositories
- Bootstrap controller elegantly hydrates providers on auth changes

**Weaknesses:**
- All repositories are global singletons (`final authRepository = AuthRepository()`), making unit testing and dependency injection impossible without refactoring
- Models use manual `fromJson` with hard casts — a schema change causes runtime crashes, not compile-time errors
- Error handling largely converts exceptions to `e.toString()` and exposes raw Supabase error messages to users
- Some business logic is split between Flutter code, DB triggers, and RLS with no single source of truth

### 3.3 Notable Architecture Observations

**`bootstrap_controller.dart`** — Well-designed side-effect provider that hydrates providers on login/cold-start. The generation-count pattern in `PetNotifier` to cancel stale loads is correct.

**`feed_controller.dart`** — Uses a generation counter to prevent stale async loads. The auth stream listener correctly deduplicates by user ID.

**`chat_controller.dart`** — `threadMessagesProvider` is intentionally not auto-disposed (comment explains why). The `ThreadMessagesNotifier` correctly unsubscribes the Realtime channel in `onDispose`.

**`auth_controller.dart`** — The `_init()` method subscribes to `authStateChanges` stream but the subscription is **never stored and never cancelled**. On provider rebuild, a new subscription is added without removing the old one. This is a memory/event leak.

---

## 4. Authentication Analysis

### 4.1 Implemented Auth Flows

| Flow | Status | Notes |
|------|--------|-------|
| Email/password login | ✅ Complete | |
| Email/password registration | ✅ Complete | Profile upsert post-signup |
| Session restoration (cold start) | ✅ Complete | `_checkCurrentSession()` + `bootstrapProvider` |
| Logout | ✅ Complete | |
| Password reset email | ⚠️ Partial | Email sent; no deep-link callback handling |
| Google Sign-In | ❌ Placeholder | Shows "coming soon" SnackBar |
| Apple Sign-In | ❌ Placeholder | Shows "coming soon" SnackBar |
| Email confirmation | ❌ Not handled | If email confirmation enabled in Supabase, UX is broken |
| Account deletion | ❌ Missing | |
| MFA | ❌ Missing | |

### 4.2 Auth Controller Issues

**Issue 1: Stream subscription leak**
```dart
// auth_controller.dart:56 — subscription stored nowhere
authRepository.authStateChanges.listen((event) async { ... });
```
The stream subscription is never stored in a variable or cancelled. On provider rebuild, multiple subscriptions accumulate. Fix:
```dart
StreamSubscription<AuthState>? _authSub;

void _init() {
  _authSub?.cancel();
  _authSub = authRepository.authStateChanges.listen(...);
  ref.onDispose(() => _authSub?.cancel());
  _checkCurrentSession();
}
```

**Issue 2: Direct Supabase call in UI layer**
```dart
// login_screen.dart:95 — bypasses AuthRepository
await supabase.auth.resetPasswordForEmail(email);
```
The `_forgotPassword` method calls Supabase directly from the UI widget, bypassing the repository pattern. Add `resetPassword(String email)` to `AuthRepository` and route the call through `AuthNotifier`.

**Issue 3: Registration does not handle email confirmation**
If Supabase has email confirmation enabled, `signUp()` returns a user object but the user cannot authenticate until confirming their email. The UI transitions to authenticated state immediately.

**Issue 4: No post-login redirect**
When a deep link navigates to `/product/:id` and the user is not logged in, go_router redirects to `/login`, then on success redirects to `/home` — dropping the original destination.

### 4.3 Password Reset Deep Linking

The password reset email is sent correctly. However, there is no:
- Custom URL scheme registered in `AndroidManifest.xml` or `Info.plist`
- Deep link redirect URL configured in Supabase Dashboard
- Handler listening for `AuthChangeEvent.passwordRecovery`

Per [Supabase Native Mobile Deep Linking docs](https://supabase.com/docs/guides/auth/native-mobile-deep-linking):

**Android** (`AndroidManifest.xml`) needs:
```xml
<intent-filter android:autoVerify="true">
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="com.petsphere.app" android:host="login-callback" />
</intent-filter>
```

**iOS** (`Info.plist`) needs:
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLName</key>
    <string>com.petsphere.app</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.petsphere.app</string>
    </array>
  </dict>
</array>
```

**Supabase initialization** should use PKCE flow:
```dart
await Supabase.initialize(
  url: supabaseUrl,
  anonKey: supabaseAnonKey,
  authOptions: FlutterAuthClientOptions(
    authFlowType: AuthFlowType.pkce,
  ),
);
```

---

## 5. Security Review

### 5.1 Credentials in Source Code

**Finding:** `lib/utils/supabase_config.dart` contains a hardcoded Supabase URL and anon JWT:
```dart
const String supabaseUrl = 'https://foubokcqaxyqgjhtgzsx.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

**Risk Level:** Medium. The anon key is public-by-design when RLS is correct, but committing it:
- Ties every build to one project (no dev/staging/prod separation)
- Makes key rotation require a code release
- Can become high-risk if the key is accidentally escalated to service role

**Remediation:** Use `--dart-define-from-file` with a `.dart_define.json` file:
```json
{
  "SUPABASE_URL": "https://foubokcqaxyqgjhtgzsx.supabase.co",
  "SUPABASE_ANON_KEY": "eyJ..."
}
```
```dart
const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
```
```bash
flutter run --dart-define-from-file=.dart_define.json
```

### 5.2 Storage Policy Vulnerabilities (CRITICAL)

**Finding:** Storage policies for `pet-images` and `post-media` allow **any authenticated user** to update or delete **any other user's files**:

```sql
-- Current (from storage_policies.sql and remote)
CREATE POLICY "Authenticated users can update pet images"
ON storage.objects FOR UPDATE TO authenticated
USING (bucket_id = 'pet-images')        -- ANY file in bucket
WITH CHECK (bucket_id = 'pet-images');  -- ANY file in bucket

CREATE POLICY "Authenticated users can delete pet images"  
ON storage.objects FOR DELETE TO authenticated
USING (bucket_id = 'pet-images');       -- ANY file in bucket
```

**Impact:** A malicious user can delete any other user's pet images or profile photos, causing visible data loss.

**Remediation:** Scope all mutating policies to the user's own path:

```sql
-- Drop the broad policies
DROP POLICY IF EXISTS "Authenticated users can update pet images" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can delete pet images" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can update post media" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can delete post media" ON storage.objects;

-- Replace with user-scoped policies (path format: {user_id}/{filename})
CREATE POLICY "Users can update own pet images"
ON storage.objects FOR UPDATE TO authenticated
USING (bucket_id = 'pet-images' AND (storage.foldername(name))[1] = (auth.uid())::text)
WITH CHECK (bucket_id = 'pet-images' AND (storage.foldername(name))[1] = (auth.uid())::text);

CREATE POLICY "Users can delete own pet images"
ON storage.objects FOR DELETE TO authenticated
USING (bucket_id = 'pet-images' AND (storage.foldername(name))[1] = (auth.uid())::text);
```

Also update upload paths in `PetRepository.uploadPetImage()` to include the user ID prefix:
```dart
// Current
final path = '$petId/${DateTime.now().millisecondsSinceEpoch}.$ext';

// Fixed — include user_id as folder prefix
final userId = supabase.auth.currentUser!.id;
final path = '$userId/$petId/${DateTime.now().millisecondsSinceEpoch}.$ext';
```

### 5.3 Avatar Upload to Wrong Bucket (BUG)

**Finding:** `AuthRepository.uploadAvatar()` uploads to `pet-images` instead of `avatars`:
```dart
// auth_repository.dart:99 — WRONG BUCKET
await supabase.storage.from(kBucketPetImages).upload(...);  
return supabase.storage.from(kBucketPetImages).getPublicUrl(path);

// Should be:
await supabase.storage.from('avatars').upload(...);
return supabase.storage.from('avatars').getPublicUrl(path);
```

The `avatars` bucket already has correct user-scoped policies (verified remotely). This is a simple bug that causes avatars to go into the wrong bucket and accumulate alongside pet images, and means the avatar-specific access policies don't apply.

### 5.4 Match Request Authorization Bypass (HIGH)

**Finding:** The `match_requests` UPDATE RLS policy allows EITHER the sender OR receiver to update the status:
```sql
-- Allows sender to change status to 'matched' on their OWN request
USING (EXISTS (
  SELECT 1 FROM pets
  WHERE (pets.id = match_requests.sender_pet_id 
     OR pets.id = match_requests.receiver_pet_id)
  AND pets.user_id = auth.uid()
))
```

**Impact:** The user who sent a match request can call `updateRequestStatus(requestId, 'matched')` on their own pending request, bypassing the intended accept/decline flow. This could create fraudulent matches and associated chat threads.

**Remediation:** Restrict the UPDATE policy to the receiver only:
```sql
DROP POLICY IF EXISTS "Users can update own match requests" ON public.match_requests;

CREATE POLICY "Only receiver can accept/decline match requests"
ON public.match_requests FOR UPDATE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.pets
    WHERE pets.id = match_requests.receiver_pet_id
    AND pets.user_id = auth.uid()
  )
)
WITH CHECK (
  status IN ('matched', 'rejected')  -- only these transitions allowed by receiver
);
```

### 5.5 Client-Writeable Notifications (MEDIUM)

**Finding:** The `notifications` table has a client INSERT policy:
```sql
CREATE POLICY "Users can insert notifications"
ON public.notifications FOR INSERT TO authenticated
WITH CHECK (auth.uid() = user_id);
```

**Impact:** Users can create arbitrary notifications for themselves. If the front-end uses notifications as triggers for business logic, this could be abused. The intent is likely that notifications should only be created by DB triggers/functions.

**Remediation:** Remove the client INSERT policy. All notifications are already written by server-side functions (`notify_on_match_accepted`, `notify_on_new_message`, `notify_on_order_status_change`).

### 5.6 Checkout Price Manipulation (HIGH)

**Finding:** `MarketplaceRepository.placeOrder()` inserts client-computed prices:
```dart
final orderItems = items.map((i) => {
  'product_id': i.product.id,
  'name': i.product.name,
  'quantity': i.quantity,
  'price': i.product.price,   // ← client-provided price
  'subtotal': i.subtotal,     // ← client-computed subtotal
}).toList();

await supabase.from('orders').insert({
  'total': total,  // ← client-computed total
  ...
});
```

**Impact:** A modified client (Burp Suite, frida) can submit any price including $0.

**Remediation:** Create a Supabase Edge Function or RPC that:
1. Accepts only `[{product_id, quantity}]` from the client
2. Reads current prices from the `products` table server-side
3. Checks stock availability
4. Computes totals
5. Inserts the order transactionally

### 5.7 Leaked Password Protection

**Finding:** Supabase security advisor reports: "Leaked Password Protection Disabled." Supabase can check against HaveIBeenPwned.org to prevent use of compromised passwords.

**Remediation:** Enable in Supabase Dashboard > Authentication > Password.

### 5.8 Logging PII in Release

**Finding:** Many `debugPrint` statements log user IDs, pet names, operation details, and raw exceptions. `debugPrint` is stripped in release mode on some platforms but not all, and relies on Flutter's `kDebugMode` guard.

**Remediation:** Introduce a logging utility that gates on `kReleaseMode`:
```dart
void log(String message) {
  if (kDebugMode) debugPrint(message);
}
```

---

## 6. Database Schema Analysis

### 6.1 Tables (Confirmed Remote)

| Table | Rows | RLS | Notes |
|-------|------|-----|-------|
| `profiles` | 3 | ✅ | User profiles linked to `auth.users` |
| `pets` | 9 | ✅ | Multi-pet per user; `is_breeding_listed`, `is_verified` |
| `posts` | 8 | ✅ | Pet posts with `media_url`, `caption` |
| `post_likes` | 7 | ✅ | Composite FK: post_id + pet_id |
| `comments` | 12 | ✅ | Pet-authored comments |
| `match_requests` | 10 | ✅ | sender/receiver pets, status pending/matched/rejected |
| `chat_threads` | 1 | ✅ | Two pet participants |
| `messages` | 3 | ✅ | Thread messages with delivery metadata |
| `products` | 15 | ✅ | Marketplace products |
| `orders` | 3 | ✅ | JSONB items, client-computed total |
| `order_items` | 0 | ✅ | Normalized order lines — **unused by Flutter** |
| `matches` | 1 | ✅ | Accepted matches — **unused by Flutter UI** |
| `pet_listings` | 0 | ✅ | Rich listing table — **unused by Flutter** |
| `notifications` | 14 | ✅ | In-app notifications |

### 6.2 Schema Drift (Local SQL vs Remote)

The local `supabase/` directory contains 4 ad-hoc SQL scripts, not a proper migration history. Remote has significantly more:

| Item | Local | Remote | Impact |
|------|-------|--------|--------|
| `orders.user_id` FK | → `auth.users` | → `profiles.id` | Breaking if local SQL re-applied |
| `matches` table | Not documented | Exists with triggers | Flutter ignores it |
| `pet_listings` table | Not documented | Exists with policies | Flutter ignores it |
| `order_items` table | Not documented | Exists | Flutter uses JSONB instead |
| `notifications` table | Not documented | Exists with 14 rows | Flutter reads/writes it |
| Duplicate triggers | Not documented | 4 duplicate triggers | Bug (see §8) |

**Remediation:** Adopt proper Supabase CLI migrations:
```bash
supabase db pull --schema public --local --yes  # baseline migration from remote
supabase migration list --local                  # verify
```

### 6.3 Missing Constraints

| Column | Table | Issue |
|--------|-------|-------|
| `pet_id` in chat_threads | Has no uniqueness constraint on the (pet_id_1, pet_id_2) pair | Possible duplicate threads despite application-level check |
| `match_requests` | No unique constraint on (sender_pet_id, receiver_pet_id) | Multiple requests can be sent |
| `orders.total` | No server-side validation | Client can submit any value |
| `pets.age` | No CHECK constraint | Negative age allowed |

---

## 7. RLS Policy Analysis

### 7.1 Policy Summary

All public tables have RLS enabled. Key patterns:

| Table | SELECT | INSERT | UPDATE | DELETE |
|-------|--------|--------|--------|--------|
| `profiles` | All authenticated | Own id only | Own id only | — |
| `pets` | All authenticated | Own user_id | Own user_id | Own user_id |
| `posts` | All authenticated | Via owned pet | — | Via owned pet |
| `post_likes` | All authenticated | Via owned pet | — | Via owned pet |
| `comments` | All authenticated | Via owned pet | — | — |
| `match_requests` | Sender OR receiver | Via sender pet | **Sender OR receiver** ⚠️ | — |
| `chat_threads` | Via owned pet | Via ANY owned pet | — | — |
| `messages` | Via thread pet | Via sender pet | — | — |
| `notifications` | Own user_id | **Own user_id** ⚠️ | Own user_id | — |
| `orders` | Own user_id | Own user_id | — | — |
| `products` | All authenticated | **Via vendor_id** ⚠️ | Via vendor_id | Via vendor_id |

### 7.1a RLS Performance — `auth.uid()` Caching Pattern

All current RLS policies call `auth.uid()` directly in the `USING` clause. Postgres re-evaluates this function **once per row**. Wrapping it in a subquery caches the result for the entire query, which is a major performance win on large tables:

```sql
-- Current (re-evaluated per row)
USING (user_id = auth.uid())

-- Optimized (evaluated once per query)
USING (user_id = (SELECT auth.uid()))
```

Apply this pattern to all policies in `profiles`, `pets`, `posts`, `orders`, `notifications`, `match_requests`, `chat_threads`, `messages`, and storage objects.

### 7.2 Policy Issues

**Issue 1: `match_requests` UPDATE — sender can accept own request** (covered in §5.4)

**Issue 2: `notifications` INSERT — client can create own notifications** (covered in §5.5)

**Issue 3: `products` INSERT — any user can create products**
The `Vendors can manage products` policy uses `auth.uid() = vendor_id`. Any user who sends a POST request with their own user ID as `vendor_id` becomes a vendor. There is no vendor approval flow or role. This may be intended for an eventual seller marketplace, but should be locked down or a role-based check added.

**Issue 4: `chat_threads` INSERT — does not require a match**
The policy allows any user to create a thread where they own either pet_id_1 OR pet_id_2. This means a user can initiate chat with anyone without a match. The application code attempts to call `createOrGetThread` only after a match, but there is no DB-level enforcement.

**Issue 5: Multiple permissive SELECT policies (performance)**
- `pet_listings`: `Anyone can view active listings` + `Owners can manage listings` → 2 policies for SELECT
- `products`: `Anyone can view products` + `Vendors can manage products` → 2 policies for SELECT

Supabase advisor correctly flags these. Fix by consolidating into a single policy per action.

### 7.3 Storage Policies (Full List)

**`avatars` bucket:**
- ✅ Users can upload/update/delete own avatar (path-scoped to `auth.uid()`)
- ⚠️ Public SELECT broad (allows listing all files in bucket)

**`pet-images` bucket:**
- ❌ Any authenticated user can update/delete any file (not path-scoped)
- ❌ Duplicate INSERT policies: "Authenticated users can upload pet images" + "pet-images: allow auth insert"
- ❌ Duplicate UPDATE policies: "Authenticated users can update pet images" + "pet-images: allow auth update"
- ⚠️ Public SELECT broad (allows listing)

**`post-media` bucket:**
- ❌ Any authenticated user can update/delete any file (not path-scoped)
- ⚠️ Public SELECT broad (allows listing)

**Remediation (see §5.2):** Fix all policies to be path-scoped, remove duplicates, remove broad listing policies.

---

## 8. Triggers and Functions Analysis

### 8.1 Trigger Inventory

| Trigger | Table | Event | Function |
|---------|-------|-------|----------|
| `set_chat_threads_updated_at` | `chat_threads` | BEFORE UPDATE | `set_updated_at()` |
| `on_match_request_accepted` | `match_requests` | AFTER UPDATE | `handle_match_accepted()` |
| `trg_match_accepted_side_effects` | `match_requests` | AFTER UPDATE | `handle_match_accepted()` ⚠️ DUPLICATE |
| `trg_match_accepted_notifications` | `match_requests` | AFTER UPDATE | `notify_on_match_accepted()` |
| `trg_notify_match_accepted` | `match_requests` | AFTER UPDATE | `notify_on_match_accepted()` ⚠️ DUPLICATE |
| `set_matches_updated_at` | `matches` | BEFORE UPDATE | `set_updated_at()` |
| `trg_notify_new_message` | `messages` | AFTER INSERT | `notify_on_new_message()` |
| `trg_notify_on_new_message` | `messages` | AFTER INSERT | `notify_on_new_message()` ⚠️ DUPLICATE |
| `set_orders_updated_at` | `orders` | BEFORE UPDATE | `set_updated_at()` |
| `trg_notify_order_status_change` | `orders` | AFTER UPDATE | `notify_on_order_status_change()` |
| `set_pet_listings_updated_at` | `pet_listings` | BEFORE UPDATE | `set_updated_at()` |

### 8.2 Duplicate Trigger Analysis (CRITICAL)

**`match_requests` duplicates:**
- `handle_match_accepted` is called by TWO triggers (`on_match_request_accepted` + `trg_match_accepted_side_effects`). The function is **idempotent** thanks to `ON CONFLICT DO NOTHING` on `matches` and the `WHERE NOT EXISTS` check on `chat_threads`. So currently this does not cause data corruption, but wastes resources.
- `notify_on_match_accepted` is called by TWO triggers (`trg_match_accepted_notifications` + `trg_notify_match_accepted`). This function is **NOT idempotent** — it inserts notifications unconditionally. Every match acceptance creates **4 notifications** (2 × 2 duplicate triggers). This is a confirmed bug causing notification spam.

**`messages` duplicate:**
- `notify_on_new_message` is called by TWO triggers (`trg_notify_new_message` + `trg_notify_on_new_message`). Each new message creates **2 notifications** for the recipient. Confirmed notification spam bug.

**Remediation:**
```sql
-- Remove duplicate triggers
DROP TRIGGER IF EXISTS on_match_request_accepted ON public.match_requests;
DROP TRIGGER IF EXISTS trg_match_accepted_notifications ON public.match_requests;
DROP TRIGGER IF EXISTS trg_notify_on_new_message ON public.messages;
-- Keep: trg_match_accepted_side_effects, trg_notify_match_accepted, trg_notify_new_message
```

### 8.3 Function Analysis

| Function | Purpose | Issues |
|----------|---------|--------|
| `handle_match_accepted` | Creates `matches` row + `chat_threads` row when status='matched' | Idempotent. Works correctly. |
| `handle_new_user` | Creates `profiles` row on auth user creation | Missing from trigger list — check if trigger exists on `auth.users` |
| `notify_on_match_accepted` | Creates 2 notifications (sender + receiver) when match accepted | Called twice per match due to duplicate triggers |
| `notify_on_new_message` | Creates notification for message recipient | Called twice per message due to duplicate triggers |
| `notify_on_order_status_change` | Creates notification when order status changes | Appears correct |
| `set_updated_at` | Updates `updated_at` timestamp | Correct utility function |

---

## 9. Dependency Package Review

### 9.1 Direct Dependencies

| Package | Constraint | Locked | Latest | Status |
|---------|-----------|--------|--------|--------|
| `go_router` | ^17.1.0 | 17.1.0 | 17.2.2 | Minor update available |
| `flutter_riverpod` | ^3.3.1 | ~3.2.1 | 3.x | Check current |
| `supabase_flutter` | ^2.8.4 | 2.12.2 | 2.12.4 | Patch update available |
| `share_plus` | ^10.1.4 | 10.1.4 | 13.1.0 | **CRITICAL on iOS 26** — crashes due to deprecated APIs |
| `image_picker` | ^1.1.2 | 1.2.1 | Latest | OK |
| `cached_network_image` | ^3.4.1 | — | 3.4.1 | ⚠️ Largely unmaintained — consider `cached_network_image_ce` |
| `google_fonts` | ^8.0.2 | 8.0.2 | Latest | OK |
| `url_launcher` | ^6.3.1 | 6.3.2 | Latest | OK |
| `intl` | ^0.20.2 | — | Latest | OK |

### 9.2 Issues Found

**`share_plus` — iOS 26 crash (CRITICAL):**
Versions 10.x–11.x crash on iOS 26 (released 2026) because they use deprecated iOS share-sheet APIs. The API changed entirely:
```dart
// Old (crashes on iOS 26)
Share.share('text');

// New — required for iOS 26+
SharePlus.instance.share(ShareParams(text: 'text'));
```
iPad additionally requires `sharePositionOrigin` or it crashes. Version 13.0.0 also requires Android Gradle Plugin ≥8.12.1 and Kotlin 2.2.0. Plan this as a coordinated upgrade with build config changes.

**SDK constraint too broad:**
```yaml
environment:
  sdk: ">=3.0.0 <4.0.0"  # Declared minimum is too low
```
The lockfile requires `>=3.11.0`. Update the constraint to reflect reality:
```yaml
environment:
  sdk: ">=3.11.0 <4.0.0"
```

**Missing dev dependencies:**
- No `mockito` or `mocktail` for mocking
- No `riverpod_generator` for code generation
- No `freezed` for immutable models
- No `json_serializable` for type-safe JSON

**`cached_network_image` maintenance concern:**
The package has been largely unmaintained for 2+ years. A community fork `cached_network_image_ce` (using `hive_ce`) provides significantly faster cache lookups. Monitor this if image loading performance degrades at scale; it is a drop-in replacement.

### 9.3 Recommended Additions

| Package | Purpose | Priority |
|---------|---------|---------|
| `mocktail` | Mocking for tests | High (needed before testing) |
| `flutter_secure_storage` | Secure credential storage | Medium |
| `connectivity_plus` | Offline/network detection | Medium |
| `flutter_local_notifications` | Push notification display | Medium |
| `firebase_messaging` | FCM for push notifications | Medium |
| `freezed` + `json_serializable` | Type-safe models | Low-Medium |
| `riverpod_generator` | Riverpod code generation | Low-Medium |
| `custom_lint` + `riverpod_lint` | Static analysis | Low |

---

## 10. UI/UX Analysis

### 10.1 Design System

The app uses a cohesive, warm design system ("The Nurtured Atelier"):
- Primary: deep terracotta (#99472C)
- Secondary: amber/gold (#745C00)
- Tertiary: sage green (#506453)
- Typography: Plus Jakarta Sans (Google Fonts)
- Material 3 (`useMaterial3: true`) with custom theme

The theme is well-structured in `AppTheme` with both light and dark variants, proper `ColorScheme` usage, and consistent component overrides.

### 10.2 Brand Inconsistency

Multiple brand names appear throughout the app:
- `PetSphere` — app title in `main.dart`
- `The Nurtured Atelier` — login screen brand text
- `The Nurtured Nest` — mentioned in docs
- `pet_dating_app` — package/bundle ID
- `Pet Dating App` — iOS display name

**All UI text and platform metadata must be unified under one brand.**

### 10.3 Incomplete UI Elements

| Element | Location | Status |
|---------|---------|--------|
| Google Sign-In button | `login_screen.dart` | Shows SnackBar "coming soon" |
| Apple Sign-In button | `login_screen.dart` | Shows SnackBar "coming soon" |
| Chat attachment button | `chat_screen.dart` | Placeholder only |
| Terms & Privacy links | `settings_screen.dart` | May be placeholder URLs |
| Post edit functionality | Post detail | Missing |

### 10.4 Navigation Issues

**Bottom navigation:**
- 5-tab nav uses a custom `_InstagramNavBar` with `InkResponse`
- Tab items have no semantic labels (`Semantics(label: ...)` missing)
- The "add" tab (index 2) pushes a route but leaves `IndexedStack` at index 2, which renders `SizedBox.shrink()` on the stack — could cause layout confusion
- Tab index is kept in widget state, not reflected in route URL

**Route naming inconsistency:**
```
/create_post    # snake_case
/add_pet        # snake_case  
/pet/:id        # REST-like with snake_case
/product/:id    # REST-like
/chat/:threadId # camelCase path parameter
```
Standardize all routes to one convention. go_router docs recommend kebab-case path segments.

### 10.5 Accessibility Gaps

| Issue | Severity | Location |
|-------|---------|---------|
| Bottom nav icons lack semantic labels | High | `main_layout.dart` |
| Custom `GestureDetector` login button lacks button semantics | High | `login_screen.dart` |
| Pet profile images often lack `Semantics(label: ...)` | Medium | Multiple screens |
| `NetworkImage` avatars in bottom nav lack alt text | Medium | `main_layout.dart` |
| No accessibility tests | High | Project-wide |

The login screen uses a `GestureDetector`-wrapped `Container` for the sign-in button instead of a `FilledButton`. This means screen readers cannot identify it as a button, and it won't respond to keyboard navigation.

**Fix:** Replace the custom gradient button with a proper `FilledButton` that uses a `BoxDecoration` via `style` or use `FilledButton` with `ShaderMask`:
```dart
FilledButton(
  onPressed: authState.isLoading ? null : _login,
  style: FilledButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 18),
    shape: const StadiumBorder(),
  ),
  child: authState.isLoading
    ? const CircularProgressIndicator()
    : const Text('Sign In'),
),
```

### 10.6 Known UX Gaps

| Feature | Status |
|---------|--------|
| Pagination / infinite scroll | Missing — feed hardcoded to 50 posts |
| Cart persistence (restart) | Missing — cart is in-memory only |
| Offline / poor network UX | Missing — shows generic error strings |
| Onboarding after registration | Missing — lands on empty home |
| Theme toggle in UI | Missing — only follows system theme |
| Localization | Missing — all strings are hardcoded English |
| Pull-to-refresh on all list screens | Present ✅ |
| Empty/loading/error states | Mostly present ✅ |

---

## 11. User Stories and Actor Analysis

### 11.1 Actors

| Actor | Description | Implementation Status |
|-------|-------------|----------------------|
| **Visitor** | Unauthenticated user | Can only see login/register screens |
| **Pet Owner** | Authenticated user who owns pets | Main persona — most features implemented |
| **Pet Persona** | User's active pet (used for likes, comments, matches, chats) | Implemented via `activePetProvider` |
| **Product Vendor** | User whose ID matches `products.vendor_id` | No UI, DB policy exists |
| **Admin/Operator** | System administrator | No UI, implied by order/status management needs |

### 11.2 User Stories

#### Implemented ✅
- As a visitor, I can register with email/password
- As a visitor, I can log in with email/password
- As a user, I can request a password reset email
- As a user, I can log out
- As a user, I can create a pet profile with photo
- As a user, I can switch between my pets as the active pet
- As a pet owner, I can create posts with images for my pet
- As a pet owner, I can browse the social feed
- As a pet owner, I can like and unlike posts as my active pet
- As a pet owner, I can comment on posts as my active pet
- As a pet owner, I can list/unlist my pet for breeding discovery
- As a pet owner, I can browse listed pets in discovery
- As a pet owner, I can filter discovery by animal type and breed
- As a pet owner, I can send match/like requests to other pets
- As a pet owner, I can view received match requests
- As a pet owner, I can accept or decline match requests
- As a pet owner, I can chat with matched pets
- As a user, I can receive and view in-app notifications
- As a user, I can mark notifications as read
- As a user, I can browse marketplace products
- As a user, I can filter products by category
- As a user, I can view product details
- As a user, I can add products to an in-memory cart
- As a user, I can place a basic order
- As a user, I can view order history
- As a user, I can view my sent match requests ("liked pets")

#### Partially Implemented ⚠️
- As a user, I can sign in with Google (button exists, "coming soon")
- As a user, I can sign in with Apple (button exists, "coming soon")
- As a user, I can complete password reset (email sent, no callback)
- As a user, I can update my profile (exists but pet profile screen mixes concerns)
- As a vendor, I can manage products (DB policy exists, no UI)

#### Not Implemented ❌
- As a user, I can attach media in chat messages
- As a user, I can receive push notifications
- As a user, I can delete my account
- As a user, I can verify my email after registration
- As a user, I can navigate back to my original destination after login
- As a user, I can browse the app without logging in (guest mode)
- As a user, I can pay for orders (no payment gateway)
- As a user, I can manage my shipping address
- As a user, I can report or block other users
- As a vendor, I can manage my products
- As an admin, I can manage orders and products
- As a user, I can search for posts or users globally
- As a user, I can see a pet deletion flow
- As a user, I can see localized content (multi-language)

---

## 12. Feature and Functionality Analysis

### 12.1 Social Feed

| Aspect | Status | Issues |
|--------|--------|--------|
| Post listing | ✅ | Hardcoded `.limit(50)`, no pagination |
| Post creation | ✅ | |
| Post deletion | ✅ | |
| Like/unlike (optimistic) | ✅ | |
| Realtime likes | ✅ | |
| Comments | ✅ | |
| Realtime comments | ✅ | Extra HTTP call per new comment (fetches full comment) |
| Post detail route | ✅ | |
| Post edit | ❌ | Not implemented |
| Comment validation | ⚠️ | No length limit enforced client-side |
| Media type validation | ⚠️ | Extension-based only, no MIME check |

### 12.2 Pet Management

| Aspect | Status | Issues |
|--------|--------|--------|
| Create pet | ✅ | |
| View my pets | ✅ | |
| Edit pet | ✅ | Via `updatePet()` |
| Toggle breeding listing | ✅ | |
| Delete pet | ❌ | No UI found |
| Multiple images per pet | ⚠️ | Data model supports it; upload UI unclear |
| Pet image upload | ✅ | |
| Active pet switching | ✅ | |

### 12.3 Discovery and Matching

| Aspect | Status | Issues |
|--------|--------|--------|
| Browse listed pets | ✅ | |
| Filter by animal type | ✅ | |
| Filter by breed | ✅ | |
| Search by name/breed | ✅ | Client-side filter on loaded data |
| Send like/match request | ✅ | |
| Receive match requests | ✅ | |
| Accept request | ✅ | |
| Decline request | ✅ | |
| Exclude already-requested pets | ⚠️ | Comment says "excludes already-requested" but code only excludes by `user_id`; a user can send multiple requests to the same pet |
| Duplicate match requests | ❌ | No unique constraint on (sender_pet_id, receiver_pet_id) in DB |
| DB-enforced match requirement for chat | ❌ | Missing |

### 12.4 Chat

| Aspect | Status | Issues |
|--------|--------|--------|
| Thread listing | ✅ | |
| Message listing | ✅ | |
| Send message (with optimistic update) | ✅ | |
| Realtime new messages | ✅ | |
| Mark thread as read | ✅ | |
| Message attachments | ❌ | Button visible, not implemented |
| Thread creation | ✅ | |
| N+1 query: last message per thread | ❌ | `fetchThreads()` loops and does 1 extra query per thread |
| Unread count | ⚠️ | Local only, not from DB |
| `ChatThreadModel` field mismatch | ❌ | Model expects `updated_at` and `unread_count` but `fetchThreads()` only selects `id, pet_id_1, pet_id_2, created_at, pet1, pet2` — `updatedAt` silently falls back to `DateTime.now()` |

**N+1 Issue in `ChatRepository.fetchThreads()`:**
```dart
// Fetches thread list, then 1 query per thread for last message
for (final thread in threads) {
  final lastMsg = await _fetchLastMessage(thread.id);
  ...
}
```
Fix with a single Postgres query using lateral join or window function:
```sql
SELECT ct.*, 
  last_msg.text as last_message_text,
  last_msg.created_at as last_message_at
FROM chat_threads ct
LEFT JOIN LATERAL (
  SELECT text, created_at FROM messages
  WHERE thread_id = ct.id
  ORDER BY created_at DESC LIMIT 1
) last_msg ON true
WHERE ct.pet_id_1 = $myPetId OR ct.pet_id_2 = $myPetId;
```

### 12.5 Marketplace

| Aspect | Status | Issues |
|--------|--------|--------|
| Browse products | ✅ | |
| Filter by category | ✅ | |
| Product details | ✅ | |
| Add to cart | ✅ | |
| Update quantity | ✅ | |
| Remove from cart | ✅ | |
| Checkout | ⚠️ | Client-computed totals (price manipulation risk) |
| Order history | ✅ | |
| Cart persistence | ❌ | In-memory only |
| Payment integration | ❌ | Not implemented |
| Stock validation | ❌ | No stock decrement on order |
| Shipping/address | ❌ | Not implemented |
| Vendor dashboard | ❌ | Not implemented |

### 12.6 Notifications

| Aspect | Status | Issues |
|--------|--------|--------|
| View notifications | ✅ | |
| Mark single as read | ✅ | |
| Mark all as read | ✅ | |
| Realtime subscription | ✅ | |
| Duplicate notifications | ❌ | Bug — duplicate triggers create 2x or 4x notifications |
| Client-writeable | ⚠️ | Users can insert own notifications (see §5.5) |
| Push notifications | ❌ | Not implemented |

---

## 13. Platform Configuration Review

### 13.1 Android

**`android/app/src/main/AndroidManifest.xml` issues:**

| Issue | Severity | Details |
|-------|---------|--------|
| Missing `INTERNET` permission | **CRITICAL** | Release builds will fail to reach Supabase; debug/profile manifests include it, but main does not |
| `android:label="pet_dating_app"` | High | Wrong brand |
| No deep link intent-filter | High | Password reset and OAuth callbacks won't work |

**Fix:** Add to main `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
```

**`android/app/build.gradle.kts` issues:**

| Issue | Severity | Details |
|-------|---------|--------|
| `applicationId = "com.example.pet_dating_app"` | High | Wrong app ID |
| `signingConfig = signingConfigs.getByName("debug")` | **Critical** | Release builds are signed with debug key — rejected by Play Store |
| No ProGuard/R8 obfuscation configured | Medium | Unobfuscated release |
| `compileSdk = flutter.compileSdkVersion` | Low | Should target SDK 35 for 2026 Play Store requirements |

### 13.2 iOS

**`ios/Runner/Info.plist` issues:**

| Issue | Severity | Details |
|-------|---------|--------|
| `CFBundleDisplayName = "Pet Dating App"` | High | Wrong brand |
| `CFBundleName = "pet_dating_app"` | High | Wrong name |
| Missing `NSCameraUsageDescription` | **Critical** | `image_picker` crashes without this permission string |
| Missing `NSPhotoLibraryUsageDescription` | **Critical** | `image_picker` crashes without this permission string |
| Missing URL scheme for deep links | High | OAuth/password reset callbacks won't work |

**Fix:** Add to `Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>PetSphere needs camera access to take photos of your pets.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>PetSphere needs photo library access to select pet photos.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>PetSphere needs permission to save photos to your library.</string>
```

### 13.3 Web

Web metadata (`web/index.html`, `web/manifest.json`) still uses default "pet_dating_app" branding. Not critical for mobile-first release but should be updated.

---

## 14. CI/CD Pipeline Review

### 14.1 Current State

One GitHub Actions workflow exists: `.github/workflows/ios-build.yml`

**Issues:**
- **No PR gate:** No workflow runs `flutter analyze` or `flutter test` on pull requests
- **Debug by default:** The workflow defaults to `configuration: Debug` (faster but not production-representative)
- **No Android workflow:** No automated Android build/test
- **Unsigned builds by default:** `use_signing: false` means the IPA artifact is unsigned
- **No `--dart-define`:** Workflow doesn't pass Supabase credentials, so any build that needs them will fail

### 14.2 Recommended CI Structure

```yaml
# .github/workflows/ci.yml
name: CI

on: [pull_request, push]

jobs:
  analyze-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test

  android-build:
    runs-on: ubuntu-latest
    needs: analyze-and-test
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
      - run: flutter pub get
      - run: |
          flutter build apk --release \
            --dart-define=SUPABASE_URL=${{ secrets.SUPABASE_URL }} \
            --dart-define=SUPABASE_ANON_KEY=${{ secrets.SUPABASE_ANON_KEY }}
```

---

## 15. Performance Analysis

### 15.1 Database Query Issues

| Issue | Location | Impact |
|-------|---------|--------|
| N+1: last message per chat thread | `ChatRepository.fetchThreads()` | O(n) queries per thread load |
| No pagination on feed | `FeedRepository.fetchPosts()` `.limit(50)` | Memory grows, slow first load |
| No cursor-based pagination on marketplace | `MarketplaceRepository.fetchProducts()` | All products loaded at once |
| No cursor-based pagination on messages | `ChatRepository.fetchMessages()` | All history loaded at once |

### 15.2 Supabase Performance Advisor

All flagged items are `INFO` level (unused indexes) because the app has minimal data/traffic. These indexes should not be removed — they will be used under real load.

| Flagged Index | Table | Note |
|--------------|-------|------|
| `idx_pets_user_id` | `pets` | Will be used — keep |
| `idx_posts_pet_id` | `posts` | Will be used — keep |
| `idx_comments_pet_id` | `comments` | Will be used — keep |
| `idx_messages_sender_pet_id` | `messages` | Will be used — keep |
| `idx_notifications_actor_pet_id` | `notifications` | Will be used — keep |

### 15.3 Widget Performance

| Issue | Location |
|-------|---------|
| `ImageStack` in `IndexedStack` renders all 5 tab screens on first navigation | `main_layout.dart` |
| `cached_network_image` not used universally — some screens use `NetworkImage` | Multiple screens |
| `google_fonts` downloads fonts at runtime first-run | Global |
| No `const` widget constructors used in some custom painters | `_DotGridPainter` (fine) |

---

## 16. Code Quality and Testing

### 16.1 Static Analysis

`flutter analyze`: **PASSES** — no issues found.

### 16.2 Testing

`flutter test`: **FAILS** — "Test directory 'test' not found."

No tests exist whatsoever. This is the largest single maintainability risk.

### 16.3 Code Quality Observations

**Positive patterns:**
- Consistent use of `copyWith` on all state classes
- Generation counters prevent stale async result application
- `ref.onDispose` used correctly in `FeedNotifier` and `ThreadMessagesNotifier`
- `bootstrapProvider` elegantly decouples data hydration from auth events
- Riverpod `select` used correctly in `postByIdProvider` and `productByIdProvider`

**Negative patterns:**
- Auth stream subscription not cancelled (§4.2 Issue 1)
- All repositories are global singletons — not injectable, not testable
- Models use manual `fromJson` with hard casts — runtime crash on schema mismatch
- Error strings exposed to users via `e.toString()` — leaks backend details
- Many `debugPrint` statements in production code paths
- `match_controller.dart` has debug emoji `⚠️` in production `debugPrint` calls
- Login screen calls `supabase.auth.resetPasswordForEmail` directly (bypasses repository)

### 16.4 Specific Code Issues

**`ChatRepository.createOrGetThread` — race condition:**
```dart
// Check if exists, then insert — not atomic
final existing = await supabase.from('chat_threads')...maybeSingle();
if (existing != null) return existing['id'];
// Race: another client may insert here
final data = await supabase.from('chat_threads').insert({...}).select('id').single();
```
Fix with a DB-level unique constraint on the unordered pet pair + upsert.

**`FeedRepository.uploadPostMedia` — no content-type detection:**
```dart
// No MIME type specified — defaults to octet-stream
await supabase.storage.from(kBucketPostMedia).upload(path, file);
```
Fix by detecting MIME type from extension (same pattern as `AuthRepository.uploadAvatar`).

**`MatchRepository.fetchDiscoveryPets` — comment vs. implementation mismatch:**
```dart
// Comment: "Fetch pets for discovery (excludes ALL owner's pets + already-requested ones)"
// Implementation: Only excludes by user_id, does NOT exclude already-requested pets
var query = supabase
    .from('pets')
    .select()
    .eq('is_breeding_listed', true)
    .neq('user_id', userId);  // ← only excludes own pets
```
Users can see and like the same pet multiple times (no unique constraint blocks this).

---

## 17. Issues by Severity

### 🔴 Critical (Must fix before any production release)

1. **Duplicate DB triggers create notification spam**
   - `trg_match_accepted_notifications` + `trg_notify_match_accepted` → 4 match notifications per accept (should be 2)
   - `trg_notify_new_message` + `trg_notify_on_new_message` → 2 message notifications per message (should be 1)
   - Fix: Drop duplicate triggers (see §8.2)

2. **Android release lacks `INTERNET` permission**
   - Main `AndroidManifest.xml` has no `<uses-permission android:name="android.permission.INTERNET"/>`
   - Release builds cannot reach Supabase
   - Fix: Add to main manifest

3. **Android release uses debug signing**
   - `build.gradle.kts`: `signingConfig = signingConfigs.getByName("debug")`
   - Play Store rejects debug-signed APKs/AABs
   - Fix: Configure production signing (see §13.1)

4. **Avatar upload goes to wrong bucket**
   - `AuthRepository.uploadAvatar()` uploads to `pet-images` instead of `avatars`
   - Avatars stored incorrectly, correct access policies don't apply
   - Fix: Change to `supabase.storage.from('avatars')`

5. **Checkout accepts client-computed prices**
   - `MarketplaceRepository.placeOrder()` inserts client-provided `price` and `total`
   - Financial integrity risk — price manipulation possible
   - Fix: Server-side Edge Function or RPC (see §5.6)

6. **No automated tests**
   - `flutter test` fails — no test directory
   - Zero regression safety for any code change
   - Fix: Create `test/` with minimum unit + widget tests

7. **iOS missing camera/photo permissions**
   - `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription` absent from `Info.plist`
   - App crashes when `image_picker` requests access on iOS
   - Fix: Add usage descriptions (see §13.2)

### 🟠 High

8. **RLS: Match request sender can accept own request**
   - UPDATE policy includes both sender AND receiver pets
   - Any user can set their own sent request to 'matched'
   - Fix: Restrict UPDATE to receiver only (see §5.4)

9. **Storage: Any user can delete/overwrite others' files**
   - `pet-images` and `post-media` UPDATE/DELETE policies not path-scoped
   - Malicious deletion of other users' pet photos
   - Fix: Path-scope all mutating storage policies (see §5.2)

10. **Hardcoded Supabase credentials in source**
    - `lib/utils/supabase_config.dart` contains URL + anon JWT
    - Rotate key + migrate to `--dart-define` (see §5.1)

11. **Duplicate storage policies on `pet-images`**
    - Two INSERT policies + two UPDATE policies — confusing and wasteful
    - Fix: Drop duplicates (see §7.3)

12. **No deep link configuration for password reset / OAuth**
    - URL schemes missing from Android manifest + iOS plist
    - Password reset flow broken end-to-end
    - Fix: Add URL schemes and Supabase redirect URL (see §4.3)

13. **Auth stream subscription never cancelled**
    - `AuthNotifier._init()` leaks subscriptions on rebuild
    - Fix: Store and cancel subscription in `onDispose` (see §4.2)

14. **`match_requests`: no unique constraint on sender+receiver pair**
    - Multiple like requests to the same pet allowed
    - Fix: `CREATE UNIQUE INDEX` on (sender_pet_id, receiver_pet_id)

### 🟡 Medium

15. Android applicationId is `com.example.pet_dating_app`
16. iOS display name is "Pet Dating App"
17. No post-login redirect to original deep link destination
18. Login screen bypasses `AuthRepository` for password reset call
19. `ChatRepository.fetchThreads()` has N+1 query per thread
20. Feed lacks pagination — hardcoded `.limit(50)`
21. Cart is not persisted — lost on app restart
22. Error strings expose raw Supabase/exception details to users
23. `share_plus` major version gap (10.x vs 13.x latest)
24. `notifications` INSERT policy should be removed (DB triggers handle all inserts)
25. Multiple permissive SELECT policies on `pet_listings` and `products`
26. `FeedRepository.uploadPostMedia()` lacks content-type detection
27. Brand inconsistency: PetSphere vs "The Nurtured Atelier" vs "The Nurtured Nest"
28. Discovery does not filter out already-requested pets

### 🟢 Low / Informational

29. No push notification support
30. No localization (`flutter gen-l10n`)
31. No accessibility tests
32. No dark mode toggle in UI settings
33. Unused remote tables: `pet_listings`, `matches` (from Flutter perspective)
34. `order_items` table unused — checkout writes JSONB instead
35. `pubspec.yaml` SDK lower bound too low (`>=3.0.0` vs actual `>=3.11.0`)
36. `share_plus` should be upgraded to v13 (breaking changes, plan migration)
37. Custom `GestureDetector` login button lacks semantic button role
38. Bottom nav `InkResponse` tabs lack semantic labels
39. `handle_new_user` function status unclear (no trigger found in information_schema)
40. All unused indexes flagged by advisor (keep until real traffic proves otherwise)
41. `share_plus` v10 crashes on iOS 26 — **upgrade to v13 is now time-critical, not optional**
42. `ChatThreadModel.updatedAt` silently falls back to `DateTime.now()` due to missing field in `fetchThreads()` select
43. `home_screen.dart` has hardcoded `https://petsphere.app/post/...` share URL — domain may not be live
44. `web/manifest.json` background color `#0175C2` (Flutter default blue) does not match app terracotta theme
45. All RLS `auth.uid()` calls should be wrapped in `(SELECT auth.uid())` for per-query caching (performance)

---

## 18. Implementation Plan

### Phase 0: Emergency Fixes (This Week)

These are blockers for any testing or staging deployment.

- [ ] **Add INTERNET permission** to `android/app/src/main/AndroidManifest.xml`
- [ ] **Fix avatar upload bucket** — change `kBucketPetImages` to `'avatars'` in `AuthRepository.uploadAvatar()`
- [ ] **Drop duplicate triggers** — remove `on_match_request_accepted`, `trg_match_accepted_notifications`, `trg_notify_on_new_message`
- [ ] **Fix match request RLS** — restrict UPDATE to receiver only
- [ ] **Add iOS camera/photo permissions** to `Info.plist`
- [ ] **Create `test/` directory** with one smoke widget test so `flutter test` passes

- [ ] **Fix `ChatRepository.fetchThreads()` select** — add `updated_at` to the select string so `ChatThreadModel.updatedAt` maps correctly

### Phase 1: Security & Production Readiness (Week 1–2)

- [ ] **Move Supabase config to `--dart-define`** — rotate the committed anon key
- [ ] **Fix Android release signing** — generate upload keystore, configure `key.properties`
- [ ] **Fix storage policies** — path-scope UPDATE/DELETE for `pet-images` and `post-media`, remove duplicates, remove broad listing
- [ ] **Remove `notifications` client INSERT policy**
- [ ] **Add deep link URL scheme** — Android manifest + iOS plist + Supabase dashboard redirect URL
- [ ] **Add PKCE auth flow** to Supabase initialization
- [ ] **Move password reset** into `AuthRepository.resetPassword()` method; listen for `passwordRecovery` event
- [ ] **Enable leaked password protection** in Supabase Dashboard → Auth → Password
- [ ] **Fix brand identity** — set `applicationId`, `android:label`, `CFBundleDisplayName`, `pubspec.yaml name`, login screen brand

### Phase 2: Data Integrity & Authorization (Week 2–3)

- [ ] **Server-side checkout** — create `create_order` Edge Function or RPC that reads server-side prices
- [ ] **Unique constraint on match_requests** — `CREATE UNIQUE INDEX ON match_requests(sender_pet_id, receiver_pet_id)`
- [ ] **Fix unique constraint on chat_threads** — `CREATE UNIQUE INDEX ON chat_threads(LEAST(pet_id_1, pet_id_2), GREATEST(pet_id_1, pet_id_2))`
- [ ] **Fix discovery exclusion** — exclude already-requested pets from discovery query
- [ ] **Consolidate duplicate SELECT policies** on `pet_listings` and `products`
- [ ] **Supabase migrations baseline** — `supabase db pull --local --yes` then commit to `supabase/migrations/`
- [ ] **Document or remove unused tables** — decide on `pet_listings`, `matches`, `order_items` roadmap

### Phase 3: Testing Infrastructure (Week 3–4)

- [ ] **Unit tests for AuthNotifier** — login, logout, session check, error states
- [ ] **Unit tests for CartController** — add, remove, update quantity, place order
- [ ] **Unit tests for MatchController** — send, accept, decline, search filter
- [ ] **Widget tests for login form** — validation, error display, submit
- [ ] **Widget tests for empty/loading/error states** — feed, marketplace, discovery
- [ ] **Add CI workflow** — `flutter analyze` + `flutter test` on every PR
- [ ] **Add `mocktail`** to dev dependencies for repository mocking

### Phase 4: Feature Completion (Month 2)

- [ ] **Fix auth stream subscription leak** in `AuthNotifier._init()`
- [ ] **Add `AuthRepository.resetPassword()`** + listen for password recovery event
- [ ] **Post-login redirect** — preserve intended destination in go_router redirect
- [ ] **Implement or remove** Google/Apple Sign-In buttons
- [ ] **Implement or remove** chat attachment button
- [ ] **Add onboarding flow** after registration — create first pet wizard
- [ ] **Implement pet deletion UI**
- [ ] **Fix N+1 query** in `ChatRepository.fetchThreads()` with lateral join
- [ ] **Add pagination** to feed (`fetchPosts(cursor, limit)` with `FlatList`/`Sliver`)
- [ ] **Cart persistence** — use `shared_preferences` or Supabase
- [ ] **User-safe error messages** — replace `e.toString()` with typed failure classes

- [ ] **Upgrade `share_plus` to v13** (iOS 26 crash) — update constraint, migrate all `Share.share()` calls to `SharePlus.instance.share(ShareParams(...))`, add `sharePositionOrigin` for iPad, verify AGP ≥8.12.1 and Kotlin 2.2.0

### Phase 5: Quality and Scalability (Month 3+)

- [ ] Add accessibility semantics to bottom nav, login button, pet images
- [ ] Add push notifications (FCM + `flutter_local_notifications`)
- [ ] Add localization (`flutter gen-l10n`)
- [ ] Migrate repositories to injectable interfaces for testability
- [ ] Consider `freezed` + `json_serializable` for type-safe models
- [ ] Consider `riverpod_generator` for code generation
- [ ] Add `cached_network_image` universally (replace all raw `NetworkImage`)
- [ ] Evaluate `share_plus` upgrade from v10 → v13
- [ ] Add structured logging with release-mode redaction
- [ ] Evaluate feature-first folder restructuring

---

## 19. Research Notes — Latest Best Practices

### 19.1 Flutter 3.41 / Dart 3.11 (February 2026)

- **Breaking:** `IconData` is now `final` — no subclassing
- **Breaking:** `findChildIndexCallback` → `findItemIndexCallback`
- **Breaking:** `containsSemantics` → `isSemantics`
- **Web:** Importing `dart:js_util` or `package:js` is a compilation error when targeting WASM; use `dart:js_interop`
- **iOS:** `UIScene` lifecycle is now default for Flutter apps; plugin authors need updates
- **Tools:** `dart pub cache gc` to clean unused packages
- **AI:** Dart/Flutter MCP Server `read_package_uris` for better AI context

Run `dart fix --apply` after upgrading to auto-migrate deprecated APIs.

### 19.1a share_plus v13 Migration (iOS 26 — Critical)

`share_plus` v10–v11 crash on iOS 26 because the underlying `UIActivityViewController` presentation API was deprecated and removed. The migration is:

```dart
// Before (v10 — crashes on iOS 26)
Share.share('Check out this pet!', subject: 'PetSphere');
Share.shareFiles(['/path/to/image.jpg']);

// After (v13 — required)
await SharePlus.instance.share(
  ShareParams(
    text: 'Check out this pet!',
    subject: 'PetSphere',
    sharePositionOrigin: buttonRect, // required on iPad or crash
  ),
);
await SharePlus.instance.share(
  ShareParams(files: [XFile('/path/to/image.jpg')]),
);
```

Build requirements for v13: AGP ≥ 8.12.1, Kotlin ≥ 2.2.0, iOS 12+.

### 19.2 Riverpod 3.0 (October 2025)

Key changes relevant to this project:

- **`Ref` unified** — `AsyncNotifierRef` etc. are now just `Ref`; no type parameters
- **Testing:** Use `ProviderContainer.test()` — auto-disposes after test:
  ```dart
  test('auth state test', () {
    final container = ProviderContainer.test(overrides: [...]);
    // container auto-disposed after test
  });
  ```
- **`ProviderException`:** Provider failures now rethrow as `ProviderException`; check `e.exception` property
- **Automatic retry:** Providers retry on failure by default. Disable globally:
  ```dart
  ProviderScope(
    child: MyApp(),
    // or disable per-provider: retry: null
  )
  ```
- **Equality:** Providers use `==` instead of `identical` for filtering updates; override `updateShouldNotify` if needed
- **Legacy:** `StateProvider` and `StateNotifierProvider` are now legacy — prefer `NotifierProvider`/`AsyncNotifierProvider`
- **`ref.mounted`:** Guard async operations with `if (!ref.mounted) return;`

The project uses `NotifierProvider` correctly for all controllers. Migrating to Riverpod code generation (`riverpod_generator`) is optional but reduces boilerplate.

### 19.3 go_router 17.x

- The project is on 17.1.0; 17.2.2 is available (minor update, safe to apply)
- **Destination preservation pattern:**
  ```dart
  redirect: (context, state) {
    if (status == AuthStatus.unauthenticated) {
      final from = state.matchedLocation;
      return '/login?from=${Uri.encodeComponent(from)}';
    }
    if (status == AuthStatus.authenticated) {
      final from = state.uri.queryParameters['from'];
      if (from != null) return from;
      return isGoingToAuth ? '/home' : null;
    }
    return null;
  }
  ```

### 19.4 supabase_flutter 2.12.x

- The project is on 2.12.2; 2.12.4 has bug fixes (safe to apply)
- **PKCE flow** is recommended for mobile apps (prevents auth code interception):
  ```dart
  authOptions: FlutterAuthClientOptions(authFlowType: AuthFlowType.pkce)
  ```
- **Deep linking** requires URL scheme in Android/iOS config AND Supabase Dashboard redirect URLs
- **Password recovery:** Listen for `AuthChangeEvent.passwordRecovery` in `onAuthStateChange`
- **Storage upsert** still requires INSERT + SELECT + UPDATE policies (confirmed)

### 19.5 Android Release Checklist (2026)

Per Flutter official docs and Play Store requirements:
- `compileSdk = 35`, `targetSdk = 35`
- Generate upload keystore; store `key.properties` outside version control
- Build AAB (not APK): `flutter build appbundle --release`
- Enable R8/ProGuard: add `minifyEnabled = true` to release buildType
- Add obfuscation: `flutter build appbundle --release --obfuscate --split-debug-info=build/symbols`
- INTERNET permission in **main** manifest (not just debug/profile)
- Unique `applicationId` (not `com.example.*`)

### 19.5a go_router 17.x — Breaking API Removal

`GoRouter.location` was removed in go_router 17.x. The project should audit for any usage:
```dart
// Removed — compile error in 17.x
router.location

// Replacement
GoRouterState.of(context).uri.toString()
```

### 19.6 Supabase RLS Best Practices (2026)

- **Wrap `auth.uid()` in `(SELECT auth.uid())`** for all policies — caches the value once per query instead of re-evaluating per row; significant performance improvement on large tables
- **Never use `user_metadata` for authorization** — it is user-editable. Use `app_metadata` or dedicated tables
- **Storage upsert needs INSERT + SELECT + UPDATE** policies
- **Path-scope storage policies** using `storage.foldername(name)` function
- **Avoid multiple permissive policies** for same role+action — consolidate for performance
- **Enable leaked password protection** — checks HaveIBeenPwned.org
- **Keep JWT expiry short** for sensitive operations; validate `session_id` against `auth.sessions` if needed

### 19.7 Flutter Testing Best Practices (2026)

```
test/
├── unit/
│   ├── controllers/
│   │   ├── auth_controller_test.dart
│   │   ├── cart_controller_test.dart
│   │   └── match_controller_test.dart
│   └── models/
│       └── pet_model_test.dart
├── widget/
│   ├── login_screen_test.dart
│   ├── feed_screen_test.dart
│   └── cart_screen_test.dart
└── integration/
    └── auth_flow_test.dart
```

For Riverpod providers, use `ProviderContainer.test()` with repository overrides:
```dart
test('login succeeds', () async {
  final mockAuthRepo = MockAuthRepository();
  when(() => mockAuthRepo.signIn(any(), any()))
    .thenAnswer((_) async => fakeUser);

  final container = ProviderContainer.test(
    overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepo)],
  );
  
  await container.read(authProvider.notifier).login('test@test.com', 'pass');
  expect(container.read(authProvider).status, AuthStatus.authenticated);
});
```
This requires repositories to be injectable (via providers) rather than global singletons.

---

## Appendix A: File Inventory

**Dart files:** 61 (lib/)  
**SQL files:** 4 (supabase/)  
**CI/CD workflows:** 1 (.github/workflows/)  
**Platform configs:** AndroidManifest.xml, build.gradle.kts, Info.plist

**Complete dart file list:**
```
lib/controllers/    auth_controller.dart, bootstrap_controller.dart, 
                    cart_controller.dart, chat_controller.dart,
                    feed_controller.dart, follow_controller.dart,
                    marketplace_controller.dart, match_controller.dart,
                    notification_controller.dart, pet_controller.dart

lib/repositories/   auth_repository.dart, chat_repository.dart,
                    feed_repository.dart, follow_repository.dart,
                    marketplace_repository.dart, match_repository.dart,
                    notification_repository.dart, pet_repository.dart

lib/models/         cart_item_model.dart, chat_thread_model.dart,
                    match_request_model.dart, message_model.dart,
                    notification_model.dart, order_model.dart,
                    pet_model.dart, post_model.dart, product_model.dart,
                    user_model.dart

lib/views/          add_pet_screen.dart, cart_screen.dart,
                    chat_screen.dart, create_post_screen.dart,
                    discovery_screen.dart, home_screen.dart,
                    liked_pets_screen.dart, login_screen.dart,
                    main_layout.dart, marketplace_screen.dart,
                    match_pet_profile_screen.dart,
                    messages_list_screen.dart, notifications_screen.dart,
                    order_history_screen.dart, pet_profile_screen.dart,
                    post_detail_screen.dart, product_detail_screen.dart,
                    registration_screen.dart, settings_screen.dart,
                    splash_screen.dart
                    components/: cart_item_tile.dart, chat_thread_tile.dart,
                    match_pet_card.dart, message_bubble.dart, pet_avatar.dart,
                    post_card.dart, product_card.dart

lib/theme/          app_theme.dart
lib/utils/          image_upload_helper.dart, pet_navigation.dart,
                    routes.dart, supabase_config.dart
lib/                main.dart
```

---

## Appendix B: Remote Supabase Functions

```sql
-- handle_match_accepted
-- When status = 'matched': inserts into matches (ON CONFLICT DO NOTHING)
-- + inserts into chat_threads (if not exists)
-- → IDEMPOTENT ✅ but called TWICE due to duplicate triggers

-- notify_on_match_accepted  
-- Inserts 2 notifications: one for sender, one for receiver
-- → NOT IDEMPOTENT ❌ called TWICE → 4 notifications created

-- notify_on_new_message
-- Inserts 1 notification for the recipient
-- → NOT IDEMPOTENT ❌ called TWICE → 2 notifications created

-- notify_on_order_status_change
-- Inserts 1 notification for the order owner
-- → Correct ✅

-- handle_new_user
-- Creates profiles row on auth user creation
-- → Correct ✅ (trigger on auth.users not shown in public schema)

-- set_updated_at
-- Sets updated_at = now()
-- → Correct ✅
```

---

*Audit complete. All findings are based on direct inspection of source code, live Supabase MCP queries, and research against official documentation dated April 2026.*
