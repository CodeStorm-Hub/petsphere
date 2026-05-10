# 🗺️ PetFolio UI/UX Map

This document provides a comprehensive mapping of the PetFolio application's UI screens, components, database tables, and feature status.

## 1. Core & Navigation
| Feature | Screen | Path | Key Components | DB Tables | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Auth** | Splash | `/splash` | `AnimatedOpacity`, `FlutterLogo` | - | ✅ Stable |
| **Auth** | Login | `/login` | `PetFolioLogo`, `AuthTextField`, `AuthButton` | `auth.users` | ✅ Stable |
| **Auth** | Register | `/register` | `AuthTextField`, `AuthButton` | `auth.users`, `profiles` | ✅ Stable |
| **Shell** | Main Layout | - | `BottomNavigationBar`, `NavigationShell` | - | ✅ Stable |

## 2. Main Features (Bottom Nav)
| Feature | Screen | Path | Key Components | DB Tables | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Home** | Home Screen | `/home` | `StoryBar`, `FeedPostCard`, `ActivityTicker` | `posts`, `stories`, `pets` | ✅ Stable |
| **Match** | Discovery | `/discover` | `TinderCard`, `PetCardActions`, `MatchOverlay` | `pets`, `match_requests` | ✅ Stable |
| **Shop** | Marketplace | `/shop` | `CategoryChips`, `ProductCard`, `PromoCarousel` | `products` | ✅ Stable |
| **Profile** | Pet Profile | `/profile` | `PetHeader`, `StatsGrid`, `MediaGallery` | `pets`, `profiles` | ✅ Stable |

## 3. Secondary Features & Modules
| Feature | Screen | Path | Key Components | DB Tables | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Social** | Create Post | `/create_post` | `ImagePicker`, `CaptionField`, `PetSelector` | `posts` | ✅ Stable |
| **Social** | Create Story | `/create_story` | `CameraPreview`, `FilterOverlay` | `stories` | ✅ Stable |
| **Social** | Post Detail | `/post/:id` | `CommentList`, `PostActions` | `posts`, `comments`, `likes` | ✅ Stable |
| **Social** | Story Viewer | `/story/:petId` | `StoryProgress`, `Gestures` | `stories` | 🚧 Migrated Placeholder |
| **Messaging**| Messages List| `/messages` | `ThreadTile`, `SearchField` | `chat_threads`, `messages` | ✅ Stable |
| **Messaging**| Chat Screen | `/chat/:id` | `MessageBubble`, `ChatInput` | `messages` | ✅ Stable |
| **Market** | Product Detail| `/product/:id` | `ImageCarousel`, `ReviewSection`, `ATCBar` | `products` | ✅ Stable |
| **Market** | Cart | `/cart` | `CartItemTile`, `CheckoutSummary` | - (In-memory/Cache) | ✅ Stable |
| **Market** | Orders | `/orders` | `OrderTile`, `StatusBadge` | `orders` | ✅ Stable |
| **Pet** | Add/Edit Pet | `/add_pet` | `ImageUpload`, `PetForm`, `TypeSelector` | `pets` | ✅ Stable |
| **Health** | Health Dashboard| `/medical_records` | `HealthScore`, `VitalsChart`, `Reminders` | `pet_care_logs`, `vitals` | ✅ Stable |
| **Care** | Care Tracker | `/pet_care` | `TaskCalendar`, `StreakCounter` | `pet_care_logs` | ✅ Stable |
| **Care** | Onboarding | `/pet_care_onboarding` | `GoalSetter`, `PreferenceStep` | `pet_care_onboarding` | ✅ Stable |

## 4. Extended Services (Discovery/More)
| Feature | Screen | Path | Key Components | Status |
| :--- | :--- | :--- | :--- | :--- |
| **Services** | Vet Booking | `/vet_booking` | `DoctorCard`, `CalendarPicker` | ✅ Stable |
| **Services** | Emergency Care| `/emergency_care` | `EmergencyActionCard`, `Map` | ✅ Stable |
| **Services** | Community | `/community_groups` | `GroupCard`, `CategoryGrid` | ✅ Stable |
| **Services** | Lost & Found | `/lost_and_found` | `AlertCard`, `PostForm` | ✅ Stable |
| **Services** | Adoption | `/adoption_center` | `PetCard`, `ApplicationForm` | ✅ Stable |
| **Services** | Training | `/training` | `CourseCard`, `VideoPlayer` | ✅ Stable |
| **Services** | Expenses | `/expenses` | `BudgetChart`, `ExpenseList` | ✅ Stable |
| **Services** | Growth Charts | `/growth_charts` | `WeightChart`, `MilestoneTimeline` | ✅ Stable |
| **Services** | Memorial | `/memorial` | `TributeWall`, `InMemoriamCard` | ✅ Stable |
| **Services** | Pet Places | `/pet_friendly_places` | `Map`, `PlaceTile` | 🚧 Migrated Placeholder |
| **Services** | Events | `/events` | `EventCard`, `Calendar` | 🚧 Migrated Placeholder |
| **Services** | Sitters | `/sitters` | `SitterCard`, `BookingForm` | 🚧 Migrated Placeholder |
| **Services** | Nutrition | `/nutrition_planner` | `MealPlanCard`, `KcalCalc` | ✅ Stable |
| **Services** | Knowledge Base| `/knowledge_base` | `ArticleList`, `CategoryChips` | 🚧 Migrated Placeholder |
| **Services** | Breed ID | `/breed_identifier` | `Camera/AI Analyzer` | 🚧 Disabled Placeholder |

## 5. Design Review & Redesign Plan
### Identified Missing/Redundant Components:
1.  **Consolidated Followers Screen**: Currently duplicated in `pet` and `social`. Should be unified into a single reusable component.
2.  **Visitor Profile Screens**: Currently missing (using placeholders). Need to implement `VisitorPetProfileScreen` and `VisitorUserProfileScreen`.
3.  **Service Placeholders**: Several discovery features are currently placeholders (Events, Places, Sitters, Knowledge Base).
4.  **Floating Action Button (FAB) Consistency**: `PetHealthRecordScreen` has a placeholder "Scan Document" FAB that needs real functionality or a better UI design.

### Aesthetic Refinement Goals (Amber Whisker Style):
*   **Color**: Enforce `#D4845A` as the primary brand seed.
*   **Typography**: Ensure **Playfair Display** (Headlines) and **DM Sans** (Body) are applied globally.
*   **Depth**: Apply multi-layered shadows to all cards in the `Home` and `Marketplace` screens.
*   **Micro-animations**: Add subtle entry animations for cards and list items using `flutter_animate`.

## 6. Implementation Checklist (Next Steps)
- [ ] **Fix Redundancies**: Remove duplicate screens/controllers.
- [ ] **Implement Missing Screens**:
    - [ ] Visitor Pet Profile
    - [ ] Visitor User Profile
    - [ ] Complete Service Placeholders (Events, Places, etc.)
- [ ] **Aesthetic Polish**: Apply brand tokens to all screens.
- [ ] **Routing Refinement**: Ensure all placeholders in `router.dart` are replaced with real screens.
