# PetSphere UI/UX Redesign & Audit Report

**Date**: May 1, 2026  
**Project**: PetSphere Flutter App (Mobile-First iOS/Android → Web)  
**Scope**: Complete UI/UX redesign covering visual consistency, user experience, feature completeness, and cross-platform optimization

---

## EXECUTIVE SUMMARY

PetSphere is a comprehensive pet social and marketplace platform with solid architecture but requires significant UI/UX improvements to:
- Establish a cohesive, modern design system aligned with Material Design 3
- Streamline user flows and information architecture
- Complete missing features and screens
- Optimize for mobile-first responsive design across iOS, Android, and Web

**Key Findings**: 18 screens documented, 8-10 screens missing, design inconsistencies throughout, opportunity for gamification integration, and marketplace/social features underdeveloped in UI.

---

## PART 1: CURRENT STATE ASSESSMENT

### 1.1 Current Design System

**Theme**: "Amber Whisker (PawSync)" — warm, pet-friendly palette
- **Primary**: `#D4845A` (warm amber)
- **Secondary**: `#4A7C59` (sage green)  
- **Background**: `#0F0E0C` (near-black)
- **Surface**: `#1A1814` (dark charcoal)
- **Text Primary**: `#F2EDE4` (off-white)
- **Text Secondary**: `#B8B0A4` (warm gray)

**Typography**:
- **Headlines**: Playfair Display (serif, premium feel)
- **Body/UI**: DM Sans (sans-serif, clean)

**Issues Identified**:
- ❌ No consistent component specifications (buttons, cards, inputs, dialogs)
- ❌ Missing design tokens for spacing, shadows, borders, radius
- ❌ No Material Design 3 integration despite Flutter 3.x
- ❌ Limited accessibility considerations in documented theme
- ❌ No dark/light mode strategy defined
- ❌ Color palette lacks secondary/tertiary variants for differentiation

### 1.2 Current Screens (18 documented)

**Authentication Flow**:
1. ✅ `splash_screen.dart` — App initialization
2. ✅ `login_screen.dart` — User authentication

**Main Navigation**:
3. ✅ `home_screen.dart` — Feed and pet showcase
4. ✅ `discovery_screen.dart` — Browse other pets
5. ✅ `marketplace_screen.dart` — Product browsing
6. ✅ `chat_screen.dart` — Messaging interface
7. ✅ `notifications_screen.dart` — Notification center

**Pet Management**:
8. ✅ `add_pet_screen.dart` — Create/edit pet profile
9. ✅ `health_tab.dart` — Health metrics and care tracking
10. ✅ `pet_care_controller.dart` (embedded) — Care logs

**Social Features**:
11. ✅ `create_post_screen.dart` — Post creation
12. ✅ `create_story_screen.dart` — Story creation
13. ✅ `post_detail_screen.dart` — Post view with comments
14. ✅ `liked_pets_screen.dart` — Favorites/liked pets

**Matching/Dating**:
15. ✅ `match_pet_profile_screen.dart` — Detailed pet profile with actions

**Messages**:
16. ✅ `messages_list_screen.dart` — Message threads list

**Marketplace**:
17. ✅ `product_detail_screen.dart` — Product details and purchase
18. ✅ `cart_screen.dart` — Shopping cart and checkout

**Layout**:
19. ✅ `main_layout.dart` — Bottom navigation container

### 1.3 Missing Screens & Features

**Critical Missing Screens**:
1. ❌ **Onboarding Flow** (multi-screen) — User registration, pet setup, permissions
2. ❌ **Profile Management** — User profile settings, avatar, bio, preferences
3. ❌ **Pet Profile Detail Screen** — Public-facing pet profile (not just matching)
4. ❌ **Search & Filters** — Comprehensive search with advanced filters
5. ❌ **Gamification Dashboard** — Badge/achievement showcase, leaderboards
6. ❌ **Care Goals & Plans** — Pet care goal setting and tracking UI
7. ❌ **Community/Groups** — Pet interest groups, forums, discussions
8. ❌ **Settings & Preferences** — App settings, privacy, notifications
9. ❌ **Account Security** — Password change, two-factor auth, login history
10. ❌ **Order History & Tracking** — Purchase history, order tracking, returns

### 1.4 Existing Screen Issues

