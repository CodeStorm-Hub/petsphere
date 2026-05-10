```
Agent Thinking: (For Refference Only!!)

This is a major undertaking. I'll run a deep parallel audit of every layer of the codebase, research best practices, and then synthesize a comprehensive refactoring + redesign plan.

Launching parallel exploration agents across all areas now.

Five parallel agents are now auditing the codebase. While they work, I'll query the Supabase database schema and check additional config files.

Got the full database schema (28 tables), test files (only 8), and .gitignore locations. Let me check additional config files and get Supabase advisors while agents work.

Good findings. Major security issues in the database (5 tables with no RLS policies, a SECURITY DEFINER function exposed to anon, leaked password protection disabled). Let me read the performance advisors detail and check a few more critical files.

Controllers audit is complete (26 controllers, ~4,800 LOC, 12+ anti-patterns found). Massive database performance issues identified: **28 unindexed foreign keys** and **25+ RLS policies re-evaluating `auth.uid()` per row**. Waiting for remaining agents to complete before synthesizing the full plan.

Let me check the RLS policies and storage buckets while we wait.

**150 Dart files, 46,215 lines of code total.** Full RLS policy audit captured (40 policies across tables). The `pets_select_authenticated` policy is extremely complex with 8 OR conditions and 5 nested EXISTS subqueries — a major performance concern.

Still waiting for 4 more agents to report back. Let me continue checking storage buckets and the Supabase functions.

Three agents complete (controllers, utils/config). Two remaining (models/repos, views/UI, research). Let me continue gathering insights while waiting.

57 view files mapped. Now I have a clear picture of the full screen inventory. Let me wait for the remaining agents — they'll provide critical detail on models/repositories quality and UI patterns.

22 models, 21 repositories, 57 views. Full inventory captured. I'll start structuring the comprehensive plan while the remaining agents finish their deep analysis.

Four of five agents complete. Models/repos audit reveals inconsistent serialization patterns (only 14/22 models have copyWith), missing content-type detection in pet image uploads, and no pagination on expense queries. Still waiting for views/UI and web research agents.

Let me check the theme file in full — it's central to the redesign plan.

Let me check if the web research agent completed and gather any remaining data before producing the full execution plan.

All 5 agents completed. The web research agent returned detailed findings across 8 topics. Now synthesizing everything into the comprehensive execution plan.
```
---

# PetFolio: Complete Refactoring & UI/UX Redesign Execution Plan

## Codebase Audit Summary

| Metric | Current State |
|--------|--------------|
| **Total Dart Files** | 150 |
| **Lines of Code** | 46,215 |
| **Controllers** | 26 files (~4,800 LOC) |
| **Models** | 22 files |
| **Repositories** | 21 files |
| **Views/Screens** | 57 files |
| **Database Tables** | 28 (Supabase) |
| **RLS Policies** | 40 |
| **Test Files** | 8 (<10% coverage) |
| **Critical Security Issues** | 7 |
| **Performance Issues** | 28+ unindexed FKs |

---

## PHASE 1: Foundation & Security Fixes (Week 1-2)

### Step 1.1: Project Identity & Configuration Cleanup

**Goal**: Standardize naming, fix .gitignore, harden analysis options.

**Files to modify**:
- `pubspec.yaml` — rename `pet_dating_app` to `petfolio`
- `.gitignore` — add missing entries
- `analysis_options.yaml` — enable strict rules
- `lib/main.dart` — rename `PetFolioApp` to `PetFolioApp`
- `lib/theme/app_theme.dart` — rename all `Petfolio*` references to `PetFolio*`

**Actions**:

1. **Fix pubspec.yaml**:
   ```yaml
   name: petfolio  # was: pet_dating_app
   description: PetFolio - Pet Social & Marketplace Platform
   ```

2. **Update .gitignore** (add these missing entries):
   ```
   # Flutter plugins
   .flutter-plugins
   lib/generated_plugin_registrant.dart
   
   # Android
   **/android/.gradle
   **/android/gradle-wrapper.jar
   **/android/captures/
   **/android/gradlew
   **/android/gradlew.bat
   **/android/local.properties
   **/android/GeneratedPluginRegistrant.java
   **/android/key.properties
   *.jks
   *.keystore
   
   # iOS
   **/ios/Pods/
   **/ios/.symlinks/
   **/ios/Flutter/App.framework
   **/ios/Flutter/Flutter.framework
   **/ios/Flutter/Flutter.podspec
   **/ios/Flutter/Generated.xcconfig
   **/ios/Flutter/ephemeral/
   **/ios/Runner.xcworkspace/xcuserdata/
   
   # Code generation
   *.g.dart
   *.freezed.dart
   *.mocks.dart
   
   # Security
   *.jks
   *.keystore
   ```

3. **Enable strict analysis_options.yaml**:
   ```yaml
   include: package:flutter_lints/flutter.yaml
   
   analyzer:
     errors:
       missing_return: error
       dead_code: warning
     language:
       strict-casts: true
       strict-inference: true
       strict-raw-types: true
   
   linter:
     rules:
       - avoid_print
       - prefer_single_quotes
       - prefer_const_constructors
       - prefer_const_declarations
       - prefer_final_locals
       - avoid_unnecessary_containers
       - sized_box_for_whitespace
       - use_key_in_widget_constructors
       - prefer_const_literals_to_create_immutables
       - unnecessary_string_interpolations
       - avoid_redundant_argument_values
   ```

4. **Rename all PetFolio references** across the codebase to PetFolio:
   - `lib/main.dart`: `PetFolioApp` -> `PetFolioApp`
   - `lib/theme/app_theme.dart`: `PetfolioShadows` -> `PetFolioShadows`, all brand references
   - Search and replace across all files: `PetFolio` -> `PetFolio`, `Petfolio` -> `Petfolio`, `petfolio` -> `petfolio`

---

### Step 1.2: Database Security Fixes (CRITICAL)

