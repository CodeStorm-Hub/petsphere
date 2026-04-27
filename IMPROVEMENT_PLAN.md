# PetSphere — Comprehensive Improvement Plan

**Generated:** 2026-04-27  
**Based on:** Full codebase review, COMPREHENSIVE_AUDIT.md, TECH_RESEARCH_2025_2026.md, docs/cursor-flutter-priority-tasks.md, stitch UX redesign specs, and online research (pet super-app trends, Flutter 2026 best practices)  
**Scope:** All existing features, UI/UX overhaul, DB schema, architecture, and new feature roadmap  
**Status:** Pre-implementation (save before coding)

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Current State — What Exists](#2-current-state--what-exists)
3. [Identified Issues by Severity](#3-identified-issues-by-severity)
4. [UI/UX Improvement Plan](#4-uiux-improvement-plan)
5. [Feature & Functionality Improvement Plan](#5-feature--functionality-improvement-plan)
6. [Database Schema Improvements](#6-database-schema-improvements)
7. [Architecture Improvements](#7-architecture-improvements)
8. [Security & Production Hardening](#8-security--production-hardening)
9. [New Feature Roadmap (2026 Pet Super-App)](#9-new-feature-roadmap-2026-pet-super-app)
10. [Phased Implementation Plan](#10-phased-implementation-plan)
11. [Research Sources](#11-research-sources)

---

## 1. Executive Summary

PetSphere is a **Flutter + Supabase social-commerce app** for pet owners with a premium dark "Amber Whisker / Nurtured Atelier" aesthetic. It combines a social feed, pet profiles, pet discovery/matching (breeding), in-app chat, health tracking, and a marketplace.

The app is architecturally coherent and passes `flutter analyze` cleanly, but has **8 critical blockers** preventing any production release, **numerous UX gaps** vs. 2026 pet super-app expectations, and **zero test coverage**.

This plan covers:
- **Fix all critical/high issues** before any launch
- **Polish every existing feature** to production quality
- **Redesign the full UI** to match the Stitch "Amber Whisker" premium dark spec consistently
- **Add new high-value features** based on 2026 pet tech research (AI health, vet triage, stories, memorials)
- **Lay the architecture foundation** for long-term scale

---

## 2. Current State — What Exists

### 2.1 App Identity
- **Package:** `pet_dating_app` (should be `petsphere`)
- **Bundle ID:** `com.example.pet_dating_app` (should be `com.petsphere.app`)
- **Brand name split:** "PetSphere", "The Nurtured Atelier", "The Nurtured Nest", "Atelier" — needs unification
- **Theme:** Premium dark (`#0F0E0C` background, `#D4845A` terracotta primary, `#4A7C59` sage secondary, Playfair Display + DM Sans typography) — well-designed but not consistently applied

### 2.2 Existing Screens
| Screen | File | Status |
|--------|------|--------|
| Splash | `splash_screen.dart` | ✅ |
| Login | `login_screen.dart` | ⚠️ GestureDetector button, brand mismatch |
| Registration | `registration_screen.dart` | ⚠️ No email confirmation handling |
| Home Feed | `home_screen.dart` | ⚠️ No pagination, "Atelier" brand in AppBar |
| Post Detail | `post_detail_screen.dart` | ⚠️ No edit functionality |
| Create Post | `create_post_screen.dart` | ✅ |
| Create Story | `create_story_screen.dart` | ✅ |
| Story Viewer | `story_viewer_screen.dart` | ✅ |
| Discovery | `discovery_screen.dart` | ⚠️ Client-side search only, no already-sent filter |
| Match Pet Profile | `match_pet_profile_screen.dart` | ✅ |
| Liked Pets | `liked_pets_screen.dart` | ✅ |
| Chat (thread) | `chat_screen.dart` | ⚠️ Attachment button is placeholder |
| Messages List | `messages_list_screen.dart` | ⚠️ N+1 query per thread |
| Notifications | `notifications_screen.dart` | ⚠️ Duplicate notifications from DB triggers |
| Marketplace | `marketplace_screen.dart` | ✅ |
| Product Detail | `product_detail_screen.dart` | ✅ |
| Cart | `cart_screen.dart` | ⚠️ In-memory only, client-price manipulation |
| Order History | `order_history_screen.dart` | ✅ |
| Pet Profile | `pet_profile_screen.dart` | ⚠️ No pet deletion UI |
| Add Pet | `add_pet_screen.dart` | ✅ |
| Health Tab | `health_tab.dart` | ✅ Good implementation |
| Pet Care | `pet_care_screen.dart` | ✅ |
| Settings | `settings_screen.dart` | ⚠️ Several placeholder actions |
| Main Layout | `main_layout.dart` | ⚠️ No semantic labels, tab index not URL-reflected |

### 2.3 Database Tables (Live Supabase)
| Table | Notes |
|-------|-------|
| `profiles` | User profiles |
| `pets` | Multi-pet per user, breeding listing |
| `posts` | Feed posts with media |
| `post_likes` | Pet-authored likes |
| `comments` | Pet-authored comments |
| `match_requests` | Sender/receiver pets, status |
| `chat_threads` | Two pet participants |
| `messages` | Thread messages |
| `products` | Marketplace products |
| `orders` | JSONB items, client total |
| `order_items` | **Unused by Flutter** |
| `matches` | Accepted matches — **unused by Flutter UI** |
| `pet_listings` | Rich listing table — **unused by Flutter** |
| `notifications` | In-app notifications |

### 2.4 Tech Stack
- Flutter 3.41.6 / Dart 3.11.4
- Riverpod 3.x (NotifierProvider/AsyncNotifierProvider pattern)
- go_router 17.1.0
- Supabase (Auth, Postgres, Storage, Realtime)
- Google Fonts (Playfair Display + DM Sans)

---

## 3. Identified Issues by Severity

### 🔴 CRITICAL — Must fix before any release

| # | Issue | Location | Fix |
|---|-------|----------|-----|
| C1 | Duplicate DB triggers → 4x match notifications, 2x message notifications | Supabase remote | Drop `on_match_request_accepted`, `trg_match_accepted_notifications`, `trg_notify_on_new_message` |
| C2 | Android release builds missing `INTERNET` permission | `android/app/src/main/AndroidManifest.xml` | Add `<uses-permission android:name="android.permission.INTERNET"/>` |
| C3 | Android release signed with debug key → Play Store rejection | `android/app/build.gradle.kts` | Configure production signing with `key.properties` |
| C4 | Avatar upload goes to wrong bucket (`pet-images` instead of `avatars`) | `AuthRepository.uploadAvatar()` | Change `kBucketPetImages` → `'avatars'` |
| C5 | Checkout accepts client-computed prices → price manipulation | `MarketplaceRepository.placeOrder()` | Create `create_order` Edge Function or RPC; only accept `[{product_id, quantity}]` |
| C6 | No test suite — `flutter test` fails | Project root | Create `test/` with smoke tests |
| C7 | iOS missing camera/photo permission strings | `ios/Runner/Info.plist` | Add `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription` |
| C8 | `ChatThreadModel.updatedAt` silently uses `DateTime.now()` (field not selected) | `ChatRepository.fetchThreads()` | Add `updated_at` to select string |

### 🟠 HIGH — Fix before public beta

| # | Issue | Fix |
|---|-------|-----|
| H1 | RLS: Match request sender can accept own request | Restrict UPDATE policy to receiver pet only |
| H2 | Storage: any user can delete/overwrite others' files | Path-scope `pet-images` and `post-media` UPDATE/DELETE policies |
| H3 | Hardcoded Supabase credentials in source | Move to `--dart-define-from-file`; rotate key |
| H4 | Auth stream subscription never cancelled in `AuthNotifier._init()` | Store + cancel `StreamSubscription` in `onDispose` |
| H5 | No deep link configuration for password reset / OAuth | Add URL scheme to Android manifest + iOS plist; add Supabase Dashboard redirect URL |
| H6 | `match_requests`: no unique constraint on (sender_pet_id, receiver_pet_id) | `CREATE UNIQUE INDEX` on pair |
| H7 | Duplicate storage policies on `pet-images` (2 INSERT + 2 UPDATE policies) | Drop duplicates; consolidate |
| H8 | Login screen calls `supabase.auth.resetPasswordForEmail` directly, bypassing repository | Move to `AuthRepository.resetPassword()`, route through `AuthNotifier` |

### 🟡 MEDIUM — Fix in sprint 1–2

| # | Issue |
|---|-------|
| M1 | App identity not set: package name `pet_dating_app`, bundle `com.example.*`, iOS display "Pet Dating App" |
| M2 | Brand name inconsistency across screens ("PetSphere" vs "Atelier" vs "The Nurtured Atelier") |
| M3 | N+1 query in `ChatRepository.fetchThreads()` — one extra query per thread |
| M4 | Feed hardcoded `.limit(50)` — no pagination |
| M5 | Cart in-memory only — lost on app restart |
| M6 | Error strings expose raw Supabase exception details to users |
| M7 | `share_plus` v10 crashes on iOS 26 — needs upgrade to v13 |
| M8 | Discovery does not filter already-requested pets |
| M9 | Post-login redirect lost — deep link destination dropped after auth |
| M10 | `notifications` client INSERT policy should be removed (only DB triggers should insert) |
| M11 | `FeedRepository.uploadPostMedia()` lacks content-type/MIME detection |
| M12 | Google/Apple Sign-In buttons exist but show "coming soon" SnackBar |

### 🟢 LOW — Polish & scale

| # | Issue |
|---|-------|
| L1 | No push notifications |
| L2 | No localization |
| L3 | Accessibility gaps: bottom nav labels missing, login button not a semantic button |
| L4 | Dark mode toggle in settings — forced dark only, no system toggle UI |
| L5 | `pet_listings`, `matches`, `order_items` tables unused by Flutter |
| L6 | `handle_new_user` trigger status unclear |
| L7 | No onboarding wizard after registration |
| L8 | No pet deletion UI |
| L9 | Chat attachment button is visible but unimplemented |
| L10 | Share URL hardcoded to `petsphere.app` domain (may not be live) |
| L11 | `web/manifest.json` uses Flutter default blue, not terracotta brand color |
| L12 | All RLS `auth.uid()` calls should be `(SELECT auth.uid())` for query-level caching |

---

## 4. UI/UX Improvement Plan

### 4.1 Design System Audit

The "Amber Whisker / Nurtured Atelier" dark theme in `AppTheme` is well-structured but inconsistently applied across screens. Full audit and corrections:

**Token standardization (enforce everywhere):**
```
Background:       #0F0E0C  (dark charcoal)
Surface:          #1A1814  (elevated card)
Card:             #211F1B  (card background)
Border:           #2E2B26  (subtle borders)
Primary Accent:   #D4845A  (terracotta — CTAs, active states)
Secondary Accent: #4A7C59  (sage green — success, health)
Text Primary:     #F2EDE4  (warm white)
Text Secondary:   #B8B0A4  (muted warm gray)
Error:            #E05B5B  (warm red, not Material default)
Warning:          #E8A44A  (amber)
```

**Typography (enforce everywhere):**
```
Display/Headline:  Playfair Display (serif — premium feel)
Body/UI:           DM Sans (clean, modern sans-serif)
Monospace/data:    DM Mono (for health metrics, prices)
```

**Spacing system:**
- 4pt base grid (4, 8, 12, 16, 20, 24, 32, 48, 64)
- Screen horizontal padding: 20px
- Card inner padding: 16px
- Section gap: 24px

**Border radius:**
```
Small (chips, badges): 8px
Medium (cards, inputs): 16-20px
Large (bottom sheets): 32px
Full (pills, avatars): 999px
```

### 4.2 Screen-by-Screen UI Improvements

#### Login Screen (`login_screen.dart`)
**Current issues:**
- `GestureDetector`-wrapped `Container` for sign-in button (not a semantic button)
- Brand text "The Nurtured Atelier" (wrong brand)
- Google/Apple buttons show dead SnackBar

**Improvements:**
- Replace gradient `Container` button with `FilledButton.styleFrom()` with gradient via `ShaderMask`
- Show "PetSphere" logo/wordmark (SVG asset)
- Google/Apple Sign-In: either implement fully or visually mark as "coming soon" with a badge, not a dead button
- Add subtle parallax background with ambient pet paw or leaf motifs (Lottie animation or static)
- Input fields: add animated floating labels
- "Forgot password?" links to a properly working reset flow

#### Registration Screen (`registration_screen.dart`)
**Improvements:**
- Add email confirmation UX (show "check your email" screen post-signup if Supabase has verification enabled)
- Add Terms & Privacy inline checkbox with tappable links
- Add profile photo picker step (not just text fields)
- Post-registration → onboarding wizard (add first pet)

#### Home Feed (`home_screen.dart`)
**Current issues:**
- AppBar shows "Atelier" with a hardcoded `Color(0xFF99472C)` icon (not using theme tokens)
- Story row present but UI integration could be stronger
- No infinite scroll

**Improvements:**
- Unify AppBar brand to "PetSphere" with proper logo mark
- Use `AppTheme.primaryAccent` token (no hardcoded hex in views)
- Implement cursor-based infinite scroll with `riverpod_infinite_scroll_pagination` package
- Story row: full-width horizontal scroll with circular avatar + gradient ring for unread stories
- Post cards: add share sheet via `share_plus` v13
- Pull-to-refresh with branded animation (Lottie paw print)
- Empty state: illustrated "No posts yet — follow some pets!" with CTA

#### Post Card Component (`components/post_card.dart`)
**Improvements:**
- Double-tap to like with heart burst animation (Riverpod optimistic update already exists — add animation layer)
- Add swipe-left for quick actions (save, share, report)
- Like count with animated counter
- Comment count with tap-to-expand inline preview (first 2 comments)
- "More" menu: Edit (own post), Report/Block (others)

#### Post Detail Screen (`post_detail_screen.dart`)
**Current issues:** No post editing

**Improvements:**
- Add edit mode for caption (own posts)
- Full comment thread with nested replies (1 level)
- Comment character limit (500 chars) with live counter
- Report comment functionality
- Keyboard-aware bottom sheet for comment input

#### Discovery Screen (`discovery_screen.dart`)
**Current issues:** Client-side search, doesn't exclude already-requested pets

**Improvements:**
- Move search/filter to server-side Supabase query
- Add `NOT IN (already-requested pet IDs)` to discovery query
- Card swipe gestures: swipe-right to like (send match request), swipe-left to pass
- Filter drawer: animal type, breed, age range, size, gender
- "Liked Pets" tab integrated into Discovery as a sub-tab
- Map view: optional location-based discovery (with opt-in geolocation)
- Distance filter (km/miles) when location enabled

#### Chat Screen (`chat_screen.dart`)
**Current issues:** Attachment button is a placeholder

**Improvements:**
- Implement image attachment: `image_picker` → upload to `post-media` bucket → send URL as message
- Add typing indicator (Supabase Realtime presence channel)
- Swipe-to-reply gesture on messages
- Message reactions (emoji) — quick 6-emoji picker
- Read receipts (delivered/read timestamps) — DB columns exist (`is_read`)
- Group chat threads by date (Today, Yesterday, earlier)

#### Messages List Screen (`messages_list_screen.dart`)
**Improvements:**
- Fix N+1 query → single lateral join SQL query via Supabase RPC
- Add unread count badge per thread (from DB `unread_count`)
- Search threads by pet name
- Swipe-to-delete/archive thread

#### Health Tab (`health_tab.dart`)
**Current state:** Well-implemented with medications, appointments, vaccinations, parasites, dental, allergies, symptoms.

**Improvements:**
- **Health Score card** at top: visual gauge (0–100) computed from: no overdue vaccines + no active symptoms + recent vet visit + current medications
- **Weight trend chart** (line chart using `fl_chart` or `syncfusion_flutter_charts`)
- **Appointment reminders** with local notification push (via `flutter_local_notifications`)
- **Medication reminder** push notifications with snooze
- **Export health report** as PDF (`printing` package)
- **Vet consultation CTA**: "Chat with a Vet" button → in-app triage form or external telehealth link
- **AI symptom checker** integration (LLM-powered triage, Claude API or GPT-4 via Edge Function)

#### Pet Profile Screen (`pet_profile_screen.dart`)
**Improvements:**
- Add **delete pet** functionality with confirmation dialog and cascade warning
- Pet gallery (multiple images, horizontal scroll)
- **Breeding listing toggle** with availability calendar
- **Health summary badge** (last vet visit date, vaccination status)
- **Match CTA**: "Send Match Request" / "Already matched — Message" based on relationship state

#### Marketplace Screen (`marketplace_screen.dart`)
**Improvements:**
- **Cursor-based pagination** for product list
- **Featured banner** carousel at top
- **Categories horizontal scroll** with icon chips
- **Product search** (server-side with Postgres full-text search)
- **Wishlist/save** product to profile
- **Price range filter** slider

#### Cart Screen (`cart_screen.dart`)
**Current issues:** In-memory, client-computed totals

**Improvements:**
- Persist cart to `shared_preferences` (survives app restart)
- Server-side price validation via `create_order` Supabase RPC
- Promo code input field
- Estimated delivery date display
- **Checkout flow**: Address entry → Order summary → Payment (Stripe integration)

#### Settings Screen (`settings_screen.dart`)
**Improvements:**
- Theme toggle: Dark / Light / System
- Push notification preferences (matches, messages, health reminders, orders)
- Privacy settings (profile visibility, discovery visibility)
- Account deletion flow (Supabase `deleteUser()`)
- Linked social accounts (Google, Apple once implemented)
- Export personal data (GDPR)

#### Main Layout Navigation (`main_layout.dart`)
**Current issues:** No semantic labels, tab not reflected in URL

**Improvements:**
- Add `Semantics(label: 'Home Feed')` to each nav item
- Replace current `IndexedStack` with `NavigationBar` (Material 3) — preserves scroll position per tab
- Reflect active tab index in URL query param or path for deep linking
- Bottom nav badges: unread message count, notification count
- Add haptic feedback on tab change (`HapticFeedback.selectionClick()`)

### 4.3 New Screens to Add

| Screen | Priority | Description |
|--------|----------|-------------|
| Onboarding wizard | High | Post-registration 3-step: profile photo, add first pet, set discovery prefs |
| Password reset | High | Deep-link handler for Supabase password recovery |
| AI Symptom Checker | Medium | Form-based triage → Edge Function → LLM response |
| Vet Consultation | Medium | Book video call or chat with vet via third-party API |
| Pet Memorial | Low | "Rainbow Bridge" section — memorial page for deceased pets |
| Vendor Dashboard | Low | Product management for sellers |
| Global Search | Medium | Search posts, pets, products in one screen |
| User/Pet Report | High | Report/block flow with moderation queue |

### 4.4 Micro-Interaction & Animation Plan

| Element | Animation | Library |
|---------|-----------|---------|
| Post like button | Heart burst particle | Custom `AnimationController` |
| Pull-to-refresh | Paw print loader | Lottie animation |
| Notification badge | Pulse/scale | `AnimatedContainer` |
| Tab change | Slide + fade | `AnimatedSwitcher` |
| Match accepted | Confetti burst | `confetti` package |
| Health score gauge | Sweep arc | Custom `CustomPainter` |
| Story ring | Gradient conic progress | `CustomPainter` |
| App launch | Logo scale-in | Hero + `FadeTransition` |

### 4.5 Accessibility Improvements

- **Touch targets:** All interactive elements minimum 48×48 logical pixels
- **Semantic labels:** All `IconButton`, `GestureDetector`, `InkWell` with non-obvious icons must have `tooltip` or `Semantics(label:)`
- **Login button:** Replace with proper `FilledButton` (semantic button role)
- **Bottom nav:** Add `Semantics(label:)` to each tab
- **Images:** All `CachedNetworkImage` / pet avatars with descriptive `semanticLabel`
- **Color contrast:** All text/background combinations verified WCAG AA (4.5:1 ratio)
- **Text scaling:** Test at 200% font scale — no overflow, no fixed-height containers clipping text
- **Keyboard navigation** (web/desktop): ensure tab order is logical

---

## 5. Feature & Functionality Improvement Plan

### 5.1 Social Feed

| Improvement | Detail | Priority |
|-------------|--------|----------|
| Infinite scroll pagination | `riverpod_infinite_scroll_pagination` + cursor-based Supabase query | High |
| Post editing | Edit caption for own posts | Medium |
| Comment character limit | 500 chars max, enforced client + DB CHECK | Medium |
| Nested comment replies | 1 level of nesting | Low |
| Post saving/bookmarking | Save posts to private collection | Medium |
| Content reporting | Report post / comment | High |
| Media type validation | MIME type check on upload, not just extension | Medium |
| Content-type on upload | Set `contentType` in `uploadPostMedia()` | High (bug fix) |

### 5.2 Pet Management

| Improvement | Detail | Priority |
|-------------|--------|----------|
| Delete pet UI | Confirmation dialog + cascade warning | High |
| Pet gallery | Multi-image upload and display | Medium |
| Pet deletion cascade | DB: deleting pet should cascade to posts, match requests, etc. | High |
| Pet age validation | DB `CHECK (age >= 0 AND age <= 50)` | Medium |
| Breeding availability | Calendar date picker for available breeding windows | Low |

### 5.3 Discovery & Matching

| Improvement | Detail | Priority |
|-------------|--------|----------|
| Server-side search | Move search/filter to Supabase query (`.ilike()`, `.eq()`) | High |
| Exclude already-requested | Add `NOT IN` subquery for sent requests | High |
| Unique match constraint | DB: unique index on (sender_pet_id, receiver_pet_id) | Critical |
| Swipe gesture | Swipe card left/right as like/pass | Medium |
| Match accepted → auto-open chat | Navigate to chat thread on match acceptance | High |
| Location-based discovery | Opt-in geolocation filter | Low |
| DB-enforce match for chat | RLS policy: chat thread creation requires a matched pair | High |

### 5.4 Chat

| Improvement | Detail | Priority |
|-------------|--------|----------|
| Image attachments | `image_picker` → Storage upload → message URL | High |
| Fix N+1 query | Lateral join RPC for threads + last message | High |
| Typing indicator | Supabase Realtime presence | Medium |
| Read receipts | Use existing `is_read` field; mark on open | Medium |
| Message reactions | 6 quick emojis | Low |
| Thread unread count | Compute from DB, not local state | Medium |
| Chat with matched pets only | Enforce via RLS (see §6) | High |

### 5.5 Marketplace

| Improvement | Detail | Priority |
|-------------|--------|----------|
| Server-side price validation | `create_order` Edge Function / RPC | Critical |
| Cart persistence | `shared_preferences` serialization | High |
| Stripe payment integration | Supabase Edge Function → Stripe API | Medium |
| Product search | Postgres FTS (`to_tsvector`) | Medium |
| Stock management | `stock_count` column on products; decrement on order | Medium |
| Wishlist | `saved_products` table | Low |
| Shipping address | `shipping_addresses` table + UI | Medium |
| Order status tracking | Real-time order status updates | Low |
| Vendor dashboard | Product CRUD UI for verified vendors | Low |

### 5.6 Health & Care

| Improvement | Detail | Priority |
|-------------|--------|----------|
| Health score computation | Server-side RPC or client calculation, visualized as gauge | High |
| Weight tracking chart | Line chart over time using `fl_chart` | Medium |
| Local push notifications | Medication reminders, appointment alerts | High |
| PDF health report export | `printing` package → share | Medium |
| AI symptom checker | Edge Function calling LLM API | Medium |
| Vet consultation CTA | External telehealth link or in-app booking | Low |

### 5.7 Notifications

| Improvement | Detail | Priority |
|-------------|--------|----------|
| Fix duplicate triggers | Drop 3 duplicate DB triggers | Critical |
| Remove client INSERT policy | Only DB triggers should create notifications | High |
| Push notifications (FCM) | Firebase + `flutter_local_notifications` | Medium |
| Notification preferences | Per-category toggle in settings | Medium |
| Notification grouping | Group by type (matches, messages, orders) in UI | Low |

### 5.8 Authentication

| Improvement | Detail | Priority |
|-------------|--------|----------|
| Fix stream subscription leak | Store + cancel in `onDispose` | High |
| Password reset deep link | Android + iOS URL schemes + Supabase redirect | High |
| PKCE auth flow | `FlutterAuthClientOptions(authFlowType: AuthFlowType.pkce)` | High |
| Email confirmation handling | Show "verify email" screen post-signup | High |
| Post-login redirect | Preserve deep link destination via `?from=` query param | Medium |
| Google Sign-In | Supabase OAuth with Google provider | Medium |
| Apple Sign-In | Supabase OAuth with Apple provider | Medium |
| Account deletion | `supabase.auth.admin.deleteUser()` via Edge Function | Medium |

---

## 6. Database Schema Improvements

### 6.1 Fix Duplicate Triggers (CRITICAL)

```sql
-- Drop duplicate match request triggers
DROP TRIGGER IF EXISTS on_match_request_accepted ON public.match_requests;
DROP TRIGGER IF EXISTS trg_match_accepted_notifications ON public.match_requests;
-- Keep: trg_match_accepted_side_effects, trg_notify_match_accepted

-- Drop duplicate message trigger
DROP TRIGGER IF EXISTS trg_notify_on_new_message ON public.messages;
-- Keep: trg_notify_new_message
```

### 6.2 Fix RLS Policies

```sql
-- Fix match_requests UPDATE: restrict to receiver only
DROP POLICY IF EXISTS "Users can update own match requests" ON public.match_requests;
CREATE POLICY "Only receiver can accept or decline match requests"
ON public.match_requests FOR UPDATE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.pets
    WHERE pets.id = match_requests.receiver_pet_id
    AND pets.user_id = (SELECT auth.uid())
  )
)
WITH CHECK (status IN ('matched', 'rejected'));

-- Remove client INSERT on notifications (DB triggers handle all inserts)
DROP POLICY IF EXISTS "Users can insert notifications" ON public.notifications;

-- Optimize all auth.uid() to (SELECT auth.uid()) for query-level caching
-- Apply to: profiles, pets, posts, orders, notifications, match_requests, chat_threads, messages
```

### 6.3 Fix Storage Policies

```sql
-- Drop overly broad pet-images policies
DROP POLICY IF EXISTS "Authenticated users can update pet images" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can delete pet images" ON storage.objects;
DROP POLICY IF EXISTS "pet-images: allow auth update" ON storage.objects;

-- Replace with user-scoped policies
CREATE POLICY "Users can update own pet images"
ON storage.objects FOR UPDATE TO authenticated
USING (
  bucket_id = 'pet-images'
  AND (storage.foldername(name))[1] = (SELECT auth.uid())::text
)
WITH CHECK (
  bucket_id = 'pet-images'
  AND (storage.foldername(name))[1] = (SELECT auth.uid())::text
);

CREATE POLICY "Users can delete own pet images"
ON storage.objects FOR DELETE TO authenticated
USING (
  bucket_id = 'pet-images'
  AND (storage.foldername(name))[1] = (SELECT auth.uid())::text
);

-- Same for post-media bucket
```

### 6.4 Add Missing Constraints

```sql
-- Prevent duplicate match requests
CREATE UNIQUE INDEX IF NOT EXISTS idx_match_requests_unique_pair
ON public.match_requests(sender_pet_id, receiver_pet_id);

-- Prevent duplicate chat threads (order-independent pair)
CREATE UNIQUE INDEX IF NOT EXISTS idx_chat_threads_unique_pair
ON public.chat_threads(
  LEAST(pet_id_1::text, pet_id_2::text),
  GREATEST(pet_id_1::text, pet_id_2::text)
);

-- Pet age validation
ALTER TABLE public.pets
ADD CONSTRAINT pets_age_non_negative CHECK (age IS NULL OR (age >= 0 AND age <= 100));
```

### 6.5 New Tables to Add

```sql
-- Cart persistence (server-side cart sync)
CREATE TABLE public.cart_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  product_id UUID REFERENCES public.products(id) ON DELETE CASCADE,
  quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (user_id, product_id)
);
ALTER TABLE public.cart_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own cart" ON public.cart_items
USING (user_id = (SELECT auth.uid()))
WITH CHECK (user_id = (SELECT auth.uid()));

-- Saved/wishlisted products
CREATE TABLE public.saved_products (
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  product_id UUID REFERENCES public.products(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id, product_id)
);
ALTER TABLE public.saved_products ENABLE ROW LEVEL SECURITY;

-- Shipping addresses
CREATE TABLE public.shipping_addresses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  label TEXT,
  street TEXT NOT NULL,
  city TEXT NOT NULL,
  country TEXT NOT NULL,
  postal_code TEXT,
  is_default BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE public.shipping_addresses ENABLE ROW LEVEL SECURITY;

-- User reports / content moderation
CREATE TABLE public.reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id UUID REFERENCES public.profiles(id),
  reported_type TEXT NOT NULL CHECK (reported_type IN ('post', 'comment', 'pet', 'user')),
  reported_id UUID NOT NULL,
  reason TEXT NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'dismissed')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;

-- Pet weight tracking (for health chart)
CREATE TABLE public.pet_weight_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pet_id UUID REFERENCES public.pets(id) ON DELETE CASCADE,
  weight_kg NUMERIC(5,2) NOT NULL,
  logged_at TIMESTAMPTZ DEFAULT NOW(),
  notes TEXT
);
ALTER TABLE public.pet_weight_logs ENABLE ROW LEVEL SECURITY;
```

### 6.6 Edge Functions to Create

| Function | Purpose |
|----------|---------|
| `create_order` | Server-side price validation + stock check + order creation |
| `ai_symptom_triage` | Accepts symptom description → LLM triage → structured response |
| `delete_account` | Soft-delete or hard-delete user + cascade cleanup |
| `send_push_notification` | FCM push via Firebase Admin SDK |

### 6.7 Supabase Migrations Baseline

```bash
# Pull live schema as baseline migration
supabase db pull --schema public --local --yes
supabase migration list --local
# Commit resulting supabase/migrations/ files to git
```

---

## 7. Architecture Improvements

### 7.1 App Identity Fix

```yaml
# pubspec.yaml
name: petsphere
description: "PetSphere — The premium social app for pet owners."
environment:
  sdk: ">=3.11.0 <4.0.0"
```

```
android applicationId: com.petsphere.app
iOS CFBundleDisplayName: PetSphere
iOS CFBundleName: petsphere
iOS CFBundleIdentifier: com.petsphere.app
```

### 7.2 Supabase Config — Move to `--dart-define`

```json
// .dart_define.json (add to .gitignore)
{
  "SUPABASE_URL": "https://foubokcqaxyqgjhtgzsx.supabase.co",
  "SUPABASE_ANON_KEY": "eyJ..."
}
```

```dart
// lib/utils/supabase_config.dart
const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
```

### 7.3 Auth Stream Fix

```dart
// lib/controllers/auth_controller.dart
class AuthNotifier extends Notifier<AuthState> {
  StreamSubscription<AuthState>? _authSub;

  void _init() {
    _authSub?.cancel();
    _authSub = authRepository.authStateChanges.listen((event) async {
      // ... existing handler
    });
    ref.onDispose(() => _authSub?.cancel());
    _checkCurrentSession();
  }
}
```

### 7.4 Repository Error Handling

Replace raw `e.toString()` error exposure:

```dart
// lib/utils/app_error.dart
sealed class AppError {
  const AppError();
}
class NetworkError extends AppError { const NetworkError(); }
class AuthError extends AppError { final String message; const AuthError(this.message); }
class NotFoundError extends AppError { const NotFoundError(); }
class PermissionError extends AppError { const PermissionError(); }
class UnknownError extends AppError { final String raw; const UnknownError(this.raw); }
```

Map Supabase exceptions to `AppError` in each repository. Display user-friendly messages in the UI from the sealed class.

### 7.5 go_router: Post-Login Redirect

```dart
redirect: (context, state) {
  final isLoggedIn = status == AuthStatus.authenticated;
  final isOnAuthScreen = state.matchedLocation.startsWith('/login') 
      || state.matchedLocation.startsWith('/register');
  
  if (!isLoggedIn && !isOnAuthScreen) {
    final from = Uri.encodeComponent(state.matchedLocation);
    return '/login?from=$from';
  }
  if (isLoggedIn && isOnAuthScreen) {
    final from = state.uri.queryParameters['from'];
    if (from != null && from.isNotEmpty) return Uri.decodeComponent(from);
    return '/home';
  }
  return null;
}
```

### 7.6 Chat N+1 Fix — Lateral Join RPC

```sql
-- supabase/functions/fetch_chat_threads.sql
CREATE OR REPLACE FUNCTION fetch_chat_threads(my_pet_id UUID)
RETURNS TABLE (
  id UUID, pet_id_1 UUID, pet_id_2 UUID,
  created_at TIMESTAMPTZ, updated_at TIMESTAMPTZ,
  last_message_text TEXT, last_message_at TIMESTAMPTZ,
  pet1 JSONB, pet2 JSONB
) LANGUAGE SQL AS $$
  SELECT
    ct.id, ct.pet_id_1, ct.pet_id_2, ct.created_at, ct.updated_at,
    lm.text AS last_message_text,
    lm.created_at AS last_message_at,
    row_to_json(p1)::JSONB AS pet1,
    row_to_json(p2)::JSONB AS pet2
  FROM chat_threads ct
  LEFT JOIN LATERAL (
    SELECT text, created_at FROM messages
    WHERE thread_id = ct.id
    ORDER BY created_at DESC LIMIT 1
  ) lm ON true
  LEFT JOIN pets p1 ON p1.id = ct.pet_id_1
  LEFT JOIN pets p2 ON p2.id = ct.pet_id_2
  WHERE ct.pet_id_1 = my_pet_id OR ct.pet_id_2 = my_pet_id
  ORDER BY COALESCE(lm.created_at, ct.created_at) DESC;
$$;
```

### 7.7 Feed Pagination

```dart
// lib/controllers/feed_controller.dart
// Replace single-page state with paginated state using riverpod_infinite_scroll_pagination
// or implement cursor-based pagination manually:

class FeedState {
  final List<PostModel> posts;
  final bool isLoading;
  final bool hasMore;
  final String? cursor; // last post's created_at
  final String? error;
  ...
}

// FeedRepository
Future<List<PostModel>> fetchPostsPage({String? cursor, int limit = 20}) async {
  var query = supabase.from('posts').select('...').order('created_at', ascending: false).limit(limit);
  if (cursor != null) query = query.lt('created_at', cursor);
  // ...
}
```

### 7.8 Platform Config Fixes

**Android `AndroidManifest.xml` (main):**
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
```

**Android `build.gradle.kts`:**
```kotlin
android {
  defaultConfig {
    applicationId = "com.petsphere.app"
    targetSdk = 35
    compileSdk = 35
  }
  buildTypes {
    release {
      signingConfig = signingConfigs.getByName("release")
      isMinifyEnabled = true
      isShrinkResources = true
    }
  }
}
```

**iOS `Info.plist`:**
```xml
<key>CFBundleDisplayName</key><string>PetSphere</string>
<key>NSCameraUsageDescription</key>
<string>PetSphere needs camera access to take photos of your pets.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>PetSphere needs photo library access to select pet photos.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>PetSphere needs permission to save photos.</string>
```

---

## 8. Security & Production Hardening

### 8.1 Checklist

- [ ] Rotate Supabase anon key (exposed in git history)
- [ ] Move credentials to `--dart-define-from-file` + CI secrets
- [ ] Fix avatar bucket (C4)
- [ ] Fix storage UPDATE/DELETE policies (H2)
- [ ] Fix match request RLS (H1)
- [ ] Remove notifications client INSERT policy (M10)
- [ ] Add PKCE auth flow
- [ ] Enable leaked password protection (Supabase Dashboard → Auth → Password)
- [ ] Add Android release signing
- [ ] Add iOS URL scheme for deep links
- [ ] Move `create_order` server-side (C5)
- [ ] Add `Content-Security-Policy` and `X-Frame-Options` to web build

### 8.2 Logging

```dart
// lib/utils/logger.dart
import 'package:flutter/foundation.dart';
void appLog(String message) {
  if (kDebugMode) debugPrint('[PetSphere] $message');
}
```

Replace all `debugPrint` with `appLog()` throughout codebase.

---

## 9. New Feature Roadmap (2026 Pet Super-App)

Based on research: the 2025–2026 shift is toward **pet super-apps** with AI health, telehealth, and life-cycle management.

### 9.1 AI Symptom Checker (High Value)
- Onboarding: symptom text/photo input
- Supabase Edge Function → Claude API (or GPT-4o) structured prompt
- Response: severity level (low/medium/high), possible conditions, recommended action (monitor / see vet / emergency)
- **Data needed:** `symptom_checks` table (pet_id, input, response, severity, created_at)

### 9.2 Vet Consultation / Telehealth (High Value)
- In-app booking form → confirmation
- Integration with third-party telehealth (e.g., Vetster, Chewy Health API, or custom video call)
- Async text chat with verified vet profiles
- **Data needed:** `vet_consultations` table

### 9.3 Push Notifications (High Value)
- FCM setup via Firebase Flutter plugin
- `flutter_local_notifications` for in-app display
- Notification categories: match requests, new messages, health reminders, order updates
- Supabase `send_push_notification` Edge Function

### 9.4 Google / Apple Sign-In (High Value)
- Supabase OAuth providers: Google + Apple
- `supabase.auth.signInWithOAuth(OAuthProvider.google)`
- iOS: Apple Sign-In required for App Store if any OAuth exists

### 9.5 Global Search (Medium Value)
- Single search screen: pets, posts, products
- Postgres full-text search with `to_tsvector` + `plainto_tsquery`
- Debounced input, category tabs on results

### 9.6 Onboarding Wizard (High Value)
- Post-registration 3 steps:
  1. Upload profile photo
  2. Add first pet (or skip)
  3. Set discovery preferences (animal type, location radius, breeding intent)
- Marks `profiles.onboarding_complete = true` on finish
- `go_router` redirects to wizard if `!onboarding_complete`

### 9.7 Pet Memorial / Rainbow Bridge (Aspirational)
- Mark pet as "passed" with a private/public memorial toggle
- Memorial gallery and tribute post type
- Bereavement resources list
- Timeline of memories (all posts, health records, photos)

### 9.8 Content Moderation
- Report flow for posts, comments, pets, users
- `reports` table → admin review queue (web admin panel or Supabase table editor)
- Block user: `blocked_users` table + RLS filter

---

## 10. Phased Implementation Plan

### Phase 0 — Emergency Fixes (Week 1) — Must do FIRST

These are production blockers. Do before any feature work.

| Task | File/Location | Est. |
|------|--------------|------|
| C1: Drop duplicate DB triggers | Supabase migration | 30min |
| C2: Add INTERNET permission to main AndroidManifest | `android/app/src/main/AndroidManifest.xml` | 5min |
| C3: Configure Android release signing | `build.gradle.kts` + `key.properties` | 2hrs |
| C4: Fix avatar upload bucket | `auth_repository.dart` | 5min |
| C7: Add iOS camera/photo permission strings | `ios/Runner/Info.plist` | 10min |
| C8: Fix `fetchThreads()` select to include `updated_at` | `chat_repository.dart` | 5min |
| H4: Fix auth stream subscription leak | `auth_controller.dart` | 30min |
| Create `test/` with smoke tests so `flutter test` passes | `test/widget_test.dart` | 30min |

**Total Phase 0: ~1 day**

---

### Phase 1 — Security & Identity (Week 1–2)

| Task | Priority |
|------|----------|
| Rotate Supabase anon key | Critical |
| Move Supabase credentials to `--dart-define` | High |
| Fix app identity (package name, bundle ID, display name) | High |
| Unify brand: decide "PetSphere" everywhere (no "Atelier", no "Nurtured") | High |
| H1: Fix match request RLS (receiver-only update) | High |
| H2: Path-scope storage UPDATE/DELETE policies | High |
| H5: Add deep link URL schemes (Android + iOS) + PKCE flow | High |
| H8: Move password reset into `AuthRepository`; listen for `passwordRecovery` event | High |
| M10: Remove `notifications` client INSERT policy | Medium |
| Enable leaked password protection in Supabase Dashboard | Medium |

---

### Phase 2 — Core Feature Fixes (Week 2–3)

| Task | Priority |
|------|----------|
| C5: Create `create_order` Edge Function (server-side price validation) | Critical |
| M3: Fix N+1 chat query → `fetch_chat_threads` RPC | High |
| M4: Implement feed pagination (cursor-based, 20 posts/page) | High |
| M5: Cart persistence to `shared_preferences` | High |
| M7: Upgrade `share_plus` to v13; migrate all call sites | High |
| M8: Fix discovery to exclude already-requested pets | High |
| M9: Post-login redirect (`?from=` query param in go_router) | Medium |
| M11: Add content-type detection in `uploadPostMedia()` | Medium |
| H6: Add unique constraint on `match_requests(sender_pet_id, receiver_pet_id)` | High |
| Add unique constraint on `chat_threads` unordered pet pair | High |

---

### Phase 3 — UI/UX Polish Pass (Week 3–4)

| Task | Priority |
|------|----------|
| Fix login screen: replace GestureDetector button with FilledButton | High |
| Unify AppBar brand across all screens ("PetSphere" logo) | High |
| Replace all hardcoded hex colors in views with AppTheme tokens | High |
| Add semantic labels to bottom nav | High |
| Post card: double-tap like animation | Medium |
| Match accepted → navigate to chat thread | High |
| Pet profile: add delete pet UI | High |
| Settings: implement working account deletion flow | Medium |
| Onboarding wizard (post-registration 3-step) | High |
| Add `flutter_local_notifications` for health reminders | Medium |

---

### Phase 4 — Testing Infrastructure (Week 4)

| Task |
|------|
| Add `mocktail` to dev dependencies |
| Unit tests: `AuthNotifier` (login, logout, session check, error states) |
| Unit tests: `CartController` (add, remove, update, place order) |
| Unit tests: `MatchController` (send, accept, decline) |
| Widget tests: login form (validation, error display, submit) |
| Widget tests: empty/loading/error states (feed, marketplace) |
| Add GitHub Actions CI: `flutter analyze` + `flutter test` on every PR |

---

### Phase 5 — New High-Value Features (Month 2)

| Feature | Effort |
|---------|--------|
| Google Sign-In | 1 day |
| Apple Sign-In | 1 day |
| Chat image attachments | 2 days |
| Global search screen | 2 days |
| Push notifications (FCM) | 3 days |
| Weight tracking chart in Health tab | 1 day |
| Health score gauge | 1 day |
| AI symptom checker (Edge Function + UI) | 3 days |

---

### Phase 6 — Scale & Polish (Month 3+)

| Feature | Effort |
|---------|--------|
| Stripe payment integration | 1 week |
| Vendor dashboard | 1 week |
| Feature-first folder restructure | 2 days |
| `freezed` + `json_serializable` for type-safe models | 3 days |
| Localization (`flutter gen-l10n`) | 2 days |
| Pet memorial section | 3 days |
| Vet consultation booking | 1 week |
| Content moderation / report system | 3 days |

---

## 11. Research Sources

- [Mobile App UI/UX Design Trends 2026 — designstudiouiux.com](https://www.designstudiouiux.com/blog/mobile-app-ui-ux-design-trends/)
- [12 Mobile App UI/UX Design Trends 2026 — thebrandsbureau.com](https://thebrandsbureau.com/mobile-app-design-trends-2026/)
- [Flutter Pagination with Riverpod — codewithandrea.com](https://codewithandrea.com/articles/flutter-riverpod-pagination/)
- [riverpod_infinite_scroll_pagination — pub.dev](https://pub.dev/packages/riverpod_infinite_scroll_pagination)
- [AI Pet Health Monitoring App — suffescom.com](https://www.suffescom.com/product/ai-pet-health-monitoring-app)
- [AI Pet Care App Development — biz4group.com](https://www.biz4group.com/blog/ai-pet-care-app-development)
- [TTcare AI Pet Health — ttcareforpet.com](https://www.ttcareforpet.com/)
- [Modern Flutter UI Design Patterns 2026 — Medium](https://medium.com/@expertappdevs/how-to-build-modern-ui-in-flutter-design-patterns-64615b5815fb)
- [Flutter Dark Mode Best Practices 2026 — copyprogramming.com](https://copyprogramming.com/howto/how-can-make-flutter-app-with-dark-mode)
- [Flutter Clean Architecture 2026 — flutterstudio.dev](https://flutterstudio.dev/blog/flutter-clean-architecture.html)
- [Supabase RLS Best Practices — supabase.com](https://supabase.com/docs/guides/database/postgres/row-level-security)
- [UX/UI Design for Pet Tech App — softeq.com](https://www.softeq.com/featured_projects/ux-ui-design-for-a-pet-tech-mobile-application)
- [DCM Riverpod 3 ref lifecycle guide — dcm.dev](https://dcm.dev/blog/2026/03/25/inside-riverpod-source-code-guide-dcm-rules)
- [PetSphere Stitch UX Audit & Expansion Plan — local: `stitch_petsphere_app_redesign/ux_audit_expansion_plan.md`](stitch_petsphere_app_redesign/stitch_petsphere_app_redesign/ux_audit_expansion_plan.md)

---

*Plan saved: 2026-04-27. Review this document before starting each phase. Update checkboxes as tasks complete.*