**Home Screen (`home_screen.dart`)**
- ❌ No clear visual hierarchy between feed content types (posts vs. stories vs. pet cards)
- ❌ Missing skeleton loaders for perceived performance
- ❌ Unclear CTA (call-to-action) for new user engagement
- ❌ No "create" floating button for quick post/story access
- ❌ Missing infinite scroll implementation

**Discovery Screen (`discovery_screen.dart`)**
- ❌ No filter UI for pet breed, age, size, location
- ❌ Missing swipe gesture support for card-based matching (Tinder-like)
- ❌ No saved/liked indicator on cards
- ❌ Unclear match request flow

**Pet Profile Add Screen (`add_pet_screen.dart`)**
- ❌ Likely too cramped for form-heavy content
- ❌ Missing multi-step stepper UI
- ❌ No image gallery/carousel for multiple pet photos
- ❌ Unclear required vs. optional fields

**Health Tab (`health_tab.dart`)**
- ❌ Documented as "large, complex screen" — likely overwhelming
- ❌ No chart/graph visualizations for health trends
- ❌ Missing goal-setting UI
- ❌ No quick-log functionality for vitals

**Marketplace (`marketplace_screen.dart`)**
- ❌ No category navigation (tabs or sidebar)
- ❌ Missing search/filter bar
- ❌ No wishlist/save for later
- ❌ Unclear product card design

**Chat Screen (`chat_screen.dart`)**
- ❌ No visible message status (sent/delivered/read)
- ❌ Missing typing indicators
- ❌ No media sharing UI
- ❌ Unclear group chat support

---

## PART 2: IDENTIFIED ISSUES & PAIN POINTS

### 2.1 Visual & Design Issues

| Issue | Severity | Impact |
|-------|----------|--------|
| No Material Design 3 integration | High | Behind modern Flutter standards, inconsistent with platform conventions |
| Inconsistent spacing/padding | High | Unprofessional, harder to maintain |
| No comprehensive component library | High | Inconsistent UI across screens |
| Limited accessibility (A11y) | High | Excludes users with disabilities |
| No responsive design tokens | High | Web/tablet views likely broken or unoptimized |
| Color palette lacks variants | Medium | Limited visual differentiation for states |
| Typography underutilized | Medium | Weak visual hierarchy |

### 2.2 User Experience Issues

| Issue | Severity | Impact |
|-------|----------|--------|
| No onboarding flow | Critical | New users confused about app purpose/features |
| Unclear information architecture | High | Users unsure where to find features |
| No search functionality | High | Discovery frustration, reduced engagement |
| Missing empty states | High | Confusing when no data present |
| No loading/skeleton states | High | Perceived sluggishness, poor perceived performance |
| Unclear CTAs | Medium | Users miss engagement opportunities |
| No error handling UI | Medium | Silent failures, user confusion |

### 2.3 Feature Gaps

| Feature | Status | Impact |
|---------|--------|--------|
| Onboarding (multi-step) | Missing | User retention risk |
| User profile management | Missing | Users can't customize presence |
| Pet care goals & tracking | Partial | Core feature incomplete |
| Gamification (badges, leaderboards) | Partial | Reduced engagement/habit formation |
| Search & advanced filters | Missing | Discoverability issue |
| Community/forums | Missing | Limited social engagement |
| Settings & preferences | Missing | User autonomy limited |
| Order management | Missing | Marketplace support incomplete |
| Social features (comments, shares, DMs) | Partial | Limited social binding |

### 2.4 Cross-Platform Issues

| Issue | Severity |
|-------|----------|
| No responsive breakpoints defined | High |
| No tablet layout considerations | High |
| Web navigation untested | High |
| No touch target optimization (mobile) | Medium |
| No landscape orientation support | Medium |

---

## PART 3: DESIGN SYSTEM RECOMMENDATIONS

### 3.1 Modern Material Design 3 Integration

**Implementation**:
```dart
// lib/theme/app_theme.dart
ThemeData buildLightTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: Color(0xFFD4845A), // Primary amber
    brightness: Brightness.light,
  );
  
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    typography: Typography.material2021(),
    // ... surface tint, elevation, component themes
  );
}
```

**Color System**:
- **Primary**: `#D4845A` (Warm Amber) — CTAs, highlights
- **Primary Container**: `#FFDCC4` (Light Amber) — Subtle backgrounds
- **Secondary**: `#4A7C59` (Sage Green) — Secondary CTAs, accents
- **Secondary Container**: `#C8EFD5` (Light Sage) — Secondary backgrounds
- **Tertiary**: `#8B5A7D` (Warm Mauve) — Tertiary accents, badges
- **Error**: `#D32F2F` (Alert Red) — Errors, destructive actions
- **Neutral**: Grayscale from `#0F0E0C` to `#F2EDE4`