**Goal**: Fix RLS gaps, remove security vulnerabilities.

**Execute these SQL migrations via Supabase MCP or dashboard**:

1. **Add missing RLS policies** (5 tables have RLS enabled but NO policies):
   ```sql
   -- care_badge_definitions (read-only for all authenticated users)
   CREATE POLICY "Authenticated users can read badge definitions"
     ON public.care_badge_definitions FOR SELECT
     TO authenticated
     USING (true);
   
   -- notifications (users see only their own)
   CREATE POLICY "Users can read own notifications"
     ON public.notifications FOR SELECT
     TO authenticated
     USING (user_id = (SELECT auth.uid()));
   
   CREATE POLICY "Users can update own notifications"
     ON public.notifications FOR UPDATE
     TO authenticated
     USING (user_id = (SELECT auth.uid()));
   
   -- pet_care_badge_unlocks (users see their pets' badges)
   CREATE POLICY "Users can read own pet badge unlocks"
     ON public.pet_care_badge_unlocks FOR SELECT
     TO authenticated
     USING (pet_id IN (SELECT id FROM pets WHERE user_id = (SELECT auth.uid())));
   
   CREATE POLICY "Users can insert own pet badge unlocks"
     ON public.pet_care_badge_unlocks FOR INSERT
     TO authenticated
     WITH CHECK (pet_id IN (SELECT id FROM pets WHERE user_id = (SELECT auth.uid())));
   
   -- pet_care_gamification
   CREATE POLICY "Users can manage own pet gamification"
     ON public.pet_care_gamification FOR ALL
     TO authenticated
     USING (pet_id IN (SELECT id FROM pets WHERE user_id = (SELECT auth.uid())));
   
   -- pet_care_onboarding
   CREATE POLICY "Users can manage own pet onboarding"
     ON public.pet_care_onboarding FOR ALL
     TO authenticated
     USING (pet_id IN (SELECT id FROM pets WHERE user_id = (SELECT auth.uid())));
   ```

2. **Fix SECURITY DEFINER function** — convert to SECURITY INVOKER:
   ```sql
   CREATE OR REPLACE FUNCTION pet_is_owned_by_auth_user(pet_row_id uuid)
   RETURNS boolean
   LANGUAGE sql
   SECURITY INVOKER  -- was: SECURITY DEFINER
   STABLE
   AS $$
     SELECT EXISTS (
       SELECT 1 FROM pets WHERE id = pet_row_id AND user_id = (SELECT auth.uid())
     );
   $$;
   
   -- Revoke from anon role
   REVOKE EXECUTE ON FUNCTION pet_is_owned_by_auth_user FROM anon;
   ```

3. **Optimize all RLS policies** — use `(SELECT auth.uid())` instead of `auth.uid()`:
   ```sql
   -- For ALL 25+ policies using auth.uid(), change pattern from:
   USING (user_id = auth.uid())
   -- To:
   USING (user_id = (SELECT auth.uid()))
   ```
   This prevents re-evaluation per row (up to 100x speedup on large tables).

4. **Enable leaked password protection**:
   - Dashboard -> Authentication -> Settings -> Enable "Leaked Password Protection"

---

### Step 1.3: Database Performance — Add Missing Indexes

**Goal**: Add indexes for all 28 unindexed foreign keys.

```sql
-- Core tables
CREATE INDEX idx_pets_user_id ON public.pets(user_id);
CREATE INDEX idx_posts_user_id ON public.posts(user_id);
CREATE INDEX idx_posts_pet_id ON public.posts(pet_id);
CREATE INDEX idx_comments_post_id ON public.comments(post_id);
CREATE INDEX idx_comments_user_id ON public.comments(user_id);
CREATE INDEX idx_stories_user_id ON public.stories(user_id);
CREATE INDEX idx_stories_pet_id ON public.stories(pet_id);

-- Social
CREATE INDEX idx_follows_follower_id ON public.follows(follower_id);
CREATE INDEX idx_follows_following_id ON public.follows(following_id);
CREATE INDEX idx_post_likes_post_id ON public.post_likes(post_id);
CREATE INDEX idx_post_likes_user_id ON public.post_likes(user_id);
CREATE INDEX idx_match_requests_sender_id ON public.match_requests(sender_id);
CREATE INDEX idx_match_requests_receiver_id ON public.match_requests(receiver_id);
CREATE INDEX idx_notifications_user_id ON public.notifications(user_id);

-- Messaging
CREATE INDEX idx_messages_thread_id ON public.messages(thread_id);
CREATE INDEX idx_messages_sender_id ON public.messages(sender_id);
CREATE INDEX idx_chat_threads_user1_id ON public.chat_threads(user1_id);
CREATE INDEX idx_chat_threads_user2_id ON public.chat_threads(user2_id);

-- Health
CREATE INDEX idx_pet_symptoms_pet_id ON public.pet_symptoms(pet_id);
CREATE INDEX idx_pet_medications_pet_id ON public.pet_medications(pet_id);
CREATE INDEX idx_pet_medication_doses_medication_id ON public.pet_medication_doses(medication_id);
CREATE INDEX idx_pet_allergies_pet_id ON public.pet_allergies(pet_id);
CREATE INDEX idx_pet_vaccinations_pet_id ON public.pet_vaccinations(pet_id);
CREATE INDEX idx_pet_vet_appointments_pet_id ON public.pet_vet_appointments(pet_id);
CREATE INDEX idx_pet_weight_logs_pet_id ON public.pet_weight_logs(pet_id);
CREATE INDEX idx_pet_activity_logs_pet_id ON public.pet_activity_logs(pet_id);
CREATE INDEX idx_pet_dental_logs_pet_id ON public.pet_dental_logs(pet_id);
CREATE INDEX idx_pet_parasite_prevention_pet_id ON public.pet_parasite_prevention(pet_id);

-- Care & Commerce
CREATE INDEX idx_pet_care_logs_pet_id ON public.pet_care_logs(pet_id);
CREATE INDEX idx_orders_user_id ON public.orders(user_id);
CREATE INDEX idx_user_fcm_tokens_user_id ON public.user_fcm_tokens(user_id);
```

