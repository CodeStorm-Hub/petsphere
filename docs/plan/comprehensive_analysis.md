# PetFolio — Comprehensive Codebase Analysis & Missing UI Gap Report

> Generated: May 11, 2026 | Last Updated: May 11, 2026 (Post-Implementation)
> PetSphere Project

---

## 1. FEATURE INVENTORY

The codebase is organized into **22 feature modules**, following a feature-first architecture under `lib/features/`.

### 1.1 Feature Modules

| # | Feature | Models | Controllers | Screens | Widgets | Status |
|---|---------|--------|------------|---------|--------|--------|
| 1 | **Auth** | 1 | 1 | 4 | 0 | ✅ Complete |
| 2 | **Pet** | 1 | 2 | 4 | 0 | ✅ Good |
| 3 | **Care** | 4 | 6 | 7 | 8 | ✅ Full |
| 4 | **Health** | 2 | 8 | 6 | 0 | ✅ Full |
| 5 | **Social** | 4 | 3 | 10 | 2 | ✅ Full |
| 6 | **Marketplace** | 4 | 3 | 5 | 2 | ✅ Full |
| 7 | **Messaging** | 2 | 1 | 2 | 2 | ✅ Good |
| 8 | **Notifications** | 1 | 2 | 1 | 0 | ✅ Good |
| 9 | **Match** | 1 | 4 | 3 | 1 | ✅ Full |
| 10 | **Services** | 3 | 7 | 9 | 0 | ✅ Full (but duplicates) |
| 11 | **Home** | 0 | 0 | 1 | 0 | ⚠️ Minimal |
| 12 | **Profile** | 0 | 0 | 2 | 1 | ⚠️ Partial |
| 13 | **Settings** | 0 | 0 | 1 | 0 | ⚠️ Scaffold |
| 14 | **Discovery** | 2 | 1 | 1 | 0 | ⚠️ Partial (duplicates services) |
| 15 | **Community** | 0 | 0 | 2 | 0 | 🔴 Empty - No data layer |
| 16 | **Chat** | 0 | 0 | 0 | 0 | 🔴 Empty shell |
| 17 | **Feed** | — | — | — | — | 🔴 Missing - No files |
| 18 | **Matching** | — | — | — | — | 🔴 Missing - No files |
| 19 | **Nutrition** | 1 | 0 | 0 | 0 | 🔴 Stub - Only repository |
| 20 | **Training** | 1 | 0 | 0 | 0 | 🔴 Stub - Only repository |

### 1.1.1 Feature Implementation Levels

**Complete (>80%)**: auth, pet, care, health, social, marketplace, messaging, notifications, match, services

**Partial (40-80%)**: pet (profile editing incomplete), messaging (typing indicators, read receipts), notifications (basic), match (request management), home, profile, settings, discovery

**Minimal (<40%)**: home (screen only), profile (screens only), settings (screen only), community (screens, no data layer), discovery (search exists, limited feed), nutrition (repository only), training (repository only)

**Empty/Missing**: chat (empty directories), feed (no files), matching (no files)

### 1.2 Core Module

| Category | Files |
|----------|-------|
| Theme (colors, typography, spacing, shadows, border_radius, breakpoints, durations, icon_sizes, theme_bootstrap, theme_controller) | 11 |
| Constants (app_categories, app_durations, app_routes, app_strings, supabase_config) | 6 |
| Services (connectivity, offline_cache, push_notifications, push_deeplinks, storage, push_token) | 8 |
| Shared Widgets | 36 |
| Utilities (image_compressor, image_upload_helper, layout_utils, logger, media_utils, pet_navigation, safe_route_params, search_query_escape, video_compressor) | 9 |
| App Shell (app.dart, router.dart, bootstrap_controller.dart, main_layout.dart, adaptive_navigation.dart) | 5 |

### 1.3 Code Duplication & Redundancy

**Critical Overlaps Found:**

| Duplicate Area | Locations | Issue |
|----------------|-----------|-------|
| Pet Events Models | discovery/data/pet_event_models.dart, services/data/pet_event_models.dart | Identical models in 2 features |
| Pet Friendly Place Models | discovery/data/pet_friendly_place_model.dart, services/data/pet_friendly_place_model.dart | Duplicate models |
| Pet Events Repositories | discovery/data/pet_events_repository.dart, services/data/pet_events_repository.dart | Identical repositories |
| Places Repositories | discovery/data/pet_events_repository.dart (search), services/data/places_repository.dart | Overlapping functionality |
| Search Controllers | discovery/presentation/controllers/search_controller.dart, match/presentation/controllers/search_controller.dart | Multiple search implementations |
| Nutrition | care/pet_nutrition_controller.dart, nutrition/data/nutrition_repository.dart, health/data/nutrition_repository.dart, services/pet_nutrition_controller.dart | Scattered across 4 locations |
| Training | care/pet_training_controller.dart, training/data/training_repository.dart | Duplicated |
| Adoption Center Screens | community/presentation/screens/adoption_center_screen.dart, services/presentation/screens/adoption_center_screen.dart | Duplicate screens |
| Liked Pets Screens | pet/presentation/screens/liked_pets_screen.dart, match/presentation/screens/liked_pets_screen.dart | Duplicated |
| Chat vs Messaging | chat/ (empty shell), messaging/ (full implementation) | Two directories for same feature |
| Feed | social/feed_repository.dart exists but feed/ directory is empty | Unfinished extraction |

---

## 2. EXISTING SCREENS vs. ROUTES — ROUTING MATRIX

### 2.1 Auth

| Route | Screen | File | Status |
|-------|--------|------|--------|
| `/splash` | SplashScreen | auth/presentation/screens/splash_screen.dart | ✅ |
| `/login` | LoginScreen | auth/presentation/screens/login_screen.dart | ✅ |
| `/register` | RegistrationScreen | auth/presentation/screens/registration_screen.dart | ✅ |

### 2.2 Bottom Navigation (Main Layout)

| Tab | Route | Screen | File | Status |
|----|-------|--------|------|--------|
| 0 | `/home` | HomeScreen | home/presentation/screens/home_screen.dart | ✅ |
| 1 | `/discover` | DiscoveryScreen | match/presentation/screens/discovery_screen.dart | ✅ |
| 2 | Center FAB | PetCareScreen | care/presentation/screens/pet_care_screen.dart | ✅ (via route) |
| 3 | `/shop` | MarketplaceScreen | marketplace/presentation/screens/marketplace_screen.dart | ✅ |
| 4 | `/profile` | OwnerProfileScreen | profile/presentation/screens/owner_profile_screen.dart | ✅ |

