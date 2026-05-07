# PetSphere Design Tokens Quick Reference
## Developer Cheat Sheet for Material Design 3

**Last Updated**: May 1, 2026  
**For Use With**: `lib/theme/app_theme_v2_material3.dart`

---

## COLOR SYSTEM

### Primary Brand Colors

| Usage | Token | Color | Hex |
|-------|-------|-------|-----|
| Primary buttons, links, highlights | `theme.colorScheme.primary` | 🟧 Warm Amber | `#D4845A` |
| Text on primary bg | `theme.colorScheme.onPrimary` | ⚪ White | `#FFFFFF` |
| Secondary buttons, subtle bg | `theme.colorScheme.primaryContainer` | 🟨 Light Amber | `#FFDCC4` |
| Text on primary container | `theme.colorScheme.onPrimaryContainer` | 🟫 Dark Brown | `#3E2817` |

### Secondary Accent Colors

| Usage | Token | Color | Hex |
|-------|-------|-------|-----|
| Secondary CTA, accents, status | `theme.colorScheme.secondary` | 🟩 Sage Green | `#4A7C59` |
| Text on secondary bg | `theme.colorScheme.onSecondary` | ⚪ White | `#FFFFFF` |
| Subtle secondary bg | `theme.colorScheme.secondaryContainer` | 🟦 Light Sage | `#C8EFD5` |
| Text on secondary container | `theme.colorScheme.onSecondaryContainer` | ⬛ Dark Green | `#0A2818` |

### Tertiary (Achievements/Badges)

| Usage | Token | Color | Hex |
|-------|-------|-------|-----|
| Achievements, badges, accents | `theme.colorScheme.tertiary` | 🟪 Warm Mauve | `#8B5A7D` |
| Text on tertiary bg | `theme.colorScheme.onTertiary` | ⚪ White | `#FFFFFF` |
| Tertiary bg | `theme.colorScheme.tertiaryContainer` | 🟦 Light Mauve | `#E8D7E8` |
| Text on tertiary container | `theme.colorScheme.onTertiaryContainer` | 🟪 Dark Purple | `#32223C` |

### Neutral Backgrounds

| Usage | Token | Color | Hex |
|-------|-------|-------|-----|
| App background | `theme.colorScheme.background` | ⬛ Near Black | `#0F0E0C` |
| Primary text on bg | `theme.colorScheme.onBackground` | 🟦 Off White | `#F2EDE4` |
| Card/surface bg | `theme.colorScheme.surface` | ⬛ Dark Charcoal | `#1A1814` |
| Text on surface | `theme.colorScheme.onSurface` | 🟦 Off White | `#F2EDE4` |
| Dimmed surface | `theme.colorScheme.surfaceDim` | ⬛ Deep Charcoal | `#0F0E0C` |
| Bright surface | `theme.colorScheme.surfaceBright` | 🟫 Light Charcoal | `#2B2620` |

### Borders & Dividers

| Usage | Token | Color | Hex |
|-------|-------|-------|-----|
| Primary border/divider | `theme.colorScheme.outline` | 🟫 Warm Gray | `#6B645B` |
| Secondary border | `theme.colorScheme.outlineVariant` | 🟫 Lighter Gray | `#8B8377` |
| Modal/overlay scrim | `theme.colorScheme.scrim` | ⬛ Black | `#000000` |

### Error & Status Colors

| Usage | Token | Color | Hex |
|-------|-------|-------|-----|
| Error states, destructive | `theme.colorScheme.error` | 🔴 Alert Red | `#B3261E` |
| Text on error | `theme.colorScheme.onError` | ⚪ White | `#FFFFFF` |
| Error bg | `theme.colorScheme.errorContainer` | 🟥 Light Red | `#F9DEDC` |
| Text on error bg | `theme.colorScheme.onErrorContainer` | 🔴 Dark Red | `#410E0B` |
| Success | `AppThemeV2.successColor` | 🟢 Green | `#2E7D32` |
| Warning | `AppThemeV2.warningColor` | 🟠 Orange | `#F57C00` |
| Info | `AppThemeV2.infoColor` | 🔵 Blue | `#1976D2` |

