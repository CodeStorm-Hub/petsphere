# CLAUDE.md - PetSphere Development Guide

This document provides comprehensive guidance for AI assistants working on the PetSphere Flutter application. It explains the codebase structure, architectural patterns, conventions, and workflows for effective collaboration.

---

## Project Overview

**PetSphere** is a comprehensive pet-centric social and marketplace platform built with Flutter. The application enables pet owners to:

- Create and manage pet profiles
- Connect with other pet owners (matching/dating features)
- Share content (posts, stories, updates)
- Manage pet health and care goals
- Participate in a marketplace for pet products
- Communicate via chat and notifications
- Track pet activities and gamified care achievements

**Current Status**: Active development with recent additions for pet care, onboarding, gamification, and UI improvements.

**Target Platforms**: Mobile (iOS/Android) with web support via Flutter Web.

---

## Architecture Overview

PetSphere follows a **layered, feature-based architecture** with clear separation of concerns:

```
lib/
├── main.dart                 # Entry point, app configuration
├── controllers/              # State management (Riverpod Notifiers)
├── models/                   # Data models (Dart classes)
├── repositories/             # Data abstraction layer (Supabase API)
├── views/                    # UI screens and widgets
│   └── components/           # Reusable UI components
├── theme/                    # App theming and design tokens
└── utils/                    # Utilities, helpers, configuration
```

### Architecture Principles

1. **MVC-inspired with Riverpod**: Controllers manage state using Riverpod's `Notifier` pattern; Models define data structures; Views consume state reactively.
2. **Repository Pattern**: All data access flows through repositories (`PetRepository`, `AuthRepository`, etc.), abstracting Supabase details.
3. **Feature-based Organization**: Related controllers, models, and repositories are grouped by feature (auth, pet, health, marketplace, etc.).
4. **Immutable Data**: Models use `copyWith()` for safe mutations; state is immutable and rebuilt via `StateNotifier`.
5. **Reactive UI**: Views use `ConsumerWidget` and `ConsumerStatefulWidget` to watch and rebuild on state changes.

---

## Technology Stack

### Core Framework
- **Flutter**: 3.0+
- **Dart**: 3.0+

### State Management
- **flutter_riverpod** (3.3.1): Modern, tree-shakeable state management
  - `Notifier` classes for state logic
  - `Provider` for read-only values
  - `FutureProvider` for async operations

### Backend & Database
- **Supabase** (2.8.4): PostgreSQL + Realtime + Auth
  - Supabase Flutter SDK for authentication and database access
  - `supabase.from('table_name')` for queries
  - Bucket storage for image uploads (`kBucketPetImages`)

### Routing
- **go_router** (17.1.0): Declarative navigation
  - URL-based routing with deep linking support
  - Type-safe route parameters
  - Auth-based route guards

### UI & Design
- **Material 3**: Latest Material Design language
- **google_fonts** (8.0.2): Custom typography (Playfair Display, DM Sans)
- **cached_network_image** (3.4.1): Image caching and optimization

### Utilities
- **image_picker** (1.1.2): Camera/gallery integration
- **shared_preferences** (2.3.5): Local persistent storage
- **url_launcher** (6.3.1): External URL/app launching
- **video_player** (2.11.1): Video playback
- **share_plus** (13.1.0): Share functionality
- **intl** (0.20.2): Internationalization & formatting

---

## Directory Structure & File Organization

### `/lib/main.dart`
**Single entry point for the application.** Initializes Supabase, sets up Riverpod's `ProviderScope`, applies theme, and configures routing via `go_router`.

```dart
// Pattern: Always use ProviderScope and MaterialApp.router for routing
runApp(const ProviderScope(child: PetSphereApp()));
```

### `/lib/models/`
**Data models representing Supabase tables and domain objects.**

Naming: `*_model.dart` (e.g., `pet_model.dart`, `user_model.dart`)

Each model includes:
- Constructor with required/optional parameters
- `copyWith()` for immutable updates
- `fromJson()` factory for Supabase deserialization
- `toJson()` for Supabase serialization

