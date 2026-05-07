# Material Design 3 Implementation Guide
## PetSphere Flutter Redesign - Phase 1: Foundation

**Status**: Ready for Implementation  
**Version**: 1.0  
**Date**: May 1, 2026

---

## OVERVIEW

This guide provides step-by-step instructions to migrate PetSphere from partial Material Design 3 to a complete, comprehensive Material Design 3 implementation with proper semantic colors, component theming, and accessibility compliance.

### What's Included

- ✅ Complete Material Design 3 theme (`app_theme_v2_material3.dart`)
- ✅ All semantic colors properly configured
- ✅ Full component theme overrides
- ✅ Typography system (Playfair + DM Sans)
- ✅ Spacing and sizing tokens
- ✅ Accessibility defaults (touch targets, contrast)
- ✅ Dark mode implementation

### Benefits of This Implementation

1. **Consistency**: All components now follow Material Design 3 guidelines
2. **Maintainability**: Centralized theme system reduces hardcoded colors
3. **Accessibility**: Proper contrast ratios, touch targets, focus states
4. **Scalability**: Easy to extend with new colors, sizes, or components
5. **Performance**: Reduced widget rebuilds through proper theming

---

## PHASE 1: THEME INTEGRATION (Week 1)

### Step 1: Update main.dart

**File**: `lib/main.dart`

Replace the current theme initialization:

```dart
// OLD:
home: Consumer(
  builder: (context, ref, child) {
    final authState = ref.watch(authProvider);
    return authState.status == AuthStatus.authenticated
        ? const MainLayout()
        : const LoginScreen();
  },
),
theme: AppTheme.darkTheme,

// NEW:
home: Consumer(
  builder: (context, ref, child) {
    final authState = ref.watch(authProvider);
    return authState.status == AuthStatus.authenticated
        ? const MainLayout()
        : const LoginScreen();
  },
),
theme: AppThemeV2.darkTheme,  // Use new theme
```

**Full main.dart template**:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

import 'theme/app_theme_v2_material3.dart';
import 'controllers/auth_controller.dart';
import 'views/main_layout.dart';
import 'views/login_screen.dart';
import 'utils/supabase_config.dart';
import 'utils/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const ProviderScope(child: PetSphereApp()));
}

class PetSphereApp extends ConsumerWidget {
  const PetSphereApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'PetSphere',
      routerConfig: router,
      theme: AppThemeV2.darkTheme,  // NEW: Material Design 3 theme
      debugShowCheckedModeBanner: false,
    );
  }
}
```

### Step 2: Verify Theme Properties in main.dart

After updating `main.dart`, verify that all Material Design 3 colors are accessible:

```dart
// These are now available throughout the app:
Theme.of(context).colorScheme.primary              // #D4845A
Theme.of(context).colorScheme.secondary            // #4A7C59
Theme.of(context).colorScheme.tertiary             // #8B5A7D
Theme.of(context).colorScheme.error                // #B3261E
Theme.of(context).colorScheme.background           // #0F0E0C
Theme.of(context).colorScheme.surface              // #1A1814
Theme.of(context).colorScheme.outline              // #6B645B

// Typography:
Theme.of(context).textTheme.displayLarge           // 57sp, Playfair
Theme.of(context).textTheme.headlineMedium         // 28sp, Playfair
Theme.of(context).textTheme.titleLarge             // 22sp, DM Sans Bold
Theme.of(context).textTheme.bodyMedium             // 14sp, DM Sans Regular
```

---

## PHASE 2: COMPONENT MIGRATION (Weeks 2-3)

### Component-by-Component Migration

#### 1. Buttons

**OLD PATTERN** (hardcoded colors):
```dart
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFFD4845A),
    padding: EdgeInsets.all(16),
  ),
  child: Text('Click Me'),
)
```

**NEW PATTERN** (theme-based):
```dart
ElevatedButton(
  onPressed: () {},
  child: const Text('Click Me'),
)
// Theme handles: color, padding (24h x 12v), height (48dp), radius (8dp)
```

**Button Variants**:

```dart
// Primary (default ElevatedButton)
ElevatedButton(onPressed: () {}, child: const Text('Primary'))

