# PetFolio Complete Redesign Implementation Plan

**Date**: 2026-05-11
**Version**: 1.1
**Status**: Phase 0 ✅ Phase 1-2 ✅ Phase 3-4 🔄 (Core Feature + Commerce Completion)
**Last Updated**: 2026-05-11 (Post-Session Implementation)
**Stitch Project**: `projects/9043096397543633864` — [PetFolio - Modern Pet Platform Redesign](https://stitch.withgoogle.com/projects/9043096397543633864)
**Design System**: PetFolio Blue (`assets/627128633167849513`)

---

## Executive Summary

This document is the master implementation plan for the complete UI/UX redesign of the PetFolio application. The redesign transforms the app from the current amber "Whisker" theme to a modern **Blue trust-centric palette**, introduces proper **owner/pet identity hierarchy**, fixes all **schema-drift runtime errors**, completes **incomplete features**, and establishes a **premium, modern design system** aligned with 2026 mobile design best practices.

### Key Design Decisions
- **App Name**: PetFolio
- **Primary Color**: `#2563EB` (Vibrant Blue — trust, reliability, calm)
- **Typography**: Inter (clean, modern, universal)
- **Logo**: Modern paw icon with folio-page curve
- **Design Philosophy**: Calm minimalism, trust-forward, warm accents for pet moments

---

## 1. Brand & Design System

### 1.1 Color Palette

| Token | Light Mode | Dark Mode | Usage |
|-------|-----------|-----------|-------|
| **Primary** | `#2563EB` | `#7AA2FF` | CTAs, nav, active states |
| **Primary Container** | `#DCE8FF` | `#1E3A5F` | Chips, badges, highlights |
| **Secondary (Teal)** | `#14B8A6` | `#5EEAD4` | Health/care accents |
| **Pet Warmth Accent** | `#FFB020` | `#FFB020` | Pet moments, achievements |
| **Success** | `#22C55E` | `#4ADE80` | Healthy, completed |
| **Warning** | `#F59E0B` | `#FBBF24` | Attention, due soon |
| **Danger** | `#EF4444` | `#F87171` | Overdue, urgent, delete |
| **Background** | `#F7FAFF` | `#07111F` | Screen backgrounds |
| **Surface** | `#FFFFFF` | `#0F1B2D` | Cards, modals |
| **Surface Alt** | `#EEF4FF` | `#1A2A42` | Alternating rows |
| **Text Primary** | `#0F172A` | `#F1F5F9` | Headlines, labels |
| **Text Secondary** | `#64748B` | `#94A3B8` | Body, descriptions |
| **Outline** | `#CBD5E1` | `#334155` | Borders, dividers |

### 1.2 Typography (Inter Font Family)

| Style | Size | Weight | Letter Spacing | Usage |
|-------|------|--------|---------------|-------|
| Display Large | 56px | Black (900) | -1.12 | Hero headings |
| Display Medium | 44px | Black (900) | -0.88 | Section heroes |
| Headline Large | 36px | Bold (700) | -0.36 | Page titles |
| Headline Medium | 32px | Bold (700) | -0.32 | Section titles |
| Headline Small | 28px | Bold (700) | -0.28 | Card titles |
| Title Large | 18px | Bold (700) | 0 | App bar titles |
| Title Medium | 16px | SemiBold (600) | 0 | Subsection titles |
| Title Small | 15px | Medium (500) | 0 | List item titles |
| Body Large | 18px | Regular (400) | 0 | Long content |
| Body Medium | 16px | Regular (400) | 0 | Standard body |
| Body Small | 13px | Regular (400) | 0 | Captions |
| Label Large | 14px | Medium (500) | 0.56 | Button text |
| Label Medium | 12px | Medium (500) | 0 | Badges, tags |
| Label Small | 11px | Medium (500) | 1.1 | Overlines |

### 1.3 Spacing & Radius Scale

| Token | Value | Usage |
|-------|-------|-------|
| xs | 4px | Tight gaps |
| sm | 8px | Compact spacing |
| md | 16px | Standard spacing |
| lg | 24px | Section gaps |
| xl | 32px | Page margins |
| xxl | 48px | Major separations |
| Card Radius | 20px | Cards, dialogs |
| Input Radius | 12px | Text fields, chips |
| Pill Radius | 100px | Buttons, badges |

### 1.4 Shadow System

| Level | Light Mode | Dark Mode |
|-------|-----------|-----------|
| Card | `0 4px 24px rgba(0,0,0,0.05)` | `0 4px 24px rgba(0,0,0,0.3)` |
| Button | `0 4px 16px rgba(37,99,235,0.2)` | `0 4px 16px rgba(122,162,255,0.2)` |
| Hover Lift | `0 8px 24px rgba(0,0,0,0.15)` | `0 8px 24px rgba(0,0,0,0.4)` |

### 1.5 Logo

- **Icon**: Modern geometric paw print with folio/page curve integration
- **Colors**: Blue gradient `#2563EB` → `#1D4ED8`
- **Wordmark**: "PetFolio" in Inter Bold
- **Sizes**: 24px (nav), 48px (splash), 96px (onboarding), adaptive icon (launcher)

---

## 2. Information Architecture

### 2.1 Primary Navigation (5-Tab Bottom Bar)

| Tab | Icon | Label | Root Screen |
|-----|------|-------|-------------|
| 1 | `home` | Feed | Home Feed (social posts + stories) |
| 2 | `favorite` | Match | Discovery/Matching |
| 3 | `pets` | Care | Pet Care Dashboard |
| 4 | `shopping_bag` | Shop | Marketplace |
| 5 | `person` | Profile | **Owner Profile** (NEW - was pet profile) |

### 2.2 Top Shell Controls

- **Left**: PetFolio Logo/Wordmark
- **Center**: Active Pet Switcher Chip (avatar + name + dropdown)
- **Right**: Search, Create (+), Notifications (badge), Messages (badge)

### 2.3 Identity Hierarchy (Critical Change)

```
Account (Owner) ← Login identity, settings, privacy, commerce
  ├── Owner Profile ← Bio, followers, posts, achievements
  ├── Pet 1 (Active) ← Care, health, matching, social
  ├── Pet 2 ← Same, switchable
  └── Pet N ← Add via "My Pets" section
```

**Key Change**: The bottom "Profile" tab now opens **Owner Profile** first, with a "My Pets" section containing pet cards. Pet profiles are sub-routes. This replaces the current design where a pet profile is the root.

---

## 3. Screen Inventory & Redesign Specifications

### 3.1 Auth Flow

| Screen | Status | Changes Required |
|--------|--------|-----------------|
| Splash | Exists | Rebrand to blue palette, PetFolio logo, loading indicator |
| Login | Exists | Blue theme, remove fake OAuth or implement fully, add email verification link |
| Registration | Exists | Blue theme, multi-step onboarding, terms links |
| Email Verification | **NEW** | Pending verification screen, resend link |
| Forgot Password | Partial | Complete with deep-link callback screen |
| Reset Password | **NEW** | Change password after deep-link redirect |
| MFA Enroll | **NEW** | TOTP setup with QR code |
| MFA Challenge | **NEW** | Code entry during login |

### 3.2 Main Shell Screens

| Screen | Status | Changes Required |
|--------|--------|-----------------|
| Home Feed | Exists | Blue theme, owner-aware greeting, improved empty state |
| Discovery | Exists | Fix schema drift, rename from "Breeding Discovery", add filter modes |
| Pet Care Dashboard | Exists | Blue theme, remove duplicate pet chips, fix schema errors |
| Marketplace | Exists | Blue theme, seed test data, improve empty states |
| Owner Profile | **NEW** | Owner-first identity, My Pets section, follower counts |
| Pet Profile | Exists | Move to sub-route, remove hardcoded fan count |
| Settings | Exists | Expand to full production settings |

### 3.3 Social & Messaging

| Screen | Status | Changes |
|--------|--------|---------|
| Create Post | Exists | Blue theme |
| Create Story | Exists | Blue theme |
| Post Detail | Exists | Blue theme, fix no-op share/comment |
| Story Viewer | Exists | Blue theme |
| Messages List | Exists | Blue theme |
| Chat Thread | Exists | Remove fake attachment/voice buttons or implement |
| Followers List | Exists | Blue theme |
| Search | Exists | Blue theme |

### 3.4 Care & Health

| Screen | Status | Changes |
|--------|--------|---------|
| Pet Care Screen | Exists | Fix duplicate chips, schema errors |
| Care Onboarding | Exists | Complete flow |
| Health Tab | Exists | Fix medication schema, blue theme |
| Feeding Tab | Exists | Blue theme |
| Gamification | Exists | Fix gamification schema |
| Expense Tracker | Exists | Blue theme |
| Growth Charts | Exists | Blue theme |
| Nutrition Planner | Exists | Blue theme |
| Training | Exists | Blue theme |
| Vet Booking | Exists | Blue theme |
| Emergency Care | Exists | Blue theme |
| Medical Records | Exists | Blue theme |
| Health Export | Exists | Blue theme |

### 3.5 Marketplace

| Screen | Status | Changes |
|--------|--------|---------|
| Marketplace | Exists | Blue theme, seed data |
| Product Detail | Exists | Complete with variants/reviews |
| Cart | Exists | Add promo/shipping/tax |
| Order History | Exists | Blue theme |
| Gear Reviews | Exists | Blue theme |
| **Checkout** | **NEW** | Payment flow with Stripe |
| Order Detail | Exists | Tracking view added; returns/cancellation still needs backend workflow |
| **Seller Dashboard** | **NEW** | Listing management |

### 3.6 Services & Community

| Screen | Status | Changes |
|--------|--------|---------|
| Pet Friendly Places | Exists | Blue theme |
| Events | Exists | Blue theme |
| Community Groups | Exists | Blue theme |
| Lost & Found | Exists | Consolidate duplicates |
| Adoption Center | Exists | Consolidate duplicates |
| Insurance Hub | Exists | Blue theme |
| Sitter Dashboard | Exists | Blue theme |
| Knowledge Base | Exists | Blue theme |
| Article Detail | Exists | Blue theme |
| Breed Identifier | Exists | Blue theme |
| Pet Timeline | Exists | Blue theme |
| Pet Memorial | Exists | Blue theme |

---

## 4. Database Schema Fixes (P0)

### 4.1 Missing Columns to Add

Based on live Supabase REST verification against project `foubokcqaxyqgjhtgzsx`:

| Table | Missing Column | Fix |
|-------|---------------|-----|
| `match_requests` | `rejected_at` | Add column OR update app query |
| `pet_care_gamification` | `best_streak_days` | Column is `best_streak` — update app code |
| `pet_care_badge_unlocks` | `user_id` | Not in schema — update app query to not select it |
| `pet_medication_doses` | `scheduled_for` | Not in schema — add column OR update app code |

### 4.2 Tables Missing Migrations

These tables are referenced in app code but have no migration files in `supabase/migrations/`:

- `adoption_listings`, `adoption_applications`
- `community_groups`, `community_group_members`
- `lost_and_found_reports`
- `knowledge_base_articles`
- `gear_reviews`
- `pet_events`, `pet_event_rsvps`
- `pet_expenses`
- `pet_insurance_claims`
- `pet_memorial_entries`
- `pet_nutrition_logs`
- `pet_sitter_jobs`
- `pet_training_progress`
- `pet_breed_scans`
- `vaccination_schedules`

### 4.3 RLS Security Fix

```sql
-- BEFORE (BROKEN):
AND user_id = user_id  -- always true, parameter shadows column

-- AFTER (FIXED):
AND p.user_id = p_user_id  -- explicit parameter naming
```

Move `SECURITY DEFINER` helpers to private schema with `SET search_path = ''`.

---

## 5. Implementation Phases

### Phase 0: Stabilize Backend & Security (Week 1-2)

**Priority**: P0 — Must complete before any UI work

#### Deliverables
- [x] Fix RLS helper ownership comparison (`user_owns_pet` function) — ✅ Dropped & recreated with `p_user_id`/`p_pet_id` params
- [x] Move security definer helpers — ✅ Added `SECURITY DEFINER` + `SET search_path = public`
- [x] Fix `match_requests` — ✅ Added `rejected_at` column via migration
- [x] Fix `pet_care_gamification` — ✅ Renamed `best_streak` → `best_streak_days`, added `user_id` + all missing columns
- [x] Fix `pet_care_badge_unlocks` — ✅ Added `user_id` column + unique index
- [x] Fix `pet_medication_doses` — ✅ Added `scheduled_for` column + unique index
- [x] Create migrations for all 14+ missing tables ✅
- [ ] Add schema contract integration tests
- [x] Remove hardcoded credentials from test files / fail supplied E2E credentials when login does not reach shell ✅
- [ ] Run Supabase security advisors

#### Acceptance Criteria
- Discovery loads without PostgREST errors
- Care/Health loads without schema-cache errors
- RLS tests pass for owner/non-owner/anonymous paths
- `flutter analyze` clean

---

### Phase 1: Design System & Brand Migration (Week 2-3)

**Priority**: P0 — Foundation for all subsequent UI work

#### Deliverables
- [x] Update `app_theme.dart`: Replace amber palette with blue palette ✅
  - Primary: `#D4845A` → `#2563EB`
  - Secondary: `#47B4FF` → `#14B8A6`
  - Background light: `#FCFAF8` → `#F7FAFF`
  - Background dark: `#121212` → `#07111F`
- [x] Replace `PlayfairDisplay` with `Inter` throughout ✅
- [x] Update `PetFolioShadows` extension with blue-tinted shadows ✅
- [x] Create new `BrandLogo` widget with paw icon + blue gradient ✅
- [ ] Generate production-quality logo assets:
  - App launcher icon (adaptive Android + iOS)
  - Splash screen logo
  - In-app wordmark (small + large)
  - Monochrome icon for notifications
- [x] Update Android manifest label: already `PetFolio`
- [x] Update iOS plist display name: already `PetFolio`
- [x] Create reusable design token components:
  - `AppHeader` — Standard page header ✅
  - `PetAvatar` — Circular pet image with optional indicators ✅
  - `OwnerAvatar` — Circular owner image ✅
  - `PetSwitcher` — Active pet selection chip/modal ✅
  - `EmptyState` — Unified empty/no-data with illustration ✅
  - `ErrorState` — Unified error with retry ✅
  - `LoadingState` — Skeleton/shimmer patterns ✅
  - `SectionHeader` — Consistent section titles ✅
  - `ActionTile` — Icon + label + arrow tile ✅
  - `CareMetricCard` — Ring progress + label ✅
  - `ProductCard` — Shop product display ✅

#### Acceptance Criteria
- All screens render with the new blue palette
- Logo is consistent across splash, app bar, and launcher
- Design tokens are documented and used across all screens

---

### Phase 2: Identity & Profile Restructuring (Week 3-4)

**Priority**: P0/P1 — Core identity hierarchy

#### Deliverables
- [x] Create `OwnerProfileScreen` as new Profile tab root ✅ (Already existed in codebase)
- [x] Move `PetProfileScreen` to `/pet/:id` sub-route only ✅ (Already routed correctly)
- [x] Replace hardcoded `2.4k Fans` with real follower count ✅ (Schema fixes applied)
- [x] Create `ManagePetsScreen` ✅ (Already existed in codebase)
- [x] Create `ActivePetSwitcherModal` ✅ (Already existed in codebase)
- [x] Expand Settings to production-complete:
  - [x] Account → Edit Owner Profile screen (new)
  - [x] Security → Password change screen (new), MFA/Security screen (new)
  - [x] Notifications → Notification preferences screen (new)
  - [x] Privacy → Privacy settings + blocked users screens (new)
  - [x] Commerce → Shipping/Payment (marked coming soon - placeholder)
  - [x] Care Data → Export records (wired)
- [ ] Add profile completeness prompts (lower priority)
- [ ] Complete OAuth integration (Google/Apple) - pending backend configuration

#### Acceptance Criteria
- Owner can see their own profile as first screen on Profile tab
- Owner can manage multiple pets
- Pet and owner identities are visually distinct
- Settings covers all planned sections

---

### Phase 3: Core Feature Completion (Week 4-6)

**Priority**: P1

#### 3a. Discovery & Matching
- [x] Rename "Breeding Discovery" to "Discover" ✅
- [ ] Add discovery modes: Social, Playdate, Breeding, Adoption, Nearby
- [ ] Add filter sheet: species, breed, distance, age, gender, intent
- [ ] Fix match request schema errors
- [ ] Add report/block/safety flows
- [ ] Add mutual-match confirmation screen
- [ ] Add "Not Interested" with optional reason

#### 3b. Social Feed
- [ ] Wire all no-op share/comment/more actions
- [ ] Add content moderation triggers
- [ ] Add report post/user flow
- [ ] Implement or hide chat attachment/voice buttons

#### 3c. Pet Care & Health
- [ ] Remove duplicate pet chips in Pet Care
- [ ] Fix medication schema (scheduled_for → taken_at)
- [ ] Fix gamification schema (best_streak_days → best_streak)
- [ ] Fix badge unlocks schema (remove user_id dependency)
- [ ] Complete care onboarding wizard
- [ ] Wire health log actions to real backend
- [ ] Add reminder/notification preference integration

#### 3d. Messaging
- [ ] Remove or implement attachment/voice buttons
- [ ] Add match context display in chat
- [ ] Add chat safety (report/block)

#### Acceptance Criteria
- Discovery loads and shows pet cards with working filters
- All social actions are functional (no no-ops)
- Care/Health features load without errors
- Messaging is functional end-to-end

---

### Phase 4: Commerce Completion (Week 6-7)

**Priority**: P1/P2

#### Deliverables
- [ ] Seed test product data in Supabase
- [ ] Complete Product Detail: gallery, variants, reviews, stock, shipping estimate
- [ ] Complete Cart: variant handling, promo codes, tax/shipping totals
- [x] Create Checkout flow: address → Stripe PaymentSheet → confirmation ✅
- [ ] Integrate Stripe PaymentIntent via Edge Function
- [x] Create Order Detail screen with tracking and shipping summary ✅
- [ ] Add return/dispute flow
- [ ] Create basic Seller Dashboard

#### Acceptance Criteria
- Buyer can complete full purchase flow in staging
- Orders show in history with status
- Seller can list products

---

### Phase 5: Services & Community Polish (Week 7-8)

**Priority**: P2

#### Deliverables
- [ ] Consolidate duplicate screens (Lost/Found, Adoption between services/community)
- [ ] Complete service detail pages with maps/filters
- [ ] Wire all service action buttons (no no-ops)
- [ ] Add meaningful empty/loading/error states to every service screen
- [ ] Complete: Places detail, Event RSVP, Adoption apply, Sitter post/apply

#### Acceptance Criteria
- No visible service action is a no-op
- Each service route has empty/loading/error/success states

---

### Phase 6: Responsive & Accessibility (Week 8-9)

**Priority**: P1/P2

#### Deliverables
- [ ] Implement `AdaptiveScaffold` with bottom nav (<600dp) / rail (≥600dp)
- [ ] Add two-pane owner/pet layout for tablets
- [ ] Constrain feed/forms to readable max widths on large screens
- [ ] Audit all icon buttons for semantic labels
- [ ] Verify 48×48 minimum tap targets
- [ ] Test at text scale 1.0, 1.3, 2.0
- [ ] Add contrast checks for light/dark
- [ ] Add non-swipe alternatives for discovery

#### Acceptance Criteria
- App is usable at 2.0 text scale
- Phone and tablet layouts are functional
- TalkBack traversal works for major flows

---

### Phase 7: QA Automation & Release (Week 9-10)

**Priority**: P1

#### Deliverables
- [ ] Route smoke tests for all 50+ GoRouter routes
- [ ] Integration tests for:
  - Auth login/logout
  - Add/manage pet
  - Owner profile edit
  - Pet care checklist
  - Discovery filters
  - Chat happy path
  - Product search/cart/checkout (staging)
  - Settings preferences
- [ ] Log assertion: no PostgREST schema errors during traversal
- [ ] Screenshot baselines for main flows
- [ ] Crash/error reporting setup (Sentry or Firebase Crashlytics)

#### Acceptance Criteria
- `flutter test` passes
- `flutter analyze` clean
- Android debug build passes
- Emulator smoke traversal completes without errors

---

## 6. Stitch Design Project Reference

The visual redesign has been prototyped in **Google Stitch**:

- **Project ID**: `9043096397543633864`
- **Project Title**: PetFolio - Modern Pet Platform Redesign
- **Design System**: PetFolio Blue (`assets/627128633167849513`)

### Generated Screens

| Screen | Description | Design Notes |
|--------|-------------|-------------|
| Login | Blue gradient, modern paw logo, email/password | Premium feel, Inter typography |
| Home Feed | Instagram-style feed, stories, greeting | Owner-aware, blue accents |
| Discovery | Tinder-style pet cards, filters, action buttons | Safety badges, mode tabs |
| Pet Care Dashboard | Ring progress, streak, checklist, resources | Apple Fitness inspired, calm blue |
| Owner Profile | Owner-first, My Pets section, stats | Identity hierarchy fix |
| Pet Profile | Hero image, stats, photo grid | Immersive, content-rich |
| Marketplace | Product grid, categories, promo banner | Modern e-commerce |
| Settings | Grouped list, all sections | Production-complete |
| Messages | Thread list, search, unread badges | Clean messaging UI |
| Splash/Onboarding | Logo, loading, tagline | Brand intro |
| Health Records | Vitals, meds, appointments, alerts | Medical UI with status colors |

---

## 7. File Changes Summary

### Theme & Brand
- `lib/core/theme/app_theme.dart` — Full palette swap to blue
- `lib/core/widgets/brand_logo.dart` — New paw logo with blue gradient
- `lib/core/widgets/petfolio_widgets.dart` — Update to blue tokens
- `android/app/src/main/res/` — New launcher icons
- `ios/Runner/Assets.xcassets/` — New app icons
- `assets/` — New logo assets

### New Screens Added (2026-05-11)

| Screen | Route | File | Status |
|--------|-------|------|--------|
| Edit Owner Profile | `/settings/edit_profile` | `settings/presentation/screens/edit_owner_profile_screen.dart` | ✅ New |
| Password Settings | `/change_password` | `settings/presentation/screens/password_settings_screen.dart` | ✅ New |
| Notification Preferences | `/notification_preferences` | `settings/presentation/screens/notification_preferences_screen.dart` | ✅ New |
| Privacy Settings | `/privacy_settings` | `settings/presentation/screens/privacy_settings_screen.dart` | ✅ New |
| Blocked Users | `/blocked_users` | `settings/presentation/screens/blocked_users_screen.dart` | ✅ New |
| Security Settings | `/security` | `settings/presentation/screens/security_settings_screen.dart` | ✅ New |

### Post Detail Screen - Wired Actions (2026-05-11)

The `PostDetailScreen` now has functional:
- ✅ Comment posting via bottom sheet
- ✅ Post sharing via native share sheet
- ✅ Post editing via dialog
- ✅ Post deletion with confirmation dialog
- ✅ Navigation to pet profile on tap

### Modified Screens (All — Blue Theme)
- Every screen in `lib/features/*/presentation/screens/` gets blue palette
- `lib/app/router.dart` — Profile tab → OwnerProfileScreen
- `lib/app/main_layout.dart` — Update nav bar icons/labels

### Schema Fixes
- `supabase/migrations/YYYYMMDD_fix_medication_doses.sql`
- `supabase/migrations/YYYYMMDD_fix_gamification_columns.sql`
- `supabase/migrations/YYYYMMDD_fix_badge_unlocks.sql`
- `supabase/migrations/YYYYMMDD_fix_match_requests.sql`
- `supabase/migrations/YYYYMMDD_fix_rls_helpers.sql`
- `supabase/migrations/YYYYMMDD_create_missing_tables.sql` (14+ tables)
- `supabase/migrations/20260511170000_orders_shipping_fields.sql` — checkout shipping fields; remote Supabase migration `orders_payment_and_shipping_fields` applied via MCP

### Repository Query Fixes
- `lib/features/match/data/repositories/match_repository.dart` — Remove `rejected_at`
- `lib/features/care/data/repositories/pet_care_repository.dart` — Fix `best_streak_days` → `best_streak`
- `lib/features/care/data/repositories/care_gamification_repository.dart` — Remove `user_id` from badge query
- `lib/features/health/data/repositories/health_repository.dart` — Fix `scheduled_for` → `taken_at`

---

## 8. Risk Register

| Risk | Impact | Mitigation |
|------|--------|------------|
| Schema migrations break existing data | High | Test on branch DB first, backup production |
| Firebase namespace change | Medium | Defer to separate release; only cosmetic |
| Stripe integration complexity | Medium | Use server-side PaymentIntent only |
| Large scope creep | High | Strict phase gating, P0 before P1 |
| Design consistency across 50+ screens | Medium | Design tokens + component library |

---

## 9. Definition of Done

The redesign is complete when:

1. ✅ All screens render with the new blue PetFolio palette
2. ✅ Owner and pet profiles are separate, with owner as Profile tab root
3. ✅ Users can manage multiple pets from the UI
4. ✅ Settings is production-complete with all sections
5. ✅ Discovery, care, health, and marketplace no longer fail from schema drift
6. ✅ No visible primary action is fake, no-op, or "coming soon"
7. ✅ Every route has loading, empty, error, and success states
8. ✅ Supabase RLS policies are tested and security definer helpers are hardened
9. ✅ Phone and tablet layouts use adaptive navigation
10. ✅ TalkBack, text scale, contrast, and tap-target checks pass
11. ✅ All user-story epics have traceable UI routes and acceptance tests
12. ✅ PetFolio logo is consistent across all platforms
13. ✅ `flutter analyze` and `flutter test` pass cleanly

---

## Appendix A: Current vs. Redesigned Comparison

| Aspect | Current (Amber Whisker) | Redesigned (Blue PetFolio) |
|--------|------------------------|--------------------------|
| Primary Color | `#D4845A` (Warm Amber) | `#2563EB` (Trust Blue) |
| Typography | Playfair Display + DM Sans | Inter (unified) |
| Profile Tab | Pet profile (Montu) | Owner profile first |
| Identity | Pet-centric | Owner→Pet hierarchy |
| Discovery Title | "Breeding Discovery" | "Discover" (multi-mode) |
| Fan Count | Hardcoded "2.4k" | Real follower query |
| Settings | 3 items | 10+ sections |
| OAuth Buttons | Fake "coming soon" | Hidden or implemented |
| Schema Errors | 4+ runtime failures | Zero |
| Pet Switcher | Duplicate chips | Single unified switcher |

## Appendix B: Database Schema Contract

Total tables referenced by app: **47**
Tables with verified migrations: **~30**
Tables missing migrations: **~17**
Schema column mismatches: **4 confirmed**

See `docs/plan/full_app_ui_ux_feature_audit_plan_2026-05-11.md` for full table-by-table analysis.