**Spacing System** (8px base):
- `xs`: 4px, `sm`: 8px, `md`: 16px, `lg`: 24px, `xl`: 32px, `xxl`: 48px

**Typography Scale**:
- **Display Large/Medium/Small** (Playfair Display) — Hero sections, titles
- **Headline Large/Medium/Small** (Playfair Display) — Section headers
- **Title Large/Medium/Small** (DM Sans Bold) — Card titles, labels
- **Body Large/Medium/Small** (DM Sans Regular) — Content, descriptions
- **Label Large/Medium/Small** (DM Sans Medium) — Buttons, chips

### 3.2 Component Library

**Core Components to Standardize**:

1. **Buttons**
   - Primary (filled) — Main actions
   - Secondary (outlined) — Alternative actions
   - Tertiary (text) — Low priority
   - States: Default, Hover, Pressed, Disabled, Loading

2. **Input Fields**
   - Text, Email, Password, Number, Phone
   - Variants: Outlined, Filled
   - States: Enabled, Focused, Error, Disabled
   - Indicators: Hint text, error message, character count

3. **Cards**
   - Standard card with elevation
   - Pet card (avatar, name, breed, quick stats)
   - Product card (image, title, price, rating)
   - Post card (content, engagement metrics)
   - Story card (overlay image with user info)

4. **Navigation**
   - Bottom Navigation Bar (5-6 items max)
   - Chips for filtering
   - Breadcrumbs for deep navigation
   - Tabs for content switching

5. **Dialog/Bottom Sheet**
   - Confirmation dialogs
   - Input forms
   - Options menus
   - Image pickers

6. **Lists**
   - List tiles with avatars
   - Dividers and separators
   - Swipe actions (delete, edit)
   - Load more / pagination

7. **Feedback**
   - Snackbars (error, success, info)
   - Loading spinners and skeleton loaders
   - Progress indicators
   - Empty states with illustrations

8. **Data Display**
   - Charts (line, bar) for health metrics
   - Badge/chips for tags and achievements
   - Counters and metrics
   - Rating stars

### 3.3 Accessibility Standards

- **WCAG 2.1 AA compliance** minimum
- **Touch targets**: 48dp minimum (44dp acceptable)
- **Color contrast**: 4.5:1 for text, 3:1 for graphics
- **Typography**: No text below 12sp, max line length 80 chars
- **Keyboard navigation**: All interactive elements keyboard accessible
- **Screen readers**: Semantic labels, meaningful announcements
- **Focus indicators**: Visible, high contrast

---

## PART 4: MISSING SCREENS DESIGN SPECIFICATIONS

### 4.1 Onboarding Flow (5 Screens)

**Screen 1: Welcome/Value Prop**
- Hero image (animated illustration of pets together)
- App name and tagline
- Brief value proposition
- "Get Started" button
- "I already have an account" link

**Screen 2: Sign Up Form**
- Email/username field
- Password field (strength indicator)
- Confirm password
- Terms & privacy checkbox
- Sign up button
- Sign in link

**Screen 3: Create Your Pet Profile (Multi-step)**
- Pet name (required)
- Pet type (dog, cat, bird, etc.)
- Breed (dropdown + search)
- Age (date picker)
- Upload pet photo (gallery + camera)
- "Next" button

**Screen 4: Tell Us More**
- Pet size (small/medium/large)
- Pet personality traits (chips)
- Looking for (match preferences)
- Location (permission request)
- "Next" button

**Screen 5: Enable Notifications & Review**
- Notification opt-in (push, email)
- Location services opt-in
- Summary of profile created
- "Start Exploring" button

### 4.2 User Profile Management Screen

**Structure**:
- Header: Avatar, username, pet count
- Edit Profile section:
  - Avatar (with upload)
  - Name, bio, location
  - Email, phone
  - Date of birth (optional)
- Pet Collection:
  - List of user's pets with quick edit/delete
  - "Add Pet" button
- Social Stats:
  - Followers/following count
  - Badges achieved
  - Match count
- Account Settings link
- Log out button

### 4.3 Search & Filters Screen

**Layout**:
- Search bar (prominent, sticky)
- Active filters (horizontal scrollable chips)
- Filter panel (collapsible or modal):
  - Pet type (checkboxes)
  - Breed (searchable dropdown)
  - Age range (slider)
  - Size (radio buttons)
  - Location radius (slider + unit)
  - Personality traits (multi-select)
  - Adoption status (if applicable)