Example models:
- `PetModel`: Core pet entity with profile data, care goals, vitals
- `UserModel`: User account and profile information
- `PostModel`, `StoryModel`: Social feed content
- `PetHealthModels`: Health tracking (vitals, conditions, medications)
- `PetCareLogModel`: Care activity logs (feeding, exercise, training)
- `CareBadgeModel`: Gamification achievements
- `NotificationModel`: In-app notifications
- `MessageModel`, `ChatThreadModel`: Messaging
- `MatchRequestModel`: Matching/dating features
- `CartItemModel`, `OrderModel`: Marketplace
- `ProductModel`: Marketplace inventory

### `/lib/controllers/`
**Riverpod state management logic.**

Naming: `*_controller.dart` (e.g., `pet_controller.dart`, `auth_controller.dart`)

Pattern: Each controller contains:
1. A **State class** (immutable, holds data)
   - Example: `PetState` with `myPets`, `activePet`, `isLoading`, `error`
   - Includes `copyWith()` for safe updates

2. A **Notifier class** extending `Notifier<State>`
   - `build()` method: Initialization logic, listening to other providers
   - Public methods: State mutations triggered by user actions
   - Private methods: Internal async operations, error handling

3. **Provider declarations** at end of file
   ```dart
   final petProvider = NotifierProvider<PetNotifier, PetState>(PetNotifier.new);
   final selectedPetProvider = StateProvider<PetModel?>((ref) => null);
   ```

Key controllers:
- `auth_controller.dart`: User authentication, session management
- `pet_controller.dart`: Pet profile CRUD, active pet selection
- `health_controller.dart`: Health metrics, vital tracking
- `pet_care_controller.dart`: Care logs, goals, achievements
- `feed_controller.dart`: Posts, stories, social feed
- `marketplace_controller.dart`: Products, cart management
- `match_controller.dart`: Pet matching, connection requests
- `chat_controller.dart`: Messaging, threads
- `notification_controller.dart`: In-app notifications
- `bootstrap_controller.dart`: App initialization, auth hydration

### `/lib/repositories/`
**Data abstraction layer for Supabase interactions.**

Naming: `*_repository.dart` (e.g., `pet_repository.dart`, `auth_repository.dart`)

Pattern: Singleton/static instance
```dart
final petRepository = PetRepository();
```

Each repository provides:
- CRUD methods (`fetch*`, `create*`, `update*`, `delete*`)
- Query methods specific to feature needs
- Image/file upload helpers
- Error handling (exceptions propagate to controllers)

Example structure:
```dart
class PetRepository {
  Future<List<PetModel>> fetchMyPets(String userId) async {
    final data = await supabase
        .from('pets')
        .select()
        .eq('user_id', userId);
    return (data as List<dynamic>)
        .map((e) => PetModel.fromJson(e))
        .toList();
  }
  
  Future<String> uploadPetImage(String petId, File imageFile) async {
    // Storage bucket: 'kBucketPetImages'
  }
}
```

Key repositories:
- `auth_repository.dart`: User registration, login, session
- `pet_repository.dart`: Pet CRUD, image uploads
- `health_repository.dart`: Health records, vitals
- `pet_care_repository.dart`: Care logs, achievements
- `feed_repository.dart`: Post/story creation, feed queries
- `marketplace_repository.dart`: Product browse, cart, orders
- `match_repository.dart`: Match requests, connections
- `chat_repository.dart`: Messages, threads
- `notification_repository.dart`: Notification management
- `follow_repository.dart`: Follow/unfollow relationships

### `/lib/views/`
**UI screens and components.**

Naming: `*_screen.dart` for full screens; `/components/` for reusable widgets

**Screen Pattern**: Each screen is a `ConsumerWidget` or `ConsumerStatefulWidget`

```dart
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch state from controller
    final petState = ref.watch(petProvider);
    
    // Trigger actions
    onPressed: () => ref.read(petProvider.notifier).updatePet(...),
    
    // Build UI
    return Scaffold(...);
  }
}
```

**Key screens**:
- `splash_screen.dart`: App initialization, auth check
- `login_screen.dart`: Authentication UI
- `home_screen.dart`: Main hub, feed, pet profile showcase
- `discovery_screen.dart`: Browse other pets, matchmaking
- `match_pet_profile_screen.dart`: Detailed pet profile with actions
- `add_pet_screen.dart`: Create/edit pet profile
- `health_tab.dart`: Health metrics, care tracking (large, complex screen)
- `marketplace_screen.dart`: Product browsing, cart
- `cart_screen.dart`: Shopping cart, checkout
- `chat_screen.dart`: Messaging interface
- `messages_list_screen.dart`: Message threads list
- `notifications_screen.dart`: Notification center
- `create_post_screen.dart`: Social post creation
- `create_story_screen.dart`: Story creation (ephemeral content)
- `post_detail_screen.dart`: Post view with comments
- `product_detail_screen.dart`: Product details, purchase
- `liked_pets_screen.dart`: Favorites/liked pets
- `main_layout.dart`: Bottom nav, screen container

