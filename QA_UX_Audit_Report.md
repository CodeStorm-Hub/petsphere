# PetSphere QA/UX Audit Report

**Audit Date:** 2026-05-02  
**Auditor:** Antigravity AI QA Engine  
**App Version:** Debug Build (Flutter)  
**Device:** PJB110 (OnePlus/OPPO Physical Device, Android)  
**Package:** com.example.pet_dating_app  
**Test Account:** afsanchowdhury25@gmail.com  

---

## Executive Summary

A comprehensive, screen-by-screen QA/UX audit of PetSphere was conducted on a physical Android device. The audit covered authentication flows, all primary navigation destinations, core user journeys (liking posts, shop add-to-cart, messaging), and accessibility. A total of **12 issues** were identified, including 1 critical content safety issue, 3 high-severity UX bugs, 5 medium-severity UX improvements, and 3 low-severity polish items.

---

## Severity Legend

| Severity | Description |
|----------|-------------|
| 🔴 Critical | Security/Safety risk or app-breaking bug |
| 🟠 High | Major UX friction blocking core user journeys |
| 🟡 Medium | Noticeable UX gap degrading user experience |
| 🟢 Low | Polish, consistency, or accessibility refinement |

---

## Phase 1: Authentication

### Screen: Login Screen

**Elements Identified:**
- Email Address text field
- Password text field (with show/hide toggle)
- Forgot Password link
- Sign In button (amber/terracotta)
- Google sign-in button
- Apple sign-in button
- "Don't have an account? Register" link

**Test Cases Executed:**

#### ✅ TC-01: Login with Valid Credentials
- Entered email: `afsanchowdhury25@gmail.com`
- Entered password: `callofduty100`
- Tapped "Sign In"
- **Result:** PASS — Navigated to Home Screen

#### ❌ TC-02: Email Field Input Truncation
- Entered email via `enter_text` MCP action
- **Result:** FAIL — Email field truncated the first 2 characters ("af" prefix lost). Only "sanchowdhury25@gmail.com" appeared.

#### ❌ TC-03: Keyboard Obscuring Sign In Button
- After typing in the password field, the soft keyboard covered the "Sign In" button
- **Result:** FAIL — User must manually dismiss the keyboard to tap Sign In

**Issues Found:**

| ID | Severity | Issue | Location |
|----|----------|-------|----------|
| BUG-001 | 🟠 High | Email `TextFormField` truncates first ~2 characters during programmatic input | Login Screen → Email field |
| BUG-002 | 🟠 High | Soft keyboard obscures the "Sign In" button; no auto-scroll or keyboard-aware layout | Login Screen → Scaffold |

**Proposed Fixes:**

**BUG-001:** Investigate if `autofocus` or a `controller.text = value` race condition is causing the truncation. Ensure that `TextEditingController` is initialized before `enter_text` is invoked. Consider adding a small delay before text entry.

**BUG-002:** In the Login `Scaffold`, add `resizeToAvoidBottomInset: true` (already likely set) and wrap the body in a `SingleChildScrollView`. Alternatively, use `Scaffold`'s `extendBodyBehindAppBar` and ensure the content scrolls above the keyboard. Also consider adding `ScrollController` or `ensureVisible` on the password field focus.

```dart
// Fix for Login Scaffold
Scaffold(
  resizeToAvoidBottomInset: true,
  body: SingleChildScrollView(
    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
    child: /* login form */,
  ),
)
```

---

## Phase 2: Home Screen (Social Feed)

**Screen:** Atelier Feed

**Elements Identified:**
- App bar: PetSphere paw logo + "Atelier" title
- Top-right action icons: Search, New Post, Notifications, Messages (badge)
- Stories row: "Your story" + other users' stories
- Feed card: Pet avatar with gradient ring, pet name, breed, verified badge, ⋯ menu
- Post image (tappable/gesture-detected)
- Action row: Like (heart), Comment (speech bubble), Share (paper plane), Bookmark
- Caption text with pet name + text, timestamp
- Bottom Nav: Home, Discovery, Create (+), Shop, Profile

