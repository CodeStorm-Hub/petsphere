# Flutter Tech Stack Research Report — 2025-2026

Generated: 2026-04-26  
Applies to: PetSphere Flutter app (Flutter 3.41.x / Dart 3.11.x)

---

## Table of Contents

1. [Flutter 3.41.x / Dart 3.11.x](#1-flutter-341x--dart-311x)
2. [Riverpod 3.x](#2-riverpod-3x)
3. [go_router 17.x](#3-go_router-17x)
4. [supabase_flutter 2.12.x](#4-supabase_flutter-212x)
5. [image_picker 1.x](#5-image_picker-1x)
6. [share_plus: Migration 10.x → 13.x](#6-share_plus-migration-10x--13x)
7. [Flutter Security Best Practices](#7-flutter-security-best-practices)
8. [Flutter Testing Best Practices 2025-2026](#8-flutter-testing-best-practices-2025-2026)
9. [Supabase RLS Best Practices 2025-2026](#9-supabase-rls-best-practices-2025-2026)
10. [Flutter Performance Best Practices 2025-2026](#10-flutter-performance-best-practices-2025-2026)

---

## 1. Flutter 3.41.x / Dart 3.11.x

### 1.1 Key New Features (2025-2026)

| Feature | Detail |
|---|---|
| **Impeller default** | Default renderer on iOS and Android API 29+ — eliminates shader compilation jank |
| **Dart dot shorthands** | Concise enum/constructor syntax (`.new`, `.start`) introduced in Dart 3.10 (Flutter 3.38) |
| **Widget Previewer** | Experimental: preview widgets in IDEs and browsers without running the full app |
| **Android 16KB page alignment** | Flutter 3.38+ supports Android 16KB page size required for new Pixel hardware |
| **Java 17 required** | Android builds now require Java 17+ |
| **Web hot reload (stable)** | `flutter run -d chrome` now supports stable hot reload |
| **iOS 11/12 dropped** | Minimum iOS deployment target raised to iOS 13 |
| **Wasm (near-default)** | WebAssembly compilation is approaching default for Flutter web |

### 1.2 Impeller — The New Rendering Engine

Impeller replaces Skia as the GPU renderer. It precompiles shaders at build time, eliminating the "first-frame jank" caused by runtime shader compilation.

**Performance impact:**
- ~50% reduction in frame rasterization time on supported hardware
- 120fps as the new baseline on capable devices
- Uses tile-based GPU rendering (~256×256 pixel tiles) to minimize redundant work

**Enabling Impeller:**
- iOS: enabled by default (no action needed)
- Android: enabled by default on API 29+ as of Flutter 3.27+
- To opt out for debugging: `--no-enable-impeller`

**Optimization techniques with Impeller:**

```dart
// Use RepaintBoundary to isolate complex or animated subtrees
RepaintBoundary(
  child: ComplexAnimationWidget(),
)

// Combine frequently used textures into atlases — reduces GPU texture bindings
// Configure via flutter.yaml shader warmup manifest for frequently used shaders
```

Profile using `flutter run --profile` and Flutter DevTools GPU thread view, not debug mode.

### 1.3 App Architecture Best Practices

Both "feature-first" and "layer-first" structures are used in production apps; the consensus in 2025-2026 leans **feature-first for medium-to-large apps**.

**Feature-first (recommended for PetSphere):**
```
lib/
  features/
    feed/
      data/          # repositories, data sources
      domain/        # models, use cases
      presentation/  # screens, widgets, controllers
    profile/
    marketplace/
    chat/
  core/              # shared utilities, theme, routing
```

**Layer-first (simpler, fine for small apps):**
```
lib/
  models/
  repositories/
  controllers/
  views/
```

**Current PetSphere structure** is layer-first. Migrating to feature-first would improve code discoverability and team scalability.

**Key architectural principles for 2026:**
- Strict separation: UI → Domain → Data
- One consistent state management solution (Riverpod) — never mix with Provider or BLoC
- All controllers/notifiers must be tested in isolation
- Use `const` constructors everywhere possible
- Keep `build()` methods free of business logic

### 1.4 Deep Linking — Android App Links & iOS Universal Links

**Android App Links setup (`AndroidManifest.xml`):**
```xml
<activity android:name=".MainActivity" ...>
  <intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="https" android:host="yourdomain.com" />
  </intent-filter>
</activity>
```

Host at `https://yourdomain.com/.well-known/assetlinks.json`:
```json
[{
  "relation": ["delegate_permission/common.handle_all_urls"],
  "target": {
    "namespace": "android_app",
    "package_name": "com.yourcompany.petsphere",
    "sha256_cert_fingerprints": ["<YOUR_SHA256_FINGERPRINT>"]
  }
}]
```

**iOS Universal Links setup (Xcode):**
1. Xcode → Signing & Capabilities → Add "Associated Domains" → `applinks:yourdomain.com`
2. Host at `https://yourdomain.com/.well-known/apple-app-site-association`:
```json
{
  "applinks": {
    "details": [{
      "appID": "TEAMID.com.yourcompany.petsphere",
      "paths": ["/*"]
    }]
  }
}
```

**Testing deep links:**
```bash
# Android
adb shell am start -a android.intent.action.VIEW \
  -c android.intent.category.BROWSABLE \
  -d "https://yourdomain.com/pet/123" com.yourcompany.petsphere

# iOS Simulator
xcrun simctl openurl booted "https://yourdomain.com/pet/123"
```

### 1.5 App Signing Best Practices

**Android release signing:**
```groovy
// android/app/build.gradle
android {
  signingConfigs {
    release {
      keyAlias keystoreProperties['keyAlias']
      keyPassword keystoreProperties['keyPassword']
      storeFile file(keystoreProperties['storeFile'])
      storePassword keystoreProperties['storePassword']
    }
  }
  buildTypes {
    release {
      signingConfig signingConfigs.release
      minifyEnabled true
      shrinkResources true
    }
  }
}
```

```properties
# android/key.properties (add to .gitignore!)
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path-to-keystore>
```

**iOS:** Use Xcode automatic signing for development; use App Store Connect / Fastlane for CI/CD. Never commit `.p12` or provisioning profiles.

**Build commands for release:**
```bash
flutter build apk --release --obfuscate --split-debug-info=build/debug-info
flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info
flutter build ipa --release --obfuscate --split-debug-info=build/debug-info
```

### 1.6 Breaking Changes Reference

Always check: https://docs.flutter.dev/release/breaking-changes

Run after upgrading:
```bash
dart fix --apply
flutter analyze
```

Key changes relevant to PetSphere (Flutter 3.27–3.41):
- `GoRouter.location` removed — use `GoRouterState.of(context).uri.toString()`
- `Color` APIs: `Color.value` deprecated in favor of `.r`, `.g`, `.b`, `.a` components
- `Material 3` is now the default theme; `useMaterial3: false` is needed to keep M2

---

## 2. Riverpod 3.x

### 2.1 What's New in Riverpod 3 (Released September 2025)

Riverpod 3.0 is a major redesign. Released September 2025.

| Feature | Details |
|---|---|
| **Automatic retry** | Failed providers automatically retry; configurable per-provider or globally |
| **Pause/Resume** | Providers automatically pause when their listeners are offscreen |
| **`Ref.mounted`** | Safe check after `await` to prevent accessing disposed providers |
| **Mutations (experimental)** | First-class side-effect management with `Mutation` objects |
| **Offline persistence (experimental)** | State caching to SQLite/Hive across app restarts |
| **`ProviderContainer.test()`** | Simplified test containers with automatic disposal |

### 2.2 Breaking Changes: 2.x → 3.x Migration

```dart
// BEFORE (Riverpod 2.x)
import 'package:flutter_riverpod/flutter_riverpod.dart';

final counterProvider = StateProvider<int>((ref) => 0);

class MyNotifier extends StateNotifier<MyState> {
  MyNotifier() : super(MyState.initial());
}
final myProvider = StateNotifierProvider<MyNotifier, MyState>((ref) => MyNotifier());

// AutoDispose variants used explicitly
class MyAutoNotifier extends AutoDisposeAsyncNotifier<Data> { ... }
final autoProvider = AsyncNotifierProvider.autoDispose<MyAutoNotifier, Data>(
  MyAutoNotifier.new,
);
```

```dart
// AFTER (Riverpod 3.x)
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Legacy providers moved to:
import 'package:flutter_riverpod/legacy.dart'; // StateProvider, StateNotifierProvider

// Modern approach - use Notifier/AsyncNotifier directly
class MyNotifier extends Notifier<MyState> {
  @override
  MyState build() => MyState.initial();
  
  void increment() => state = state.copyWith(count: state.count + 1);
}
final myProvider = NotifierProvider<MyNotifier, MyState>(MyNotifier.new);

// AutoDispose is now handled via keepAlive or via code generation
class MyAsyncNotifier extends AsyncNotifier<Data> {
  @override
  Future<Data> build() => fetchData();
}
final asyncProvider = AsyncNotifierProvider<MyAsyncNotifier, Data>(MyAsyncNotifier.new);
// No more AutoDispose prefix classes
```

**Other key changes:**
```dart
// AsyncValue: valueOrNull is deprecated
// BEFORE:
final value = ref.watch(myProvider).valueOrNull;
// AFTER:
final value = ref.watch(myProvider).value; // same behavior

// Equality filtering: now uses == instead of identical()
// Ensure your state classes implement == (use freezed or equatable)

// ref.mounted — use after await gaps
Future<void> refresh() async {
  await someAsyncOperation();
  if (!ref.mounted) return; // NEW in 3.x — prevents use after dispose
  state = AsyncData(result);
}
```

### 2.3 Best Practices for NotifierProvider & AsyncNotifierProvider

```dart
// ✅ GOOD: Lean notifiers with single responsibility
@riverpod
class PetFeedNotifier extends _$PetFeedNotifier {
  @override
  Future<List<Pet>> build() => ref.watch(petRepositoryProvider).fetchFeed();
  
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(petRepositoryProvider).fetchFeed());
  }
  
  Future<void> like(String petId) async {
    // Optimistic update
    final previous = state;
    state = state.whenData((pets) => 
      pets.map((p) => p.id == petId ? p.copyWith(liked: true) : p).toList()
    );
    try {
      await ref.read(petRepositoryProvider).likePet(petId);
    } catch (e) {
      state = previous; // rollback on failure
    }
  }
}
```

```dart
// ✅ GOOD: Repository as a simple provider (no state)
@riverpod
PetRepository petRepository(Ref ref) {
  final client = ref.watch(supabaseClientProvider);
  return PetRepository(client);
}

// ✅ GOOD: Family providers with stable equality
@riverpod
Future<Pet> petDetail(Ref ref, String petId) {
  return ref.watch(petRepositoryProvider).fetchPet(petId);
}
```

```dart
// ❌ BAD: Calling ref.read inside build()
class BadNotifier extends Notifier<int> {
  @override
  int build() {
    final value = ref.read(someProvider); // Don't read inside build, use watch
    return value;
  }
}

// ❌ BAD: Heavy logic inside build()
class BadAsyncNotifier extends AsyncNotifier<List<Pet>> {
  @override
  Future<List<Pet>> build() async {
    // This runs on every rebuild! Keep it minimal.
    await Future.delayed(Duration(seconds: 5));
    return [];
  }
}
```

### 2.4 Code Generation with riverpod_generator

**Yes — use it.** It eliminates boilerplate errors, enforces correct provider types, and integrates with `riverpod_lint` for static analysis.

```yaml
# pubspec.yaml
dependencies:
  flutter_riverpod: ^3.3.1
  riverpod_annotation: ^3.0.0

dev_dependencies:
  riverpod_generator: ^3.0.0
  riverpod_lint: ^3.0.0
  build_runner: ^2.4.0
```

```dart
// With code generation — this is the recommended approach
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'pet_feed_notifier.g.dart';

@riverpod
class PetFeedNotifier extends _$PetFeedNotifier {
  @override
  Future<List<Pet>> build() async {
    return ref.watch(petRepositoryProvider).fetchFeed();
  }
}

// keepAlive equivalent
@Riverpod(keepAlive: true)
PetRepository petRepository(Ref ref) {
  return PetRepository(ref.watch(supabaseClientProvider));
}
```

Run: `dart run build_runner build --delete-conflicting-outputs`

### 2.5 Testing with Riverpod 3.x

```dart
// Unit test with ProviderContainer
test('PetFeedNotifier loads pets', () async {
  final container = ProviderContainer(
    overrides: [
      petRepositoryProvider.overrideWith((ref) => MockPetRepository()),
    ],
  );
  addTearDown(container.dispose);
  
  // Disable auto-retry in tests!
  // Configure in ProviderContainer or ProviderScope:
  // retry: (_, __) => null

  final notifier = container.read(petFeedNotifierProvider.notifier);
  expect(
    container.read(petFeedNotifierProvider),
    const AsyncLoading<List<Pet>>(),
  );
  await container.read(petFeedNotifierProvider.future);
  expect(
    container.read(petFeedNotifierProvider),
    isA<AsyncData<List<Pet>>>(),
  );
});
```

```dart
// Widget test
testWidgets('Feed screen shows pets', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        petFeedNotifierProvider.overrideWith(() => MockPetFeedNotifier()),
      ],
      child: const MaterialApp(home: FeedScreen()),
    ),
  );
  await tester.pumpAndSettle();
  expect(find.byType(PetCard), findsWidgets);
});
```

**Critical: Disable retry in tests**
```dart
// In test setup or ProviderScope
ProviderContainer(
  overrides: [
    // Disable global retry behavior
  ],
);
// Or configure retry: (_, __) => null on ProviderScope during tests
```

### 2.6 Common Pitfalls

| Pitfall | Solution |
|---|---|
| Provider not disposed | Use `keepAlive: false` (default) or explicit `ref.onDispose` |
| Reading disposed ref after await | Check `ref.mounted` before using `ref` post-await |
| Family argument equality | Use `const` objects or implement `==`/`hashCode` |
| Mixing ref.read and ref.watch | `watch` in `build()`, `read` in event handlers only |
| Global `ref.read` in UI | Only use `ref.read` in callbacks, never in `build()` |

---

## 3. go_router 17.x

### 3.1 Breaking Changes (17.0 → 17.2.2)

| Version | Breaking Change |
|---|---|
| 17.0.0 | `GoRouter.location` removed — use `GoRouterState.of(context).uri.toString()` |
| 17.0.0 | `ShellRoute` navigation changes now notify `GoRouter` observers by default |
| 17.0.0 | `notifyRootObserver` added to `ShellRouteBase` and variants |
| 17.0.1+ | Requires Flutter 3.32 / Dart 3.8 minimum |

**Migration:**
```dart
// BEFORE (< 17.0)
final location = router.location;

// AFTER (17.0+)
final location = GoRouterState.of(context).uri.toString();
// or in redirect:
final location = state.uri.toString();
```

Always run after upgrading:
```bash
dart fix --apply
```

### 3.2 Auth Redirect Best Practices

**The correct pattern for auth-aware routing:**

```dart
// 1. Create a notifier for auth state
class AuthNotifier extends ChangeNotifier {
  AuthNotifier(this._client) {
    _client.auth.onAuthStateChange.listen((_) => notifyListeners());
  }
  final SupabaseClient _client;
  bool get isAuthenticated => _client.auth.currentSession != null;
}

// 2. Wire it to go_router's refreshListenable
final router = GoRouter(
  refreshListenable: authNotifier,
  redirect: (context, state) {
    final isAuth = authNotifier.isAuthenticated;
    final isOnLoginPage = state.matchedLocation == '/login';

    if (!isAuth && !isOnLoginPage) {
      // Preserve the intended destination
      final destination = state.uri.toString();
      return '/login?from=${Uri.encodeComponent(destination)}';
    }
    if (isAuth && isOnLoginPage) {
      // Redirect back to intended destination after login
      final from = state.uri.queryParameters['from'];
      return from != null ? Uri.decodeComponent(from) : '/';
    }
    return null; // no redirect needed
  },
  routes: [...],
);
```

**Key rules:**
- `redirect` **must be synchronous** — do async auth checks during app initialization, before the router is created
- Use `refreshListenable` to trigger re-evaluation of redirects on auth state changes
- Preserve intended URL via query parameter, not shared state (survives hot restart)
- Clear the stored path immediately after navigation

### 3.3 Shell Routes & Nested Navigation

```dart
// StatefulShellRoute for bottom navigation with state persistence
GoRouter(
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => ScaffoldWithNavBar(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/feed', builder: (_, __) => const FeedScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (_, __) => const ProfileScreen(),
              routes: [
                // Nested route within branch
                GoRoute(
                  path: 'edit',
                  builder: (_, __) => const EditProfileScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
```

**Gotchas:**
- `StatefulShellBranch` does NOT support parameterized default locations (e.g., `/pet/:id`)
- `state.extra` is NOT persisted across browser refreshes — use `pathParameters` or `queryParameters` for web
- When popping nested screens causes unexpected parent stack behavior, wrap in `RouteNeglect`

### 3.4 Deep Linking with go_router

```dart
// go_router handles deep links automatically when routes are set up correctly
// For Supabase OAuth callback:
GoRoute(
  path: '/auth/callback',
  redirect: (context, state) async {
    // Handle Supabase OAuth callback
    final uri = state.uri;
    await Supabase.instance.client.auth.getSessionFromUrl(uri);
    return '/home';
  },
),
```

### 3.5 Route Parameter Handling

```dart
// Path parameters (preferred for required data)
GoRoute(
  path: '/pet/:petId',
  builder: (context, state) {
    final petId = state.pathParameters['petId']!;
    return PetDetailScreen(petId: petId);
  },
),

// Query parameters (for optional/filter data)
GoRoute(
  path: '/search',
  builder: (context, state) {
    final query = state.uri.queryParameters['q'] ?? '';
    return SearchScreen(query: query);
  },
),

// Extra (for complex in-memory objects — NOT preserved on web refresh)
context.push('/pet/detail', extra: petObject);
// Access:
final pet = state.extra as Pet;
```

---

## 4. supabase_flutter 2.12.x

### 4.1 What's New in 2.12.x

| Feature | Detail |
|---|---|
| **Idempotent initialization** | `Supabase.initialize()` can now be called multiple times safely |
| **`storageRetryAttempts`** | Configure retries for transient upload failures during init |
| **New publishable keys** | Transitioning from `anon` keys to `sb_publishable_xxx` format |
| **MFA support** | Enroll, challenge, and verify MFA flows built in |
| **JWT cache (PostgREST v14)** | Improved throughput for GET requests via PostgREST v14 |
| **Realtime improvements** | Better channel management and cleanup APIs |

**Minimum requirements for 2.9.0+:** Dart >= 3.3.0, Flutter >= 3.19.0

**Latest stable:** 2.12.4 (app is locked at 2.12.2 — upgrade to 2.12.4 for bug fixes)

### 4.2 Initialization Best Practices

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
    // Configure storage retry for transient failures
    storageRetryAttempts: 3,
    // Realtime configuration
    realtimeClientOptions: const RealtimeClientOptions(
      logLevel: RealtimeLogLevel.info,
    ),
    // Auth configuration
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce, // Use PKCE for mobile
      autoRefreshToken: true,
    ),
    debug: false, // false in production
  );
  
  runApp(const MyApp());
}

// Access client anywhere
final supabase = Supabase.instance.client;
```

### 4.3 Authentication Best Practices

```dart
// ✅ CORRECT: Use auth state stream for reactive UI
class AuthRepository {
  final SupabaseClient _client;
  AuthRepository(this._client);
  
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
  
  Session? get currentSession => _client.auth.currentSession;
  User? get currentUser => _client.auth.currentUser;
  
  Future<void> signInWithEmail(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }
  
  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'com.yourcompany.petsphere://auth/callback',
      // For web:
      // redirectTo: 'https://yourdomain.com/auth/callback',
    );
  }
  
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
```

```dart
// ✅ CORRECT: Riverpod-based auth state
@Riverpod(keepAlive: true)
Stream<AuthState> authStateChanges(Ref ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
}

@Riverpod(keepAlive: true)
User? currentUser(Ref ref) {
  ref.watch(authStateChangesProvider); // subscribe to changes
  return Supabase.instance.client.auth.currentUser;
}
```

**Security rules:**
- Always use `auth.currentUser` (not `auth.currentSession?.user`) for the most up-to-date user info
- Never use `user_metadata` (raw_user_meta_data) for authorization decisions — it is user-editable
- Use `app_metadata` for roles and authorization claims
- Enable PKCE flow for mobile apps (`AuthFlowType.pkce`)
- Use short JWT expiry (default 1 hour) + auto-refresh

### 4.4 Realtime Best Practices

```dart
// ✅ CORRECT: Manage channel lifecycle properly
class ChatRepository {
  final SupabaseClient _client;
  RealtimeChannel? _channel;
  
  ChatRepository(this._client);
  
  Stream<List<Message>> subscribeToChat(String roomId) {
    // Unsubscribe from any existing channel first
    _channel?.unsubscribe();
    
    _channel = _client
      .channel('chat:$roomId')
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'messages',
        filter: PostgresChangeFilter(
          type: FilterType.eq,
          column: 'room_id',
          value: roomId,
        ),
        callback: (payload) {
          // Handle new message
        },
      )
      .subscribe();
    
    // Return a stream
    return _client
      .from('messages')
      .stream(primaryKey: ['id'])
      .eq('room_id', roomId)
      .order('created_at')
      .map((data) => data.map(Message.fromJson).toList());
  }
  
  Future<void> dispose() async {
    await _channel?.unsubscribe();
    _channel = null;
  }
}
```

```dart
// ✅ CORRECT: Persist stream reference in StatefulWidget / Notifier
// BAD: Creating stream inside build() causes reconnection on every rebuild
// GOOD: Create stream once in build() of AsyncNotifier or initState()
class ChatNotifier extends AsyncNotifier<List<Message>> {
  StreamSubscription? _sub;
  
  @override
  Future<List<Message>> build() async {
    final roomId = arg; // from family
    final repo = ref.watch(chatRepositoryProvider);
    
    // Subscribe once, cancel on dispose
    _sub = repo.subscribeToChat(roomId).listen((messages) {
      state = AsyncData(messages);
    });
    
    ref.onDispose(() {
      _sub?.cancel();
      repo.dispose();
    });
    
    return repo.fetchInitialMessages(roomId);
  }
}
```

### 4.5 Storage Best Practices

```dart
// ✅ CORRECT: Scoped path (user_id/filename)
Future<String> uploadAvatar(String userId, File file) async {
  final path = '$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
  
  await Supabase.instance.client.storage
    .from('avatars')
    .upload(
      path,
      file,
      fileOptions: const FileOptions(
        contentType: 'image/jpeg',
        upsert: true, // requires INSERT + SELECT + UPDATE policy
      ),
    );
  
  return Supabase.instance.client.storage
    .from('avatars')
    .getPublicUrl(path);
}

// ✅ CORRECT: Delete on cleanup
Future<void> deleteOldAvatar(String userId, String oldPath) async {
  await Supabase.instance.client.storage
    .from('avatars')
    .remove([oldPath]);
}
```

**Storage path conventions:**
- Always prefix with `user_id/` so RLS can use `storage.foldername(name)[1] = auth.uid()::text`
- For pets: `{user_id}/pets/{pet_id}/{filename}`
- For posts: `{user_id}/posts/{post_id}/{filename}`

### 4.6 Deep Linking for OAuth and Password Reset

**Android `AndroidManifest.xml`:**
```xml
<activity ...>
  <!-- Custom scheme for Supabase auth callbacks -->
  <intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="com.yourcompany.petsphere" android:host="auth" />
  </intent-filter>
</activity>
```

**iOS `Info.plist`:**
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.yourcompany.petsphere</string>
    </array>
  </dict>
</array>
```

**Supabase Dashboard:** Add `com.yourcompany.petsphere://auth/callback` to Redirect URLs.

**Handling callback in app:**
```dart
// Using app_links package (recommended companion to go_router)
final appLinks = AppLinks();

// In your auth repository or router setup
appLinks.uriLinkStream.listen((uri) async {
  if (uri.host == 'auth') {
    // Handle Supabase auth callback
    await Supabase.instance.client.auth.getSessionFromUrl(uri);
  }
});
```

**New publishable keys:** Supabase is migrating from `anon` keys to `sb_publishable_xxx` format. Migrate when prompted in the Dashboard — the old `anon` keys will eventually be deprecated.

---

## 5. image_picker 1.x

### 5.1 iOS Permissions (Info.plist)

All three entries must be present even if you only use some features:

```xml
<!-- ios/Runner/Info.plist -->
<key>NSPhotoLibraryUsageDescription</key>
<string>PetSphere needs access to your photo library to share pet photos.</string>

<key>NSCameraUsageDescription</key>
<string>PetSphere needs camera access to take photos of your pets.</string>

<key>NSMicrophoneUsageDescription</key>
<string>PetSphere needs microphone access to record pet videos.</string>
```

**Notes:**
- iOS 14+ uses `PHPickerViewController` (no prompt for gallery-only access when using limited selection)
- Setting `requestFullMetadata: false` avoids the full library permission prompt, but `NSPhotoLibraryUsageDescription` must still be in `Info.plist` per App Store policy
- The iOS permission prompt is only shown once; if denied, users must go to Settings manually

### 5.2 Android Permissions

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<!-- Required for Android < 13 -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />

<!-- Android 13+ (API 33) — granular media permissions -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
```

**Critical gotcha:** If your app uses `launchMode: singleInstance`, the picker returns `RESULT_CANCELED`. Switch to `singleTask`.

Minimum `minSdkVersion`: **24**

### 5.3 Image Compression and Upload Best Practices

```dart
class MediaService {
  final _picker = ImagePicker();
  
  // ✅ Compress at pick time — most efficient approach
  Future<XFile?> pickAndCompressImage({
    required ImageSource source,
    int maxWidth = 1024,
    int maxHeight = 1024,
    int quality = 85,
  }) async {
    final image = await _picker.pickImage(
      source: source,
      maxWidth: maxWidth.toDouble(),
      maxHeight: maxHeight.toDouble(),
      imageQuality: quality, // 0-100, 85 is a good balance
    );
    return image;
  }
  
  // ✅ Always handle Android state restoration
  Future<XFile?> recoverLostImage() async {
    final response = await _picker.retrieveLostData();
    if (response.isEmpty) return null;
    if (response.exception != null) throw response.exception!;
    return response.file;
  }
  
  // ✅ Move to permanent storage after picking
  Future<String> uploadImage(XFile image, String userId) async {
    final bytes = await image.readAsBytes();
    final extension = image.path.split('.').last;
    final path = '$userId/${DateTime.now().millisecondsSinceEpoch}.$extension';
    
    await Supabase.instance.client.storage
      .from('pet_photos')
      .uploadBinary(path, bytes, fileOptions: FileOptions(
        contentType: image.mimeType ?? 'image/jpeg',
        upsert: false,
      ));
    
    return Supabase.instance.client.storage
      .from('pet_photos')
      .getPublicUrl(path);
  }
}
```

**Important:** Images from `image_picker` are stored in a **temporary cache directory** — they are deleted when the OS clears the cache. Always upload or copy them to permanent storage immediately.

For 50+ images, consider `wechat_assets_picker` which handles large batches without UI freezes.

---

## 6. share_plus: Migration 10.x → 13.x

### 6.1 Breaking Changes Summary

| Change | 10.x | 13.x |
|---|---|---|
| API class | `Share` (static) | `SharePlus.instance` (singleton instance) |
| Parameters | Positional args | `ShareParams` object |
| Result type | `ShareResult` string | `ShareResult` with `.status` (enum) |
| Min Flutter | 3.x | 3.38.1+ (13.1.0) |
| iOS share sheet | UIActivityViewController (deprecated API) | Updated — required for iOS 26+ |
| Android Gradle | Any | AGP >= 8.12.1, Kotlin 2.2.0 (13.0.0) |

**iOS urgency:** Versions 11 and below use deprecated iOS APIs that crash on iOS 26+. **Upgrade is mandatory.**

### 6.2 Migration Code Examples

```dart
// ─── BEFORE (share_plus 10.x) ───
import 'package:share_plus/share_plus.dart';

// Share text
await Share.share('Check out this pet! #PetSphere');

// Share URI
await Share.shareUri(Uri.parse('https://petsphere.app/pet/123'));

// Share files
await Share.shareXFiles(
  [XFile(imagePath)],
  text: 'My cute pet!',
  subject: 'PetSphere Photo',
);
```

```dart
// ─── AFTER (share_plus 13.x) ───
import 'package:share_plus/share_plus.dart';

// Share text
await SharePlus.instance.share(
  ShareParams(text: 'Check out this pet! #PetSphere'),
);

// Share URI
await SharePlus.instance.share(
  ShareParams(uri: Uri.parse('https://petsphere.app/pet/123')),
);

// Share files
await SharePlus.instance.share(
  ShareParams(
    files: [XFile(imagePath)],
    text: 'My cute pet!',
    subject: 'PetSphere Photo',
  ),
);

// ✅ REQUIRED for iPad — provide share position origin or it crashes
Future<void> shareOnIpad(BuildContext context, String text) async {
  final box = context.findRenderObject() as RenderBox?;
  await SharePlus.instance.share(
    ShareParams(
      text: text,
      sharePositionOrigin: box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : null,
    ),
  );
}

// Handle result
final result = await SharePlus.instance.share(ShareParams(text: 'Hello!'));
switch (result.status) {
  case ShareResultStatus.success:
    print('Shared successfully');
  case ShareResultStatus.dismissed:
    print('User dismissed share sheet');
  case ShareResultStatus.unavailable:
    print('Sharing not available on this platform');
}
```

### 6.3 Android Build Requirements (13.0.0+)

Update `android/app/build.gradle`:
```groovy
android {
  // Required for share_plus 13.x
}
```

Update `android/gradle/wrapper/gradle-wrapper.properties`:
```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.13-bin.zip
```

Update `android/build.gradle`:
```groovy
buildscript {
  dependencies {
    classpath 'com.android.tools.build:gradle:8.12.1'
  }
}
```

And `android/app/build.gradle` Kotlin version:
```groovy
kotlin_version = '2.2.0'
```

---

## 7. Flutter Security Best Practices

### 7.1 API Key Management with `--dart-define-from-file`

**Never hardcode API keys in Dart source files.**

```json
// dart_defines/dev.json (add to .gitignore)
{
  "SUPABASE_URL": "https://your-project.supabase.co",
  "SUPABASE_ANON_KEY": "your-anon-key-here"
}
```

```json
// dart_defines/prod.json (add to .gitignore)
{
  "SUPABASE_URL": "https://your-prod-project.supabase.co",
  "SUPABASE_ANON_KEY": "your-prod-anon-key-here"
}
```

```bash
# Development
flutter run --dart-define-from-file=dart_defines/dev.json

# Production build
flutter build apk --dart-define-from-file=dart_defines/prod.json \
  --release --obfuscate --split-debug-info=build/debug-info
```

```dart
// Access in Dart code — injected at compile time
const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
```

**For native code (Android Manifest / iOS plist):** Use `--dart-define` values accessible via Gradle's `manifestPlaceholders`:
```groovy
// android/app/build.gradle
def dartEnvironmentVariables = [
  SUPABASE_URL: '',
  SUPABASE_ANON_KEY: '',
]
if (project.hasProperty('dart-defines')) {
  dartEnvironmentVariables = dartEnvironmentVariables + project.property('dart-defines')
    .split(',')
    .collectEntries { entry ->
      def pair = new String(entry.decodeBase64(), 'UTF-8').split('=')
      [(pair.first()): pair.last()]
    }
}
android {
  defaultConfig {
    manifestPlaceholders += dartEnvironmentVariables
  }
}
```

### 7.2 Code Obfuscation

```bash
# Full release build with obfuscation
flutter build apk \
  --release \
  --obfuscate \
  --split-debug-info=build/debug-info/android

flutter build ipa \
  --release \
  --obfuscate \
  --split-debug-info=build/debug-info/ios
```

Store the `build/debug-info/` folder securely — you need it to symbolicate crash reports (Crashlytics, Sentry).

**Android additional hardening** (`android/gradle.properties`):
```properties
android.enableR8.fullMode=true
```

### 7.3 Certificate Pinning

```dart
// Using Dio with custom certificate pinning
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

Dio createPinnedDio() {
  final dio = Dio();
  (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
    final client = HttpClient();
    client.badCertificateCallback = (cert, host, port) {
      // Replace with your server's actual SHA-256 fingerprint
      const expectedFingerprint = 'AA:BB:CC:...';
      final actualFingerprint = cert.der
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join(':')
        .toUpperCase();
      return actualFingerprint == expectedFingerprint;
    };
    return client;
  };
  return dio;
}
```

**Note:** For Supabase requests specifically, Supabase manages TLS/certificates on their infrastructure. Certificate pinning is more relevant for custom backend APIs where you control the certificate.

### 7.4 Secure Storage for Tokens

```dart
// ✅ Use flutter_secure_storage for tokens, NOT SharedPreferences
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _storage = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
  iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
);

// Store
await _storage.write(key: 'refresh_token', value: token);

// Read
final token = await _storage.read(key: 'refresh_token');

// Delete
await _storage.delete(key: 'refresh_token');
```

**Note:** `supabase_flutter` already stores session data securely using `flutter_secure_storage` internally. You typically don't need to store Supabase tokens manually.

### 7.5 Security Checklist for PetSphere

- [ ] Rotate committed anon key (it's in version history)
- [ ] Move Supabase URL/key to `--dart-define-from-file` with environment-specific files
- [ ] Add `dart_defines/*.json` to `.gitignore`
- [ ] Enable R8 full mode in `android/gradle.properties`
- [ ] Add `--obfuscate --split-debug-info` to all release builds
- [ ] Verify the application ID is changed from `com.example.pet_dating_app`
- [ ] Audit third-party package permissions in `AndroidManifest.xml`
- [ ] Never use `service_role` key in the Flutter app

---

## 8. Flutter Testing Best Practices 2025-2026

### 8.1 Unit Testing with Riverpod

```dart
// test/features/feed/pet_feed_notifier_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

class MockPetRepository extends Mock implements PetRepository {}

void main() {
  group('PetFeedNotifier', () {
    late ProviderContainer container;
    late MockPetRepository mockRepo;

    setUp(() {
      mockRepo = MockPetRepository();
      container = ProviderContainer(
        overrides: [
          petRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('loads feed successfully', () async {
      final pets = [Pet(id: '1', name: 'Rex'), Pet(id: '2', name: 'Bella')];
      when(() => mockRepo.fetchFeed()).thenAnswer((_) async => pets);

      // Trigger the provider
      expect(
        container.read(petFeedNotifierProvider),
        const AsyncLoading<List<Pet>>(),
      );

      await container.read(petFeedNotifierProvider.future);

      expect(
        container.read(petFeedNotifierProvider),
        AsyncData(pets),
      );
    });

    test('handles error state', () async {
      when(() => mockRepo.fetchFeed()).thenThrow(Exception('Network error'));

      await container.read(petFeedNotifierProvider.future).catchError((_) => <Pet>[]);

      expect(
        container.read(petFeedNotifierProvider),
        isA<AsyncError<List<Pet>>>(),
      );
    });
  });
}
```

### 8.2 Widget Testing

```dart
// test/features/feed/feed_screen_test.dart
void main() {
  testWidgets('FeedScreen shows pet cards', (tester) async {
    final pets = [Pet(id: '1', name: 'Rex'), Pet(id: '2', name: 'Bella')];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          petFeedNotifierProvider.overrideWith(
            () => FakePetFeedNotifier(pets),
          ),
        ],
        child: MaterialApp(
          home: FeedScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle(); // Wait for async state

    expect(find.text('Rex'), findsOneWidget);
    expect(find.text('Bella'), findsOneWidget);
    expect(find.byType(PetCard), findsNWidgets(2));
  });
}

// Fake notifier for testing
class FakePetFeedNotifier extends _$PetFeedNotifier {
  FakePetFeedNotifier(this._pets);
  final List<Pet> _pets;
  
  @override
  Future<List<Pet>> build() async => _pets;
}
```

### 8.3 Golden File Testing

```yaml
# pubspec.yaml dev_dependencies
dev_dependencies:
  golden_toolkit: ^0.15.0
```

```dart
// test/golden/pet_card_golden_test.dart
void main() {
  testGoldens('PetCard renders correctly', (tester) async {
    await loadAppFonts(); // Critical for font consistency
    
    await tester.pumpWidgetBuilder(
      PetCard(
        pet: Pet(id: '1', name: 'Rex', breed: 'Labrador'),
        onTap: () {},
      ),
      surfaceSize: const Size(400, 200),
    );
    
    await screenMatchesGolden(tester, 'pet_card');
  });
}
```

**Best practices:**
- Run golden tests exclusively on **Linux x64** in CI to avoid cross-platform pixel drift
- Use tags in `dart_test.yaml` to isolate golden tests:
  ```yaml
  # dart_test.yaml
  tags:
    golden:
      skip: false
  ```
- Generate baselines: `flutter test --update-goldens --tags golden`
- Do NOT golden-test full screens with dynamic content (timestamps, random avatars)
- Commit golden files to version control

### 8.4 Integration Testing

```dart
// integration_test/app_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('User can browse feed', (tester) async {
    // GIVEN: App is launched and user is logged in
    app.main();
    await tester.pumpAndSettle();

    // WHEN: User navigates to feed
    expect(find.byType(FeedScreen), findsOneWidget);
    
    // THEN: Pet cards are visible
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.byType(PetCard), findsWidgets);
  });
}
```

**Best practices:**
- Mock external dependencies (Supabase) with `mocktail` in integration tests to avoid CI flakiness
- Use `Given-When-Then` structure for readability
- `tester.pumpAndSettle()` waits for all animations and async operations
- Run on real devices in CI (Firebase Test Lab, Appetize) for reliable results
- Use `integration_test` runner: `flutter test integration_test/ --device-id=<device>`

### 8.5 Recommended Testing Pyramid

```
         ┌──────────┐
         │  Golden  │  ~10% — visual regression only
         │   Tests  │
        ┌┴──────────┴┐
        │ Integration │  ~20% — critical user journeys
        │    Tests    │
       ┌┴─────────────┴┐
       │ Widget / UI    │  ~30% — component behavior
       │    Tests       │
      ┌┴────────────────┴┐
      │   Unit Tests      │  ~40% — business logic, repositories
      └───────────────────┘
```

---

## 9. Supabase RLS Best Practices 2025-2026

### 9.1 The #1 Performance Optimization

```sql
-- ❌ SLOW: auth.uid() called for every row
CREATE POLICY "Users can view own posts" ON posts
FOR SELECT USING (user_id = auth.uid());

-- ✅ FAST: Wrap in SELECT to cache result per statement (initPlan)
CREATE POLICY "Users can view own posts" ON posts
FOR SELECT TO authenticated
USING (user_id = (SELECT auth.uid()));
```

This single change can dramatically improve query performance on tables with many rows. The `SELECT auth.uid()` triggers Postgres's `initPlan` optimization, evaluating the function once and caching it for the entire statement instead of re-evaluating per row.

### 9.2 Essential RLS Patterns

```sql
-- ─── User-owned data (most common pattern) ───
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own posts" ON posts
FOR SELECT TO authenticated
USING (user_id = (SELECT auth.uid()));

CREATE POLICY "Users can insert own posts" ON posts
FOR INSERT TO authenticated
WITH CHECK (user_id = (SELECT auth.uid()));

-- UPDATE needs both USING (which rows) and WITH CHECK (new values)
CREATE POLICY "Users can update own posts" ON posts
FOR UPDATE TO authenticated
USING (user_id = (SELECT auth.uid()))
WITH CHECK (user_id = (SELECT auth.uid()));

CREATE POLICY "Users can delete own posts" ON posts
FOR DELETE TO authenticated
USING (user_id = (SELECT auth.uid()));

-- ─── Public read, authenticated write ───
CREATE POLICY "Anyone can read public pets" ON pets
FOR SELECT TO anon, authenticated
USING (is_public = true);

CREATE POLICY "Owners can update their pets" ON pets
FOR UPDATE TO authenticated
USING (owner_id = (SELECT auth.uid()))
WITH CHECK (owner_id = (SELECT auth.uid()));

-- ─── Role-based access via app_metadata ───
CREATE POLICY "Admins can view all orders" ON orders
FOR SELECT TO authenticated
USING (
  (SELECT auth.jwt()->'app_metadata'->>'role') = 'admin'
  OR user_id = (SELECT auth.uid())
);
```

### 9.3 Storage Policies for User-Owned Content

```sql
-- Storage bucket: 'avatars' (public bucket)
-- Path convention: {user_id}/avatar.jpg

-- Allow authenticated users to upload to their own folder
CREATE POLICY "Users can upload own avatar" ON storage.objects
FOR INSERT TO authenticated
WITH CHECK (
  bucket_id = 'avatars'
  AND (storage.foldername(name))[1] = (SELECT auth.uid()::text)
);

-- Allow users to view/download their own files
CREATE POLICY "Users can view own avatar" ON storage.objects
FOR SELECT TO authenticated
USING (
  bucket_id = 'avatars'
  AND (storage.foldername(name))[1] = (SELECT auth.uid()::text)
);

-- Public bucket — allow anyone to view (if you want public avatars)
CREATE POLICY "Public can view all avatars" ON storage.objects
FOR SELECT TO anon, authenticated
USING (bucket_id = 'avatars');

-- ✅ REQUIRED FOR UPSERT: must have INSERT + SELECT + UPDATE
CREATE POLICY "Users can update own avatar" ON storage.objects
FOR UPDATE TO authenticated
USING (
  bucket_id = 'avatars'
  AND (storage.foldername(name))[1] = (SELECT auth.uid()::text)
)
WITH CHECK (
  bucket_id = 'avatars'
  AND (storage.foldername(name))[1] = (SELECT auth.uid()::text)
);

-- Allow deletion of own files
CREATE POLICY "Users can delete own avatar" ON storage.objects
FOR DELETE TO authenticated
USING (
  bucket_id = 'avatars'
  AND (storage.foldername(name))[1] = (SELECT auth.uid()::text)
);
```

**Critical:** `storage.foldername(name)` returns an array. Index `[1]` is the first folder segment. For path `userId/pets/photo.jpg`, `[1]` = `userId`, `[2]` = `pets`.

### 9.4 Performance Indexes for RLS

```sql
-- Always index columns used in RLS policies
CREATE INDEX idx_posts_user_id ON posts(user_id);
CREATE INDEX idx_pets_owner_id ON pets(owner_id);
CREATE INDEX idx_messages_room_id ON messages(room_id);
CREATE INDEX idx_messages_sender_id ON messages(sender_id);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);

-- Compound indexes for common query patterns
CREATE INDEX idx_posts_user_created ON posts(user_id, created_at DESC);
```

### 9.5 Common RLS Security Traps

| Trap | Risk | Fix |
|---|---|---|
| Using `user_metadata` in policies | User can edit their own metadata → privilege escalation | Use `app_metadata` only |
| Views without `security_invoker` | Views bypass RLS by default | Add `WITH (security_invoker = true)` (Postgres 15+) |
| UPDATE policy without SELECT policy | Updates silently return 0 rows | Always add SELECT policy alongside UPDATE |
| Missing `WITH CHECK` on INSERT/UPDATE | New rows bypass the policy check | Always include `WITH CHECK` |
| `service_role` key on client | Bypasses all RLS | Only use `anon` key on client |
| Not specifying `TO authenticated` | Policy evaluated for `anon` role too | Always specify target role |

### 9.6 Testing RLS Policies

```sql
-- Test as a specific user (in Supabase SQL Editor)
SET LOCAL role TO authenticated;
SET LOCAL request.jwt.claims TO '{"sub": "user-uuid-here", "role": "authenticated"}';

-- Now queries will execute under that user's RLS
SELECT * FROM posts; -- Should only show that user's posts
```

**Always test policies from the client SDK**, not the SQL editor — the SQL editor runs as the `postgres` superuser which bypasses RLS.

---

## 10. Flutter Performance Best Practices 2025-2026

### 10.1 Pagination and Infinite Scroll

```dart
// Using infinite_scroll_pagination package (recommended)
// pubspec.yaml: infinite_scroll_pagination: ^5.0.0
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class FeedScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  static const _pageSize = 20;
  final _pagingController = PagingController<int, Pet>(firstPageKey: 0);

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final repo = ref.read(petRepositoryProvider);
      final newItems = await repo.fetchFeed(
        offset: pageKey * _pageSize,
        limit: _pageSize,
      );
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        _pagingController.appendPage(newItems, pageKey + 1);
      }
    } catch (e) {
      _pagingController.error = e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PagedListView<int, Pet>(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<Pet>(
        itemBuilder: (context, pet, index) => PetCard(pet: pet),
        firstPageProgressIndicatorBuilder: (_) => const LoadingSpinner(),
        newPageProgressIndicatorBuilder: (_) => const SmallLoadingSpinner(),
        noItemsFoundIndicatorBuilder: (_) => const EmptyFeedWidget(),
        firstPageErrorIndicatorBuilder: (_) => ErrorWidget(
          onRetry: _pagingController.retryLastFailedRequest,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
```

**Supabase pagination query:**
```dart
Future<List<Pet>> fetchFeed({required int offset, required int limit}) async {
  final data = await _client
    .from('pets')
    .select('*, profiles(*)')
    .order('created_at', ascending: false)
    .range(offset, offset + limit - 1); // Supabase uses range() for pagination
  
  return data.map(Pet.fromJson).toList();
}
```

### 10.2 Image Loading and Caching

```dart
// Using cached_network_image (your current package)
CachedNetworkImage(
  imageUrl: pet.photoUrl,
  // ✅ ALWAYS specify cache dimensions to prevent full-resolution decode
  memCacheWidth: 400,
  memCacheHeight: 400,
  // Placeholder and error widgets
  placeholder: (context, url) => const ShimmerPlaceholder(),
  errorWidget: (context, url, error) => const PetAvatarFallback(),
  // Fit
  fit: BoxFit.cover,
)
```

**Important note on `cached_network_image` maintenance:**

As of 2025, `cached_network_image` has been largely unmaintained (last major update was 2+ years ago). The community has created a maintained fork:
- **`cached_network_image_ce`** — uses `hive_ce` instead of `sqflite` for cache lookups, with significantly faster cache reads

Consider migrating if you experience cache performance issues, especially in feeds with many images.

**Image optimization pipeline:**
```dart
// When uploading, use WebP format via image compression
// When displaying, use Supabase Image Transformations
final transformedUrl = supabase.storage
  .from('pet_photos')
  .getPublicUrl(
    path,
    transform: const TransformOptions(
      width: 400,
      height: 400,
      resize: ResizeMode.cover,
      format: 'webp', // Modern format, smaller size
    ),
  );
```

### 10.3 Reducing Widget Rebuilds

```dart
// ✅ Use const constructors religiously
class PetCard extends StatelessWidget {
  const PetCard({super.key, required this.pet}); // const constructor
  final Pet pet;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          const SizedBox(height: 8),   // ← const: reused, never rebuilt
          Text(pet.name),
          const Divider(),             // ← const: reused, never rebuilt
        ],
      ),
    );
  }
}
```

```dart
// ✅ Use Consumer/ref.watch at the lowest possible level
// BAD: Entire screen rebuilds on any state change
class FeedScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likeCount = ref.watch(likeCountProvider); // rebuilds entire screen!
    return ListView(children: [/* ... */]);
  }
}