### 2.3 Pet-Centric Routes (`/pet/:id`)

| Route | Screen | File | Status |
|-------|--------|------|--------|
| `/pet/:id` | PetProfileScreen / VisitorPetProfileScreen | pet/presentation/screens/pet_profile_screen.dart | ✅ |
| `/pet/:id/care` | PetCareScreen | care/presentation/screens/pet_care_screen.dart | ✅ |
| `/pet/:id/care/onboarding` | PetCareOnboardingScreen | care/presentation/screens/pet_care_onboarding_screen.dart | ✅ |
| `/pet/:id/followers` | PetFollowersScreen | social/presentation/screens/pet_followers_screen.dart | ✅ |
| `/pet/:id/achievements` | GamificationScreen | care/presentation/screens/gamification_screen.dart | ✅ |
| `/pet/:id/medical_records` | PetHealthRecordScreen | health/presentation/screens/pet_health_record_screen.dart | ⚠️ Partial |
| `/pet/:id/medical_records/export` | PetHealthRecordExportScreen | health/presentation/screens/pet_health_record_export_screen.dart | ⚠️ Partial |
| `/pet/:id/expenses` | PetExpenseTrackerScreen | care/presentation/screens/pet_expense_tracker_screen.dart | ⚠️ Partial |
| `/pet/:id/growth` | PetGrowthChartScreen | health/presentation/screens/pet_growth_chart_screen.dart | ⚠️ Partial |
| `/pet/:id/nutrition` | PetNutritionPlannerScreen | care/presentation/screens/pet_nutrition_planner_screen.dart | ⚠️ Partial |
| `/pet/:id/timeline` | PetSocialTimelineScreen | social/presentation/screens/pet_social_timeline_screen.dart | ✅ |
| `/pet/:id/training` | PetTrainingScreen | care/presentation/screens/pet_training_screen.dart | ⚠️ Partial |
| `/pet/:id/vet_booking` | VetBookingScreen | health/presentation/screens/vet_booking_screen.dart | ⚠️ Partial |
| `/pet/:id/emergency_care` | EmergencyCareScreen | health/presentation/screens/emergency_care_screen.dart | ⚠️ Partial |
| `/pet/:id/insurance` | PetInsuranceHubScreen | services/presentation/screens/pet_insurance_hub_screen.dart | ⚠️ Partial |
| `/pet/:id/memorial` | PetMemorialScreen | social/presentation/screens/pet_memorial_screen.dart | ✅ |
| `/pet/:id/memorial/create` | CreateMemorialTributeScreen | social/presentation/screens/create_memorial_tribute_screen.dart | ✅ |
| `/pet/:id/memorial/:memorialId` | PetMemorialDetailScreen | social/presentation/screens/pet_memorial_detail_screen.dart | ✅ |

### 2.4 Other Routes

| Route | Screen | File | Status |
|-------|--------|------|--------|
| `/create_post` | CreatePostScreen | social/presentation/screens/create_post_screen.dart | ✅ |
| `/create_story` | CreateStoryScreen | social/presentation/screens/create_story_screen.dart | ✅ |
| `/add_pet` | AddPetScreen | pet/presentation/screens/add_pet_screen.dart | ✅ |
| `/notifications` | NotificationsScreen | notifications/presentation/screens/notifications_screen.dart | ✅ |
| `/liked_pets` | LikedPetsScreen | pet/presentation/screens/liked_pets_screen.dart | ✅ |
| `/messages` | MessagesListScreen | messaging/presentation/screens/messages_list_screen.dart | ✅ |
| `/chat/:threadId` | ChatScreen | messaging/presentation/screens/chat_screen.dart | ✅ |
| `/post/:id` | PostDetailScreen | social/presentation/screens/post_detail_screen.dart | ✅ |
| `/story/:petId` | StoryViewerScreen | social/presentation/screens/story_viewer_screen.dart | ✅ |
| `/cart` | CartScreen | marketplace/presentation/screens/cart_screen.dart | ✅ |
| `/orders` | OrderHistoryScreen | marketplace/presentation/screens/order_history_screen.dart | ✅ |
| `/product/:id` | ProductDetailScreen | marketplace/presentation/screens/product_detail_screen.dart | ✅ |
| `/settings` | SettingsScreen | settings/presentation/screens/settings_screen.dart | ✅ |
| `/search` | SearchScreen | discovery/presentation/screens/search_screen.dart | ✅ |
| `/user/:id` | VisitorUserProfileScreen | social/presentation/screens/visitor_user_profile_screen.dart | ✅ |
| `/user/:id/followers` | PetFollowersScreen (ownerFollowers) | social/presentation/screens/pet_followers_screen.dart | ✅ |
| `/user/:id/following` | PetFollowersScreen (following) | social/presentation/screens/pet_followers_screen.dart | ✅ |
| `/community_groups` | CommunityGroupsScreen | community/presentation/screens/community_groups_screen.dart | ⚠️ Partial |
| `/lost_and_found` | LostAndFoundScreen | services/presentation/screens/lost_and_found_screen.dart | ⚠️ Partial |
| `/adoption_center` | AdoptionCenterScreen | services/presentation/screens/adoption_center_screen.dart | ⚠️ Partial |
| `/pet_friendly_places` | PetFriendlyPlacesScreen | services/presentation/screens/pet_friendly_places_screen.dart | ⚠️ Partial |
| `/events` | PetEventDiscoveryScreen | services/presentation/screens/pet_event_discovery_screen.dart | ⚠️ Partial |
| `/sitters` | PetSitterDashboardScreen | services/presentation/screens/pet_sitter_dashboard_screen.dart | ⚠️ Partial |
| `/breed_identifier` | PetBreedIdentifierScreen | services/presentation/screens/pet_breed_identifier_screen.dart | ⚠️ Partial |
| `/knowledge_base` | PetKnowledgeBaseScreen | services/presentation/screens/pet_knowledge_base_screen.dart | ⚠️ Partial |
| `/article_detail` | ArticleDetailScreen | services/presentation/screens/article_detail_screen.dart | ⚠️ Partial |
| `/gear_reviews` | PetGearReviewsScreen | marketplace/presentation/screens/pet_gear_reviews_screen.dart | ⚠️ Partial |
| `/manage_pets` | ManagePetsScreen | profile/presentation/screens/manage_pets_screen.dart | ✅ |

