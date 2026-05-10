
# PetSphere Flutter App

## Overview

PetSphere is a pet social and marketplace platform that allows users to connect with other pet owners, find and list pets for adoption, and buy and sell pet products.

## Features
---

### 🔐 Authentication
- Email/password sign up and login
- Session persistence across app restarts
- Auto-redirect based on auth state (splash → login → home)
- Profile update (name, bio, location, profile image)
- Logout with confirmation dialog

---

### 🏠 Home Feed (Social)
- Instagram-style scrollable post feed
- Stories row with per-pet story creation
- Pull-to-refresh
- Real-time like updates via Supabase Realtime
- Optimistic like toggle
- Comment bottom sheet with live comment list
- Post sharing via native share sheet
- Post creation (with media upload, caption, location, pet tagging)
- Post editing and deletion (own posts only)
- Story creation (select which pet posts the story)
- Story viewing
- Story deletion
- Notification sent on like, comment, and share
- Shimmer loading skeleton

---

### 🔍 Discovery / Breeding Matching
- Tinder-style swipeable pet card stack
- Swipe right to like, swipe left to pass
- Animated swipe-out and snap-back physics
- Action buttons: Like, Nope, View Profile (Star)
- Filter chips: For You, Same Breed, Nearby
- Text search across pet name, breed, animal type
- Multi-pet selector bar (browse as different pets)
- My Listings tab — manage your breeding-listed pets
- Nearby tab (distance-sorted view)
- Like/match request system
- Duplicate request prevention
- Notification sent to receiver on like

---

### 🐾 Pet Profiles
- Owner profile view (bio, location, email, follower/following counts)
- Individual pet profile view (breed, animal type, verified badge, bio)
- Pet carousel selector (switch between owner and each pet)
- Post grid with category filter chips (Playtime, Nap, Outdoor, Food)
- Follower/following count (tappable → opens list)
- Edit owner profile (name, bio, location, profile image upload)
- Edit pet profile (name, breed, age, bio, image upload)
- Add new pet
- Share profile (generates deep link)
- Public care badges row on owner profile
- Visitor profile view (follow/unfollow, send match request, message)
- Logout from profile

---

### 💬 Messaging
- Messages inbox with search
- Unread count badge per thread
- Real-time message delivery via Supabase Realtime
- Message bubbles with date separators
- Floating pill input bar
- Attachment sheet (camera, gallery, document — UI ready, marked coming soon)
- Voice message button (UI ready, marked coming soon)
- Tap avatar to open other pet's profile
- Thread auto-created when a match is accepted (DB trigger)
- Mark thread as read on open

---

### 🔔 Notifications
- Activity tab: likes, comments, shares, follows, orders
- Requests tab: incoming breeding match requests
- Accept / Decline match requests inline
- "Like Back" → creates match + opens chat
- Unread count badge on home screen icon
- Mark all as read on open
- Tap notification → navigate to relevant entity (post, order, messages)

#### Push notifications (FCM, Android)
When the app is in the background or killed, **in-app** Supabase Realtime updates stop; **Firebase Cloud Messaging** delivers system notifications instead.

**Client (this repo)**  
- After login, the app registers an FCM device token and upserts it into Supabase `user_fcm_tokens` (`lib/services/push_notification_service.dart`, `lib/repositories/push_token_repository.dart`).  
- Android 13+ uses the existing `POST_NOTIFICATIONS` permission plus a runtime prompt via `permission_handler`.  
- Firebase is wired for **PetSphere** (`petfolio-197e6`): `firebase.json`, `android/app/google-services.json`, and `lib/firebase_options.dart` are generated via [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/configure) (`flutterfire configure --project=petfolio-197e6 …`). Re-run that command if you clone on a new machine or add iOS/Web. `google-services.json.example` remains as a template reference only.