**Test Cases Executed:**

#### ✅ TC-04: Feed Scroll Test
- Swiped up on feed
- **Result:** PASS — Feed scrolled smoothly, next post loaded

#### ✅ TC-05: Message Navigation
- Tapped Messages icon (with badge "2")
- **Result:** PASS — Navigated to Messages screen

#### ✅ TC-06: Post Like Action
- Tapped heart icon on feed post
- **Result:** PASS (partially) — Tap registered; like state updated

**Issues Found:**

| ID | Severity | Issue | Location |
|----|----------|-------|----------|
| BUG-003 | 🟡 Medium | Stories row shows only "Your story" item visible without any content loaded below; scrolling to reveal others not immediately discoverable | Home → Stories row |
| BUG-004 | 🟢 Low | Post action buttons (like, comment, share) have no semantic labels for screen readers | Home → Feed card actions |

---

## Phase 3: Discovery / Breeding Discovery Screen

**Screen:** Breeding Discovery

**Elements Identified:**
- "Breeding Discovery" header with Favorites and Add Listing icons
- Tab bar: Discover, Nearby, My Listings
- Category filter chips: For You, Dogs, Cats, Nearby (horizontally scrollable)

**Test Cases Executed:**

#### ⚠️ TC-07: Empty State — Discover Feed
- Navigated to Discovery tab
- **Result:** PARTIAL — Empty state displayed: "No more pets available. Check back soon!" with heart icon

**Issues Found:**

| ID | Severity | Issue | Location |
|----|----------|-------|----------|
| BUG-005 | 🟡 Medium | Empty state copy "No more pets available. Check back soon!" is ambiguous; doesn't clarify if no pets exist globally or the feed is exhausted | Discovery → Discover tab |
| BUG-006 | 🟢 Low | "Nearby" filter chip requires location permission; no prompt or graceful handling visible if permission is denied | Discovery → Nearby filter |

**Proposed Fixes:**

**BUG-005:** Update empty state copy to something like:
- "You're all caught up! No new pet listings right now." (if user has swiped all)
- OR "No listings in your area yet. Be the first!" (if location-based)

Add a CTA button: "Add Your Pet" to reduce dead-end experience.

---

## Phase 4: Pet Shop Screen

**Screen:** Pet Shop

**Elements Identified:**
- "Pet Shop" header with Search, Order History (receipt), and Cart icons
- Personalized greeting: "Welcome back, Afsan"
- Sub-headline: "Discover curated items for your companions"
- Member Exclusive promo banner (amber→green gradient)
- Category filter chips: All, Food, Toys, Accessories (scrollable)
- Product grid (staggered/masonry layout): image, name, price, "+" add-to-cart chip

**Test Cases Executed:**

#### ✅ TC-08: Product Navigation
- Tapped product name "Organic Puppy Kibble"
- **Result:** PASS — Navigated to Product Detail screen

#### ❌ TC-09: Add to Cart Feedback
- On Product Detail screen, tapped "Add to Cart" button
- **Result:** FAIL (UX) — Product added to cart (cart badge incremented to 1 after navigation), but NO in-context feedback (no snackbar, toast, or button state change) visible immediately after tap

#### ✅ TC-10: Product Detail Screen Integrity
- Verified product detail contains: image, category, name, rating, price, stock count, feature tags, description, total, "Add to Cart" button
- **Result:** PASS

#### ⚠️ TC-11: Product Image Card Tap
- Tapped on product image area in grid
- **Result:** PARTIAL — Tap on image area alone did not navigate; only tapping product name text navigated to detail

**Issues Found:**

| ID | Severity | Issue | Location |
|----|----------|-------|----------|
| BUG-007 | 🟠 High | "Add to Cart" provides zero in-context feedback (no snackbar/animation). User has no confirmation the action succeeded | Product Detail → Add to Cart |
| BUG-008 | 🟡 Medium | Product card tap zone is inconsistent — only text label triggers navigation, not entire card area | Shop → Product Grid |