---

## TYPOGRAPHY SYSTEM

### Display Styles (Playfair Display)

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| `displayLarge` | 57sp | 700 | Hero titles, splash screens |
| `displayMedium` | 45sp | 700 | Large headlines |
| `displaySmall` | 36sp | 700 | Medium headlines |

**Code**:
```dart
Text('Hero Title', style: Theme.of(context).textTheme.displayLarge)
```

### Headline Styles (Playfair Display)

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| `headlineLarge` | 32sp | 700 | Section titles |
| `headlineMedium` | 28sp | 700 | Card titles |
| `headlineSmall` | 24sp | 700 | Dialog titles |

**Code**:
```dart
Text('Section Title', style: Theme.of(context).textTheme.headlineMedium)
```

### Title Styles (DM Sans Bold)

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| `titleLarge` | 22sp | 700 | Screen titles, AppBar |
| `titleMedium` | 16sp | 700 | Card section titles |
| `titleSmall` | 14sp | 700 | List item titles |

**Code**:
```dart
Text('Title', style: Theme.of(context).textTheme.titleLarge)
```

### Body Styles (DM Sans Regular)

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| `bodyLarge` | 16sp | 400 | Primary paragraph text |
| `bodyMedium` | 14sp | 400 | Standard body text |
| `bodySmall` | 12sp | 400 | Helper text, captions |

**Code**:
```dart
Text('Body content', style: Theme.of(context).textTheme.bodyMedium)
```

### Label Styles (DM Sans Medium)

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| `labelLarge` | 14sp | 500 | Button labels, chips |
| `labelMedium` | 12sp | 500 | Secondary labels |
| `labelSmall` | 11sp | 500 | Tags, badges |

**Code**:
```dart
Text('Label', style: Theme.of(context).textTheme.labelLarge)
```

---

## SPACING SYSTEM
### 8px Base Unit

| Token | Value | Usage |
|-------|-------|-------|
| `spacingXs` | 4px | Half spacing, small gaps |
| `spacingSm` | 8px | Basic spacing, padding |
| `spacingMd` | 16px | Standard padding/margin |
| `spacingLg` | 24px | Large gaps, section spacing |
| `spacingXl` | 32px | Extra large spacing |
| `spacingXxl` | 48px | Maximum spacing |

**Code**:
```dart
Padding(
  padding: const EdgeInsets.all(16),  // spacingMd
  child: ...
)

Padding(
  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),  // lg, md
  child: ...
)

SizedBox(height: 8)  // spacingSm
```

---

## CORNER RADIUS SYSTEM

| Token | Value | Usage |
|-------|-------|-------|
| `radiusSm` | 4px | Subtle rounding |
| `radiusMd` | 8px | Standard buttons, small cards |
| `radiusLg` | 12px | Input fields, chips |
| `radiusXl` | 16px | Cards, dialogs |
| `radiusXxl` | 20px | Cards, large components |
| `radiusRound` | 999px | Fully rounded, pills, FAB |

**Code**:
```dart
BorderRadius.circular(8)   // radiusMd
BorderRadius.circular(12)  // radiusLg
BorderRadius.circular(16)  // radiusXl

RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
```

---

## ELEVATION SYSTEM

| Token | Value | Usage |
|-------|-------|-------|
| `elevationNone` | 0 | Flat surfaces, backgrounds |
| `elevationSm` | 1 | Subtle lift (cards, inputs) |
| `elevationMd` | 3 | Moderate lift (menus, overlays) |
| `elevationLg` | 6 | Dialog, bottom sheet |
| `elevationXl` | 8 | Maximum elevation (FAB) |

**Code**:
```dart
Card(
  elevation: 1,  // elevationSm
  child: ...
)
```

---

## TOUCH TARGET SIZES