---

## 3. EXISTING UI COMPONENTS & WIDGETS

### 3.1 Core Shared Widgets (`lib/core/widgets/`)

| Widget | Purpose |
|--------|---------|
| `PetAvatar` | Circular avatar with optional story ring |
| `SkeletonLoader` / `ShimmerLoader` / `ShimmerGroup` | Shimmer loading states |
| `AsyncValueWidget<T>` | Async loading/error/data wrapper |
| `PetfolioEmptyState` | Empty state with icon, title, message, CTA button |
| `BrandLogo` | App logo / fallback icon |
| `ResponsiveBuilder` | Responsive breakpoint helper |
| `PetfolioWidgets` | Aggregated barrel file |

### 3.2 App Shell Widgets (`lib/app/widgets/`)

| Widget | Purpose |
|--------|---------|
| `PetFolioNavBar` | Mobile bottom nav with 5 items (center FAB for care) |
| `PetFolioNavRail` | Tablet/desktop side nav, collapsible/extended |
| `NavProfileAvatar` | Animated profile avatar with active ring |
| `NavItem` | Nav item data model (inactive/active icon, label) |

### 3.3 Feature Widgets

| Feature | Widget | Purpose |
|---------|--------|---------|
| Care | `PublicCareBadgesRow` | Display showcased care badges on profiles |
| Social | `PostCard` | Full post card with header, media, actions |
| Social | `PostMedia` | Image/video display for posts |
| Marketplace | `ProductCard` | Product grid card with image, price, add-to-cart |
| Marketplace | `CartItemTile` | Cart item with quantity controls |
| Messaging | `MessageBubble` | Sent/received message bubble with read indicators |
| Messaging | `ChatThreadTile` | Chat thread list tile |
| Match | `MatchPetCard` | Swipeable pet card for discovery |
| Profile | `ActivePetSwitcherModal` | Quick pet switching bottom sheet |

---

## 4. MISSING UI SCREENS, COMPONENTS & WIDGETS

### 4.1 Missing Screens (No Route / No File)

| # | Missing Screen | Route | Reason | Priority |
|---|----------------|-------|--------|----------|
| 1 | **Health Tab Screen** (integrated inside care) | — | Part of `pet_care_screen.dart` as a tab; should be a standalone route | Medium |
| 2 | **Sitter Detail Screen** | `/sitter/:id` | `PetSitterDashboardScreen` lists jobs, but no detail view | High |
| 3 | **Lost Pet Detail Screen** | `/lost_found/:id` | `LostAndFoundScreen` shows list, no detail view | High |
| 4 | **Found Pet Detail Screen** | `/found_pet/:id` | Same as above | High |
| 5 | **Adoption Listing Detail Screen** | `/adoption/:id` | `AdoptionCenterScreen` shows grid, no detail view | High |
| 6 | **Community Group Detail Screen** | `/group/:id` | `CommunityGroupsScreen` lists groups, no detail view | High |
| 7 | **Event Detail Screen** | `/event/:id` | `PetEventDiscoveryScreen` shows cards, no detail view | High |
| 8 | **Pet Friendly Place Detail Screen** | `/place/:id` | `PetFriendlyPlacesScreen` shows list, no detail view | High |
| 9 | **Place Finder/Map Screen** | `/map` | Map button exists in nav but no screen | Medium |
| 10 | **Insurance Claim Detail Screen** | `/claim/:id` | `PetInsuranceHubScreen` lists claims, no detail | Medium |
| 11 | **Order Detail Screen** | `/order/:id` | `OrderHistoryScreen` shows orders, no detail view | High |
| 12 | **Checkout Screen** | `/checkout` | Cart screen links to checkout but no dedicated screen | High |
| 13 | **Payment Screen** | `/payment` | No payment flow screen | High |
| 14 | **Edit Post Screen** | `/edit_post/:id` | Post detail has edit menu but no dedicated screen | Medium |
| 15 | **Edit Pet Profile Screen** | `/pet/:id/edit` | `AddPetScreen` used for add/edit but no dedicated edit | High |
| 16 | **Edit Owner Profile Screen** | `/edit_profile` | Settings links to edit profile but no screen | High |
| 17 | **Password Change Screen** | `/change_password` | Referenced in settings, not implemented | Medium |
| 18 | **Two-Factor Auth Screen** | `/2fa` | Referenced in settings, not implemented | Medium |
| 19 | **Active Sessions Screen** | `/sessions` | Referenced in settings, not implemented | Low |
| 20 | **Blocked Users Screen** | `/blocked_users` | Referenced in settings, not implemented | Low |
| 21 | **Report History Screen** | `/report_history` | Referenced in settings, not implemented | Low |
| 22 | **Content Filters Screen** | `/content_filters` | Referenced in settings, not implemented | Low |
| 23 | **Shipping Address Screen** | `/shipping` | Referenced in settings, not implemented | Medium |
| 24 | **Payment Methods Screen** | `/payment_methods` | Referenced in settings, not implemented | Medium |
| 25 | **Notification Preferences Screen** | `/notification_prefs` | Referenced in settings, not implemented | Medium |
| 26 | **Health Data Export Screen** | `/export_health` | Referenced in settings, not implemented | Medium |
| 27 | **Share Health With Vet Screen** | `/share_health` | Referenced in settings, not implemented | Low |
| 28 | **Language Selection Screen** | `/language` | Referenced in settings, not implemented | Low |
| 29 | **Accessibility Settings Screen** | `/accessibility` | Referenced in settings, not implemented | Low |
| 30 | **Units & Measurement Screen** | `/units` | Referenced in settings, not implemented | Low |
| 31 | **Terms of Service Screen** | `/terms` | Referenced in settings, not implemented | Low |
| 32 | **Privacy Policy Screen** | `/privacy` | Referenced in settings, not implemented | Low |
| 33 | **Open Source Licenses Screen** | `/licenses` | Referenced in settings, not implemented | Low |
| 34 | **Onboarding/Welcome Flow** | `/onboarding` | Not in routes; app starts at splash → login | High |
| 35 | **Care Goal Detail Screen** | `/pet/:id/care/goals/:goalId` | Goals shown as list, no detail/edit screen | Medium |
| 36 | **Medication Detail/Edit Screen** | `/pet/:id/medication/:id` | Health tab shows meds list, no detail screen | Medium |
| 37 | **Vaccination Detail Screen** | `/pet/:id/vaccine/:id` | No detail/edit for individual vaccines | Medium |
| 38 | **Appointment Detail Screen** | `/pet/:id/appointment/:id` | Vet booking shows list, no detail view | Medium |
| 39 | **Match Request Detail Screen** | `/match/:id` | No detail view for individual match requests | Medium |
| 40 | **Breed Scan Result Detail** | `/breed_scan/:id` | `BreedIdentifierScreen` shows recent scans, no detail | Low |
| 41 | **Knowledge Article Search Results** | `/knowledge/search` | Knowledge base has search UI but no results screen | Low |
| 42 | **Pet Sitter Job Post Screen** | `/post_sitter_job` | FAB in sitter screen has no target | Medium |
| 43 | **Pet Sitter Job Detail Screen** | `/sitter_job/:id` | No detail view for job listings | Medium |
| 44 | **Notifications Settings (per-type)** | `/notif/:type` | No granular notification control screen | Low |
| 45 | **Health Tab / Health Dashboard** (standalone) | `/pet/:id/health` | Integrated into care screen; should be standalone | Medium |
| 46 | **Care Log History Screen** | `/pet/:id/care/history` | Care log shows today; no historical view | Medium |
| 47 | **Training Command Detail** | `/pet/:id/training/:commandId` | Training shows commands list, no detail/edit | Medium |
| 48 | **Training History Screen** | `/pet/:id/training/history` | No training history screen | Low |
| 49 | **Dietary Profile Detail Screen** | `/pet/:id/diet` | Nutrition shows profile; no detail screen | Low |
| 50 | **Expense Category Detail Screen** | `/pet/:id/expense/:catId` | Expense tracker shows categories; no detail | Low |

