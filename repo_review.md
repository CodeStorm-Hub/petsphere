# PetSphere Repository Review

## 1. Project Objective
PetSphere is a Flutter-based mobile application acting as a social network and dating platform for pets. It includes features for pet discovery (dating/matching), a social feed for posting pet updates, a chat system for matched pets, and a marketplace for pet-related products.

## 2. Features and Functionalities
- **Authentication:** User registration and login (via Supabase Auth).
- **Pet Profiles:** Users can add and manage pet profiles with details like name, breed, age, and images.
- **Discovery & Matching:** Swiping/liking mechanism to match pets. Tracks pending, matched, and rejected requests.
- **Social Feed:** A feed showing posts (images/text) from pets. Supports liking and commenting on posts.
- **Chat System:** Real-time messaging between matched pets.
- **Marketplace:** An e-commerce section to browse and purchase pet products. Includes a shopping cart and order history.
- **Notifications:** System to alert users about matches, messages, and other interactions.

## 3. Architecture & System Design
The project follows a **Controller-Repository-Model (CRM)** architecture (similar to Clean Architecture principles) coupled with **Riverpod** for state management and Dependency Injection:
- **Views (`lib/views/`):** Flutter UI components (Widgets and Screens). Uses `go_router` for declarative navigation.
- **Controllers (`lib/controllers/`):** Riverpod `Notifier` classes that hold business logic, manage UI state, and communicate with repositories.
- **Repositories (`lib/repositories/`):** Data access layer handling external API calls (Supabase DB, Auth, and Storage).
- **Models (`lib/models/`):** Data transfer objects (DTOs) with JSON serialization mapping to Supabase tables.

## 4. Tech Stack
- **Frontend:** Flutter & Dart
- **State Management & DI:** `flutter_riverpod`
- **Routing:** `go_router`
- **Backend as a Service (BaaS):** Supabase (PostgreSQL DB, Auth, Storage)
- **Other Libraries:** `image_picker`, `share_plus`, `url_launcher`, `cached_network_image`, `google_fonts`

## 5. Security & Authentication
- **Auth Provider:** Supabase Auth (Email/Password implemented, easily extensible to OAuth).
- **Security Practices Needed:** Currently, Supabase keys are hardcoded in `lib/utils/supabase_config.dart`. They should be moved to environment variables (`.env` or `--dart-define`).
- Row Level Security (RLS) is presumably handled on the Supabase side (indicated by `supabase/table_policies.sql`).

## 6. DB Schema & ERD (Inferred)
- **`users`**: id, email, name, profile_image_url, bio, location
- **`pets`**: id, user_id (FK to users), name, breed, animal_type, age, images, etc.
- **`posts`**: id, pet_id (FK to pets), media_url, caption, created_at
- **`comments`**: id, pet_id (FK to pets), post_id (FK to posts), text, created_at
- **`match_requests`**: id, sender_pet_id, receiver_pet_id, status
- **`chat_threads`**: id, pet_id_1, pet_id_2, last_message_id, unread_count
- **`messages`**: id, thread_id (FK to chat_threads), sender_pet_id, text, created_at, is_read
- **`products`**: id, vendor_id, name, price, stock, category
- **`orders` / `order_items`**: User purchase history.
- **`notifications`**: user_id, actor_pet_id, type, title, is_read

## 7. User Stories
- As a pet owner, I want to create a profile for my pet so other pets can discover them.
- As a user, I want to swipe on other pet profiles to find playdates or breeding partners.
- As a user, I want to post pictures of my pet to a social feed so my followers can see them.
- As a matched pet owner, I want to chat with the other pet's owner to arrange a meetup.
- As a user, I want to buy pet food and accessories from the marketplace.

## 8. Suggested New Features & Non-functional implementations
### Missing/Incomplete Features (from `cursor-flutter-priority-tasks.md`)
- **Deep Links:** Implement robust fetching logic for `/post/:id` and `/product/:id`.
- **State UX:** Add empty states when no `activePet` is selected in match/chat tabs.
- **Chat Orchestration:** Automatically create a `chat_thread` upon a successful match.
- **Password Reset:** Implement forgot password flow.

### Performance Optimizations
- **Image Caching:** Heavy reliance on `cached_network_image`. Ensure proper `cacheExtent` on infinite lists (Feed/Marketplace).
- **Pagination:** Feed and Marketplace endpoints need pagination (cursor or offset-based) to handle large datasets efficiently.
- **`const` Constructors:** Enforce strict linting for `const` widgets to reduce rebuilds.

### UI/UX Review Analysis
- Ensure touch targets are >= 48x48 logical pixels.
- Implement proper error states (e.g., global `errorBuilder` in GoRouter).
- A11y (Accessibility): Add `Semantics` tags to icon buttons and ensure contrast ratios meet WCAG standards.

### Security Enhancements
- Remove hardcoded `supabaseAnonKey` and `supabaseUrl` from `lib/utils/supabase_config.dart` and use `flutter_dotenv` or `--dart-define`.
- Validate all user inputs and UUIDs (using `lib/utils/validation_utils.dart`).