- Results grid/list
- Infinite scroll with "load more"

### 4.4 Pet Care Goals & Tracking

**Goal-Setting Screen**:
- Create Goal button (FAB)
- Goal templates (exercise, training, grooming, health)
- Modal form:
  - Goal name
  - Description
  - Goal type (from templates)
  - Target (e.g., 30 min walk daily)
  - Duration/Frequency
  - Remind me (toggle + frequency)
  - Add button

**Goals Dashboard**:
- Active goals section (cards showing progress)
- Completed goals (archived)
- Progress ring/bar
- Quick log button per goal
- Weekly stats overview

### 4.5 Gamification Dashboard

**Layout**:
- Header: User's total points, current level
- Achievement Badges Grid:
  - Locked/unlocked state
  - Badge icon
  - Title
  - Description
  - Progress (if in-progress)
- Leaderboard section:
  - User's rank
  - Top 3 users
  - "View full leaderboard" link
- Recent activities (timeline):
  - "Earned badge X"
  - "Reached level Y"
  - Timestamps

### 4.6 Community/Forum Feature

**Forum List Screen**:
- Category tabs (breed-specific, health, training, fun, etc.)
- Search bar
- Thread list:
  - Thread title
  - Category badge
  - Author avatar + name
  - Last activity timestamp
  - Reply count
  - Pinned indicator (if applicable)
- Infinite scroll

**Thread Detail Screen**:
- Thread title and info (author, created date)
- Posts list with replies
- Post structure:
  - Author avatar, name, verified badge
  - Post content with images
  - Likes/replies count
  - Timestamp
  - Reply button
- Reply compose box (bottom sticky)

### 4.7 Settings & Preferences Screen

**Structure**:
- Account Settings section:
  - Email address (edit)
  - Password change link
  - Two-factor auth toggle
  - Login activity link
- App Preferences:
  - Notifications toggle (with sub-toggles: push, email, SMS)
  - Language selection
  - Theme (light/dark/auto)
  - Font size
- Privacy & Data:
  - Privacy policy link
  - Terms of service link
  - Download my data button
  - Delete account button (dangerous zone)
- About:
  - App version
  - Feedback link
  - Contact support link

### 4.8 Order History & Management

**Order List Screen**:
- Filter tabs: All, Pending, Delivered, Cancelled
- Order cards:
  - Order ID
  - Date
  - Item count
  - Total price
  - Status badge
  - View/Track button
- Infinite scroll

**Order Detail Screen**:
- Order header (ID, date, status)
- Items list:
  - Product image
  - Product name
  - Quantity
  - Price
  - Return/review button
- Shipping info:
  - Address
  - Tracking number (if shipped)
  - Estimated delivery date
- Interaction buttons:
  - Track shipment
  - Contact seller
  - Review/rate
  - Return item

---

## PART 5: SCREEN REDESIGNS (Current Issues & Solutions)

### 5.1 Home Screen Redesign

**Current Issues**:
- No visual hierarchy between content types
- Missing skeleton loaders
- Unclear CTAs
- No floating action button for quick post creation

**Redesigned Structure**:
```
┌─────────────────┐
│  Header/AppBar  │  (with profile avatar, notification bell)
├─────────────────┤
│   Story Ring    │  (horizontal scrollable stories with + button for user)
├─────────────────┤
│  Filter Chips   │  (Following, All Posts, Friends Only) — sticky
├─────────────────┤
│  Feed Content   │
│  ├─ Post Card  │  (pet avatar, name, post content, engagement metrics)
│  ├─ Story Card │  (large image overlay with user info)
│  └─ Pet Card   │  (quick pet profile with action buttons)
├─────────────────┤
│  Load More      │  (infinite scroll or explicit button)
├─────────────────┤
│  Bottom Nav     │
└─────────────────┘

FAB (Floating Action Button): "+" for quick post/story creation
```

**Key Improvements**:
- Story ring at top (Instagram-like pattern, familiar)
- Filter chips for content type switching
- Skeleton loaders while fetching
- Clear spacing between content types
- Engagement metrics prominently displayed
- FAB for quick content creation

### 5.2 Discovery/Matching Screen Redesign

**Current Issues**:
- No filter UI
- No swipe gestures
- No saved indicator
- Unclear match flow