| Size | Value | Usage |
|------|-------|-------|
| Minimum | 48dp | Material spec minimum |
| Preferred | 56dp | Recommended for mobile |

**Code**:
```dart
ElevatedButton(
  // Theme automatically sets height to 48dp
  onPressed: () {},
  child: const Text('Touch Me'),
)

// For custom components:
Material(
  child: InkWell(
    onTap: () {},
    child: Container(
      height: 48,  // minimumTouchTarget
      width: 48,
      child: ...
    ),
  ),
)
```

---

## COMMON PATTERNS

### Buttons

```dart
// Primary (Elevated)
ElevatedButton(onPressed: () {}, child: const Text('Save'))

// Secondary (Filled)
FilledButton(onPressed: () {}, child: const Text('Continue'))

// Tertiary (Outlined)
OutlinedButton(onPressed: () {}, child: const Text('Cancel'))

// Text-only
TextButton(onPressed: () {}, child: const Text('Learn More'))

// Icon button
IconButton(
  icon: const Icon(Icons.add),
  onPressed: () {},
  iconSize: 24,
)

// FAB (Floating Action Button)
FloatingActionButton(
  onPressed: () {},
  child: const Icon(Icons.add),
)
```

### Cards & Containers

```dart
// Standard card
Card(
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Text('Content'),
  ),
)

// Card with title and actions
Card(
  child: Column(
    children: [
      ListTile(
        title: const Text('Card Title'),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {},
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Content'),
      ),
    ],
  ),
)

// Container with surface color
Container(
  color: Theme.of(context).colorScheme.surface,
  padding: const EdgeInsets.all(16),
  child: Text('Surface background'),
)
```

### Forms & Inputs

```dart
// Text field
TextField(
  decoration: InputDecoration(
    labelText: 'Email',
    hintText: 'you@example.com',
    prefixIcon: const Icon(Icons.email),
  ),
)

// Form with validation
TextFormField(
  decoration: InputDecoration(
    labelText: 'Password',
    errorText: null,  // null when valid
  ),
  validator: (value) {
    if (value?.isEmpty ?? true) return 'Required';
    return null;
  },
)

// Checkbox
Checkbox(
  value: isChecked,
  onChanged: (value) {},
)

// Radio button
Radio<String>(
  value: 'option1',
  groupValue: selectedOption,
  onChanged: (value) {},
)

// Switch
Switch(
  value: isEnabled,
  onChanged: (value) {},
)
```

### Dialogs

```dart
// Confirmation dialog
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

// Input dialog
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('Edit Name'),
    content: TextField(
      decoration: InputDecoration(labelText: 'Name'),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      ElevatedButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Save'),
      ),
    ],
  ),
)
```

### Bottom Sheets

```dart
// Simple bottom sheet
showModalBottomSheet(
  context: context,
  builder: (context) => Container(
    padding: const EdgeInsets.all(16),
    child: const Text('Bottom sheet content'),
  ),
)

// Draggable bottom sheet
showModalBottomSheet(
  context: context,
  builder: (context) => DraggableScrollableSheet(
    expand: false,
    builder: (context, scrollController) => ListView(
      controller: scrollController,
      children: [
        Container(height: 50, color: Colors.grey),
        // Draggable content
      ],
    ),
  ),
)
```

### Chips

```dart
// Filter chip
FilterChip(
  label: const Text('Option'),
  selected: isSelected,
  onSelected: (selected) {},
)

// Choice chip (radio-style)
ChoiceChip(
  label: const Text('Choice 1'),
  selected: selectedChoice == 'choice1',
  onSelected: (selected) {},
)

// Action chip
ActionChip(
  label: const Text('Action'),
  onPressed: () {},
  avatar: Icon(Icons.check),
)
```

### Lists & Tiles