---

## PHASE 2: Architecture Refactoring (Week 2-4)

### Step 2.1: Restructure to Feature-First Architecture

**Goal**: Move from flat layer-first to modular feature-first organization.

**New directory structure**:
```
lib/
├── main.dart
├── app/
│   ├── app.dart                    # PetFolioApp widget
│   ├── router.dart                 # GoRouter configuration
│   └── bootstrap.dart              # App initialization
├── core/
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── colors.dart
│   │   ├── typography.dart
│   │   └── spacing.dart
│   ├── constants/
│   │   ├── supabase_config.dart
│   │   └── app_constants.dart
│   ├── utils/
│   │   ├── image_upload_helper.dart
│   │   ├── media_utils.dart
│   │   ├── care_calculator.dart
│   │   └── extensions.dart
│   ├── widgets/                    # Shared reusable widgets
│   │   ├── loading_indicator.dart
│   │   ├── error_widget.dart
│   │   ├── cached_avatar.dart
│   │   ├── responsive_builder.dart
│   │   └── skeleton_loader.dart
│   └── services/
│       ├── connectivity_service.dart
│       ├── offline_cache.dart
│       └── push_notification_service.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── auth_repository.dart
│   │   │   └── models/
│   │   │       └── user_model.dart
│   │   ├── domain/                 # Business logic (optional)
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   └── auth_controller.dart
│   │       └── screens/
│   │           ├── login_screen.dart
│   │           ├── signup_screen.dart
│   │           └── onboarding_screen.dart
│   ├── pet/
│   │   ├── data/
│   │   │   ├── pet_repository.dart
│   │   │   └── models/
│   │   │       └── pet_model.dart
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   └── pet_controller.dart
│   │       └── screens/
│   │           ├── add_pet_screen.dart
│   │           ├── pet_profile_screen.dart
│   │           └── components/
│   │               ├── pet_card.dart
│   │               └── pet_avatar.dart
│   ├── health/
│   │   ├── data/
│   │   │   ├── health_repository.dart
│   │   │   └── models/
│   │   │       ├── pet_health_models.dart
│   │   │       ├── pet_care_log_model.dart
│   │   │       └── care_badge_model.dart
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   ├── health_controller.dart     # split from 453-line god controller
│   │       │   ├── vitals_controller.dart
│   │       │   ├── medications_controller.dart
│   │       │   └── appointments_controller.dart
│   │       └── screens/
│   │           ├── health_dashboard_screen.dart
│   │           └── components/
│   ├── care/
│   │   ├── data/
│   │   │   ├── care_repository.dart
│   │   │   └── models/
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   ├── care_log_controller.dart    # split from 537-line god controller
│   │       │   ├── care_goals_controller.dart
│   │       │   └── care_gamification_controller.dart
│   │       └── screens/
│   ├── feed/
│   │   ├── data/
│   │   │   ├── feed_repository.dart
│   │   │   └── models/
│   │   │       ├── post_model.dart
│   │   │       └── story_model.dart
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   ├── feed_controller.dart
│   │       │   └── story_controller.dart
│   │       └── screens/
│   │           ├── home_feed_screen.dart
│   │           ├── create_post_screen.dart
│   │           ├── create_story_screen.dart
│   │           ├── post_detail_screen.dart
│   │           └── components/
│   ├── marketplace/
│   │   ├── data/
│   │   │   ├── marketplace_repository.dart
│   │   │   └── models/
│   │   │       ├── product_model.dart
│   │   │       ├── cart_item_model.dart
│   │   │       └── order_model.dart
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   ├── marketplace_controller.dart
│   │       │   └── cart_controller.dart
│   │       └── screens/
│   │           ├── marketplace_screen.dart
│   │           ├── product_detail_screen.dart
│   │           └── cart_screen.dart
│   ├── matching/
│   │   ├── data/
│   │   │   ├── match_repository.dart
│   │   │   └── models/
│   │   │       └── match_request_model.dart
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   ├── match_discovery_controller.dart  # split from 437-line god controller
│   │       │   └── match_requests_controller.dart
│   │       └── screens/
│   │           ├── discovery_screen.dart
│   │           ├── match_pet_profile_screen.dart
│   │           └── liked_pets_screen.dart
│   ├── chat/
│   │   ├── data/
│   │   │   ├── chat_repository.dart
│   │   │   └── models/
│   │   │       ├── message_model.dart
│   │   │       └── chat_thread_model.dart
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   └── chat_controller.dart
│   │       └── screens/
│   │           ├── messages_list_screen.dart
│   │           └── chat_screen.dart
│   └── notifications/
│       ├── data/
│       │   ├── notification_repository.dart
│       │   └── models/
│       │       └── notification_model.dart
│       └── presentation/
│           ├── controllers/
│           │   └── notification_controller.dart
│           └── screens/
│               └── notifications_screen.dart
```

**Migration steps**:
1. Create the new directory structure
2. Move files one feature at a time, updating imports
3. Run `dart fix --apply` after each feature migration
4. Run `flutter analyze` to catch broken imports
5. Run existing tests after each migration

---

### Step 2.2: Split God Controllers

**Goal**: Break down the 3 largest controllers into focused, single-responsibility units.

1. **health_controller.dart (453 LOC)** -> Split into:
   - `health_controller.dart` — orchestration, dashboard state
   - `vitals_controller.dart` — weight logs, activity logs, vital signs
   - `medications_controller.dart` — medications, doses, schedules
   - `appointments_controller.dart` — vet appointments, reminders

2. **pet_care_controller.dart (537 LOC)** -> Split into:
   - `care_log_controller.dart` — daily care logging (feed, walk, groom)
   - `care_goals_controller.dart` — goal tracking, streaks, progress
   - `care_gamification_controller.dart` — badges, points, achievements

