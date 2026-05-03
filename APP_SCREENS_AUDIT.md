# PetSphere — App Screens Audit

| Field | Value |
|-------|-------|
| **Audit date** | May 3, 2026 |
| **Build** | Debug on `emulator-5554` (Android 17 / API 37) |
| **Method** | Marionette + Cursor agent |

---

## Table of contents

1. [Home / Feed](#home--feed)
2. [Discovery / Breeding](#discovery--breeding-discovery)
3. [Search](#search)
4. [Pet Care](#pet-care)
5. [Chat / Messages](#chat--messages)
6. [Pet Profile (Own)](#pet-profile-own)
7. [Pet Profile (Visitor)](#pet-profile-visitor--other-user)
8. [Marketplace](#marketplace)
9. [Settings](#settings)
10. [Notifications](#notifications)
11. [Care resource screens](#care-resource-screens)
12. [Bottom navigation](#bottom-navigation)
13. [Summary of changes](#summary-of-all-changes)

---

## Home / Feed

| | |
|---|---|
| **Route** | `/` (MainLayout index 0) |
| **File** | `lib/views/home_screen.dart` |

### Available actions

| Done | Action | Result |
|:---:|:---|:---|
| x | Scroll feed | Working |
| x | Tap story (Your story) | Working |
| x | Tap pet post 뿯↽ opens post detail | Working |
| x | Like post (heart icon) | Working |
| x | Comment icon | Working |
| x | Share post icon | Working |
| x | Bookmark icon | Working |
| x | Search icon (AppBar) 뿯↽ Search screen | Working |
| x | New Post icon (AppBar) 뿯↽ Create Post | Working |
| x | Notifications icon (AppBar) | Working |
| x | Messages icon (AppBar) | Working (unread badge) |

### Issues found

None observed.

### Screenshots

Initial launch screenshot — 2026-05-03.

---

## Discovery / Breeding Discovery

| | |
|---|---|
| **Route** | MainLayout index 1 (bottom nav search icon) |
| **File** | `lib/views/discovery_screen.dart` |

### Available actions

| Done | Action | Result |
|:---:|:---|:---|
| x | Pet selector bar (multiple pets) | Working |
| x | Filter chips: For You, Dogs, Cats, Nearby | Working |
| x | Swipe card left (skip) | Working |
| x | Swipe card right (like) | Working |
| x | Tap star button 뿯↽ pet profile | Working |
| x | Tap heart button 뿯↽ like with animation | Working |
| x | Liked Pets icon (AppBar) | Working |
| x | New Listing icon (AppBar) 뿯↽ bottom sheet | Working |
| x | Nearby tab | Working |
| x | My Listings tab | Working |

### Issues found

- Action buttons cleared above bottom nav via `navSpace` padding.
- LIKE/NOPE overlay uses `colorScheme` tokens.

### Screenshots

2026-05-03.

---

## Search

| | |
|---|---|
| **Route** | `/search` (pushed from Home AppBar) |
| **File** | `lib/views/search_screen.dart` |

### Available actions

| Done | Action | Result |
|:---:|:---|:---|
| x | Type in SearchBar 뿯↽ live search (`onChanged`) | Fixed |
| x | Submit search (keyboard Enter) | Working |
| x | Clear button (X) | Working |
| x | Posts tab | Working |
| x | Pets tab | Working |
| x | Market tab | Working |

### Issues fixed

1. **Critical:** Added `onChanged: _onSearch` so search runs while typing.
2. **Query bug:** Replaced wrong column `species` with `animal_type` in pet search (was returning zero pet results).
3. Refresh trailing button visibility on clear via `setState`.

### Screenshots

Empty state — 2026-05-03.

---

## Pet Care

| | |
|---|---|
| **Route** | `/pet_care` (bottom nav center + button) |
| **File** | `lib/views/pet_care_screen.dart` |

### Available actions

| Done | Action | Result |
|:---:|:---|:---|
| x | Per-pet selector (above tabs) | Added |
| x | Care Diary / Health / Feeding tabs | Working |
| x | Daily checklist tasks | Working |
| x | Today's overview bento grid | Working |
| x | Edit Goals | Working |
| x | Mood selector (Sleepy / Happy / Playful / Sick) | Working |
| x | Care Resources grid (20 resource buttons) | Working |
| x | Setup banner (onboarding incomplete) | Working |
| x | Streak display | Working |
| x | Achievements block | Working |
| x | Pull-to-refresh | Working |

### Issues fixed

- Per-pet selector at top so all three tabs share the selected pet.
- Removed duplicate `_PetSelector` from Care Diary tab body.
- Selector: pill chips with avatar + name, amber border when selected.

### Screenshots

Care Diary — Fluffy 1 selected — 2026-05-03.

---

## Chat / Messages

| | |
|---|---|
| **Route** | `/messages`, `/chat/:id` |
| **Files** | `lib/views/messages_list_screen.dart`, `lib/views/chat_screen.dart` |

### Available actions

| Done | Action | Result |
|:---:|:---|:---|
| x | Messages list (avatars, names, preview) | Working |
| x | Unread badge | Working |
| x | Tap thread 뿯↽ chat | Working |
| x | AppBar avatar + name (tappable 뿯↽ pet profile) | Working |
| x | Online status indicator | Working |
| x | Three-dot menu (AppBar) | Working (placeholder) |
| x | Date separators | Working |
| x | Sent bubbles (amber gradient) | Working |
| x | Timestamp + read receipt | Working |
| x | Attachment (+) 뿯↽ bottom sheet | Fixed |
| x | Camera / Gallery / Document (sheet options) | Snackbar placeholders |
| x | Text input | Working |
| x | Mic icon when field empty | Added |
| x | Send when text present (`AnimatedSwitcher`) | Working |
| x | Empty state: "Say hello! 붿붿" | Working |

### Issues fixed

- Replaced "Attachment support coming soon" snackbar with modal bottom sheet.
- Send / mic toggle from text content; `onChanged` triggers rebuild.
- Added `_AttachOption` widget for sheet rows.

### Screenshots

Sallu chat with attachment sheet — 2026-05-03.

---

## Pet Profile (Own)

| | |
|---|---|
| **Route** | MainLayout index 4 (profile tab) |
| **File** | `lib/views/pet_profile_screen.dart` |

### Available actions

| Done | Action | Result |
|:---:|:---|:---|
| x | Hero `SliverAppBar` | Working |
| x | Edit Profile | Working |
| x | Share | Working |
| x | Pet / Owner selector chips | Working |
| x | Post grid | Working |
| x | Settings gear 뿯↽ Settings | Working |
| x | Care badges (e.g. First Step) | Working |
| x | Followers / Following / Posts stats | Working |

### Issues found

None in own-profile view.

---

## Pet Profile (Visitor / Other User)

| | |
|---|---|
| **Route** | `/pet/:id` |
| **File** | `lib/views/pet_profile_screen.dart` |

### Available actions

| Done | Action | Result |
|:---:|:---|:---|
| x | Follow / Unfollow (filled amber vs grey) | Working |
| x | Message 뿯↽ opens / creates thread | Working |
| x | Share (icon-only circle) | Fixed |

### Issues fixed

- Message: `FilledButton.icon` + `secondaryContainer`.
- Share: icon-only circle with border (min touch target).

---

## Marketplace

| | |
|---|---|
| **Route** | MainLayout index 3 |
| **File** | `lib/views/marketplace_screen.dart` |

### Available actions

| Done | Action | Result |
|:---:|:---|:---|
| x | Product grid | Working |
| x | Add to cart | Working |
| x | Tap product 뿯↽ detail | Working |
| x | Cart icon + badge | Working |
| x | Search / filter | Working |

### Issues found

None observed.

---

## Settings

| | |
|---|---|
| **Route** | `/settings` |
| **File** | `lib/views/settings_screen.dart` |

### Available actions

| Done | Action | Result |
|:---:|:---|:---|
| x | Theme toggle (Light / Dark) | Working |
| x | Account profile block | Working |
| x | Notifications tile | Working |
| x | Liked pets tile | Working |
| x | Order history tile | Working |
| x | **Achievements & Badges** (per-pet rows, horizontal scroll) | Added |
| x | Tap badge 뿯↽ dialog (title, description, date, Share) | Working |
| x | Empty state when no badges | Working |
| x | Privacy Policy 뿯↽ URL | Working |
| x | Terms 뿯↽ URL | Working |
| x | Help & Support 뿯↽ email | Working |
| x | App version | Working |
| x | Sign out (confirm dialog) | Working |

### Issues fixed

- Achievements section with detail dialog + share.
- Deprecated `Share.share()` migrated to `SharePlus.instance.share(ShareParams(...))`.

---

## Notifications

| | |
|---|---|
| **Route** | `/notifications` |
| **File** | `lib/views/notifications_screen.dart` |

### Available actions

| Done | Action | Result |
|:---:|:---|:---|
| x | Notification list | Working |
| x | Mark as read | Working |
| x | Tap 뿯↽ target screen | Working |

### Issues found

None observed.

---

## Care resource screens

Navigated from Pet Care 뿯↽ Care Resources grid.

| Screen | Route | Status |
|:---|:---|:---:|
| Vet Booking | `/vet_booking` | OK |
| Emergency Care | `/emergency_care` | OK |
| Nutrition Planner | `/nutrition_planner` | OK |
| Expense Tracker | `/expenses` | OK |
| Growth Chart | `/growth_chart` | OK |
| Insurance Hub | `/insurance` | OK |
| Pet Training | `/training` | OK |
| Adoption Center | `/adoption` | OK |
| Pet-Friendly Places | `/places` | OK |
| Event Discovery | `/events` | OK |
| Health Record | `/health_record` | OK |
| Pet Sitter Dashboard | `/sitters` | OK |
| Social Timeline | `/social_timeline` | OK |
| Breed Identifier | `/breed_identifier` | OK |
| Knowledge Base | `/knowledge` | OK |
| Gear Reviews | `/reviews` | OK |
| Community Groups | `/groups` | OK |
| Lost & Found | `/lost_found` | OK |
| Memorial | `/memorial` | OK |

---

## Bottom navigation

| | |
|---|---|
| **File** | `lib/views/main_layout.dart` |

| Index | Icon | Screen | Status |
|:---:|:---|:---|:---:|
| 0 | Home | `HomeScreen` | OK |
| 1 | Search | `DiscoveryScreen` | OK |
| 2 | + | `PetCareScreen` (push) | OK |
| 3 | Store | `MarketplaceScreen` | OK |
| 4 | Person | `PetProfileScreen` | OK |

**Checks:** glass styling, `SafeArea`, semantics labels, profile avatar tab, `extendBody` + `bottomNavSpaceFor()`.

---

## Summary of all changes

### Bug fixes

1. Search: live `onChanged` search.
2. Search: `animal_type` instead of `species` in pets query.

### UI

3. Chat: attachment bottom sheet (Camera / Gallery / Document placeholders).
4. Chat: mic 뿯↽ send via `AnimatedSwitcher`.
5. Pet Care: single top pet selector for all tabs; removed duplicate in-tab selector.
6. Visitor profile: filled Message + icon Share.
7. Settings: Achievements & Badges block.

### Code quality

8. `SharePlus` API migration.
9. `flutter analyze`: **0 issues** (at audit time).

---

*Generated by PetSphere audit — May 3, 2026.*