**Component Pattern**: Private `StatelessWidget` or `StatefulWidget` for reusable UI
```dart
class _PetCard extends StatelessWidget {
  const _PetCard({required this.pet, required this.onTap});
  final PetModel pet;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ...;
}
```

### `/lib/theme/`
**Design system and theming.**

`app_theme.dart`: Centralized `ThemeData` for light/dark modes
- Color palette (primary, secondary, accent, neutral)
- Typography (Playfair Display for headlines, DM Sans for body)
- Component themes (AppBar, Button, Card, TextField)
- Custom design tokens via `ThemeExtension`

Current theme: **"Amber Whisker" (PawSync)** — warm, pet-friendly color palette:
- Primary: `#D4845A` (warm amber)
- Secondary: `#4A7C59` (sage green)
- Background: `#0F0E0C` (near-black)
- Surface: `#1A1814` (dark charcoal)

### `/lib/utils/`
**Helper functions, configuration, and utilities.**

Key files:
- `supabase_config.dart`: Supabase initialization, bucket names
  ```dart
  const supabaseUrl = 'https://...';
  const supabaseAnonKey = '...';
  const kBucketPetImages = 'pet-images';
  ```
- `routes.dart`: GoRouter configuration with all routes and guards
  ```dart
  final routerProvider = Provider<GoRouter>((ref) {
    return GoRouter(
      routes: [
        GoRoute(path: '/', builder: (c, s) => const HomeScreen()),
        // ...
      ],
    );
  });
  ```
- `pet_navigation.dart`: Pet-specific navigation helpers
- `image_upload_helper.dart`: Image picker and upload logic
- `care_calculator.dart`: Pet care metrics computation
- `care_gamification_logic.dart`: Badge/achievement calculation
- `care_personalization.dart`: Care recommendations engine
- `care_cache.dart`: Local caching for care data
- `media_utils.dart`: Image/video utilities
- `bootstrap_controller.dart`: App initialization side-effects

---

## State Management Pattern (Riverpod)

### Core Pattern: Notifier + State

Every feature has a **State class** and a **Notifier class**:

```dart
// 1. State class (immutable)
class PetState {
  final List<PetModel> myPets;
  final bool isLoading;
  final String? error;
  
  PetState copyWith({...}) => ...;
}

// 2. Notifier class
class PetNotifier extends Notifier<PetState> {
  @override
  PetState build() {
    // Initialize, listen to other providers
    ref.listen<AuthState>(authProvider, ...);
    return PetState();
  }
  
  Future<void> loadPets() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final pets = await petRepository.fetchMyPets(userId);
      state = state.copyWith(myPets: pets, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

// 3. Provider
final petProvider = NotifierProvider<PetNotifier, PetState>(PetNotifier.new);
```

### Watching State in Widgets

```dart
// In ConsumerWidget/ConsumerStatefulWidget
final petState = ref.watch(petProvider);

if (petState.isLoading) return LoadingWidget();
if (petState.error != null) return ErrorWidget(petState.error!);
return PetListView(pets: petState.myPets);
```

### Triggering State Changes

```dart
// Read notifier and call methods
onPressed: () async {
  final success = await ref.read(petProvider.notifier).createPet(...);
},

// Or use ref.listen for reactive side-effects
ref.listen<PetState>(petProvider, (prev, next) {
  if (next.error != null) showSnackBar(context, next.error!);
});
```

### Common Provider Types

- **`NotifierProvider`**: Mutable state with methods
- **`StateProvider`**: Simple scalar state
- **`FutureProvider`**: Async single-value (not for long-running)
- **`Provider`**: Read-only computed values
- **`FamilyModifier`**: Parameterized providers (e.g., `fetchPetById(id)`)

---

## Database & API Design

### Supabase Configuration

**File**: `lib/utils/supabase_config.dart`

```dart
const supabaseUrl = 'https://...supabase.co';
const supabaseAnonKey = '...'; // Anonymous key for client
const kBucketPetImages = 'pet-images';
```