3. **match_controller.dart (437 LOC)** -> Split into:
   - `match_discovery_controller.dart` — browsing, filtering, swiping
   - `match_requests_controller.dart` — send/accept/reject requests, status tracking

**Pattern for each split**:
```dart
// Each new controller follows this pattern:
class VitalsState {
  final List<WeightLog> weightLogs;
  final List<ActivityLog> activityLogs;
  final bool isLoading;
  final String? error;
  
  const VitalsState({
    this.weightLogs = const [],
    this.activityLogs = const [],
    this.isLoading = false,
    this.error,
  });
  
  VitalsState copyWith({...}) => VitalsState(...);
}

class VitalsNotifier extends Notifier<VitalsState> {
  @override
  VitalsState build() => const VitalsState();
  
  Future<void> loadWeightLogs(String petId) async { ... }
  Future<void> addWeightLog(WeightLog log) async { ... }
}

final vitalsProvider = NotifierProvider<VitalsNotifier, VitalsState>(VitalsNotifier.new);
```

---

### Step 2.3: Standardize All Models

**Goal**: Ensure all 22 models have consistent serialization and immutability.

**For each model**:
1. Add `copyWith()` (8 models missing it)
2. Add `toJson()` (5 models missing it)
3. Standardize `toJson()` naming (replace `toUpsertJson`/`toInsertJson` with `toJson()`)
4. Add `==` operator and `hashCode` override
5. Make all fields `final`
6. Add `const` constructor where possible

**Template**:
```dart
class PetModel {
  final String id;
  final String userId;
  final String name;
  // ... all fields final
  
  const PetModel({
    required this.id,
    required this.userId,
    required this.name,
  });
  
  factory PetModel.fromJson(Map<String, dynamic> json) => PetModel(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    name: json['name'] as String,
  );
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'name': name,
  };
  
  PetModel copyWith({String? id, String? userId, String? name}) => PetModel(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
  );
  
  @override
  bool operator ==(Object other) =>
    identical(this, other) || other is PetModel && id == other.id;
  
  @override
  int get hashCode => id.hashCode;
}
```

---

### Step 2.4: Fix Anti-Patterns in Controllers

**Fix these 12+ identified anti-patterns**:

| # | Anti-Pattern | Location | Fix |
|---|-------------|----------|-----|
| 1 | Direct `state.items.add()` mutation | `cart_controller.dart` | Use `state = state.copyWith(items: [...state.items, newItem])` |
| 2 | Missing error handling on notification sends | `push_notification_coordinator.dart` | Wrap FCM calls in try-catch |
| 3 | Realtime channel reassignment without unsubscribe | `chat_controller.dart` | Call `supabase.removeChannel()` before reassigning |
| 4 | No generation tracking for stale async requests | Multiple controllers | Add generation counter pattern |
| 5 | Hardcoded "Good Morning" greeting | `home_screen.dart` | Use time-based greeting function |
| 6 | Magic route strings throughout views | All view files | Define route constants in `router.dart` |
| 7 | Duplicated category lists | Multiple screens | Extract to shared constants file |
| 8 | Missing `Semantics` on icon-only buttons | All views | Wrap with `Semantics(label: '...')` |
| 9 | Inconsistent image handling | Views | Standardize on `CachedNetworkImage` everywhere |
| 10 | No file size validation on upload | `image_upload_helper.dart` | Add max file size check (10MB images, 50MB videos) |
| 11 | No video duration limit | `image_upload_helper.dart` | Add `maxDuration` parameter |
| 12 | `ConnectivityService._onOnlineRestored()` is TODO | `connectivity_service.dart` | Implement sync queue flush |

---

### Step 2.5: Add New Dependencies

**Update pubspec.yaml**:

```yaml
dependencies:
  # Existing (keep all current deps)
  
  # NEW: Image/Video Compression
  flutter_image_compress: ^2.3.0
  v_video_compressor: ^1.0.3
  video_thumbnail: ^0.5.3
  
  # NEW: Responsive Design
  flutter_adaptive_scaffold: ^0.3.1
  flutter_screenutil: ^5.9.3
  
  # NEW: Accessibility & Dynamic Color
  dynamic_color: ^1.7.0
  
  # NEW: Animations
  flutter_animate: ^4.5.2

dev_dependencies:
  # Existing
  mocktail: ^1.0.4
  flutter_lints: ^6.0.0
  
  # NEW: Testing
  mock_supabase_http_client: ^0.2.3
  patrol: ^3.13.0
  
  # NEW: Dev tools
  device_preview: ^1.2.0
  accessibility_tools: ^2.1.0
```

---

## PHASE 3: Performance Optimization (Week 4-5)

### Step 3.1: Image Compression Pipeline

**Goal**: Compress all images before upload. Reduce storage costs and upload times by ~85%.

**Create `lib/core/utils/image_compressor.dart`**:

```dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ImageCompressor {
  static const int _maxProfileSize = 512;
  static const int _maxPostSize = 1920;
  static const int _profileQuality = 80;
  static const int _postQuality = 75;
  static const int _thumbnailQuality = 60;
  static const int _maxFileSizeBytes = 10 * 1024 * 1024; // 10MB

  static Future<File?> compressForProfile(XFile image) async {
    return _compress(image, _maxProfileSize, _maxProfileSize, _profileQuality);
  }

  static Future<File?> compressForPost(XFile image) async {
    return _compress(image, _maxPostSize, _maxPostSize, _postQuality);
  }

  static Future<File?> compressForThumbnail(XFile image) async {
    return _compress(image, 300, 300, _thumbnailQuality);
  }

  static Future<File?> _compress(
    XFile image, int maxWidth, int maxHeight, int quality,
  ) async {
    final file = File(image.path);
    if (file.lengthSync() > _maxFileSizeBytes) {
      throw Exception('File exceeds maximum size of 10MB');
    }
    
    final dir = await getTemporaryDirectory();
    final targetPath = p.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');
    
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: quality,
      minWidth: maxWidth,
      minHeight: maxHeight,
      format: CompressFormat.jpeg,
    );
    
    return result != null ? File(result.path) : null;
  }
}
```