### 4.2 Missing Feature Widgets

| # | Missing Widget | Feature | Purpose | Priority |
|---|---------------|---------|---------|----------|
| 1 | `CareTaskCard` | Care | Reusable task card with checkbox, icon, title, subtask count | High |
| 2 | `CareGoalProgressRing` | Care | Circular progress for care goals (calories, water, tasks) | High |
| 3 | `CareStreakBadge` | Care | Badge showing current/best streak with flame icon | Medium |
| 4 | `CareWeekMask` | Care | Mon–Sun mask with completion indicators | High |
| 5 | `MoodSelector` | Care | Mood logging buttons (Sleepy, Happy, Excited) | High |
| 6 | `HealthVitalsCard` | Health | Card showing vitals (weight, temp, heart rate) with trend arrow | High |
| 7 | `VaccinationCard` | Health | Vaccination card with name, date, due status, icon | High |
| 8 | `MedicationCard` | Health | Medication card with dosage, frequency, active indicator | High |
| 9 | `AppointmentCard` | Health | Vet appointment card with date, time, vet info | High |
| 10 | `SymptomLogCard` | Health | Symptom log entry card | Medium |
| 11 | `AllergyCard` | Health | Allergy info card | Medium |
| 12 | `DentalLogCard` | Health | Dental log card | Low |
| 13 | `ParasitePreventionCard` | Health | Parasite prevention card | Low |
| 14 | `WeightChartWidget` | Health | Weight trend line chart (fl_chart based) | High |
| 15 | `GrowthMilestoneCard` | Health | Growth milestone card with date, type, notes | Medium |
| 16 | `EmergencyHotlineCard` | Health | Emergency hotline card with call button | High |
| 17 | `MedicalIdCard` | Health | Pet medical ID card with QR code, vitals summary | High |
| 18 | `PostCommentSheet` | Social | Bottom sheet for adding/viewing comments (partially in home) | High |
| 19 | `PostActionRow` | Social | Like/comment/share row (extracted from PostCard) | Medium |
| 20 | `StoryBubble` | Social | Instagram-style story bubble with gradient ring | High |
| 21 | `MemorialCard` | Social | Memorial tribute card with image, name, years | High |
| 22 | `FollowTile` | Social | Reusable follow/follower tile with avatar, name, follow button | High |
| 23 | `NotificationTile` | Notifications | Notification list tile with icon, title, timestamp, unread dot | High |
| 24 | `VetCard` | Health | Vet card with image, rating, distance, specialty | Medium |
| 25 | `VetBookingSheet` | Health | Bottom sheet for booking vet appointment | Medium |
| 26 | `ProductQuantitySelector` | Marketplace | Quantity +/- stepper for product detail | High |
| 27 | `ProductFeatureTag` | Marketplace | Tag chip for product features (organic, non-gmo) | Medium |
| 28 | `OrderStatusBadge` | Marketplace | Order status badge chip | Medium |
| 29 | `ChatInputBar` | Messaging | Chat input bar with attachment, camera, send | High |
| 30 | `MediaSourceSheet` | Social | Bottom sheet for picking media source (gallery/camera) | High |
| 31 | `LocationTagSheet` | Social | Bottom sheet for tagging location | Low |
| 32 | `TagPetSheet` | Social | Bottom sheet for tagging pets in posts | Medium |
| 33 | `AdoptionListingCard` | Community | Adoption listing card with image, name, fee | High |
| 34 | `LostFoundReportCard` | Community | Lost/found pet report card | High |
| 35 | `GroupCard` | Community | Community group card | High |
| 36 | `EventCard` | Services | Event card with image, date, RSVP button | High |
| 37 | `PlaceCard` | Services | Pet-friendly place card with rating, features | High |
| 38 | `InsuranceClaimCard` | Services | Insurance claim card | Medium |
| 39 | `SitterJobCard` | Services | Pet sitter job card | Medium |
| 40 | `BreedScanResultCard` | Services | Breed scan result with confidence bar | Medium |
| 41 | `ArticleCard` | Services | Knowledge base article card (featured & recent) | High |
| 42 | `QuickActionCard` | Care | Care quick action card with icon, title, route | High |
| 43 | `PetMiniCard` | Profile | Mini pet card for profile horizontal scroll | High |
| 44 | `StatCell` | Profile | Tappable stat cell (followers, following, posts) | High |
| 45 | `AchievementBadgeChip` | Care | Badge chip with emoji, name for achievements | High |
| 46 | `ProgressBar` | Care | Custom progress bar with percentage | Medium |
| 47 | `CategoryFilterChips` | Core | Reusable category filter chips row | High |
| 48 | `SearchTextField` | Core | Reusable search field with debounce | High |
| 49 | `SectionHeader` | Core | Reusable section header with optional "View All" | Medium |
| 50 | `AvatarStack` | Core | Stacked avatars with overlap | Medium |