// GOOD: Only the like counter widget rebuilds
class PetCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      PetImage(petId: pet.id),
      LikeCounter(petId: pet.id), // Consumer is inside this widget
    ]);
  }
}

class LikeCounter extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(likeCountProvider(petId)); // only this rebuilds
    return Text('$count likes');
  }
}
```

```dart
// ✅ Use select() to narrow watch scope
class PetNameWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only rebuilds when the name changes, not on any Pet field change
    final name = ref.watch(petProvider(petId).select((pet) => pet.name));
    return Text(name);
  }
}
```

```dart
// ✅ RepaintBoundary for expensive or frequently updating subtrees
RepaintBoundary(
  child: AnimatedPetAvatar(petId: pet.id), // isolated from parent repaints
)
```

### 10.4 General Performance Guidelines

| Technique | Impact | Notes |
|---|---|---|
| `const` constructors | High | Widget instances reused across rebuilds |
| `ListView.builder` | High | Only visible items are built |
| `RepaintBoundary` | Medium | Isolates repaint regions |
| `cacheWidth`/`cacheHeight` | High | Prevents full-resolution image decode |
| `compute()` for heavy tasks | High | Moves work off UI thread |
| `AnimatedOpacity` vs `Opacity` | Medium | `Opacity` creates a new raster layer |
| Profile mode testing | Critical | Debug mode performance is not representative |
| `select()` in Riverpod | Medium | Narrows rebuild scope |
| Avoid `Expanded` in `Column` with many children | Low | Use `SliverList` instead for long lists |

```dart
// ✅ Use compute() for CPU-intensive operations
final parsedPets = await compute(parsePetsJson, rawJsonString);

