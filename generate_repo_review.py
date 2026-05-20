import os
import json

def generate_review():
    md_content = "# PetSphere Repository Review\n\n"
    md_content += "## 1. Project Objective\n"
    md_content += "PetSphere is a Flutter-based mobile application acting as a social network and dating platform for pets. It includes features for pet discovery (dating/matching), a social feed for posting pet updates, a chat system for matched pets, and a marketplace for pet-related products.\n\n"

    md_content += "## 2. Features and Functionalities\n"
    md_content += "- **Authentication:** User registration and login (via Supabase Auth).\n"
    md_content += "- **Pet Profiles:** Users can add and manage pet profiles with details like name, breed, age, and images.\n"
    md_content += "- **Discovery & Matching:** Swiping/liking mechanism to match pets. Tracks pending, matched, and rejected requests.\n"
    md_content += "- **Social Feed:** A feed showing posts (images/text) from pets. Supports liking and commenting on posts.\n"
    md_content += "- **Chat System:** Real-time messaging between matched pets.\n"
    md_content += "- **Marketplace:** An e-commerce section to browse and purchase pet products. Includes a shopping cart and order history.\n"
    md_content += "- **Notifications:** System to alert users about matches, messages, and other interactions.\n\n"

    md_content += "## 3. Architecture & System Design\n"
    md_content += "The project follows a **Controller-Repository-Model (CRM)** architecture (similar to Clean Architecture principles) coupled with **Riverpod** for state management and Dependency Injection:\n"
    md_content += "- **Views (`lib/views/`):** Flutter UI components (Widgets and Screens). Uses `go_router` for declarative navigation.\n"
    md_content += "- **Controllers (`lib/controllers/`):** Riverpod `Notifier` classes that hold business logic, manage UI state, and communicate with repositories.\n"
    md_content += "- **Repositories (`lib/repositories/`):** Data access layer handling external API calls (Supabase DB, Auth, and Storage).\n"
    md_content += "- **Models (`lib/models/`):** Data transfer objects (DTOs) with JSON serialization mapping to Supabase tables.\n\n"

    md_content += "## 4. Tech Stack\n"
    md_content += "- **Frontend:** Flutter & Dart\n"
    md_content += "- **State Management & DI:** `flutter_riverpod`\n"
    md_content += "- **Routing:** `go_router`\n"
    md_content += "- **Backend as a Service (BaaS):** Supabase (PostgreSQL DB, Auth, Storage)\n"
    md_content += "- **Other Libraries:** `image_picker`, `share_plus`, `url_launcher`, `cached_network_image`, `google_fonts`\n\n"

    md_content += "## 5. Security & Authentication\n"
    md_content += "- **Auth Provider:** Supabase Auth (Email/Password implemented, easily extensible to OAuth).\n"
    md_content += "- **Security Practices Needed:** Currently, Supabase keys are hardcoded in `lib/utils/supabase_config.dart`. They should be moved to environment variables (`.env` or `--dart-define`).\n"
    md_content += "- Row Level Security (RLS) is presumably handled on the Supabase side (indicated by `supabase/table_policies.sql`).\n\n"

    md_content += "## 6. DB Schema & ERD (Inferred)\n"
    md_content += "- **`users`**: id, email, name, profile_image_url, bio, location\n"
    md_content += "- **`pets`**: id, user_id (FK to users), name, breed, animal_type, age, images, etc.\n"
    md_content += "- **`posts`**: id, pet_id (FK to pets), media_url, caption, created_at\n"
    md_content += "- **`comments`**: id, pet_id (FK to pets), post_id (FK to posts), text, created_at\n"
    md_content += "- **`match_requests`**: id, sender_pet_id, receiver_pet_id, status\n"
    md_content += "- **`chat_threads`**: id, pet_id_1, pet_id_2, last_message_id, unread_count\n"
    md_content += "- **`messages`**: id, thread_id (FK to chat_threads), sender_pet_id, text, created_at, is_read\n"
    md_content += "- **`products`**: id, vendor_id, name, price, stock, category\n"
    md_content += "- **`orders` / `order_items`**: User purchase history.\n"
    md_content += "- **`notifications`**: user_id, actor_pet_id, type, title, is_read\n\n"

    md_content += "## 7. User Stories\n"
    md_content += "- As a pet owner, I want to create a profile for my pet so other pets can discover them.\n"
    md_content += "- As a user, I want to swipe on other pet profiles to find playdates or breeding partners.\n"
    md_content += "- As a user, I want to post pictures of my pet to a social feed so my followers can see them.\n"
    md_content += "- As a matched pet owner, I want to chat with the other pet's owner to arrange a meetup.\n"
    md_content += "- As a user, I want to buy pet food and accessories from the marketplace.\n\n"

    md_content += "## 8. Suggested New Features & Non-functional implementations\n"
    md_content += "### Missing/Incomplete Features (from `cursor-flutter-priority-tasks.md`)\n"
    md_content += "- **Deep Links:** Implement robust fetching logic for `/post/:id` and `/product/:id`.\n"
    md_content += "- **State UX:** Add empty states when no `activePet` is selected in match/chat tabs.\n"
    md_content += "- **Chat Orchestration:** Automatically create a `chat_thread` upon a successful match.\n"
    md_content += "- **Password Reset:** Implement forgot password flow.\n\n"

    md_content += "### Performance Optimizations\n"
    md_content += "- **Image Caching:** Heavy reliance on `cached_network_image`. Ensure proper `cacheExtent` on infinite lists (Feed/Marketplace).\n"
    md_content += "- **Pagination:** Feed and Marketplace endpoints need pagination (cursor or offset-based) to handle large datasets efficiently.\n"
    md_content += "- **`const` Constructors:** Enforce strict linting for `const` widgets to reduce rebuilds.\n\n"

    md_content += "### UI/UX Review Analysis\n"
    md_content += "- Ensure touch targets are >= 48x48 logical pixels.\n"
    md_content += "- Implement proper error states (e.g., global `errorBuilder` in GoRouter).\n"
    md_content += "- A11y (Accessibility): Add `Semantics` tags to icon buttons and ensure contrast ratios meet WCAG standards.\n\n"

    md_content += "### Security Enhancements\n"
    md_content += "- Remove hardcoded `supabaseAnonKey` and `supabaseUrl` from `lib/utils/supabase_config.dart` and use `flutter_dotenv` or `--dart-define`.\n"
    md_content += "- Validate all user inputs and UUIDs (using `lib/utils/validation_utils.dart`).\n\n"

    with open('repo_review.md', 'w') as f:
        f.write(md_content)

    print("Review generated at repo_review.md")

if __name__ == "__main__":
    generate_review()