**Update `image_upload_helper.dart`** to use `ImageCompressor` before every upload.

### Step 3.2: Video Compression

**Create `lib/core/utils/video_compressor.dart`**:

```dart
import 'package:v_video_compressor/v_video_compressor.dart';

class VideoCompressor {
  static const int _maxDurationSeconds = 60;
  static const int _maxFileSizeMB = 50;
  
  static Future<File?> compress(File videoFile) async {
    if (videoFile.lengthSync() > _maxFileSizeMB * 1024 * 1024) {
      throw Exception('Video exceeds maximum size of ${_maxFileSizeMB}MB');
    }
    
    final compressor = VVideoCompressor();
    final result = await compressor.compressVideo(
      videoFile.path,
      quality: VideoQuality.medium,
    );
    
    return result?.file;
  }
  
  static Future<Uint8List?> generateThumbnail(File videoFile) async {
    final compressor = VVideoCompressor();
    return compressor.getVideoThumbnail(videoFile.path);
  }
}
```

### Step 3.3: Widget Performance

**Actions across all 57 view files**:

1. **Add `const` constructors** to all stateless widgets and widget parameters
2. **Replace `ref.watch(provider)` with `ref.watch(provider.select(...))`** — only watch the specific fields each widget needs
3. **Replace all `ListView(children: [...])` with `ListView.builder`** — especially in feed, chat, marketplace
4. **Add `RepaintBoundary`** around expensive widgets (charts, images, animations)
5. **Defer non-critical initialization** in `bootstrap_controller.dart`:
   ```dart
   // Move these after first frame:
   WidgetsBinding.instance.addPostFrameCallback((_) {
     ref.read(notificationProvider.notifier).initialize();
     ref.read(analyticsProvider.notifier).initialize();
   });
   ```

### Step 3.4: Supabase Query Optimization

1. **Add `.limit()` to all list queries** — especially `pet_expense_repository` which has no pagination
2. **Filter realtime subscriptions**:
   ```dart
   // Before (bad):
   supabase.channel('messages').onPostgresChanges(...)
   
   // After (good):
   supabase.channel('messages:$threadId')
     .onPostgresChanges(
       event: PostgresChangeEvent.insert,
       schema: 'public',
       table: 'messages',
       filter: PostgresChangeFilter(
         type: PostgresChangeFilterType.eq,
         column: 'thread_id',
         value: threadId,
       ),
     )
   ```
3. **Dispose all realtime subscriptions** in controller `dispose()` or `ref.onDispose()`

---

## PHASE 4: Complete UI/UX Redesign (Week 5-10)

### Step 4.1: Design System Overhaul

**Goal**: Modern Material 3 with Dynamic Color, accessibility compliance, and responsive design.

**Update `lib/core/theme/`**:

1. **New color system** — `colors.dart`:
   ```dart
   class PetFolioColors {
     // Brand colors (fallback when Dynamic Color unavailable)
     static const Color primary = Color(0xFF4A7DF7);      // PetFolio Blue
     static const Color secondary = Color(0xFF47B4FF);     // Sky Blue
     static const Color tertiary = Color(0xFF7C5CE0);      // Lavender accent
     static const Color success = Color(0xFF4CAF50);       // Green
     static const Color warning = Color(0xFFFF9800);       // Orange
     static const Color error = Color(0xFFE53935);         // Red
     
     // Surface colors
     static const Color lightBackground = Color(0xFFFCFAF8);
     static const Color lightSurface = Color(0xFFFFFFFF);
     static const Color darkBackground = Color(0xFF121212);
     static const Color darkSurface = Color(0xFF1E1E1E);
     
     // Semantic pet-related accent colors
     static const Color catAccent = Color(0xFFE8A87C);
     static const Color dogAccent = Color(0xFF85C1E9);
     static const Color healthGreen = Color(0xFF66BB6A);
     static const Color careAmber = Color(0xFFFFCA28);
   }
   ```

2. **Dynamic Color integration** — wrap app with `DynamicColorBuilder`:
   ```dart
   DynamicColorBuilder(
     builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
       final lightScheme = lightDynamic?.harmonized() ?? PetFolioColors.lightScheme;
       final darkScheme = darkDynamic?.harmonized() ?? PetFolioColors.darkScheme;
       
       return MaterialApp.router(
         theme: AppTheme.light(lightScheme),
         darkTheme: AppTheme.dark(darkScheme),
         themeMode: themeMode,
       );
     },
   );
   ```

3. **Typography** — `typography.dart`:
   ```dart
   class PetFolioTypography {
     static TextTheme textTheme = TextTheme(
       displayLarge: GoogleFonts.playfairDisplay(fontSize: 57, fontWeight: FontWeight.w400),
       displayMedium: GoogleFonts.playfairDisplay(fontSize: 45, fontWeight: FontWeight.w400),
       displaySmall: GoogleFonts.playfairDisplay(fontSize: 36, fontWeight: FontWeight.w400),
       headlineLarge: GoogleFonts.playfairDisplay(fontSize: 32, fontWeight: FontWeight.w600),
       headlineMedium: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.w600),
       headlineSmall: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.w600),
       titleLarge: GoogleFonts.dmSans(fontSize: 22, fontWeight: FontWeight.w500),
       titleMedium: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w500),
       titleSmall: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500),
       bodyLarge: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w400),
       bodyMedium: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w400),
       bodySmall: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w400),
       labelLarge: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600),
       labelMedium: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600),
       labelSmall: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600),
     );
   }
   ```

