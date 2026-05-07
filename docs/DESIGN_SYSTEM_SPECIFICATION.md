# PetSphere Design System Specification

**Version**: 1.0  
**Status**: Implementation Ready  
**Last Updated**: May 1, 2026

---

## TABLE OF CONTENTS

1. [Design Principles](#design-principles)
2. [Color System](#color-system)
3. [Typography System](#typography-system)
4. [Spacing & Sizing System](#spacing--sizing-system)
5. [Component Specifications](#component-specifications)
6. [Patterns & Layouts](#patterns--layouts)
7. [Accessibility Guidelines](#accessibility-guidelines)
8. [Implementation Code Examples](#implementation-code-examples)

---

## DESIGN PRINCIPLES

### 1. **Pet-Centric**
Every feature, interaction, and visual element centers on celebrating pets and the relationships between pets and their owners.

### 2. **Warm & Approachable**
Use the warm color palette (amber, sage) to create a friendly, inviting experience that feels like a community for pet lovers.

### 3. **Clear & Intuitive**
Information should be organized hierarchically; users should understand functionality without explanation.

### 4. **Joyful & Playful**
Micro-interactions, illustrations, and spacing create moments of delight without distracting from core tasks.

### 5. **Trustworthy**
Clean typography, consistent patterns, and transparent information build confidence in the platform.

### 6. **Accessible to All**
Design with inclusivity in mind: proper contrast, keyboard navigation, screen reader support, and readable typography.

---

## COLOR SYSTEM

### Material Design 3 Color Palette

All colors derived from seed color `#D4845A` (Warm Amber) via `ColorScheme.fromSeed()`.

#### Primary Colors

| Token | Color | Hex | Usage |
|-------|-------|-----|-------|
| `colorScheme.primary` | Warm Amber | `#D4845A` | Primary buttons, links, highlights, icons |
| `colorScheme.onPrimary` | White | `#FFFFFF` | Text/icons on primary background |
| `colorScheme.primaryContainer` | Light Amber | `#FFDCC4` | Secondary buttons, subtle backgrounds |
| `colorScheme.onPrimaryContainer` | Dark Brown | `#3E2817` | Text on primary container |

#### Secondary Colors

| Token | Color | Hex | Usage |
|-------|-------|-----|-------|
| `colorScheme.secondary` | Sage Green | `#4A7C59` | Secondary CTAs, accents, status |
| `colorScheme.onSecondary` | White | `#FFFFFF` | Text/icons on secondary |
| `colorScheme.secondaryContainer` | Light Sage | `#C8EFD5` | Subtle secondary backgrounds |
| `colorScheme.onSecondaryContainer` | Dark Green | `#0A2818` | Text on secondary container |

#### Tertiary Colors

| Token | Color | Hex | Usage |
|-------|-------|-----|-------|
| `colorScheme.tertiary` | Warm Mauve | `#8B5A7D` | Achievements, badges, tertiary accents |
| `colorScheme.onTertiary` | White | `#FFFFFF` | Text on tertiary |
| `colorScheme.tertiaryContainer` | Light Mauve | `#E8D7E8` | Tertiary backgrounds |
| `colorScheme.onTertiaryContainer` | Dark Purple | `#32223C` | Text on tertiary container |

#### Neutral Colors

| Token | Color | Hex | Usage |
|-------|-------|-----|-------|
| `colorScheme.background` | Near Black | `#0F0E0C` | App background |
| `colorScheme.onBackground` | Off White | `#F2EDE4` | Primary text |
| `colorScheme.surface` | Dark Charcoal | `#1A1814` | Cards, sheets, elevated surfaces |
| `colorScheme.onSurface` | Off White | `#F2EDE4` | Text on surfaces |
| `colorScheme.surfaceDim` | Deep Charcoal | `#0F0E0C` | Dimmed surface (lower elevation) |
| `colorScheme.surfaceBright` | Light Charcoal | `#2B2620` | Bright surface (higher elevation) |
| `colorScheme.outline` | Warm Gray | `#6B645B` | Borders, dividers, subtle separators |
| `colorScheme.outlineVariant` | Lighter Gray | `#8B8377` | Secondary borders |
| `colorScheme.scrim` | Black with transparency | `#000000` | Overlay/modal backgrounds |

#### Error Colors

| Token | Color | Hex | Usage |
|-------|-------|-----|-------|
| `colorScheme.error` | Alert Red | `#B3261E` | Error states, destructive actions |
| `colorScheme.onError` | White | `#FFFFFF` | Text on error |
| `colorScheme.errorContainer` | Light Red | `#F9DEDC` | Error backgrounds |
| `colorScheme.onErrorContainer` | Dark Red | `#410E0B` | Text on error container |

### Semantic Colors

For specific use cases, extend `ThemeExtension`:

```dart
class AppColors extends ThemeExtension<AppColors> {
  final Color success = Color(0xFF2E7D32);     // Green for success
  final Color warning = Color(0xFFF57C00);    // Orange for warnings
  final Color info = Color(0xFF1976D2);       // Blue for info
  final Color disabled = Color(0xFF616161);   // Gray for disabled
  
  // Transparency variants
  final Color surfaceOverlay = Color(0x1A1814).withOpacity(0.8);
  
  @override
  AppColors copyWith({
    Color? success,
    Color? warning,
    // ...
  }) => AppColors();
  
  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors();
  }
}
```

### Color Usage Guidelines

- **Backgrounds**: Use `colorScheme.background` and `colorScheme.surface`
- **Interactive**: Use `colorScheme.primary` for primary actions, `colorScheme.secondary` for alternatives
- **Text**: Use `colorScheme.onBackground` or `colorScheme.onSurface` depending on background
- **Borders/Dividers**: Use `colorScheme.outline` or `colorScheme.outlineVariant`
- **Feedback**: Use semantic colors (success, warning, error)
- **Accessibility**: Maintain minimum 4.5:1 contrast for text, 3:1 for graphics

---

## TYPOGRAPHY SYSTEM

### Font Families

- **Display & Headlines**: Playfair Display (serif, premium, attention-grabbing)
- **Body & UI**: DM Sans (sans-serif, clean, readable)

### Type Scale (Based on Material Design 3)

#### Display (Headlines, Hero Text)

| Level | Font | Size | Weight | Line Height | Letter Spacing | Usage |
|-------|------|------|--------|-------------|-----------------|-------|
| Display Large | Playfair Display | 57sp | W700 | 64sp | -0.25sp | Page heroes, section titles |
| Display Medium | Playfair Display | 45sp | W700 | 52sp | 0sp | Large section headers |
| Display Small | Playfair Display | 36sp | W700 | 44sp | 0sp | Smaller section headers |

#### Headline (Sub-Headlines)

| Level | Font | Size | Weight | Line Height | Letter Spacing | Usage |
|-------|------|------|--------|-------------|-----------------|-------|
| Headline Large | Playfair Display | 32sp | W700 | 40sp | 0sp | Card titles, dialog headers |
| Headline Medium | Playfair Display | 28sp | W700 | 36sp | 0sp | Section subheadings |
| Headline Small | Playfair Display | 24sp | W700 | 32sp | 0sp | Subsection titles |

#### Title (Card/Component Titles)

| Level | Font | Size | Weight | Line Height | Letter Spacing | Usage |
|-------|------|------|--------|-------------|-----------------|-------|
| Title Large | DM Sans | 22sp | W700 | 28sp | 0sp | List item titles, card titles |
| Title Medium | DM Sans | 16sp | W700 | 24sp | 0.15sp | Smaller card titles |
| Title Small | DM Sans | 14sp | W700 | 20sp | 0.1sp | Tab labels, chip text |

#### Body (Main Content)

| Level | Font | Size | Weight | Line Height | Letter Spacing | Usage |
|-------|------|------|--------|-------------|-----------------|-------|
| Body Large | DM Sans | 16sp | W400 | 24sp | 0.5sp | Main paragraph text |
| Body Medium | DM Sans | 14sp | W400 | 20sp | 0.25sp | Secondary text, descriptions |
| Body Small | DM Sans | 12sp | W400 | 16sp | 0.4sp | Captions, helper text |

#### Label (UI Labels, Buttons)

| Level | Font | Size | Weight | Line Height | Letter Spacing | Usage |
|-------|------|------|--------|-------------|-----------------|-------|
| Label Large | DM Sans | 14sp | W700 | 20sp | 0.1sp | Button text, labels |
| Label Medium | DM Sans | 12sp | W700 | 16sp | 0.5sp | Small labels, badges |
| Label Small | DM Sans | 11sp | W700 | 16sp | 0.5sp | Tiny labels, tags |

### Dart Implementation

```dart
// lib/theme/app_typography.dart
extension AppTypography on TextTheme {
  // Custom headline styles
  TextStyle get petCardTitle => displaySmall?.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  ) ?? const TextStyle();
  
  TextStyle get engagementMetric => labelLarge?.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Colors.grey[400],
  ) ?? const TextStyle();
}

// Usage in widgets
Text(
  'Max',
  style: Theme.of(context).textTheme.petCardTitle,
)
```

---

## SPACING & SIZING SYSTEM

### Spacing Scale (8px Base Unit)

```
xs  = 4px   (half-unit, tight spacing)
sm  = 8px   (1 unit, standard spacing)
md  = 16px  (2 units, comfortable spacing)
lg  = 24px  (3 units, spacious)
xl  = 32px  (4 units, very spacious)
xxl = 48px  (6 units, extra spacious)
```

### Padding & Margin Usage

| Component | Top | Right | Bottom | Left |
|-----------|-----|-------|--------|------|
| Screen/Page | md (16) | md (16) | md (16) | md (16) |
| Card | lg (24) | lg (24) | lg (24) | lg (24) |
| List Item | md (16) | md (16) | md (16) | md (16) |
| Button | md (16) | lg (24) | md (16) | lg (24) |
| Section | 0 | 0 | lg (24) | 0 |
| Form Group | 0 | 0 | md (16) | 0 |

### Sizing Tokens

| Purpose | Value | Usage |
|---------|-------|-------|
| **Touch Target Min** | 48dp | All interactive elements (buttons, icons, etc.) |
| **Touch Target Preferred** | 56dp | Buttons, FABs |
| **Icon Size - Small** | 16px | Inline icons, badges |
| **Icon Size - Medium** | 24px | Navigation, standard icons |
| **Icon Size - Large** | 32px | Hero icons, featured |
| **Avatar - Extra Small** | 32dp | Comment avatars, inline |
| **Avatar - Small** | 40dp | List items, small stories |
| **Avatar - Medium** | 56dp | Pet card profiles |
| **Avatar - Large** | 80dp | Pet profile header |
| **Pet Card Height** | 280dp | Mobile pet cards (flexible) |
| **Product Card Height** | 220dp | Marketplace product cards |
| **Image Aspect Ratio** | 1:1 | Pet photos, products |
| **Story Ring Size** | 64dp | Story avatars |

---

## COMPONENT SPECIFICATIONS

### 1. Button Component

#### Button Types

**Primary Button (Filled)**
- Background: `colorScheme.primary` (`#D4845A`)
- Text: `colorScheme.onPrimary` (white)
- Height: 48dp (minimum)
- Padding: 16px horizontal, 12px vertical
- Border Radius: 8dp
- Elevation: 0
- States:
  - Default: Base state
  - Hovered: Overlay +8% white
  - Pressed: Overlay +12% white
  - Disabled: `colorScheme.onSurface` @ 12% opacity, gray text

```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Theme.of(context).colorScheme.primary,
    foregroundColor: Theme.of(context).colorScheme.onPrimary,
    minimumSize: const Size.fromHeight(48),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  onPressed: () {},
  child: const Text('Primary Action'),
)
```

**Secondary Button (Outlined)**
- Border: 1.5dp, `colorScheme.primary`
- Text: `colorScheme.primary`
- Background: Transparent
- Height: 48dp
- Padding: 16px horizontal, 12px vertical
- States: Similar to primary with outline variants

```dart
OutlinedButton(
  style: OutlinedButton.styleFrom(
    side: BorderSide(
      color: Theme.of(context).colorScheme.primary,
      width: 1.5,
    ),
    minimumSize: const Size.fromHeight(48),
  ),
  onPressed: () {},
  child: const Text('Secondary Action'),
)
```

**Tertiary Button (Text)**
- Background: Transparent
- Text: `colorScheme.primary`
- No border
- Minimal padding
- States: Text color change on interaction

```dart
TextButton(
  onPressed: () {},
  child: const Text('Tertiary Action'),
)
```

**Icon Button**
- Size: 48dp (touch target)
- Icon size: 24px
- Padding: 12dp
- Border radius: 8dp

```dart
IconButton(
  icon: const Icon(Icons.favorite),
  iconSize: 24,
  onPressed: () {},
)
```

#### Button Specifications Table

| Property | Value |
|----------|-------|
| Height | 48dp |
| Horizontal Padding | 24dp |
| Vertical Padding | 12dp |
| Border Radius | 8dp |
| Min Touch Target | 48dp × 48dp |
| Font Size | 14sp (Label Large) |
| Font Weight | W700 |

### 2. Card Component

#### Standard Card
- Background: `colorScheme.surface` (`#1A1814`)
- Border Radius: 12dp
- Elevation: 1 (Material 3)
- Padding: 16dp (inside content)
- Border: 1px `colorScheme.outline` (optional, subtle)

```dart
Card(
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  elevation: 1,
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        // Card content
      ],
    ),
  ),
)
```

#### Pet Card (Variant)
- Image: Aspect ratio 1:1, 200dp width (mobile)
- Border Radius: 12dp (top), 8dp (bottom)
- Content Padding: 12dp
- Shadow: Material 3 elevation 2
- Name/Breed: Title Medium
- Quick Info: Body Small

```dart
class PetCard extends StatelessWidget {
  final PetModel pet;
  final VoidCallback onTap;

  const PetCard({required this.pet, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            CachedNetworkImage(
              imageUrl: pet.photoUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pet.name, style: Theme.of(context).textTheme.titleMedium),
                  Text('${pet.breed}, ${pet.age}',
                    style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 3. Input Field Component

#### Text Input
- Height: 56dp (touch-friendly)
- Border: 1px `colorScheme.outline`
- Border Radius: 8dp
- Padding: 16dp horizontal, 12dp vertical
- Label: Title Small, floating
- Hint: Body Medium, `colorScheme.onSurfaceVariant` @ 50%
- States:
  - Enabled: Base border
  - Focused: Border `colorScheme.primary`, shadow
  - Error: Border `colorScheme.error`
  - Disabled: Border gray, text gray

```dart
TextFormField(
  decoration: InputDecoration(
    labelText: 'Pet Name',
    hintText: 'Enter your pet\'s name',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    floatingLabelBehavior: FloatingLabelBehavior.auto,
  ),
)
```

### 4. Navigation Components

#### Bottom Navigation Bar
- Height: 80dp (mobile)
- Background: `colorScheme.surface`
- Items: 5-6 max
- Icon size: 24px
- Label: Label Small
- Active color: `colorScheme.primary`
- Inactive color: `colorScheme.onSurfaceVariant` @ 50%

```dart
BottomNavigationBar(
  items: [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    // More items...
  ],
  currentIndex: _selectedIndex,
  onTap: (index) {},
  type: BottomNavigationBarType.fixed,
  backgroundColor: Theme.of(context).colorScheme.surface,
  selectedItemColor: Theme.of(context).colorScheme.primary,
  unselectedItemColor: Theme.of(context).colorScheme.onSurface,
)
```

#### Tab Navigation
- Height: 48dp
- Underline: 3dp, `colorScheme.primary`
- Label: Title Small
- Padding: 16dp horizontal

```dart
TabBar(
  labelColor: Theme.of(context).colorScheme.primary,
  unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
  indicatorSize: TabBarIndicatorSize.label,
  indicatorWeight: 3,
  tabs: [
    Tab(text: 'Overview'),
    Tab(text: 'Vitals'),
    // More tabs...
  ],
)
```

### 5. Dialog & Modal Components

#### Dialog
- Border Radius: 12dp
- Background: `colorScheme.surface`
- Padding: 24dp
- Max Width: 400dp (mobile), 600dp (tablet+)
- Scrim: Black @ 40% opacity

```dart
showDialog(
  context: context,
  builder: (context) => Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Dialog Title', style: Theme.of(context).textTheme.headlineSmall),
          SizedBox(height: 16),
          Text('Dialog content', style: Theme.of(context).textTheme.bodyMedium),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
              SizedBox(width: 8),
              ElevatedButton(onPressed: () {}, child: Text('Confirm')),
            ],
          ),
        ],
      ),
    ),
  ),
)
```

#### Bottom Sheet
- Border Radius: 16dp (top only)
- Background: `colorScheme.surface`
- Padding: 24dp
- Drag Handle: 4px × 40px, `colorScheme.outline`

```dart
showModalBottomSheet(
  context: context,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  ),
  builder: (context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Drag handle
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.outline,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(height: 16),
        // Content
      ],
    ),
  ),
)
```

### 6. Feedback & Loading Components

#### Snackbar
- Background: `colorScheme.inverseSurface`
- Text: `colorScheme.inverseOnSurface`
- Padding: 16dp
- Border Radius: 4dp
- Duration: 4 seconds (default)

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Action completed'),
    duration: Duration(seconds: 4),
    backgroundColor: Theme.of(context).colorScheme.inverseSurface,
  ),
)
```