Initialized in `main()`:
```dart
await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
final supabase = Supabase.instance.client;
```

### Query Pattern

All queries flow through repositories:

```dart
// Select
final data = await supabase
    .from('pets')
    .select()
    .eq('user_id', userId)
    .order('created_at', ascending: false);

// Insert
final result = await supabase
    .from('pets')
    .insert(petData)
    .select()
    .single();

// Update
final result = await supabase
    .from('pets')
    .update({'name': 'NewName'})
    .eq('id', petId)
    .select()
    .single();

// Delete
await supabase.from('pets').delete().eq('id', petId);
```

### Image/File Storage

**Bucket**: `pet-images`

```dart
// Upload
final path = '$petId/${DateTime.now().millisecondsSinceEpoch}.jpg';
await supabase.storage.from('pet-images').upload(path, file);

// Get public URL
final url = supabase.storage.from('pet-images').getPublicUrl(path);
```

### Data Models & JSON Serialization

Models define schema mapping:

```dart
factory PetModel.fromJson(Map<String, dynamic> json) {
  return PetModel(
    id: json['id'] as String,
    userId: json['user_id'] as String,  // snake_case in DB
    name: json['name'] as String,
    // ...
  );
}

Map<String, dynamic> toJson() => {
  'user_id': userId,                    // Convert back to snake_case
  'name': name,
  // ...
};
```

---

## Navigation (GoRouter)

**File**: `lib/utils/routes.dart`

Declarative, URL-based routing:

```dart
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  
  return GoRouter(
    redirect: (context, state) {
      // Auth guard: redirect unauthenticated users to login
      if (authState.status != AuthStatus.authenticated) {
        return '/login';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (c, s) => const HomeScreen(),
      ),
      GoRoute(
        path: '/pet/:id',
        builder: (c, s) => PetDetailScreen(id: s.pathParameters['id']!),
      ),
      // ...
    ],
  );
});
```

Usage in widgets:
```dart
// Navigate to route
context.go('/pet/123');

// Navigate with params
context.push('/chat/${threadId}');

// Pop
context.pop();
```

---

## Design & Theming

### Color System

Defined in `lib/theme/app_theme.dart`:

```dart
class AppTheme {
  static const Color primaryAccent = Color(0xFFD4845A);   // Warm amber
  static const Color secondaryAccent = Color(0xFF4A7C59); // Sage green
  static const Color background = Color(0xFF0F0E0C);      // Near-black
  static const Color surface = Color(0xFF1A1814);         // Dark charcoal
  static const Color textPrimary = Color(0xFFF2EDE4);     // Off-white
  static const Color textSecondary = Color(0xFFB8B0A4);   // Warm gray
}
```

Accessed in widgets:
```dart
color: Theme.of(context).colorScheme.primary,
textStyle: Theme.of(context).textTheme.titleLarge,
```

### Typography

**Playfair Display** (headlines, hero text):
```dart
GoogleFonts.playfairDisplay(
  fontSize: 24,
  fontWeight: FontWeight.w700,
  letterSpacing: -0.5,
)
```

**DM Sans** (body, UI):
```dart
GoogleFonts.dmSans(
  fontSize: 14,
  fontWeight: FontWeight.w500,
)
```

### Responsive Design

Use `MediaQuery` and `LayoutBuilder`:

```dart
final screenWidth = MediaQuery.of(context).size.width;
final isMobile = screenWidth < 600;

if (isMobile) {
  return MobileLayout();
} else {
  return DesktopLayout();
}
```

---

## Code Conventions & Best Practices

### Naming Conventions

Follow Dart style guide:
- **Classes**: `PascalCase` (e.g., `PetModel`, `PetNotifier`, `HomeScreen`)
- **Variables/Functions**: `camelCase` (e.g., `myPets`, `fetchPet()`)
- **Constants**: `camelCase` (e.g., `kBucketPetImages`)
- **Files**: `snake_case` (e.g., `pet_model.dart`, `health_tab.dart`)
- **Enums**: `PascalCase` values in `camelCase` (e.g., `enum AuthStatus { authenticated, unauthenticated }`)

### Code Quality Rules