### 4.3 Missing Core/Shared Widgets

| # | Missing Widget | Purpose | Priority |
|---|---------------|---------|----------|
| 1 | `AppSnackBar` | Themed snackbar helper / overlay | High |
| 2 | `AppBottomSheet` | Base bottom sheet with handle bar | High |
| 3 | `ConfirmationDialog` | Reusable confirmation dialog | High |
| 4 | `LoadingOverlay` | Full-screen loading overlay | High |
| 5 | `DateRangePicker` | Reusable date range picker for filters | Medium |
| 6 | `TimeSlotPicker` | Time slot picker for appointments | Medium |
| 7 | `ImagePickerSheet` | Bottom sheet for camera/gallery/remove | High |
| 8 | `StarRating` | Star rating display/input | Medium |
| 9 | `BadgeChip` | Reusable badge chip (status, category) | Medium |
| 10 | `TrendArrow` | Up/down/neutral trend indicator | Medium |
| 11 | `GradientCard` | Card with gradient background | Medium |
| 12 | `GlassCard` | Frosted glass effect card (for insurance hub) | Medium |
| 13 | `ShimmerListTile` | Shimmer version of list tile | Low |
| 14 | `PetTypeIcon` | Icon by pet type (dog, cat, bird, etc.) | Medium |
| 15 | `GenderIcon` | Icon for male/female gender | Low |
| 16 | `EmptySearchState` | Empty state variant for search results | Medium |
| 17 | `NoConnectionBanner` | Offline banner at top of screens | Medium |
| 18 | `TabScaffold` | Reusable scaffold with TabBar for tabbed screens | Medium |
| 19 | `ActionConfirmationSheet` | Reusable action confirmation bottom sheet | Medium |
| 20 | `ShareSheet` | Native share sheet wrapper | Low |

---

## 5. MISSING FUNCTIONALITY (UI-LEVEL TODOs)

These are screens that exist but have placeholder/hardcoded functionality:

| Screen | Missing Functionality | Priority |
|--------|----------------------|----------|
| `PetGrowthChartScreen` | Charts use hardcoded data — needs real weight/log binding | High |
| `PetExpenseTrackerScreen` | Upcoming bills hardcoded; export button placeholder | Medium |
| `PetNutritionPlannerScreen` | Safe food search UI-only; analytics button placeholder | Medium |
| `PetTrainingScreen` | View All / Training Medals / Find Trainers buttons have no action | Medium |
| `PetHealthRecordScreen` | Heart rate & temperature are TBD placeholders; Labs tab always empty | High |
| `PetHealthRecordExportScreen` | Preview & actual export logic simulated | High |
| `EmergencyCareScreen` | Open Maps / Share Location / Symptoms Checker all placeholders | High |
| `VetBookingScreen` | Vet data is static; no actual clinic booking API | High |
| `PetInsuranceHubScreen` | Claims list; no link to actual insurance policy data | Medium |
| `LostAndFoundScreen` | Contact button; report creation with real data | Medium |
| `CommunityGroupsScreen` | Create group form; join/leave action | Medium |
| `PetSitterDashboardScreen` | Job posting; marketplace job list from API | Medium |
| `PetBreedIdentifierScreen` | AI breed identification logic (photo → breed) | High |
| `PetEventDiscoveryScreen` | RSVP to event | Medium |
| `PetFriendlyPlacesScreen` | Map integration; real place data | Medium |
| `PetKnowledgeBaseScreen` | Search results | Medium |
| `PetGearReviewsScreen` | Reviews list from API | Medium |
| `CareGoalEditorModal` | Hardcoded fallback weight (10kg) when pet weight unavailable | Medium |
| `PetCareScreen` | Task editing; care history view | Medium |
| `PetCareOnboardingScreen` | Data saved to `pet_care_onboarding` table | Medium |

---

## 6. DESIGN SYSTEM GAPS

| # | Gap | Status |
|---|-----|--------|
| 1 | No dedicated `Typography` text style class (merged into `AppTheme`) | ⚠️ |
| 2 | No `Spacing` constants class (using ad-hoc `EdgeInsets`) | ⚠️ |
| 3 | No `BorderRadius` constants | ⚠️ |
| 4 | No `IconSize` constants | ⚠️ |
| 5 | No `Elevation` constants | ⚠️ |
| 6 | No `AnimationDuration` constants | ⚠️ |
| 7 | No dedicated `Breakpoints` class for responsive design | ⚠️ |
| 8 | `BrandLogo` widget exists but no consistent logo usage across app | ⚠️ |
| 9 | No dark/light theme toggle with persistence | ⚠️ (referenced in settings) |
| 10 | No `app_strings.dart` — all strings are hardcoded | ⚠️ |

---

## 7. BACKEND MISSING TABLES (Schema → UI Gap)

Per `docs/plan/phase0_backend_stabilization_plan.md`, these tables are referenced in code but missing from the database:

| Table | Feature | Affects UI |
|-------|---------|-----------|
| `adoption_listings` | Community | AdoptionCenterScreen |
| `adoption_applications` | Community | AdoptionCenterScreen |
| `community_groups` | Community | CommunityGroupsScreen |
| `community_group_members` | Community | CommunityGroupsScreen |
| `lost_and_found_reports` | Community | LostAndFoundScreen |
| `pet_expenses` | Care | PetExpenseTrackerScreen |
| `pet_insurance_claims` | Services | PetInsuranceHubScreen |
| `pet_nutrition_logs` | Nutrition | PetNutritionPlannerScreen |
| `pet_sitter_jobs` | Services | PetSitterDashboardScreen |
| `pet_training_progress` | Training | PetTrainingScreen |
| `pet_breed_scans` | Services | PetBreedIdentifierScreen |
| `vaccination_schedules` | Health | PetHealthRecordScreen |
| `gear_reviews` | Marketplace | PetGearReviewsScreen |
| `pet_events` | Services | PetEventDiscoveryScreen |
| `pet_event_rsvps` | Services | PetEventDiscoveryScreen |
| `knowledge_base_articles` | Services | PetKnowledgeBaseScreen |

---

## 8. QUICK WIN PRIORITY MATRIX