**Server (Supabase)**  
1. Apply migration `supabase/migrations/20260505140000_user_fcm_tokens.sql` (`supabase db push` or Dashboard SQL).  
2. Set Edge secret `FIREBASE_SERVICE_ACCOUNT_JSON` to the **minified** JSON from Firebase Console → Project settings → Service accounts → Generate new private key.  
3. Deploy `supabase functions deploy push-fcm` and create a **Database Webhook** on `public.notifications` **INSERT** targeting that function (same pattern as [Supabase FCM guide](https://supabase.com/docs/guides/functions/examples/push-notifications?platform=fcm)).

---

### 🐕 Pet Care Diary (Core Feature)
**Care Diary Tab:**
- Daily care log per pet (auto-creates today's log)
- Breakfast / Dinner / Snack feeding toggles
- Water cups tracker (increment/decrement, clamped to goal)
- Mood selector (Sleepy, Happy, Playful, Sick)
- Custom daily checklist with toggle tasks
- Checklist progress bar with percentage
- Personalized nudge messages based on onboarding data
- Edit Goals modal (calorie goal, water goal, exercise goal)
- Bento grid overview: Tasks ring, Calories ring, Water ring
- 7-day streak banner with day flags
- Week completion mask (Mon–Sun)
- Debounced auto-save (400ms) to Supabase
- Offline-first: serves stale cache immediately, then refreshes
- Care setup banner → onboarding flow

**Gamification:**
- Care points system (up to 10 pts/day, 2 pts per task)
- 30-day care challenge progress bar
- Streak days counter (current + best)
- Streak freeze mechanic (2 per week)
- Badge unlock system:
  - First Log, Streak 3/7/14 days
  - Week Complete, Perfect Week
  - 30-Day Challenge
  - Points 100 / 500
  - Nutrition Ninja (7-day feeding streak)
  - Hydration Station (7-day water goal streak)
  - Mood Tracker (7-day mood streak)
- Achievements screen: level card, stat boxes, 30-day path, badge grid (locked/unlocked)
- Public badge showcase editor (choose up to 3 badges to show on profile)
- Badge sharing via native share

---

### 🏥 Health Tab (inside Pet Care)
- Health overview card with alert chips (meds due, vet countdown, parasite overdue, active symptoms)
- **Vitals & Weight:** log weight + BCS score (1–9), weight trend chart (7/30/90d range selector), delta vs prior
- **Medications:** add/edit/delete medications, mark dose given/skipped, frequency options
- **Vet Appointments:** add/edit/cancel appointments, upcoming list
- **Vaccinations:** add, mark complete, scheduled/completed status
- **Parasite Prevention:** log treatments, overdue alerts, latest per type
- **Dental Logs:** home brushing and professional cleaning logs
- **Allergies:** add/remove allergy entries
- **Symptoms:** log symptom type + severity (mild/moderate/severe) + notes, resolve symptoms, active/resolved split

---

### 🍽️ Feeding Tab (inside Pet Care)
- Breakfast / Dinner / Snack / Treats tracking
- Calorie progress toward daily goal
- Treat count and kcal tracking

---

### 🛒 Marketplace
- Product grid (2-column) with category filter chips: All, Food, Toys, Bedding, Grooming, Treats, Accessories
- Personalized greeting header
- Member exclusive promo banner
- Product detail screen
- Add to cart with snackbar confirmation
- Cart with item count badge
- Cart screen (view/manage items)
- Order history screen
- Order status notifications

---

### 🔎 Search
- Unified search across Posts, Pets, and Products (3 tabs)
- Debounced search (400ms)
- Clear button
- Auto-focus on open
- Post results with like/comment actions
- Pet results → tap to open profile
- Product results → add to cart

---

### 💰 Expense Tracker
- Monthly budget dashboard with progress bar
- Total spending display
- Category breakdown grid (Food, Vet, Grooming, Toys, Accessories, Other)
- Upcoming bills section
- Transaction list with swipe-to-delete
- Add expense modal (title, amount, category, date picker)
- Edit monthly budget dialog
- Period selector (This Month / Last 3 Months / This Year)

---

### 📈 Growth Charts
- Weight history line chart (fl_chart)
- Height history bar chart (fl_chart)
- Time range selector (3M / 6M / 1Y / ALL)
- Trend indicator chip
- Milestones list
- Log measurement bottom sheet (weight + height)

---

### 🏥 Vet Booking
- Vet listing with rating, distance, specialty, price tier
- Category filter chips (All, General, Dental, Surgery, Emergency)
- Search bar
- Booking detail sheet: date picker (14-day scroll), time slot grid
- Confirm booking with snackbar

---

### 🚨 Emergency Care
- Nearby emergency vet map button
- Pet digital ID / QR code card
- Immediate action grid (CPR, Bleeding, Heatstroke, Fractures)
- 24/7 hotlines (Pet Poison Helpline, ASPCA) with tap-to-call
- Toxic food items list
- SOS floating action button (calls hotline)

---

### 👥 Community Groups
- Suggested groups list with member count and join/open button
- Trending categories grid (Training, Nutrition, Puppy Care, Senior Pets)
- Create group button

---

### 🔍 Lost & Found
- Lost Pets / Found Pets tabs
- Pet cards with photo, breed, location, time, reward badge
- Report pet FAB
- Contact finder button
- Share button

---

### 🐶 Adoption Center
- Tinder-style swipe card stack for adoptable pets
- ADOPT / NEXT swipe stamps
- Pet info overlay (name, age, location, tags)
- Verified badge

---

### 🎓 Pet Training
- Training hero card with level + progress bar
- Skill categories grid (Obedience, Agility, Social, Tricks) with completion progress
- Daily exercises list
- Find Trainers promotion card
- New Session FAB

---

### 🛡️ Insurance Hub
- Active policy card (plan name, deductible, reimbursement %, annual limit, renewal date)
- Coverage breakdown (Accidents, Illnesses, Diagnostics, Dental)
- Recent claims list with status (Approved/Pending)
- Document vault (PDF/image storage with sync status)
- Insurance perks / multi-pet discount card
- File claim bottom sheet (subject, amount, date, document upload)

---

### 🗺️ Pet-Friendly Places
- Map view / list view toggle
- Search bar overlay
- Category filter chips (Parks, Cafes, Hotels, Vets)
- Places carousel at bottom of map
- Place cards with rating, distance, open status, directions button
- My location FAB

---

### 📅 Pet Events
- (Route registered: `/events` → `PetEventDiscoveryScreen`)

---

### 🍎 Nutrition Planner
- Daily calorie budget card with macro breakdown (Protein/Fats/Carbs)
- Hydration tracker with animated circular progress
- Safe food search bar
- Meal schedule with checkboxes (Breakfast, Lunch, Dinner)
- Dietary profile tags (Grain-Free, Low Sodium, Sensitive Stomach)
- Smart nutrition tip
- Add meal button

---

### 🐾 Pet Sitter Dashboard
- Top-rated sitters list (rating, jobs, price/hr)
- Post a job card
- Upcoming bookings list

---

### 🔬 AI Breed Identifier
- Camera preview with corner frame overlay
- Animated scan line
- Start Precision Scan button
- Import from Gallery button
- Scan history horizontal scroll
- Results sheet: primary match + secondary match with confidence %, breed characteristics, lifespan/weight/group stats
- Add to Pet Profile button

---

### 📚 Knowledge Base
- Featured article hero card
- Category icons (Health, Nutrition, Training, First Aid)
- Tabbed articles (All Topics, Health & Wellness, Behavioral Tips, Expert Guides)
- Article tiles with read time, category, expert-verified badge
- Search bar
- Bookmark button

---

### ⭐ Gear Reviews
- Top-rated gear cards (product name, brand, rating, price, review count)
- Category chips (Harnesses, Smart Toys, Feeders, Beds, GPS Trackers)

---

### 🕐 Pet Social Timeline
- Immersive parallax hero header with pet photo
- Pet stats row (Memories, Milestones, Rank)
- Chronological timeline with event types (photo, achievement, health, milestone)
- Inline photo display for photo events
- Reactions (likes, comments) per event
- Add Memory FAB

---

### 🌈 Pet Memorial
- Immersive gradient background
- Memorial profile (photo, name, years)
- Quote card
- Treasured moments photo gallery grid
- Messages of love board
- Add a Memory button
- Share button

---

### 📋 Medical Records
- (Route registered: `/medical_records` → `PetHealthRecordScreen`)

### 📤 Health Record Export
- (Route registered: `/export_records` → `PetHealthRecordExportScreen`)

---

### ⚙️ Settings
- Light / Dark theme toggle (persisted via SharedPreferences)
- Account info display
- Notifications shortcut
- Liked pets shortcut
- Order history shortcut
- Achievements & badges section (per-pet badge carousel, tap to view detail + share)
- Privacy Policy, Terms of Service, Help & Support links
- App version display
- Sign out with confirmation

---

### 🌐 Cross-Cutting Features
- Material Design 3 with custom `PetsphereShadows` theme extension
- Playfair Display (headings) + DM Sans (body) typography
- Light and dark theme support
- Responsive layout (max-width constraints for tablet/web)
- Accessibility: semantic labels on nav bar, buttons, progress indicators
- GoRouter with auth-aware redirects and deep link support (50+ routes)
- Riverpod state management with `Notifier` pattern throughout
- Bootstrap coordinator for parallel cold-start data hydration
- App lifecycle sync (re-syncs data on resume, debounced 30s)
- Supabase Realtime subscriptions (likes, comments, messages)
- Image upload helper (Supabase Storage)
- Local cache for care logs (SharedPreferences)
- Marionette binding for UI automation testing