1. **Immutability**: Prefer `final`, use `const` constructors liberally
2. **Null Safety**: Avoid `!` unless guaranteed non-null; use `?.` for safe access
3. **Error Handling**: Use `try-catch` at repository/controller layers; propagate errors to UI
4. **Conciseness**: Keep methods short (<20 lines), extract complex logic to helpers
5. **Comments**: Explain "why" not "what"; avoid over-commenting
6. **Avoid `print()`**: Use `developer.log()` from `dart:developer`
7. **No Magic Numbers**: Define constants at top of file or in shared utilities
8. **Linting**: Run `flutter analyze` and fix issues; use `dart fix` for automated fixes

### File Organization

Within each file:
1. Imports (organized: dart, package, relative)
2. Constants & enums
3. Classes/functions
4. Top-level providers (at end)

```dart
// Imports
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet_model.dart';

// Constants
const kDefaultTimeout = Duration(seconds: 30);

// Classes
class PetController { ... }

// Providers
final petProvider = NotifierProvider<PetController, PetState>(...);
```

---

## Testing & Quality Assurance

### Running Tests

```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widgets/

# Integration tests (on device/emulator)
flutter test integration_test/
```

### Test Structure

Follow **Arrange-Act-Assert**:

```dart
test('loadPets updates state with fetched pets', () async {
  // Arrange
  final mockRepo = MockPetRepository();
  when(mockRepo.fetchMyPets).thenAnswer((_) async => [testPet]);
  
  // Act
  final notifier = PetNotifier(mockRepo);
  await notifier.loadPets();
  
  // Assert
  expect(notifier.state.myPets.length, 1);
  expect(notifier.state.isLoading, false);
});
```

### Linting & Analysis

```bash
# Run analyzer
flutter analyze

# Fix issues automatically
dart fix --apply

# Format code
dart format lib/ test/
```

**Configuration**: See `analysis_options.yaml` (includes `flutter_lints`).

---

## Common Development Tasks

### Adding a New Feature

1. **Define Model** (`lib/models/feature_model.dart`)
   - Add fields, `copyWith()`, `fromJson()`, `toJson()`

2. **Create Repository** (`lib/repositories/feature_repository.dart`)
   - Implement CRUD methods querying Supabase
   - Handle errors gracefully

3. **Build Controller** (`lib/controllers/feature_controller.dart`)
   - Define `FeatureState` class
   - Create `FeatureNotifier` extending `Notifier<FeatureState>`
   - Add `build()` initialization and event methods
   - Declare `featureProvider` at end

4. **Build UI Screens** (`lib/views/feature_screen.dart`)
   - Use `ConsumerWidget` to watch state
   - Trigger notifier methods on user actions
   - Handle loading/error states

5. **Add Routing** (update `lib/utils/routes.dart`)
   - Add `GoRoute` entry
   - Wire navigation from other screens

6. **Test** (create `test/controllers/feature_controller_test.dart`)
   - Unit test notifier methods
   - Mock repository
   - Verify state transitions

### Modifying an Existing Feature

1. **Update Model** if schema changes
2. **Update Repository** queries as needed
3. **Update Controller** state/methods
4. **Update Views** to reflect new state shape
5. **Update Tests** for new behavior

### Uploading Images

```dart
// In controller or screen
final ImagePicker picker = ImagePicker();
final XFile? image = await picker.pickImage(source: ImageSource.gallery);

if (image != null) {
  final file = File(image.path);
  final url = await petRepository.uploadPetImage(petId, file);
  // Update state with URL
}
```

### Error Handling

**At Repository**:
```dart
try {
  final data = await supabase.from('pets').select();
  return data.map((e) => PetModel.fromJson(e)).toList();
} on PostgrestException catch (e) {
  throw Exception('Database error: ${e.message}');
} catch (e) {
  throw Exception('Unexpected error: $e');
}
```

**At Controller**:
```dart
try {
  state = state.copyWith(isLoading: true, clearError: true);
  final pets = await petRepository.fetchMyPets(userId);
  state = state.copyWith(myPets: pets, isLoading: false);
} catch (e) {
  state = state.copyWith(error: e.toString(), isLoading: false);
}
```

**At UI**:
```dart
if (state.error != null) {
  return ErrorWidget(
    message: state.error!,
    onRetry: () => ref.refresh(petProvider),
  );
}
```

---

## Development Workflow

### Setting Up Local Environment