// Secondary (FilledButton)
FilledButton(
  onPressed: () {},
  child: const Text('Secondary'),
)

// Tertiary (OutlinedButton)
OutlinedButton(
  onPressed: () {},
  child: const Text('Tertiary'),
)

// Text-only (TextButton)
TextButton(
  onPressed: () {},
  child: const Text('Text Action'),
)
```

#### 2. Cards

**OLD PATTERN**:
```dart
Card(
  color: Color(0xFF211F1B),
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
    side: BorderSide(color: Color(0xFF2E2B26)),
  ),
  child: ...
)
```

**NEW PATTERN**:
```dart
Card(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: ...
  ),
)
// Theme handles: surface color, border, border radius, elevation
```

#### 3. Text Fields

**OLD PATTERN**:
```dart
TextField(
  decoration: InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: Color(0xFF2E2B26)),
    ),
    fillColor: Color(0xFF1A1814),
    filled: true,
  ),
)
```

**NEW PATTERN**:
```dart
TextField(
  decoration: InputDecoration(
    labelText: 'Enter text',
    hintText: 'Placeholder text',
  ),
)
// Theme handles: border, radius, fill color, focus states, padding
```

#### 4. Chips

**OLD PATTERN**:
```dart
Chip(
  label: Text('Chip'),
  backgroundColor: Color(0xFF211F1B),
  side: BorderSide(color: Color(0xFF2E2B26)),
)
```

**NEW PATTERN**:
```dart
Chip(
  label: const Text('Chip'),
)
// Theme handles: background, border, selected state, label style
```

#### 5. Dialogs

**OLD PATTERN**:
```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    backgroundColor: Color(0xFF1A1814),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    title: Text('Confirm'),
    content: Text('Are you sure?'),
  ),
)
```

**NEW PATTERN**:
```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('Confirm'),
    content: const Text('Are you sure?'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      ElevatedButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Confirm'),
      ),
    ],
  ),
)
// Theme handles: background color, border radius, button styling
```

#### 6. Bottom Sheets

**OLD PATTERN**:
```dart
showModalBottomSheet(
  context: context,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
  ),
  backgroundColor: Color(0xFF1A1814),
  builder: (context) => Container(
    child: ...
  ),
)
```

**NEW PATTERN**:
```dart
showModalBottomSheet(
  context: context,
  builder: (context) => DraggableScrollableSheet(
    expand: false,
    builder: (context, scrollController) => Container(
      child: ...
    ),
  ),
)
// Theme handles: background, shape, drag handle
```

---

## PHASE 3: SCREEN-BY-SCREEN MIGRATION (Weeks 4-8)

### Migration Priority Order

**Tier 1 - Critical Auth Screens** (Week 4):
1. `login_screen.dart` - Update form styling, button colors, error states
2. `registration_screen.dart` - Update form styling, multi-step design
3. `splash_screen.dart` - Update logo/branding, loading indicator

**Tier 2 - Main Navigation** (Week 5):
1. `main_layout.dart` - Update bottom navigation theme, FAB styling
2. `home_screen.dart` - Update feed cards, story rings, chips, loading states
3. `discovery_screen.dart` - Update swipe cards, filter panel, buttons

**Tier 3 - Pet Management** (Week 6):
1. `add_pet_screen.dart` - Update form, multi-step stepper styling
2. `pet_profile_screen.dart` - Update tabs, cards, action buttons
3. `health_tab.dart` - Update tabs, chart styling, card layouts

**Tier 4 - Social Features** (Week 7):
1. `create_post_screen.dart` - Update form, media picker, preview
2. `post_detail_screen.dart` - Update comment form, interaction buttons
3. `chat_screen.dart` - Update message bubbles, input field, indicators
4. `notifications_screen.dart` - Update list styling, action buttons

**Tier 5 - Marketplace** (Week 8):
1. `marketplace_screen.dart` - Update product cards, search, filters
2. `product_detail_screen.dart` - Update gallery, price display, buttons
3. `cart_screen.dart` - Update item cards, checkout flow
4. `order_history_screen.dart` - Update order list, status indicators

### Screen Migration Template

For each screen, follow this pattern:

```dart
// BEFORE: Hardcoded colors
Container(
  color: Color(0xFFD4845A),
  padding: EdgeInsets.all(16),
  child: Text('Title'),
)