**Redesigned Structure**:
```
┌─────────────────┐
│  Header         │  (with filter icon)
├─────────────────┤
│  Pet Card       │  (Large, swipeable)
│  ┌───────────┐  │
│  │  Photo    │  │
│  │  Gallery  │  │  (Multiple photos, swipeable within card)
│  └───────────┘  │
│  Name, Breed    │
│  Age, Size      │
│  Bio/Traits     │
├─────────────────┤
│  Action Buttons │  (Pass left, Favorite heart, Match right)
├─────────────────┤
│  Bottom Nav     │
└─────────────────┘

Filter Panel (Accessible via top-right icon):
- Pet type, breed, age, size, location
```

**Key Improvements**:
- Swipe gestures (left: pass, right: match, up: favorite) — Tinder-like
- Large, prominent pet photos
- Quick info display
- Filter panel easily accessible
- Clear call-to-actions for matching

### 5.3 Pet Profile Management Redesign

**Current Issues**:
- Form-heavy, likely overwhelming
- Missing multi-step stepper
- No image gallery
- Unclear required fields

**Redesigned Structure (Multi-Step)**:
```
Step 1: Basic Info
├─ Pet name (required)
├─ Pet type (radio)
├─ Breed (searchable dropdown)
└─ Date of birth (required)

Step 2: Appearance
├─ Size (radio)
├─ Color/Markings
└─ Photo gallery (up to 5 photos)

Step 3: Personality
├─ Personality traits (chips)
├─ Energy level (slider)
└─ Bio/About (text area)

Step 4: Preferences
├─ Looking for (checkboxes)
├─ Health notes (text)
└─ Special needs (toggle + details)

Step 5: Review & Submit
├─ Summary of all info
├─ Edit links
└─ Submit button
```

**Key Improvements**:
- Multi-step process (not overwhelming)
- Progress indicator (stepper)
- Photo gallery for multiple images
- Clear field labels and requirements
- Form validation and error messaging

### 5.4 Health Tab/Screen Redesign

**Current Issues**:
- "Large, complex screen" — too much content
- No visualizations
- Missing goal-setting UI
- No quick-log functionality

**Redesigned Structure (Tabbed)**:
```
┌─────────────────┐
│  Header         │  (Pet name, age)
├─────────────────┤
│  Tabs           │  (Overview, Vitals, Medications, Goals, History)
├─────────────────┤

OVERVIEW Tab:
├─ Quick Stats Cards:
│  ├─ Weight (trend indicator: ↑/↓)
│  ├─ Last Vet Visit
│  ├─ Medications Due
│  └─ Next Appointment
├─ Recent Activities:
│  ├─ Timeline of recent logs
│  └─ "Log New Activity" button (FAB)
└─ Health Score (circular progress)

VITALS Tab:
├─ Vital Charts (last 30 days):
│  ├─ Temperature (line chart)
│  ├─ Heart Rate (line chart)
│  └─ Weight (bar chart)
├─ Vital Entry Cards:
│  ├─ Quick log buttons
│  └─ Manual entry form
└─ Export/Share button

MEDICATIONS Tab:
├─ Active Medications:
│  ├─ Med name, dosage, frequency
│  ├─ Next dose reminder
│  └─ Edit/Remove buttons
├─ Add Medication button
└─ Refill Schedule

GOALS Tab:
├─ Active Care Goals:
│  ├─ Goal card with progress ring
│  ├─ Completion percentage
│  └─ Quick log button
├─ Completed Goals:
│  └─ Archived section
└─ Add New Goal button

HISTORY Tab:
├─ Chronological logs:
│  ├─ Vet visit notes
│  ├─ Medication history
│  ├─ Vitals history
│  └─ Care activity logs
└─ Filter by date range
```

**Key Improvements**:
- Tabbed interface (breaks into manageable chunks)
- Visualizations (charts for trends)
- Quick-log functionality (FAB with fast entry)
- Goal tracking integrated
- Timeline view for history
- Health score overview

### 5.5 Marketplace Redesign

**Current Issues**:
- No category navigation
- Missing search/filter bar
- No wishlist
- Unclear product cards