**Proposed Fixes:**

**BUG-007:** Add a `ScaffoldMessenger.of(context).showSnackBar()` or use an animated cart icon bounce to confirm the item was added. The button text should also change to "Added ✓" for 2 seconds.

```dart
// After adding to cart:
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Row(children: [
      Icon(Icons.check_circle, color: Colors.white),
      SizedBox(width: 8),
      Text('Added to cart!'),
    ]),
    duration: Duration(seconds: 2),
    behavior: SnackBarBehavior.floating,
  ),
);
```

**BUG-008:** Wrap the entire product card in a `GestureDetector` or `InkWell` rather than only wrapping the text label. Ensure the `onTap` is applied to the `Card` widget parent.

---

## Phase 5: Messages Screen

**Screen:** Messages (Direct Messages)

**Elements Identified:**
- Back navigation
- "Messages" title
- List of conversations: avatar, contact name, last message preview, unread badge

**Test Cases Executed:**

#### ✅ TC-12: Message List Navigation
- Navigated to Messages from Home bar
- **Result:** PASS — 5 conversations displayed

#### ✅ TC-13: Chat Screen Navigation
- Tapped on "Sallu" conversation row
- **Result:** PASS — Navigated to Chat screen with "Sallu · ONLINE" header

#### ✅ TC-14: Chat Screen Interface
- Verified chat elements: back button, contact name, ONLINE status, three-dot menu, message bubbles, input field, send button
- **Result:** PASS

**Issues Found:**

| ID | Severity | Issue | Location |
|----|----------|-------|----------|
| BUG-009 | 🔴 Critical | Message preview in conversation list contains vulgar/inappropriate content from user "Montuu" visible without any content moderation or profanity filtering | Messages → List |
| BUG-010 | 🟡 Medium | Conversation row tap target inconsistency — `marionette.tap(text: 'Simba')` returned Server Error; coordinate-based tap was needed. List items may not have proper `ListTile` semantics | Messages → Conversation list |

**Proposed Fixes:**

**BUG-009 (CRITICAL):** Implement server-side content moderation for message previews. At minimum, apply a client-side profanity filter on message preview text in the `MessageTile` widget. Consider integrating a moderation API or Flutter `bad_words` package:

```dart
// In message list tile
String get safePreview => _profanityFilter.hasProfanity(lastMessage)
  ? '[Message removed]'
  : lastMessage;
```

For a production app, content moderation must happen at the Supabase Edge Function level before data reaches the client.

**BUG-010:** Ensure each conversation `ListTile` has proper semantic label and is wrapped with a single tappable `InkWell` or `ListTile.onTap`.

---

## Phase 6: Profile / My Account Screen

**Screen:** My Account

**Elements Identified:**
- Back arrow / Sign Out (door-arrow icon) / Settings (gear icon) in header
- Profile photo with "+" badge overlay
- Stats row: posts, followers, following
- Display name, email, location, bio text
- "Edit profile" and "Share profile" buttons
- "Care badges" section with gamified badges
- Pet filter tabs: All, Fluffy 1, Fluffy bain
- Posts grid (photo album, 3-column)

**Test Cases Executed:**

#### ✅ TC-15: Profile Screen Load
- Navigated via bottom nav profile tab
- **Result:** PASS — Profile loaded with all user data

#### ✅ TC-16: Sign Out Flow
- Tapped "Sign Out" icon (header)
- **Result:** PASS — Confirmation dialog appeared with "Are you sure you want to sign out?" + Cancel + Sign Out buttons

#### ✅ TC-17: Sign Out Confirmation Dialog — Cancel
- Tapped "Cancel"
- **Result:** PASS — Dialog dismissed; remained on profile screen

#### ✅ TC-18: Pet Filter Tabs
- Tapped "Fluffy 1" and "Fluffy bain" pet filter chips
- **Result:** PASS — Filter chips are functional

**Issues Found:**