// AFTER: Theme-based styling
Container(
  color: Theme.of(context).colorScheme.primary,
  padding: const EdgeInsets.all(16),
  child: Text(
    'Title',
    style: Theme.of(context).textTheme.titleLarge,
  ),
)
```

### Common Refactorings Across Screens

1. **Color References**:
   ```dart
   // Replace all Color(0xFFD4845A) with:
   Theme.of(context).colorScheme.primary
   
   // Replace all Color(0xFF0F0E0C) with:
   Theme.of(context).colorScheme.background
   ```

2. **Padding Constants**:
   ```dart
   // Replace arbitrary padding values with:
   const EdgeInsets.all(8)   // spacingSm
   const EdgeInsets.all(16)  // spacingMd
   const EdgeInsets.all(24)  // spacingLg
   ```

3. **Border Radius**:
   ```dart
   // Replace arbitrary radius values with:
   BorderRadius.circular(8)   // radiusMd
   BorderRadius.circular(12)  // radiusLg
   BorderRadius.circular(16)  // radiusXl
   ```

4. **Typography**:
   ```dart
   // Replace GoogleFonts.dmSans() with:
   Theme.of(context).textTheme.bodyMedium
   
   // Replace GoogleFonts.playfairDisplay() with:
   Theme.of(context).textTheme.headlineSmall
   ```

---

## PHASE 4: NEW FEATURES & MISSING SCREENS (Weeks 9-10)

### Missing Screens from Design System Spec

These screens need implementation with Material Design 3:

#### 1. Onboarding Flow (5 screens)

**Location**: `lib/views/onboarding/`

```
- welcome_screen.dart
- signup_screen.dart
- create_first_pet_screen.dart
- pet_details_screen.dart
- enable_notifications_screen.dart
```

**Example: WelcomeScreen**

```dart
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Hero image/logo
              Image.asset('assets/petsphere_logo.png', height: 200),
              
              // Title
              Text(
                'Welcome to PetSphere',
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              
              // Subtitle
              Text(
                'Connect, care, and celebrate your pets',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
                textAlign: TextAlign.center,
              ),
              
              // CTA Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.push('/signup'),
                      child: const Text('Get Started'),
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => context.push('/login'),
                      child: const Text('Sign In'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

#### 2. User Profile Management

**Location**: `lib/views/profile_screen.dart`

```dart
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/profile/edit'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Header Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(userImageUrl),
                  ),
                  const SizedBox(height: 16),
                  // Name
                  Text(
                    'User Name',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  // Bio
                  Text(
                    'Pet lover since 2020',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Pet Collection
          Text(
            'My Pets',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              spacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: pets.length,
            itemBuilder: (context, index) => PetCard(pet: pets[index]),
          ),
        ],
      ),
    );
  }
}
```

#### 3. Pet Care Goals & Tracking

**Location**: `lib/views/care_goals_screen.dart`

#### 4. Gamification Dashboard

**Location**: `lib/views/gamification_screen.dart`

#### 5. Community/Forum

**Location**: `lib/views/community/`

#### 6. Settings & Preferences

**Location**: `lib/views/settings_screen.dart` (already exists, needs redesign)

---

## VALIDATION & TESTING

### Accessibility Checklist

Before marking a screen complete, verify:

- [ ] Color contrast: 4.5:1 for normal text, 3:1 for large text
- [ ] Touch targets: All interactive elements ≥48dp
- [ ] Focus indicators: Visible focus rings on all buttons/inputs
- [ ] Screen reader labels: All images have semantic labels
- [ ] Keyboard navigation: All features accessible via keyboard

### Theme Validation Script

Run this in the Flutter inspector to verify theme is properly applied:

```dart
void validateTheme(BuildContext context) {
  final theme = Theme.of(context);
  print('Primary Color: ${theme.colorScheme.primary}');
  print('Surface Color: ${theme.colorScheme.surface}');
  print('Body Large Font Size: ${theme.textTheme.bodyLarge?.fontSize}');
  print('Button Height: 48dp (check in inspector)');
  print('Corner Radius: Various (check in components)');
}
```

### Device Testing Matrix

Test on these devices before completing:

| Device | OS | Version | Status |
|--------|----|---------|----|
| iPhone 14 | iOS | 16.0+ | [ ] |
| iPhone SE | iOS | 14.0+ | [ ] |
| Pixel 6 | Android | 12 | [ ] |
| Pixel 4a | Android | 11 | [ ] |
| iPad Air | iPadOS | 15.0+ | [ ] |
| Tablet (Android) | Android | 12 | [ ] |

---

## MIGRATION CHECKLIST

### Week 1: Foundation
- [ ] Update `main.dart` to use `AppThemeV2`
- [ ] Copy `app_theme_v2_material3.dart` to `lib/theme/`
- [ ] Test app launches with new theme
- [ ] Verify all colors are correct in inspector

### Week 2-3: Critical Components
- [ ] Migrate button components
- [ ] Migrate card styling
- [ ] Migrate form styling
- [ ] Migrate dialog/bottom sheet styling

### Week 4-8: Screen Migration
- [ ] Tier 1: Auth screens (3 screens)
- [ ] Tier 2: Main navigation (3 screens)
- [ ] Tier 3: Pet management (3 screens)
- [ ] Tier 4: Social features (4 screens)
- [ ] Tier 5: Marketplace (4 screens)

### Week 9-10: New Features
- [ ] Implement onboarding flow
- [ ] Implement profile management
- [ ] Implement care goals screen
- [ ] Implement gamification dashboard
- [ ] Implement settings screen

### Validation
- [ ] Run `flutter analyze` - 0 errors
- [ ] Run accessibility audit
- [ ] Test on iOS devices
- [ ] Test on Android devices
- [ ] Test on web (if applicable)
- [ ] Verify dark mode on all screens

---

## TROUBLESHOOTING

### Colors Not Applying

**Problem**: New theme colors not showing.

**Solution**:
```dart
// Verify import
import 'theme/app_theme_v2_material3.dart';

// Verify usage in main.dart
theme: AppThemeV2.darkTheme,

// Hard refresh (clear cache)
flutter clean
flutter pub get
flutter run
```

### Text Styling Issues

**Problem**: Text not using correct font/size.

**Solution**:
```dart
// Always use theme text styles
Text(
  'Title',
  style: Theme.of(context).textTheme.titleLarge,
)

// NOT:
Text(
  'Title',
  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
)
```

### Button Padding Inconsistent

**Problem**: Button heights vary across screens.

**Solution**:
```dart
// The theme sets minimumSize to 48dp
// Don't override with custom padding
ElevatedButton(
  onPressed: () {},
  child: const Text('Button'),
  // Don't add padding here - theme handles it
)
```

---

## NEXT STEPS AFTER IMPLEMENTATION

1. **Performance Optimization** (Week 11)
   - Profile app performance
   - Optimize large list views (marketplace, feed)
   - Implement lazy loading where needed

2. **Analytics Integration**
   - Track screen views
   - Track button clicks
   - Track form submissions

3. **User Testing**
   - Conduct usability testing
   - Gather feedback on new design
   - Iterate based on user feedback

4. **Release Preparation**
   - Update app store screenshots
   - Write release notes
   - Plan staged rollout

---

## RESOURCES

- [Material Design 3 Documentation](https://m3.material.io/)
- [Flutter Material Design 3 Guide](https://flutter.dev/docs/release/breaking-changes/material-3-migration)
- [Google Fonts Documentation](https://pub.dev/packages/google_fonts)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)

---

**Questions?** Refer to `DESIGN_SYSTEM_SPECIFICATION.md` or `PETSPHERE_UI_UX_REDESIGN_AUDIT.md` for detailed design context.