**Redesigned Structure**:
```
┌─────────────────┐
│  Search Bar     │  (sticky, with filter icon)
├─────────────────┤
│  Category Tabs  │  (Toys, Food, Health, Accessories, Clothing)
├─────────────────┤
│  Filter Chips   │  (Price, Rating, In Stock, Deals)
├─────────────────┤
│  Product Grid   │
│  ┌───────────┐  │
│  │  Image    │  │
│  │  Gallery  │  │
│  ├───────────┤  │
│  │ Name      │  │
│  │ Rating ★  │  │
│  │ Price     │  │
│  │ [Add Cart]│  │
│  └───────────┘  │
├─────────────────┤
│  Load More      │
├─────────────────┤
│  Bottom Nav     │
└─────────────────┘

Filter Panel (Modal):
├─ Price range (slider)
├─ Category (checkboxes)
├─ Rating (stars)
├─ Availability (checkbox)
├─ Pet type (chips)
└─ Reset / Apply buttons
```

**Key Improvements**:
- Search + filter integration
- Category tabs for easy navigation
- Product cards with ratings and clear pricing
- Shopping cart badge on bottom nav
- Wishlist heart icon on product cards
- Advanced filters accessible via modal

### 5.6 Chat Screen Redesign

**Current Issues**:
- No message status indicators
- Missing typing indicators
- No media sharing UI
- Unclear group chat support

**Redesigned Structure**:
```
┌─────────────────┐
│  Header         │  (Pet name, online status, voice/video call icons)
├─────────────────┤
│  Messages List  │
│  ┌───────────┐  │
│  │ Your msg  │  │  (Right aligned, filled bg)
│  │ [✓✓]      │  │  (Read receipt indicator)
│  └───────────┘  │
│  ┌───────────┐  │
│  │ Their msg │  │  (Left aligned, subtle bg)
│  └───────────┘  │
│  Typing...      │  (Typing indicator)
├─────────────────┤
│  Message Input  │
│  ├─ Emoji picker icon
│  ├─ Message text field
│  ├─ Media/attachment button
│  └─ Send button
└─────────────────┘
```

**Key Improvements**:
- Message read receipts (✓ sent, ✓✓ delivered)
- Typing indicators ("User is typing...")
- Media sharing button (images, documents)
- Emoji picker
- Timestamp on messages
- Support for group chats (visible in header)

---

## PART 6: CROSS-PLATFORM STRATEGY

### 6.1 Responsive Breakpoints

```dart
class ResponsiveBreakpoints {
  // Mobile-first approach
  static const mobile = 320;      // iPhone SE minimum
  static const mobileLarge = 480; // Large phone
  static const tablet = 768;      // iPad mini/standard
  static const desktop = 1024;    // iPad Pro/desktop
  static const widescreen = 1400; // Large desktop
}

// MediaQuery helper
bool isMobile(BuildContext context) => 
  MediaQuery.of(context).size.width < 768;
bool isTablet(BuildContext context) => 
  MediaQuery.of(context).size.width >= 768 && 
  MediaQuery.of(context).size.width < 1024;
bool isDesktop(BuildContext context) => 
  MediaQuery.of(context).size.width >= 1024;
```

### 6.2 Layout Adaptations by Platform

**Mobile (320-767px)**
- Single-column layout
- Bottom navigation for main nav
- Full-width cards and lists
- Stacked forms
- Modal/bottom sheet dialogs
- Touch-friendly spacing (48dp min)

**Tablet (768-1023px)**
- Two-column layout for some screens
- Sidebar navigation (collapsible)
- Grid layouts (2 columns)
- Split-pane detail views
- Slightly increased spacing
- Larger touch targets (56dp)

**Desktop (1024px+)**
- Three-column layout option
- Persistent sidebar
- Grid layouts (3+ columns)
- Master-detail split screens
- Standard desktop navigation (top bar + sidebar)
- Mouse-friendly spacing

**Web-Specific Considerations**:
- Keyboard navigation throughout
- Copy/paste interactions
- Right-click context menus
- Hover states on all interactive elements
- Responsive images with srcset
- Lazy loading for images/content

### 6.3 Platform-Specific Patterns

| Feature | iOS | Android | Web |
|---------|-----|---------|-----|
| Navigation | Tab bar (bottom) | Bottom nav / Drawer | Sidebar + Top bar |
| Gesture | Swipe back | Hardware back button | Browser back |
| Dialogs | Modal sheets | Centered dialog | Modal overlay |
| Inputs | Native pickers | Material inputs | Web inputs |
| Icons | SF Symbols or custom | Material Icons | Custom SVGs |
| FAB | Floating button (bottom-right) | Floating button (bottom-right) | Button in toolbar |

---

## PART 7: IMPLEMENTATION ROADMAP