// ✅ Profile mode command (on physical device)
flutter run --profile --device-id=<device-id>
```

---

## Quick Reference: Action Items for PetSphere

### Immediate (High Priority)
1. **Rotate Supabase anon key** — it's committed to version history
2. **Add `--dart-define-from-file`** to build commands for URL/key management
3. **Upgrade `share_plus`** from 10.1.4 to 13.1.0 — crashes on iOS 26
4. **Add `INTERNET` permission** to Android release manifest
5. **Change app ID** from `com.example.pet_dating_app`
6. **Fix release signing** — switch from debug key to release keystore

### Short-term (Medium Priority)
7. **Add test suite** — minimum: repository unit tests + critical widget tests
8. **Upgrade `supabase_flutter`** from 2.12.2 to 2.12.4
9. **Tighten Storage RLS policies** — prevent arbitrary bucket access
10. **Add `(SELECT auth.uid())`** pattern to all RLS policies for performance
11. **Add indexes** to all RLS policy columns (`user_id`, `owner_id`, etc.)
12. **Migrate** to Riverpod code generation (`riverpod_generator`)

### Longer-term
13. **Consider feature-first architecture** for better scalability
14. **Evaluate `cached_network_image_ce`** fork for better cache performance
15. **Add Supabase Image Transformations** for WebP serving
16. **Implement golden tests** for core UI components
17. **Set up CI** with `flutter analyze` + `flutter test` gates

---

## Sources

- [Flutter Breaking Changes](https://docs.flutter.dev/release/breaking-changes)
- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [Flutter Impeller Docs](https://docs.flutter.dev/perf/impeller)
- [Flutter App Links Setup](https://docs.flutter.dev/cookbook/navigation/set-up-app-links)
- [Flutter Universal Links Setup](https://docs.flutter.dev/cookbook/navigation/set-up-universal-links)
- [Riverpod 3.0 What's New](https://riverpod.dev/docs/whats_new)
- [Riverpod 2.0 → 3.0 Migration](https://riverpod.dev/docs/3.0_migration)
- [Riverpod Testing Guide](https://riverpod.dev/docs/how_to/testing)
- [go_router 17.2.1 Changelog](https://pub.dev/packages/go_router/versions/17.2.1/changelog)
- [go_router GitHub Changelog](https://github.com/flutter/packages/blob/main/packages/go_router/CHANGELOG.md)
- [supabase_flutter pub.dev](https://pub.dev/packages/supabase_flutter)
- [supabase_flutter Changelog](https://pub.dev/packages/supabase_flutter/versions/2.12.1/changelog)
- [Supabase RLS Docs](https://supabase.com/docs/guides/database/postgres/row-level-security)
- [Supabase RLS Performance Guide](https://supabase.com/docs/guides/troubleshooting/rls-performance-and-best-practices-Z5Jjwv)
- [Supabase Storage Access Control](https://supabase.com/docs/guides/storage/security/access-control)
- [Supabase Security Retro 2025](https://supabase.com/blog/supabase-security-2025-retro)
- [image_picker pub.dev](https://pub.dev/packages/image_picker)
- [share_plus pub.dev](https://pub.dev/packages/share_plus)
- [share_plus Changelog](https://pub.dev/packages/share_plus/changelog)
- [Supabase RLS Best Practices (MakerKit)](https://makerkit.dev/blog/tutorials/supabase-rls-best-practices)
- [Flutter 2025 Top Features (DCM)](https://dcm.dev/blog/2025/12/23/top-flutter-features-2025/)
- [Riverpod Best Practices (DCM)](https://dcm.dev/blog/2026/03/25/inside-riverpod-source-code-guide-dcm-rules/)
- [codewithandrea.com — Notifier/AsyncNotifier guide](https://codewithandrea.com/articles/flutter-riverpod-async-notifier/)