### Priority 1 — High Impact, Low Effort (Do First)

| Item | Type | Why |
|------|------|-----|
| `CareTaskCard` | Widget | Reuse across care screens, reduce duplication |
| `MoodSelector` | Widget | Already in care screen as inline buttons |
| `QuickActionCard` | Widget | Care quick action grid — extract reusable card |
| `PetMiniCard` | Widget | Profile and home screens duplicate this |
| `CategoryFilterChips` | Widget | Used in 6+ screens |
| `SearchTextField` | Widget | Duplicated in marketplace, home, knowledge base |
| `SectionHeader` | Widget | Duplicated everywhere |
| `HealthVitalsCard` | Widget | Vitals section in health tab |
| `NotificationTile` | Widget | Notifications screen duplicates list tile logic |
| `AppBottomSheet` | Core | Base sheet with handle — used in 15+ screens |

### Priority 2 — High Impact, Medium Effort

| Item | Type | Why |
|------|------|-----|
| `OrderDetailScreen` | Screen | Cart → orders flow incomplete |
| `CheckoutScreen` | Screen | Cart exists but no checkout |
| `EditPetProfileScreen` | Screen | AddPetScreen reused awkwardly |
| `EditOwnerProfileScreen` | Screen | Settings has edit link, no target |
| `OnboardingScreen` | Screen | App goes straight to login |
| `Health Tab Standalone` | Screen | Integrated into care; should be route |
| `VetCard` + `VetBookingSheet` | Widget/Screen | Booking flow incomplete |
| `PostCommentSheet` | Widget | Inline in home_screen.dart, needs extraction |
| `ImagePickerSheet` | Core | Duplicated across create_post, create_story, memorial |
| `WeightChartWidget` | Widget | Used in health + growth screens |

### Priority 3 — Medium Impact, High Effort

| Item | Type | Why |
|------|------|-----|
| Detail screens for all list-based routes | Screens | Adoption, Lost&Found, Groups, Events, Places, Sitter jobs |
| Breed identifier AI integration | Screen | UI ready, backend missing |
| Real data binding for growth/expense/vet | Screens | Multiple screens need DB integration |
| Export health records (real logic) | Screen | UI done, needs backend |
| Map/place finder integration | Screen | Button exists, no screen |
| Onboarding flow (multi-step) | Screen | App skips onboarding |
| Password/2FA/Sessions screens | Screens | Settings references exist |

---

## 9. SUMMARY

| Category | Count |
|----------|-------|
| Total Feature Modules | 22 (10 complete, 6 partial, 6 empty/missing) |
| Total Existing Screens | ~50 |
| Total Missing Screens | 50 |
| Total Existing Widgets (feature + core) | ~50 |
| Total Missing Widgets | 70+ |
| Total Missing Core Widgets | 20 |
| Screens with Placeholder Functionality | 19 |
| Missing Backend Tables | 14+ |
| Code Duplication Areas | 10+ |
| Design System Gaps | 10 |

**Key insight**: The app has a solid feature coverage with 50+ screens and comprehensive routing, but has 6 completely empty/missing features (chat, feed, matching) and 10+ areas of significant code duplication. The core/shared widget library needs ~70 new components, but more critically, the codebase needs cleanup of empty directories and deduplication of discovery/services models before adding more screens.

### 2.5 Router Analysis

**Routes Imported from Features:**

| Import Path | Screen | Feature |
|-------------|--------|---------|
| features/match/presentation/screens/discovery_screen.dart | Discovery | match |
| features/discovery/presentation/screens/search_screen.dart | Search | discovery |
| features/services/presentation/screens/lost_and_found_screen.dart | LostAndFound | services |
| features/services/presentation/screens/adoption_center_screen.dart | AdoptionCenter | services |
| features/services/presentation/screens/pet_friendly_places_screen.dart | PetFriendlyPlaces | services |
| features/services/presentation/screens/pet_event_discovery_screen.dart | PetEventDiscovery | services |
| features/services/presentation/screens/pet_sitter_dashboard_screen.dart | PetSitterDashboard | services |
| features/services/presentation/screens/pet_breed_identifier_screen.dart | BreedIdentifier | services |
| features/services/presentation/screens/pet_knowledge_base_screen.dart | KnowledgeBase | services |
| features/services/presentation/screens/pet_insurance_hub_screen.dart | InsuranceHub | services |
| features/community/presentation/screens/community_groups_screen.dart | CommunityGroups | community |
| features/community/presentation/screens/adoption_center_screen.dart | AdoptionCenter (duplicate) | community |

**Router Issues:**
1. **Duplicate AdoptionCenter route** - Lines 408-413 register the same path twice
2. **Services-centric design** - Services feature has 9 screens in router while community feature has almost no data layer
3. **Unused imports** - Many service screens likely have unused imports from discovery/community

### 2.6 Bootstrap Coordination (lib/app/bootstrap_controller.dart)

**Providers Hydrated on Auth:**
1. feedProvider (social)
2. marketplaceProvider
3. petProvider
4. notificationProvider
5. careLogProvider
6. careGoalsProvider
7. careGamificationProvider
8. vitalsProvider
9. medicationProvider
10. appointmentProvider
11. vaccinationProvider
12. parasiteProvider
13. dentalProvider
14. allergyProvider

**NOT Hydrated by Bootstrap:**
- matchProvider (loaded per-pet after pets load)
- chatProvider (loaded on demand)
- searchProvider (loaded on demand)
- homeProvider (missing entirely)
- All services controllers

---

## 10. STITCH DESIGN SCREENS vs CODEBASE MAPPING

The Stitch project "PetFolio - Modern Pet Platform Redesign" (ID: 9043096397543633864) contains 40+ design screens. The following mapping identifies which designs are implemented vs missing in the codebase.

### 10.1 Design Screens Found in Codebase