### Phase 1: Foundation (Weeks 1-2)
- [ ] Implement Material Design 3 theme system
- [ ] Create comprehensive component library (buttons, cards, inputs, etc.)
- [ ] Set up responsive breakpoint helpers
- [ ] Establish design tokens (spacing, colors, typography)
- [ ] Update theme files and add to shared theme system

### Phase 2: Missing Critical Screens (Weeks 3-4)
- [ ] Onboarding flow (5 screens)
- [ ] User profile management screen
- [ ] Settings & preferences screen
- [ ] Search & filters screen

### Phase 3: Redesign Existing Screens (Weeks 5-7)
- [ ] Redesign home screen with improved hierarchy
- [ ] Redesign discovery screen with swipe gestures
- [ ] Redesign pet profile management (multi-step)
- [ ] Redesign health tab (tabbed interface)
- [ ] Redesign marketplace (search + category nav)
- [ ] Redesign chat screen (status indicators)

### Phase 4: Advanced Features (Weeks 8-9)
- [ ] Gamification dashboard
- [ ] Community/forum screens
- [ ] Care goals & tracking UI
- [ ] Order history and management screens

### Phase 5: Polish & Optimization (Week 10)
- [ ] Responsive design across breakpoints
- [ ] Accessibility audit (WCAG 2.1 AA)
- [ ] Performance optimization (lazy loading, skeleton states)
- [ ] Testing on real devices (iOS/Android)
- [ ] Web responsiveness testing

---

## PART 8: ACCESSIBILITY RECOMMENDATIONS

### 8.1 WCAG 2.1 AA Compliance Checklist

- [ ] **Contrast**: All text ≥ 4.5:1 (normal) or ≥ 3:1 (large)
- [ ] **Touch targets**: All interactive elements ≥ 48dp (44dp acceptable)
- [ ] **Keyboard navigation**: All features keyboard accessible
- [ ] **Focus indicators**: Visible focus states on all interactive elements
- [ ] **Screen reader**: Semantic labels, meaningful alt text on images
- [ ] **Motion**: Respectful animations, avoid vestibular motion triggers
- [ ] **Colors**: Don't rely on color alone to convey information
- [ ] **Links**: Descriptive link text (not "click here")
- [ ] **Forms**: Clear labels, error messages, validation feedback
- [ ] **Images**: Alt text or aria-hidden if decorative

### 8.2 Specific Implementations

```dart
// Semantic widgets
Semantics(
  label: 'Like post',
  button: true,
  enabled: true,
  onTap: () => like(),
  child: IconButton(...),
)

// Focus indicators
Material(
  child: Focus(
    onKey: (node, event) => handleFocus(),
    child: GestureDetector(...),
  ),
)

// Color + icon for status
Container(
  color: Colors.green, // Not just color
  child: Row(
    children: [
      Icon(Icons.check_circle), // + icon
      Text('Message delivered'),
    ],
  ),
)
```

---

## PART 9: PERFORMANCE OPTIMIZATION RECOMMENDATIONS

### 9.1 Perceived Performance

- **Skeleton loaders**: Show while fetching content
- **Image lazy loading**: Load images as they scroll into view
- **Progressive loading**: Load critical content first
- **Placeholder images**: Show low-res placeholder until full image loads

### 9.2 Actual Performance

- **Const widgets**: Leverage Flutter's const widget optimization
- **Provider selection**: Watch only required state
- **Image caching**: Use `CachedNetworkImage` properly
- **Pagination**: Implement "load more" or infinite scroll carefully
- **Debounce**: Search queries, filters (avoid excessive API calls)

---

## PART 10: DESIGN HANDOFF DELIVERABLES

### Figma/Design File Structure