#### Loading Indicator
- Size: 40dp (standard)
- Color: `colorScheme.primary`
- Animation: Smooth, indeterminate

```dart
const CircularProgressIndicator(
  strokeWidth: 3,
  valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
)
```

#### Skeleton Loader
- Color: `colorScheme.surface` with 0.5 opacity
- Animation: Shimmer left-to-right
- Duration: 1.5 seconds

```dart
class SkeletonLoader extends StatefulWidget {
  final double height;
  final double width;

  const SkeletonLoader({this.height = 16, this.width = double.infinity});

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(4),
      ),
      // Add shimmer animation
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

#### Empty State
- Illustration: 120×120dp
- Title: Display Small
- Description: Body Medium
- CTA Button: Primary

```dart
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyState({
    required this.icon,
    required this.title,
    required this.description,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 120, color: Theme.of(context).colorScheme.outline),
          SizedBox(height: 24),
          Text(title, style: Theme.of(context).textTheme.displaySmall),
          SizedBox(height: 8),
          Text(description, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
          if (onAction != null) ...[
            SizedBox(height: 24),
            ElevatedButton(onPressed: onAction, child: Text(actionLabel ?? 'Action')),
          ],
        ],
      ),
    );
  }
}
```

---

## PATTERNS & LAYOUTS

### Pattern 1: Feed Card (Posts, Stories, Pets)

```
┌──────────────────────┐
│ Avatar | Name | ... │  (16 vertical padding)
├──────────────────────┤
│                      │
│   Content/Image      │  (Flexible, max 400dp height)
│                      │
├──────────────────────┤
│ ❤️ 234 💬 45 ↗️ 12  │  (Engagement metrics)
└──────────────────────┘
```

### Pattern 2: Product Card (Marketplace)

```
┌──────────────────┐
│   Product Image  │  (1:1 ratio, 200dp)
├──────────────────┤
│  Product Name    │  (Title Medium)
│ ⭐ 4.5 (120)      │
│  $29.99          │  (Title Large, Primary color)
│ [Add to Cart]    │  (Secondary Button)
└──────────────────┘
```

### Pattern 3: List Item (with Actions)

```
┌─ Avatar ─ Title ───────┐
│          Description   │
└─────────────────────────┘
```

### Pattern 4: Multi-Step Form (Stepper)

```
Step 1 ← Step 2 ← Step 3
(Completed) (Current) (Upcoming)