| Design Screen Title | Design Variants | Codebase Route | Status |
|---------------------|-----------------|----------------|--------|
| PetFolio Home Feed | 4 variants | `/home` | ✅ Implemented |
| PetFolio Login | 2 variants | `/login` | ✅ Implemented |
| PetFolio Splash Screen | 2 variants | `/splash` | ✅ Implemented |
| PetFolio Onboarding | 2 variants | — | ❌ Not in routes |
| PetFolio Messages | 2 variants | `/messages` | ✅ Implemented |
| PetFolio Shop | 2 variants | `/shop` | ✅ Implemented |
| PetFolio Discover | 2 variants | `/discover` | ✅ Implemented |
| Health Records | 2 variants | `/pet/:id/medical_records` | ⚠️ Partial |
| Pet Care Dashboard | 2 variants | `/pet/:id/care` | ✅ Implemented |
| Owner Profile | 2 variants | `/profile` | ✅ Implemented |
| Pet Profile - Buddy | 2 variants | `/pet/:id` | ✅ Implemented |
| Add Pet | 2 variants | `/add_pet` | ✅ Implemented |
| New Post | 2 variants | `/create_post` | ✅ Implemented |
| Settings | 2 variants | `/settings` | ✅ Implemented |
| Notifications | 2 variants | `/notifications` | ✅ Implemented |

### 10.2 Design Screens NOT in Codebase

| Design Screen Title | Design Variant Folder | Priority |
|---------------------|-----------------------|-----------|
| PetFolio Ecosystem Flow | petfolio_1, petfolio_2, petfolio_3 | High |
| PetFolio Paw Logo | petfolio_paw_logo | Low |
| Premium Pet Care Social | premium_pet_care_social | Medium |
| Clinical Vitality | clinical_vitality | High |
| PetFolio Blue | petfolio_blue | Low |

### 10.3 UI Component Gaps (Design vs Implementation)

| Component | Design Spec | Codebase Status |
|-----------|-------------|-----------------|
| Glassmorphic Navigation | Nav bar with 12px blur, 70% opacity | ❌ Missing |
| Ambient Shadows | Offset 0,4px; Blur 20px | ❌ Different |
| Gradient Buttons | accent_gradient for primary CTAs | ❌ Missing |
| Status Ring | Gradient border for pet avatars | ❌ Missing |
| Card Elevation | White cards with rounded-xl | ⚠️ Partial |
| Input Focus State | White bg + Primary Blue glow | ⚠️ Partial |
| Chip/Tags | Rounded-pill with 10% opacity | ❌ Missing |

---

## 11. DATABASE SCHEMA GAPS (Supabase)

### 11.1 SUPABASE PROJECT INFO

**Project**: petsphere (ID: foubokcqaxyqgjhtgzsx)
**Region**: ap-southeast-1
**Status**: ACTIVE_HEALTHY
**Database Version**: PostgreSQL 17.6.1.084

### 11.2 Database Tables - ACTUALLY IMPLEMENTED (50 total)

The database **already has all the tables** that were previously marked as "missing"! The gap is in the **presentation layer**, not the database.

| # | Table Name | Columns | Feature Area | Status |
|---|------------|---------|--------------|--------|
| 1 | pets | 19 | Core | ✅ |
| 2 | profiles | 8 | Auth/Profile | ✅ |
| 3 | posts | 8 | Social | ✅ |
| 4 | comments | 5 | Social | ✅ |
| 5 | post_likes | 3 | Social | ✅ |
| 6 | stories | 9 | Social | ✅ |
| 7 | follows | 5 | Social | ✅ |
| 8 | messages | 8 | Messaging | ✅ |
| 9 | chat_threads | 5 | Messaging | ✅ |
| 10 | notifications | 8 | Notifications | ✅ |
| 11 | products | 13 | Marketplace | ✅ |
| 12 | orders | 6 | Marketplace | ✅ |
| 13 | gear_reviews | 6 | Marketplace | ✅ |
| 14 | pet_care_logs | 17 | Care | ✅ |
| 15 | pet_care_onboarding | 5 | Care | ✅ |
| 16 | pet_care_gamification | 22 | Care | ✅ |
| 17 | care_badge_definitions | 5 | Care | ✅ |
| 18 | pet_care_badge_unlocks | 5 | Care | ✅ |
| 19 | pet_expenses | 9 | Care | ✅ |
| 20 | pet_weight_logs | 6 | Health | ✅ |
| 21 | pet_vaccinations | 9 | Health | ✅ |
| 22 | pet_vet_appointments | 9 | Health | ✅ |
| 23 | pet_symptoms | 8 | Health | ✅ |
| 24 | pet_medications | 11 | Health | ✅ |
| 25 | pet_medication_doses | 7 | Health | ✅ |
| 26 | pet_allergies | 7 | Health | ✅ |
| 27 | pet_dental_logs | 6 | Health | ✅ |
| 28 | pet_parasite_prevention | 9 | Health | ✅ |
| 29 | pet_activity_logs | 9 | Health | ✅ |
| 30 | pet_nutrition_logs | 9 | Nutrition | ✅ |
| 31 | pet_training_progress | 6 | Training | ✅ |
| 32 | pet_memorial_entries | 11 | Social | ✅ |
| 33 | match_requests | 7 | Match | ✅ |
| 34 | adoption_listings | 15 | Community | ✅ |
| 35 | adoption_applications | 6 | Community | ✅ |
| 36 | community_groups | 9 | Community | ✅ |
| 37 | community_group_members | 5 | Community | ✅ |
| 38 | lost_and_found_reports | 15 | Community | ✅ |
| 39 | pet_events | 11 | Services | ✅ |
| 40 | pet_event_rsvps | 5 | Services | ✅ |
| 41 | pet_sitter_jobs | 8 | Services | ✅ |
| 42 | pet_insurance_claims | 9 | Services | ✅ |
| 43 | knowledge_base_articles | 9 | Services | ✅ |
| 44 | pet_breed_scans | 6 | Services | ✅ |
| 45 | user_fcm_tokens | 4 | Push | ✅ |
| 46 | waitlist | 6 | Auth | ✅ |

### 11.3 The REAL Gap: Presentation Layer

The database tables **exist but are not connected** to the UI. The actual gaps are:

| Previously Thought Gap | Reality |
|------------------------|---------|
| "Missing database tables" | ✅ All tables exist in DB |
| "Community features non-functional" | ⚠️ DB exists but community/ has no data layer |
| "Services tables missing" | ✅ All tables exist |
| "Nutrition/training no backend" | ✅ Tables exist but no presentation |

**The issue**: Code references tables but the presentation layer (controllers, screens) is incomplete or missing.

### 11.4 Security Advisories Found

| Issue | Level | Description |
|-------|-------|-------------|
| Function Search Path Mutable | WARN | `increment_group_member_count` has mutable search_path |
| Public Can Execute SECURITY DEFINER | WARN | `increment_group_member_count` can be executed by anon role |
| Authenticated Can Execute SECURITY DEFINER | WARN | Same function callable by authenticated users |
| Leaked Password Protection Disabled | WARN | Auth password security not enabled |