4. **Spacing & Sizing** — `spacing.dart`:
   ```dart
   class PetFolioSpacing {
     static const double xs = 4;
     static const double sm = 8;
     static const double md = 16;
     static const double lg = 24;
     static const double xl = 32;
     static const double xxl = 48;
     
     static const double cardRadius = 16;    // was 24 — tighter, more modern
     static const double inputRadius = 12;
     static const double pillRadius = 100;
     static const double chipRadius = 8;
     
     static const double minTouchTarget = 48; // Accessibility minimum
   }
   ```

### Step 4.2: Responsive Layout System

**Create `lib/core/widgets/responsive_builder.dart`**:

```dart
enum ScreenSize { compact, medium, expanded }

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext, ScreenSize) builder;
  
  const ResponsiveBuilder({super.key, required this.builder});
  
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 600) return ScreenSize.compact;
    if (width < 1200) return ScreenSize.medium;
    return ScreenSize.expanded;
  }
  
  @override
  Widget build(BuildContext context) => builder(context, getScreenSize(context));
}
```

**Replace `main_layout.dart`** with `AdaptiveScaffold`:

```dart
AdaptiveScaffold(
  selectedIndex: currentIndex,
  onSelectedIndexChange: onIndexChanged,
  destinations: const [
    NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
    NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Discover'),
    NavigationDestination(icon: Icon(Icons.store_outlined), selectedIcon: Icon(Icons.store), label: 'Shop'),
    NavigationDestination(icon: Icon(Icons.chat_outlined), selectedIcon: Icon(Icons.chat), label: 'Chat'),
    NavigationDestination(icon: Icon(Icons.person_outlined), selectedIcon: Icon(Icons.person), label: 'Profile'),
  ],
  body: (_) => pages[currentIndex],
);
```

### Step 4.3: Screen-by-Screen Redesign Plan

**Every screen follows this template**:
1. Wrap content in `ResponsiveBuilder`
2. Use `CustomScrollView` with `SliverAppBar` for scroll-connected headers
3. Add `Semantics` to all interactive elements
4. Add `flutter_animate` for entrance animations
5. Use `CachedNetworkImage` consistently
6. Add skeleton loading states
7. Add empty states with illustrations
8. Ensure minimum 48x48 touch targets

#### Screen Redesign Specifications:

| Screen | Key Changes |
|--------|-------------|
| **Splash/Login** | Add brand animation (logo morph), social login buttons with icons, accessibility labels on all inputs |
| **Onboarding** | Page-based with `PageView`, progress indicator, skip button, pet type selection with animated cards |
| **Home Feed** | `SliverAppBar` with collapsing profile banner, story row at top, `ListView.builder` for posts, pull-to-refresh, FAB for create post |
| **Discovery** | Card stack swipe (like Tinder) with `flutter_card_swiper`, filter chips at top, match percentage badge |
| **Pet Profile** | Hero image with parallax, tab bar (Info/Health/Care/Gallery), stat cards with `fl_chart`, share button |
| **Add/Edit Pet** | Multi-step form with stepper, image cropper, breed autocomplete, date pickers |
| **Health Dashboard** | Grid of metric cards, trend charts, medication schedule timeline, appointment calendar |
| **Care Goals** | Progress rings, streak counter, badge showcase, daily checklist |
| **Marketplace** | Grid/list toggle, category chips, search bar, product cards with price badge |
| **Product Detail** | Image carousel, expandable description, size/color selectors, add-to-cart FAB |
| **Cart** | Swipe-to-delete items, quantity stepper, coupon input, order summary, checkout button |
| **Chat List** | Last message preview, unread badge, online indicator, search |
| **Chat Screen** | Message bubbles with timestamps, image messages, typing indicator, input bar with attachment |
| **Notifications** | Grouped by date, swipe to dismiss, action buttons, read/unread states |
| **Create Post** | Multi-image picker, pet tag selector, location tag, caption with character count |
| **Create Story** | Camera view, filters, text overlay, pet sticker picker, duration selector |
| **Settings/Profile** | Account info form, theme toggle, notification preferences, logout, delete account |

### Step 4.4: Accessibility Compliance

**Apply across ALL screens**:

1. **Semantics labels** on every icon-only button:
   ```dart
   Semantics(
     label: 'Like post',
     child: IconButton(icon: Icon(Icons.favorite_border), onPressed: onLike),
   )
   ```