┌─────────────────────┐
│   Step Title        │
├─────────────────────┤
│  Form Fields        │
│  ├─ Input 1         │
│  ├─ Input 2         │
│  └─ Input 3         │
├─────────────────────┤
│  [Back] ... [Next]  │  (Right-aligned buttons)
└─────────────────────┘
```

### Pattern 5: Filter Panel

```
Collapsible/Modal:

◆ Category          (Expandable section)
  ☐ Dogs
  ☐ Cats
  ☐ Birds

◆ Price Range       (Slider)
  $0 ———————●——— $100

◆ Rating            (Star chips)
  ⭐ ⭐⭐⭐⭐ ⭐⭐⭐⭐ ⭐⭐⭐ etc.

────────────────────
[Reset] ... [Apply]  (Right-aligned buttons)
```

---

## ACCESSIBILITY GUIDELINES

### Color Contrast Minimum

- **Normal text** (≤18sp): 4.5:1
- **Large text** (>18sp): 3:1
- **Graphics**: 3:1
- **UI Components**: 3:1

**Verification**: Use WebAIM Contrast Checker

### Touch Targets

- **Minimum**: 44dp × 44dp (iOS standard)
- **Recommended**: 48dp × 48dp
- **Spacing**: 8dp minimum between targets

### Focus Indicators

- **Visible**: High contrast, not relying on color alone
- **Non-intrusive**: Subtle but clear
- **Keyboard accessible**: Tab to all interactive elements

```dart
// Custom focus indicator
Material(
  child: Focus(
    onKey: (node, event) {
      // Handle focus
      return KeyEventResult.handled;
    },
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
      child: const Text('Focusable element'),
    ),
  ),
)
```

### Screen Reader Labels

```dart
Semantics(
  label: 'Like this post',
  button: true,
  enabled: true,
  onTap: () => like(),
  customSemanticsActions: {
    CustomSemanticsAction(label: 'Like'): () => like(),
  },
  child: IconButton(
    icon: Icon(liked ? Icons.favorite : Icons.favorite_border),
    onPressed: () => like(),
  ),
)
```

### Form Accessibility

```dart
TextFormField(
  decoration: InputDecoration(
    labelText: 'Email Address',  // Associated label
    errorText: _emailError,      // Clear error message
    helperText: 'We\'ll never share your email',  // Helper text
    hintText: 'example@domain.com',  // Hint, not label replacement
  ),
  validator: (value) {
    if (value?.isEmpty ?? true) return 'Email required';
    if (!value!.contains('@')) return 'Invalid email format';
    return null;
  },
)
```

---

## IMPLEMENTATION CODE EXAMPLES

### Theme Setup (lib/theme/app_theme.dart)

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color constants
  static const Color primaryAmbber = Color(0xFFD4845A);
  static const Color secondarySage = Color(0xFF4A7C59);
  static const Color tertiaryMauve = Color(0xFF8B5A7D);
  static const Color backgroundDark = Color(0xFF0F0E0C);
  static const Color surfaceDark = Color(0xFF1A1814);
  
  static ThemeData getLightTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryAmbber,
      brightness: Brightness.light,
      surface: surfaceDark,
      background: backgroundDark,
    );
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundDark,
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 57,
          fontWeight: FontWeight.w700,
          height: 1.12,
        ),
        headlineSmall: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        labelLarge: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          height: 1.43,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: false,
        outlineBorder: BorderSide(color: colorScheme.outline),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          minimumSize: const Size.fromHeight(48),
          textStyle: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
  
  static ThemeData getDarkTheme() {
    // Same as light for this design
    return getLightTheme();
  }
}
```

---

## DESIGN TOKENS REFERENCE

```dart
// Easy-to-use token constants
class AppTokens {
  // Spacing
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;
  static const double spacingXxl = 48;
  
  // Border Radius
  static const double radiusSmall = 4;
  static const double radiusMedium = 8;
  static const double radiusLarge = 12;
  static const double radiusXlarge = 16;
  static const double radiusCircle = 999;
  
  // Elevation
  static const double elevationNone = 0;
  static const double elevationLow = 1;
  static const double elevationMedium = 3;
  static const double elevationHigh = 8;
  
  // Size
  static const double touchTargetMin = 48;
  static const double iconSizeSmall = 16;
  static const double iconSizeMedium = 24;
  static const double iconSizeLarge = 32;
}

// Usage
Container(
  padding: EdgeInsets.all(AppTokens.spacingMd),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(AppTokens.radiusLarge),
  ),
)
```

---

**Next Steps**: 
1. Export this design system to Figma
2. Create component library based on specifications
3. Begin implementation with Material Design 3 integration
4. Test across responsive breakpoints