```dart
// List tile (standard)
ListTile(
  leading: Icon(Icons.person),
  title: const Text('Title'),
  subtitle: const Text('Subtitle'),
  trailing: Icon(Icons.arrow_right),
  onTap: () {},
)

// Custom list item
Container(
  padding: const EdgeInsets.all(16),
  child: Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title', style: Theme.of(context).textTheme.titleMedium),
            Text('Subtitle', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
      Icon(Icons.arrow_right),
    ],
  ),
)
```

### Loading States

```dart
// Circular progress
CircularProgressIndicator()

// Linear progress
LinearProgressIndicator()

// Skeleton loader (shimmer)
Shimmer.fromColors(
  baseColor: Theme.of(context).colorScheme.surfaceDim,
  highlightColor: Theme.of(context).colorScheme.surfaceBright,
  child: Container(
    height: 100,
    color: Colors.white,
  ),
)
```

### Error & Empty States

```dart
// Error message
Padding(
  padding: const EdgeInsets.all(16),
  child: Column(
    children: [
      Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
      const SizedBox(height: 8),
      Text(
        'Something went wrong',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.error,
        ),
      ),
      const SizedBox(height: 8),
      ElevatedButton(
        onPressed: () => onRetry(),
        child: const Text('Try Again'),
      ),
    ],
  ),
)

// Empty state
Padding(
  padding: const EdgeInsets.all(16),
  child: Column(
    children: [
      Icon(
        Icons.inbox_outlined,
        size: 64,
        color: Theme.of(context).colorScheme.outline,
      ),
      const SizedBox(height: 16),
      Text(
        'No items yet',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 8),
      Text(
        'Check back later',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    ],
  ),
)
```

---

## COMMON MISTAKES TO AVOID

### ❌ DON'T: Hardcode Colors

```dart
// ❌ WRONG
Container(color: Color(0xFFD4845A))

// ✅ RIGHT
Container(color: Theme.of(context).colorScheme.primary)
```

### ❌ DON'T: Use Arbitrary Padding

```dart
// ❌ WRONG
Padding(padding: EdgeInsets.all(13))

// ✅ RIGHT
Padding(padding: const EdgeInsets.all(16))  // spacingMd
```

### ❌ DON'T: Ignore Touch Targets

```dart
// ❌ WRONG
GestureDetector(
  onTap: () {},
  child: Container(height: 20, width: 20, child: Icon(Icons.check)),
)

// ✅ RIGHT
GestureDetector(
  onTap: () {},
  child: Container(
    height: 48,  // minimumTouchTarget
    width: 48,
    child: Icon(Icons.check),
  ),
)
```

### ❌ DON'T: Use Custom Text Styles

```dart
// ❌ WRONG
Text('Title', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))

// ✅ RIGHT
Text('Title', style: Theme.of(context).textTheme.titleLarge)
```

### ❌ DON'T: Add Unnecessary Padding to Buttons

```dart
// ❌ WRONG
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(padding: EdgeInsets.all(24)),
  child: Text('Button'),
)

// ✅ RIGHT (theme handles padding)
ElevatedButton(
  onPressed: () {},
  child: const Text('Button'),
)
```

---

## UTILITIES & HELPERS

### Get Color with Opacity

```dart
// Primary color at 50% opacity
Color primaryFaded = AppThemeV2.getPrimaryColor(opacity: 0.5);

// Or using theme directly
color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
```

### Get Semantic Colors

```dart
Color success = AppThemeV2.successColor;
Color warning = AppThemeV2.warningColor;
Color info = AppThemeV2.infoColor;
```

### Build Themed Container

```dart
Container(
  color: Theme.of(context).colorScheme.surface,
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: Theme.of(context).colorScheme.outline,
    ),
  ),
)
```

---

## RESOURCES

- **Full Theme File**: `lib/theme/app_theme_v2_material3.dart`
- **Implementation Guide**: `MATERIAL_DESIGN_3_IMPLEMENTATION_GUIDE.md`
- **Design System Spec**: `DESIGN_SYSTEM_SPECIFICATION.md`
- **Material Design 3 Docs**: https://m3.material.io/

---

**Questions?** Refer to the full design system documentation or contact the design team.
