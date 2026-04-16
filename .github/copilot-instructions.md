# PetSphere – Copilot Agent Instructions

## Project overview

PetSphere is a Flutter mobile application that combines a **pet social network** (Instagram-style feed), **pet matching** (Tinder-style discovery), and a **pet product marketplace** into one app. Users register, create pet profiles, post to a feed, discover other pets for companionship/breeding matches, chat in real time, and shop for pet products.

---

## Technology stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart SDK ^3.11.4) |
| State management | Riverpod 3.x (`flutter_riverpod`) |
| Navigation | go_router 17.x |
| Backend / DB | Supabase (PostgreSQL + Auth + Storage + Realtime) |
| Fonts | Google Fonts – Nunito (`google_fonts`) |
| Image picking | `image_picker` |
| Localisation utils | `intl` |

---

## Repository layout

```
lib/
  main.dart                    # Entry point; initialises Supabase, wraps app in ProviderScope
  theme/
    app_theme.dart             # AppTheme.lightTheme (Material 3, Nunito font)
  utils/
    supabase_config.dart       # Supabase client, credentials, bucket name constants
    routes.dart                # routerProvider (GoRouter + auth redirect guards)
    image_upload_helper.dart   # ImageUploadHelper static methods for pick & upload
  models/                      # Pure Dart data classes (fromJson / toJson / copyWith)
    user_model.dart
    pet_model.dart
    post_model.dart            # Also contains CommentModel
    product_model.dart
    cart_item_model.dart
    chat_thread_model.dart
    message_model.dart
    match_request_model.dart
  repositories/                # Data-access layer – direct Supabase calls; file-level singletons
    auth_repository.dart
    pet_repository.dart
    feed_repository.dart
    marketplace_repository.dart
    match_repository.dart
    chat_repository.dart
  controllers/                 # Riverpod Notifiers – one per feature; file-level providers
    auth_controller.dart
    pet_controller.dart
    feed_controller.dart
    marketplace_controller.dart
    match_controller.dart
    chat_controller.dart
    cart_controller.dart
  views/                       # Flutter screens (one file per screen)
    splash_screen.dart
    login_screen.dart
    registration_screen.dart
    main_layout.dart           # 5-tab bottom nav shell
    home_screen.dart           # Social feed
    discovery_screen.dart      # Pet matching / swipe
    pet_profile_screen.dart    # Current user's pet profile
    match_pet_profile_screen.dart
    create_post_screen.dart
    messages_list_screen.dart
    chat_screen.dart
    marketplace_screen.dart
    product_detail_screen.dart
    cart_screen.dart
    notifications_screen.dart
```

---

## Running, linting, and testing

```bash
# Run on a connected device / emulator
flutter run

# Static analysis (run before committing)
flutter analyze

# Unit / widget tests
flutter test
```

> **No `.env` file or `--dart-define` flags are needed.** Supabase credentials are hardcoded constants in `lib/utils/supabase_config.dart`.

---

## Supabase configuration

`lib/utils/supabase_config.dart` contains:

- `supabaseUrl` / `supabaseAnonKey` – hardcoded compile-time constants.
- `supabase` – a getter returning `Supabase.instance.client`. Use this throughout the app instead of importing the client directly.
- Storage bucket name constants: `kBucketPetImages`, `kBucketPostMedia`, `kBucketProductImages`.

Supabase is initialised in `main()` before `runApp`. Any code that calls `Supabase.instance.client` before `main()` completes will throw a `StateError`.

### Database tables

| Table | Key columns |
|---|---|
| `profiles` | `id` (= auth UID), `name`, `profile_image_url` |
| `pets` | `id`, `user_id`, `name`, `breed`, `animal_type`, `age`, `bio`, `profile_image_url`, `images[]`, `is_public_owner` |
| `posts` | `id`, `pet_id`, `media_url`, `caption`, `created_at` |
| `post_likes` | `id`, `post_id`, `pet_id` |
| `comments` | `id`, `post_id`, `pet_id`, `text`, `created_at` |
| `products` | `id`, `name`, `price`, `vendor_id`, `description`, `images[]`, `stock`, `category` |
| `orders` | `id`, `user_id`, `items` (JSONB), `total`, `status` |
| `match_requests` | `id`, `sender_pet_id`, `receiver_pet_id`, `status` (`pending`/`matched`/`rejected`) |
| `chat_threads` | `id`, `pet_id_1`, `pet_id_2`, `created_at` |
| `messages` | `id`, `thread_id`, `sender_pet_id`, `text`, `is_read`, `created_at` |

Supabase Realtime is used for live message delivery in `chat_repository.dart` via `subscribeToMessages`.

---

## Architecture conventions

### Layered architecture

```
Views → Controllers (Notifiers) → Repositories → Supabase
```