```
PetSphere Design System
├─ Foundation
│  ├─ Colors (with variants)
│  ├─ Typography (scale)
│  ├─ Spacing & Grids
│  ├─ Shadows & Elevation
│  ├─ Borders & Radius
│  └─ Icons
├─ Components
│  ├─ Buttons (all states)
│  ├─ Input Fields (all states)
│  ├─ Cards (variants)
│  ├─ Navigation (bottom nav, tabs, breadcrumbs)
│  ├─ Dialogs & Sheets
│  ├─ Lists & Tables
│  ├─ Feedback (alerts, toasts, loaders)
│  └─ Data Display (charts, badges, ratings)
├─ Screens
│  ├─ Authentication
│  │  ├─ Login
│  │  └─ Onboarding (5 screens)
│  ├─ Main App
│  │  ├─ Home (Feed)
│  │  ├─ Discovery
│  │  ├─ Marketplace
│  │  ├─ Chat
│  │  └─ Profile/Settings
│  ├─ Pet Management
│  │  ├─ Add Pet (multi-step)
│  │  ├─ Health Dashboard
│  │  ├─ Care Goals
│  │  └─ Pet Profile Detail
│  ├─ Social Features
│  │  ├─ Create Post
│  │  ├─ Create Story
│  │  ├─ Post Detail
│  │  └─ Community/Forum
│  ├─ Gamification
│  │  └─ Achievements Dashboard
│  ├─ Account
│  │  ├─ Settings
│  │  ├─ Preferences
│  │  └─ Account Security
│  └─ Marketplace
│      ├─ Product Detail
│      ├─ Cart
│      └─ Order History
├─ Responsive Layouts
│  ├─ Mobile (320px)
│  ├─ Tablet (768px)
│  └─ Desktop (1024px+)
└─ Annotation & Specs
   ├─ Color specs
   ├─ Typography specs
   ├─ Spacing/padding specs
   ├─ Animation specs
   └─ Component interaction specs
```

---

## PART 11: RESEARCH SOURCES & CITATIONS

This audit was informed by current best practices from:

1. **Flutter Design Best Practices**
   - [Flutter App Development: 8 Best Practices to Follow in 2026](https://www.miquido.com/blog/flutter-app-best-practices/)
   - [10 Best Practices For Designing User Interfaces in Flutter - GeeksforGeeks](https://www.geeksforgeeks.org/blogs/best-practices-for-designing-user-interfaces-in-flutter/)
   - [Best practices for adaptive design - UI](https://docs.flutter.dev/ui/adaptive-responsive/best-practices)

2. **Material Design 3**
   - [Material Design 3 for Flutter](https://m3.material.io/develop/flutter)
   - [Material Design for Flutter](https://docs.flutter.dev/ui/design/material)
   - [Flutter 3.x: Material Design 3 and Modern UI Patterns](https://dasroot.net/posts/2026/01/flutter-material-design-3-modern-ui-patterns/)

3. **Responsive & Cross-Platform Design**
   - [Adaptive and responsive design in Flutter](https://docs.flutter.dev/ui/adaptive-responsive)
   - [Flutter Web Responsive: Crafting Adaptive UIs for Mobile, Tablet, and Web](https://blog.stackademic.com/flutter-web-responsive-crafting-adaptive-uis-for-mobile-tablet-and-web-211effaa2445)
   - [Responsive Web And Desktop Development With Flutter](https://www.smashingmagazine.com/2020/04/responsive-web-desktop-development-flutter/)

4. **Marketplace & Social App Patterns**
   - [What Good Marketplace UX Design Looks Like: A Feature-by-Feature Guide](https://www.rigbyjs.com/blog/marketplace-ux)
   - [Marketplace UX Design: 9 Best Practices](https://excited.agency/blog/marketplace-ux-design/)
   - [How Social Media Apps' UX & UI Are Designed To Engage](https://www.komododigital.co.uk/insights/how-social-media-apps-ux-ui-are-designed-to-engage-and-be-addictive/)

---

## PART 12: SUMMARY & NEXT STEPS

### Key Takeaways

1. **Design System**: PetSphere needs a comprehensive Material Design 3-based design system with clear component library and tokens
2. **Missing Features**: 8-10 critical screens are missing (onboarding, profile, search, settings, gamification, forums, care goals, order management)
3. **Screen Redesigns**: 6 existing screens need significant UX improvements (home, discovery, pet profile, health, marketplace, chat)
4. **Cross-Platform**: Responsive design strategy needed for mobile-first, with tablet and web optimization
5. **Accessibility**: WCAG 2.1 AA compliance required throughout

### Recommended Next Steps

1. **Validate Supabase Schema** (once you provide access) — confirm data models align with UI needs
2. **Create Figma Design File** — build comprehensive design system and screen mockups
3. **Get Stakeholder Sign-off** — review redesign direction with product/leadership
4. **Implementation Planning** — prioritize phases based on business goals
5. **Component Library Build** — start with material_design_3 integration
6. **Iterative Screen Implementation** — phase 1-5 roadmap (10 weeks)

---

**Document Version**: 1.0  
**Last Updated**: May 1, 2026  
**Status**: Ready for Design System Implementation