### 11.5 Performance Advisories

Multiple performance issues found (indices, query optimization) - see full output for details.

---

## 12. ARCHITECTURE GAPS

### 12.1 Feature Module Completeness

| Feature | Status | Issues |
|---------|--------|--------|
| chat | 🔴 Empty | Empty directories, no models, controllers, screens |
| community | 🔴 Empty | Directories exist but no files in data/models, presentation/controllers |
| feed | 🔴 Missing | Completely missing (directory has no files) |
| matching | 🔴 Missing | Completely missing (directory has no files) |
| nutrition | ⚠️ Stub | Only nutrition_repository.dart exists, no controller/screens |
| training | ⚠️ Stub | Only training_repository.dart exists, no controller/screens |
| home | ⚠️ Minimal | Only home_screen.dart exists, no models/controllers |
| profile | ⚠️ Partial | Only screens exist, no data layer or dedicated controller |
| settings | ⚠️ Scaffold | Only settings_screen.dart exists, no data layer/controller |
| discovery | ⚠️ Partial | Has search, but duplicates services models |

### 12.2 Missing Data Flow Connections

| Screen | Expected Data Source | Status |
|--------|---------------------|--------|
| PetGrowthChartScreen | pet_growth_records table | ❌ Not connected |
| PetExpenseTrackerScreen | pet_expenses table | ❌ Table missing |
| PetTrainingScreen | pet_training_progress table | ❌ Table missing |
| VetBookingScreen | Vet clinic API | ❌ Not connected |
| PetBreedIdentifierScreen | AI breed detection API | ❌ Not connected |
| Community screens | Community database tables | ❌ No data layer |
| Services screens | Services database tables | ❌ Most tables missing |

### 12.3 Database Tables - ALL IMPLEMENTED (via Supabase MCP)

**Project**: petsphere (ID: foubokcqaxyqgjhtgzsx)
**Total Tables**: 50 (ALL IMPLEMENTED)

All tables that were previously thought to be "missing" actually exist in the database:
- Community: adoption_listings, adoption_applications, community_groups, community_group_members, lost_and_found_reports ✅
- Services: pet_events, pet_event_rsvps, pet_sitter_jobs, pet_insurance_claims, knowledge_base_articles, pet_breed_scans ✅
- Care: pet_expenses ✅
- Marketplace: gear_reviews ✅
- Training: pet_training_progress ✅

### 12.4 The Real Gap: Presentation Layer

The database has all tables, but the UI layer is incomplete:

| Feature | Database | Presentation Layer | Status |
|---------|----------|-------------------|--------|
| Community tables | ✅ Exists | ❌ No data layer in community/ | Broken |
| Services tables | ✅ Exists | ⚠️ Connected but limited | Partial |
| Nutrition logs | ✅ Exists | ❌ No screen/controller | Broken |
| Training progress | ✅ Exists | ❌ No screen/controller | Broken |
| Chat threads | ✅ Exists | ❌ chat/ feature empty | Broken |
| Feed | N/A | ❌ feed/ directory empty | Missing |

**Root Cause**: The code references database tables, but the presentation layer (repositories → controllers → screens) is incomplete for several features.

---

## 13. UPDATED PRIORITY MATRIX

### Priority 1 — Critical (Blocking Features)

| Item | Type | Impact |
|------|------|--------|
| Onboarding screens | Screen | App starts at login, no onboarding flow |
| Checkout flow | Screen | Cart exists but no checkout |
| Community database tables | Backend | All community features non-functional |
| Services database tables | Backend | Most service features non-functional |
| Glassmorphic nav implementation | UI | Design spec not met |
| Nutrition presentation layer | Feature | Only data layer exists |
| Training presentation layer | Feature | Only data layer exists |

### Priority 2 — High (Missing Core Functionality)

| Item | Type | Impact |
|------|------|--------|
| Order detail screen | Screen | Order history exists but no detail |
| Edit pet profile | Screen | AddPetScreen awkwardly reused |
| Edit owner profile | Screen | Settings has link but no target |
| Health data export | Screen | UI exists, logic missing |
| Dark mode theme | UI | Design exists, implementation partial |

---

## 14. SUMMARY (UPDATED - May 2026)

| Category | Count |
|----------|-------|
| Total Feature Modules | 22 |
| Complete Features (>80%) | 10 |
| Partial Features (40-80%) | 6 |
| Empty/Missing Features | 6 |
| Total Existing Screens | ~50 |
| Total Missing Screens | 50+ |
| Total Design Screens in Stitch | 40+ |
| Design Screens Not in Codebase | 11 |
| Total Existing Widgets | ~36 (core) + 14 (feature) = ~50 |
| Total Missing Widgets | 70+ |
| Screens with Placeholder Functionality | 19 |
| **Database Tables** | **50 (ALL EXIST)** |
| Missing Backend Tables | 0 |
| Design System Gaps | 10+ |
| Code Duplication Issues | 10+ |
| Router Issues | 3 |

### 14.1 Critical Findings - CORRECTED

1. **Database is COMPLETE**: All 50 tables exist in Supabase - NO missing backend tables!
2. **The REAL Gap is Presentation Layer**: Tables exist but not connected to UI
3. **Empty Features**: chat/, feed/, matching/ directories exist but have no files
4. **Community No Data Layer**: community/ feature has screens but zero models/controllers - DB tables exist but unused
5. **Stub Features**: nutrition/ and training/ only have repositories, no UI - DB tables exist but unused
6. **Massive Code Duplication**: 10+ areas of duplicate code across discovery/services, nutrition, training
7. **Router Issues**: Duplicate AdoptionCenter route, services-centric while community is empty
8. **Design Gap**: Glassmorphic navigation, gradient buttons, status ring not implemented
9. **Onboarding Missing**: App goes straight to login, no onboarding flow despite design screens

### 14.2 Recommendations

1. **Database is NOT the problem** - All 50 tables exist
2. **Focus on presentation layer** - Connect existing DB tables to UI
3. **Immediate**: Build data layer for community/ (repositories + controllers) using existing tables
4. **High Priority**: Implement nutrition/training screens using existing tables
5. **High Priority**: Remove or implement empty features (chat/, feed/, matching/)
6. **High Priority**: Deduplicate discovery/services models and repositories