2. **Color contrast** — verify all text/background combos meet WCAG AA (4.5:1 ratio):
   - Test warm gray text (#B8B0A4) on dark charcoal (#1A1814) — this likely fails, needs lighter text
   - All interactive states need distinct visual indicators beyond color alone

3. **Touch targets** — minimum 48x48 pixels on all buttons, links, icons

4. **Text scaling** — ensure layouts don't break at 200% text scale:
   ```dart
   // Test: flutter run with --dart-define=FLUTTER_TEXT_SCALE=2.0
   ```

5. **Screen reader order** — ensure logical reading order in complex layouts

6. **Care badge emojis** — add text alternatives:
   ```dart
   Semantics(
     label: 'Gold badge: Consistent Caretaker',
     child: Text('🏆'),
   )
   ```

---

## PHASE 5: Testing & Automation (Week 10-12)

### Step 5.1: Testing Infrastructure

**Goal**: Achieve 60%+ code coverage with a proper testing pyramid.

**Test directory structure**:
```
test/
├── unit/
│   ├── models/
│   │   ├── pet_model_test.dart
│   │   ├── user_model_test.dart
│   │   └── ... (all 22 models)
│   ├── controllers/
│   │   ├── auth_controller_test.dart
│   │   ├── pet_controller_test.dart
│   │   └── ... (all controllers)
│   └── utils/
│       ├── care_calculator_test.dart
│       └── image_compressor_test.dart
├── widget/
│   ├── screens/
│   │   ├── login_screen_test.dart
│   │   ├── home_screen_test.dart
│   │   └── ... (key screens)
│   └── components/
│       ├── pet_card_test.dart
│       └── ... (shared widgets)
├── integration/
│   ├── auth_flow_test.dart
│   ├── pet_crud_test.dart
│   ├── marketplace_checkout_test.dart
│   └── care_logging_test.dart
└── helpers/
    ├── test_helpers.dart
    ├── mock_supabase.dart
    └── pump_app.dart
```

### Step 5.2: Mock Supabase for Tests

**Create `test/helpers/mock_supabase.dart`**:
```dart
import 'package:mock_supabase_http_client/mock_supabase_http_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

MockSupabaseHttpClient createMockSupabase() {
  final mock = MockSupabaseHttpClient();
  
  // Seed test data
  mock.from('pets').insert([
    {'id': 'pet-1', 'user_id': 'user-1', 'name': 'Buddy', 'species': 'dog'},
    {'id': 'pet-2', 'user_id': 'user-1', 'name': 'Whiskers', 'species': 'cat'},
  ]);
  
  mock.from('profiles').insert([
    {'id': 'user-1', 'display_name': 'Test User', 'email': 'test@example.com'},
  ]);
  
  return mock;
}
```

### Step 5.3: Unit Test Template for Controllers

```dart
void main() {
  late PetNotifier notifier;
  late MockPetRepository mockRepo;
  
  setUp(() {
    mockRepo = MockPetRepository();
    notifier = PetNotifier(mockRepo);
  });
  
  group('loadPets', () {
    test('sets isLoading true then false', () async {
      when(() => mockRepo.fetchMyPets(any())).thenAnswer((_) async => []);
      
      final future = notifier.loadPets('user-1');
      expect(notifier.state.isLoading, true);
      
      await future;
      expect(notifier.state.isLoading, false);
    });
    
    test('populates myPets on success', () async {
      when(() => mockRepo.fetchMyPets(any())).thenAnswer((_) async => [testPet]);
      
      await notifier.loadPets('user-1');
      
      expect(notifier.state.myPets.length, 1);
      expect(notifier.state.myPets.first.name, 'Buddy');
    });
    
    test('sets error on failure', () async {
      when(() => mockRepo.fetchMyPets(any())).thenThrow(Exception('DB error'));
      
      await notifier.loadPets('user-1');
      
      expect(notifier.state.error, contains('DB error'));
      expect(notifier.state.isLoading, false);
    });
  });
}
```

### Step 5.4: Android Emulator Automation Testing

**Prerequisites**:
```bash
# Install Patrol CLI
dart pub global activate patrol_cli

# Verify Android emulator
flutter emulators
flutter emulators --launch <emulator_id>
```

**Create `integration_test/` test files**:

#### Test: Complete User Journey
```dart
// integration_test/user_journey_test.dart
import 'package:patrol/patrol.dart';

void main() {
  patrolTest('complete user journey - signup to post creation', ($) async {
    await $.pumpWidgetAndSettle(const PetFolioApp());
    
    // 1. Login/Signup
    await $(#emailField).enterText('test@example.com');
    await $(#passwordField).enterText('Test1234!');
    await $(#loginButton).tap();
    await $.pumpAndSettle();
    
    // 2. Verify home screen loaded
    expect($(#homeFeed), findsOneWidget);
    
    // 3. Navigate to add pet
    await $(#addPetFab).tap();
    await $.pumpAndSettle();
    
    // 4. Fill pet form
    await $(#petNameField).enterText('Buddy');
    await $(#petSpeciesDropdown).tap();
    await $('Dog').tap();
    await $(#petBreedField).enterText('Golden Retriever');
    await $(#savePetButton).tap();
    await $.pumpAndSettle();
    
    // 5. Verify pet appears in profile
    expect($('Buddy'), findsOneWidget);
    
    // 6. Create post
    await $(#createPostFab).tap();
    await $.pumpAndSettle();
    await $(#postCaptionField).enterText('Meet my new pet Buddy! 🐕');
    await $(#publishPostButton).tap();
    await $.pumpAndSettle();
    
    // 7. Verify post in feed
    expect($('Meet my new pet Buddy!'), findsOneWidget);
  });
}
```

#### Test: Health Tracking Flow
```dart
patrolTest('health tracking - add vitals and medication', ($) async {
  // Login with existing user
  await _loginAsTestUser($);
  
  // Navigate to pet health tab
  await $(#petProfileTab).tap();
  await $(#healthTab).tap();
  await $.pumpAndSettle();
  
  // Add weight log
  await $(#addWeightButton).tap();
  await $(#weightField).enterText('25.5');
  await $(#saveWeightButton).tap();
  expect($('25.5 kg'), findsOneWidget);
  
  // Add medication
  await $(#medicationsTab).tap();
  await $(#addMedicationButton).tap();
  await $(#medicationNameField).enterText('Heartgard');
  await $(#dosageField).enterText('1 tablet');
  await $(#frequencyDropdown).tap();
  await $('Monthly').tap();
  await $(#saveMedicationButton).tap();
  expect($('Heartgard'), findsOneWidget);
});
```

#### Test: Marketplace Checkout
```dart
patrolTest('marketplace - browse, add to cart, checkout', ($) async {
  await _loginAsTestUser($);
  
  // Navigate to marketplace
  await $(#shopTab).tap();
  await $.pumpAndSettle();
  
  // Search for product
  await $(#searchField).enterText('dog food');
  await $.pumpAndSettle();
  
  // Tap first product
  await $(#productCard).first.tap();
  await $.pumpAndSettle();
  
  // Add to cart
  await $(#addToCartButton).tap();
  expect($(#cartBadge), findsOneWidget);
  
  // Go to cart
  await $(#cartIcon).tap();
  await $.pumpAndSettle();
  
  // Verify item in cart
  expect($('dog food'), findsOneWidget);
  
  // Proceed to checkout
  await $(#checkoutButton).tap();
  await $.pumpAndSettle();
  
  // Use test card (Stripe)
  // Note: In test mode, Stripe uses test card numbers
});
```

#### Test: Chat Flow
```dart
patrolTest('chat - send message and receive reply', ($) async {
  await _loginAsTestUser($);
  
  // Navigate to chat
  await $(#chatTab).tap();
  await $.pumpAndSettle();
  
  // Open existing thread (or start new)
  await $(#chatThread).first.tap();
  await $.pumpAndSettle();
  
  // Type and send message
  await $(#messageInput).enterText('Hello! How is your pet doing?');
  await $(#sendButton).tap();
  await $.pumpAndSettle();
  
  // Verify message appears
  expect($('Hello! How is your pet doing?'), findsOneWidget);
});
```

### Step 5.5: Run Tests on Android Emulator

```bash
# Run all integration tests on emulator
patrol test --target integration_test/

# Run specific test
patrol test --target integration_test/user_journey_test.dart

# Run with verbose output
patrol test --target integration_test/ --verbose

# Generate test report
flutter test --coverage --machine > test_results.json

# View coverage report
genhtml coverage/lcov.info -o coverage/html
```

---

## PHASE 6: Final Polish & Deployment (Week 12-13)

### Step 6.1: Complete Offline Sync

**Implement `ConnectivityService._onOnlineRestored()`**:
```dart
Future<void> _onOnlineRestored() async {
  final syncQueue = await _cache.getSyncQueue();
  
  for (final item in syncQueue) {
    try {
      switch (item.type) {
        case SyncType.create:
          await supabase.from(item.table).insert(item.data);
        case SyncType.update:
          await supabase.from(item.table).update(item.data).eq('id', item.id);
        case SyncType.delete:
          await supabase.from(item.table).delete().eq('id', item.id);
      }
      await _cache.removeSyncItem(item.id);
    } catch (e) {
      developer.log('Sync failed for ${item.id}: $e', name: 'ConnectivityService');
    }
  }
}
```

### Step 6.2: Error Boundary & Crash Reporting

Add global error handling in `main.dart`:
```dart
void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    FlutterError.onError = (details) {
      developer.log('Flutter error: ${details.exception}', name: 'FlutterError');
    };
    
    // ... initialization
    runApp(const ProviderScope(child: PetFolioApp()));
  }, (error, stack) {
    developer.log('Unhandled error: $error', name: 'ZoneError', stackTrace: stack);
  });
}
```

### Step 6.3: GoRouter Nested Routes

**Replace 50+ flat routes** with nested structure:
```dart
GoRouter(
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, child) => MainLayout(child: child),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/', builder: (c, s) => const HomeFeedScreen()),
          GoRoute(path: '/post/:id', builder: (c, s) => PostDetailScreen(id: s.pathParameters['id']!)),
          GoRoute(path: '/post/create', builder: (c, s) => const CreatePostScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/discover', builder: (c, s) => const DiscoveryScreen()),
          GoRoute(path: '/discover/pet/:id', builder: (c, s) => MatchPetProfileScreen(id: s.pathParameters['id']!)),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/shop', builder: (c, s) => const MarketplaceScreen()),
          GoRoute(path: '/shop/product/:id', builder: (c, s) => ProductDetailScreen(id: s.pathParameters['id']!)),
          GoRoute(path: '/shop/cart', builder: (c, s) => const CartScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/chat', builder: (c, s) => const MessagesListScreen()),
          GoRoute(path: '/chat/:threadId', builder: (c, s) => ChatScreen(threadId: s.pathParameters['threadId']!)),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/profile', builder: (c, s) => const ProfileScreen()),
          GoRoute(path: '/profile/pet/:id', builder: (c, s) => PetProfileScreen(id: s.pathParameters['id']!)),
          GoRoute(path: '/profile/settings', builder: (c, s) => const SettingsScreen()),
        ]),
      ],
    ),
    // Auth routes (outside shell)
    GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (c, s) => const SignupScreen()),
    GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingScreen()),
  ],
);
```

---

## Execution Checklist for AI Agents

Each step below is independently executable. An AI agent should:
1. Read this plan
2. Execute steps sequentially within each phase
3. Run `flutter analyze` after each file change
4. Run `flutter test` after each phase
5. Build and launch on Android emulator after Phases 3 and 4

### Quick Reference: Commands After Each Phase

```bash
# After every change
dart format lib/ test/
flutter analyze

# After Phase 1
flutter test
flutter build apk --debug  # Verify it builds

# After Phase 2
flutter test
flutter run -d emulator-5554  # Verify app works

# After Phase 3
flutter run --profile -d emulator-5554  # Check performance
flutter test --coverage

# After Phase 4
flutter run -d emulator-5554  # Visual verification on all screens
flutter run -d chrome          # Web responsive verification

# After Phase 5
patrol test --target integration_test/
flutter test --coverage
# Target: 60%+ coverage

# After Phase 6
flutter build apk --release
flutter build web --release
```

---

## Priority Matrix

| Priority | Phase | Effort | Impact | Risk |
|----------|-------|--------|--------|------|
| **P0** | 1.2 DB Security | Low | Critical | Data breach |
| **P0** | 1.3 DB Indexes | Low | High | Performance |
| **P1** | 2.1 Feature-first restructure | High | High | Maintainability |
| **P1** | 2.2 Split god controllers | Medium | High | Code quality |
| **P1** | 3.1 Image compression | Low | High | Storage/speed |
| **P2** | 4.1 Design system | Medium | High | UX |
| **P2** | 4.2 Responsive layout | Medium | High | Multi-platform |
| **P2** | 4.4 Accessibility | Medium | Medium | Legal compliance |
| **P3** | 5.1-5.4 Testing | High | High | Reliability |
| **P3** | 6.1 Offline sync | Medium | Medium | Offline UX |

---

This plan covers every aspect requested: architecture, system design, design patterns, DB schema, authentication security, project directory setup, .gitignore, complete UI/UX redesign of all screens, performance optimization, accessibility, responsive design, and automated testing with real data on Android emulator. Each step is self-contained and executable by any AI agent with access to the codebase.