```bash
# Install Flutter (see flutter.dev)
flutter --version

# Clone repo
git clone <repo>
cd petsphere

# Install dependencies
flutter pub get

# Build runner (if needed for code generation)
flutter pub run build_runner build

# Run app
flutter run -d <device>
```

### Building & Deployment

```bash
# Debug build (Android)
flutter build apk --debug

# Release build (iOS)
flutter build ios

# Web build
flutter build web
```

### Git Workflow

Follow feature-branch workflow:
```bash
git checkout -b feature/pet-health-tracking
# ... make changes ...
git add .
git commit -m "Add pet health metrics UI"
git push origin feature/pet-health-tracking
# Create PR on GitHub
```

**Branch naming**: `feature/description`, `bugfix/description`, `refactor/description`

**Commit messages**: Concise, imperative ("Add feature" not "Added feature")

---

## Known Patterns & Anti-Patterns

### ✅ DO

- Use `const` constructors for widgets and const values
- Extract complex build logic into private `_WidgetName` classes
- Watch only the state you need: `ref.watch(petProvider.select((s) => s.myPets))`
- Use `copyWith()` for safe state mutations
- Define providers at file end, controllers in separate files
- Use `try-catch` at boundaries (repo/controller); let errors propagate

### ❌ DON'T

- Don't call `notifier.state = ...` directly; use methods like `loadPets()`
- Don't use `print()` for debugging; use `developer.log()`
- Don't build large widgets in a single `build()` method; extract components
- Don't mutate models; create new instances with `copyWith()`
- Don't ignore Null Safety warnings
- Don't hardcode colors/strings; use `AppTheme` and i18n
- Don't perform async operations directly in `build()`

---

## Troubleshooting & Common Issues

### Build Errors

```bash
# Clean build artifacts
flutter clean

# Reinstall dependencies
flutter pub get

# Run on specific device
flutter devices
flutter run -d <device_id>
```

### State Not Updating

- Ensure you're watching the provider, not reading it
- Verify `copyWith()` creates a new instance (not mutating existing)
- Check that notifier method is updating state before returning

### Routing Issues

- Verify route path is in `GoRouter` configuration
- Check route guard logic in `redirect`
- Use `context.go()` to replace current route; `context.push()` to stack

### Supabase Errors

- Verify auth token is valid: `Supabase.instance.client.auth.currentUser`
- Check RLS (Row Level Security) policies on tables
- Ensure storage bucket exists and is public for read access

---

## Collaboration Guidelines for AI Assistants

### Before Making Changes

1. **Read the existing code** for the feature area to understand patterns
2. **Check related files** (models, repositories, controllers, views)
3. **Ask clarifying questions** if requirements are ambiguous
4. **Follow established conventions** in the codebase

### When Making Changes

1. **Maintain consistency** with existing code style and patterns
2. **Update all related layers** (model → repository → controller → view)
3. **Preserve immutability** and null safety
4. **Add descriptive comments** for non-obvious logic
5. **Test changes locally** before considering done

### When Adding Features

1. **Start from the model** and work upward (model → repo → controller → view)
2. **Write for clarity** over cleverness
3. **Add error handling** at repository and controller layers
4. **Update routing** if new screens are needed
5. **Consider edge cases** (empty states, errors, loading)

### Recommended Reading Order for New Features

1. `lib/models/` — understand data structures
2. `lib/repositories/` — understand data access patterns
3. `lib/controllers/` — understand state management
4. `lib/views/` — understand UI and how it consumes state
5. `lib/utils/routes.dart` — understand navigation

---

## File References

- **Core Configuration**: `lib/main.dart`, `lib/utils/supabase_config.dart`
- **Routing**: `lib/utils/routes.dart`
- **Theme**: `lib/theme/app_theme.dart`
- **Linting**: `analysis_options.yaml`
- **Dependencies**: `pubspec.yaml`
- **Flutter Style Guide**: Referenced external file `rules.md` (see root directory)

---

## Additional Resources

- [Flutter Docs](https://docs.flutter.dev/)
- [Riverpod Docs](https://riverpod.dev/)
- [GoRouter Docs](https://pub.dev/packages/go_router)
- [Supabase Flutter Docs](https://supabase.com/docs/reference/flutter/introduction)
- [Effective Dart](https://dart.dev/effective-dart)
- [Material Design 3](https://m3.material.io/)

---

**Last Updated**: April 2026
**Maintained by**: PetSphere Development Team