| ID | Severity | Issue | Location |
|----|----------|-------|----------|
| BUG-011 | 🟡 Medium | Profile header "logout" icon is ambiguous — a door-arrow icon with no tooltip visible to users who don't hover; first-time users may not recognize it as Sign Out | Profile → Header |
| BUG-012 | 🟢 Low | "0 followers / 0 following" stats are non-tappable. Standard social app pattern is to navigate to followers/following lists on tap | Profile → Stats row |

**Proposed Fixes:**

**BUG-011:** Add a clear Tooltip or change the Sign Out icon to use a more universally recognized icon with text label ("Sign Out" adjacent or inside a dropdown menu). Alternatively, move logout into the Settings screen accessible via the gear icon.

**BUG-012:** Wrap the followers and following stat columns in `GestureDetector` and route to follower/following list screens.

---

## Phase 7: Pet Care Screen

**Screen:** Pet Care (Care Diary / Health / Feeding)

**Elements Identified:**
- **Tab Bar**: Care Diary, Health, Feeding
- **Care Diary**: Stats cards (Care points, 30-day path), Weekly Mon-Sun grid, Today's Overview (Task/Calorie/Water rings), Edit Goals link.
- **Feeding Tab**: Meal tracking (Breakfast/Lunch/Dinner toggles), "Adjust Nutrition Goals" button.
- **Goal Editor (Nutrition)**: Sliders for Daily Calories (kcal), Daily Water (ml), Daily Exercise (min).
- **Health Tab**: Health Status (Good), Last Checkup, Next Vaccine, Weight history graph.

**Test Cases Executed:**

#### ✅ TC-19: Pet Care Screen Load
- Navigated via bottom nav (central "+" button)
- **Result:** PASS — Care Diary tab loaded successfully.

#### ✅ TC-20: Weekly Progress Tracker
- Observed Mon–Sun grid highlighting Sat in amber.
- **Result:** PASS — Visual design is clear and encouraging.

#### ✅ TC-21: Feeding Tab Interactions
- Toggled "Breakfast" for "Fluffy 1".
- **Result:** PASS — Progress ring in Dashboard updated immediately.

#### ✅ TC-22: Nutrition Goal Editor
- Tapped "Adjust Nutrition Goals".
- Adjusted Water Goal to 6000ml (Extreme for a cat).
- **Result:** PASS — System triggered a warning snackbar: "Wait, check again! 6000ml is very high for a cat." preventing dangerous overrides.

#### ❌ TC-23: Goal Editor Slider Sensitivity
- Attempted to slide "Calories" precisely to 450kcal.
- **Result:** FAIL (UX) — Slider thumb is very small and sensitive; hard to hit exact numbers on small screens.

**Issues Found:**

| ID | Severity | Issue | Location |
|----|----------|-------|----------|
| BUG-013 | 🟡 Medium | Goal Editor sliders are too sensitive; lacking "+" / "-" buttons for precise adjustments | Pet Care → Goal Editor |
| BUG-014 | 🟢 Low | "Edit Goals" link in Care Diary uses small text; target area is difficult to tap | Pet Care → Care Diary |

---

## Phase 8: Social & Messages Deep Dive

**Screen:** Messages / User Chat

**Test Cases Executed:**

#### ✅ TC-24: Message Notification Badge
- Tapped on top-right notification/inbox icon.
- **Result:** PASS — Navigated to Messages list.

#### ❌ TC-25: Navigation from Chat Header
- Tapped "Simba" header in chat screen to view their profile.
- **Result:** FAIL — Tap did not register or action not implemented.

**Issues Found:**

| ID | Severity | Issue | Location |
|----|----------|-------|----------|
| BUG-015 | 🟡 Medium | Chat header is not tappable to view user profile | Chat Screen → Header |

---

## Positive UX Highlights

These are design choices that work particularly well:

| Feature | Observation |
|---------|-------------|
| **Dark Theme** | Consistent, premium dark theme with amber/terracotta accents throughout |
| **Pet Verification Badges** | Blue verified checkmark on pet profiles adds credibility |
| **Sign Out Confirmation** | Confirmation dialog prevents accidental logout — good destructive action protection |
| **Care Gamification** | Care points, 30-day path, and daily streaks are engaging wellness mechanics |
| **Shop Personalization** | "Welcome back, Afsan" greeting and curated items feel personalized |
| **Product Detail Richness** | BESTSELLER tag, rating, stock count, and feature chips provide excellent purchase context |
| **Member Exclusive Banner** | Amber-to-green gradient promo banner is visually distinct and drives engagement |
| **Message Read Badges** | Unread count badge on messages is prominent and clear |

---

## Consolidated Bug Table

| ID | Severity | Screen | Issue | Priority |
|----|----------|--------|-------|----------|
| BUG-001 | 🟠 High | Login | Email field truncates first ~2 characters | Sprint 1 |
| BUG-002 | 🟠 High | Login | Soft keyboard obscures Sign In button | Sprint 1 |
| BUG-007 | 🟠 High | Shop | No feedback after "Add to Cart" tap | Sprint 1 |
| BUG-009 | 🔴 Critical | Messages | Inappropriate content visible in message previews — no content moderation | Immediate |
| BUG-003 | 🟡 Medium | Home | Stories row not discoverable | Sprint 2 |
| BUG-005 | 🟡 Medium | Discovery | Ambiguous empty state copy | Sprint 2 |
| BUG-008 | 🟡 Medium | Shop | Product card tap zone only works on text, not entire card | Sprint 2 |
| BUG-010 | 🟡 Medium | Messages | Conversation tap-target inconsistency / missing semantics | Sprint 2 |
| BUG-011 | 🟡 Medium | Profile | Sign Out icon is ambiguous (no label) | Sprint 2 |
| BUG-013 | 🟡 Medium | Pet Care | Goal Editor sliders too sensitive; missing +/- buttons | Sprint 2 |
| BUG-015 | 🟡 Medium | Messages | Chat header not tappable to view user profile | Sprint 2 |
| BUG-004 | 🟢 Low | Home | Post action buttons missing semantic labels (accessibility) | Sprint 3 |
| BUG-006 | 🟢 Low | Discovery | Location permission edge case not handled gracefully | Sprint 3 |
| BUG-012 | 🟢 Low | Profile | Followers/Following stats not tappable (non-standard for social apps) | Sprint 3 |
| BUG-014 | 🟢 Low | Pet Care | "Edit Goals" link has small hit-box | Sprint 3 |

---

## Accessibility Audit Summary

| Area | Status | Notes |
|------|--------|-------|
| Screen reader support (TalkBack) | ⚠️ Partial | Post action buttons, nav icons lack semantic labels |
| Touch target sizes (≥48dp) | ✅ Pass | Most buttons meet M3 48dp minimum |
| Color contrast | ✅ Pass | Amber on dark background passes WCAG AA |
| Focus traversal order | ⚠️ Partial | Bottom nav uses GestureDetector which may not announce correctly |
| Content descriptions | ⚠️ Partial | Profile images and pet photos lack `semanticsLabel` |

---

## Recommended Accessibility Fixes

```dart
// Add Semantics to post action buttons
Semantics(
  label: 'Like post by Fluffy 1',
  button: true,
  child: GestureDetector(
    onTap: onLike,
    child: Icon(Icons.favorite_border),
  ),
)

// Add semanticsLabel to NetworkImage widgets
Image.network(
  url,
  semanticLabel: 'Profile photo of ${pet.name}',
)
```

---

## Next Steps

1. **Implement BUG-009 fix immediately** — Content moderation is a legal and safety risk
2. **Sprint 1** — Fix BUG-001 (email truncation), BUG-002 (keyboard overlay), BUG-007 (cart feedback)
3. **Sprint 2** — Improve tap targets, slider precision, and chat navigation
4. **Sprint 3** — Accessibility pass and polish small hit-boxes
5. **Write Integration Tests** — See `test_driver/app_test.dart` for automated user journey tests

---

*Report generated by Antigravity AI QA Engine • PetSphere Audit 2026-05-02*