- **Views** consume providers via `ConsumerWidget` / `ConsumerStatefulWidget` and call methods on notifiers.
- **Controllers** hold all business logic and own their `XxxState`.
- **Repositories** are plain Dart classes with async methods that call Supabase directly. Each repository file exports a file-level singleton (`final petRepository = PetRepository()`).
- **Models** are pure Dart data classes with no Flutter dependency.

### State class pattern

Every feature has a dedicated `XxxState` class that follows this shape:

```dart
class XxxState {
  final List<Item> items;
  final bool isLoading;
  final String? error;

  XxxState({...});

  XxxState copyWith({..., bool clearError = false}) { ... }
}
```

Always update state through `copyWith`; never replace it with a raw constructor unless you intend to reset all fields.

### Riverpod Notifier pattern

All controllers extend `Notifier<XxxState>` and are exposed through `NotifierProvider`:

```dart
class XxxController extends Notifier<XxxState> {
  @override
  XxxState build() {
    // Kick off initial async load directly from build().
    // Return an initial state (usually with isLoading: true).
    _fetchData();
    return XxxState(isLoading: true);
  }
}

final xxxProvider = NotifierProvider<XxxController, XxxState>(XxxController.new);
```

**Important**: Async loaders are called directly inside `build()` (not wrapped in `Future.microtask`). Returning the initial state synchronously while the async call runs is the established pattern.

### Convenience providers

Derived read-only providers are defined at the bottom of the controller file:

```dart
final activePetProvider = Provider<PetModel?>((ref) {
  return ref.watch(petProvider).activePet;
});
```

### Optimistic updates

Likes, chat messages, and match actions use optimistic updates: mutate local state first, then call the server, and roll back on failure. See `feed_controller.dart` (toggleLike) and `chat_controller.dart` (sendMessage) for examples.

---

## Navigation

Navigation is handled by **go_router** via `routerProvider` in `lib/utils/routes.dart`.

Named routes:

| Path | Screen |
|---|---|
| `/splash` | SplashScreen |
| `/login` | LoginScreen |
| `/register` | RegistrationScreen |
| `/home` | MainLayout (tab shell) |
| `/create_post` | CreatePostScreen |
| `/notifications` | NotificationsScreen |
| `/pet/:id` | MatchPetProfileScreen |
| `/messages` | MessagesListScreen |
| `/chat/:threadId` | ChatScreen |
| `/cart` | CartScreen |
| `/product/:id` | ProductDetailScreen |

The router watches `authProvider` and redirects unauthenticated users to `/login` and authenticated users away from auth screens to `/home`.

Navigate with `context.go('/path')` (replace) or `context.push('/path')` (stack). The create-post button in the bottom nav uses `context.push('/create_post')`.

---

## UI and theming

- **Theme**: Material 3 via `AppTheme.lightTheme` in `lib/theme/app_theme.dart`.
- **Primary colour**: `#FF8A65` (warm peach/orange).
- **Secondary colour**: `#4FC3F7` (light blue).
- **Font**: Nunito via `google_fonts`.
- All screens consume `Theme.of(context).colorScheme` – avoid hardcoding colours.
- The bottom nav is a 5-tab `BottomNavigationBar` in `MainLayout`; tab index 2 pushes `/create_post` as a modal instead of switching tabs.

---

## Image upload

Use `ImageUploadHelper` (`lib/utils/image_upload_helper.dart`) for all image pick-and-upload operations:

```dart
// Pick from gallery and upload in one call
final url = await ImageUploadHelper.pickAndUpload(
  bucket: kBucketPetImages,
  folder: petId,
);
```

The helper uploads with `upsert: true` and returns the public URL.

---

## Auth flow

1. `AuthNotifier` (in `auth_controller.dart`) listens to `supabase.auth.onAuthStateChange` and also calls `_checkCurrentSession()` on startup.
2. `AuthStatus` has three values: `initial`, `unauthenticated`, `authenticated`.
3. User profiles are stored in the `profiles` table (upserted on registration).
4. Logout is a simple `supabase.auth.signOut()` followed by resetting auth state.

---

## Known issues and workarounds

- **Supabase credentials in source**: `supabaseUrl` and `supabaseAnonKey` are committed as plaintext in `lib/utils/supabase_config.dart`. This is intentional for development convenience on this project; do not rotate the keys without updating this file.
- **Cart is in-memory only**: `CartController` stores cart items in local Riverpod state. Cart is cleared after a successful order. There is no persistence across app restarts.
- **Chat Realtime subscription lifecycle**: `ThreadMessagesNotifier` intentionally does **not** auto-dispose so the Realtime subscription survives soft navigations. The channel is cancelled in `ref.onDispose`.
- **Match request filtering edge case**: `MatchRepository.fetchDiscoveryPets` manually builds a NOT IN clause by querying sent and received requests separately. If the set is empty, Supabase may error on an empty IN list – handle accordingly when modifying this query.
