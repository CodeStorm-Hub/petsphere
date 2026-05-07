# PetSphere Color Migration Progress

**Objective**: Systematically migrate all hardcoded color values throughout the PetSphere Flutter codebase to Material Design 3 semantic ColorScheme tokens.

**Status**: In Progress

---

## Completed Migrations

### Tier 1: Core Screens (Critical Path)
- ✅ **create_post_screen.dart** - All hardcoded colors replaced with colorScheme tokens (1350 lines)
- ✅ **create_story_screen.dart** - All hardcoded colors replaced with colorScheme tokens (601 lines)
- ✅ **health_tab.dart** - All hardcoded colors replaced with colorScheme tokens (2240 lines)
- ✅ **pet_profile_screen.dart** - All hardcoded colors replaced with colorScheme tokens
- ✅ **marketplace_screen.dart** - All hardcoded colors replaced (8 edits total)
  - Cart badge colors (Colors.red → colorScheme.error)
  - Promo banner gradient (hardcoded → colorScheme.primary/secondary)
  - Error state UI colors (Colors.grey variants → colorScheme.surfaceContainerHighest/onSurfaceVariant)
  - Empty state colors (Colors.grey variants → colorScheme tokens)
  - Snackbar icon colors (Colors.white → colorScheme.onPrimary)
  
- ✅ **chat_screen.dart** - All hardcoded colors replaced (5 major edits)
  - Scaffold/AppBar backgrounds (Color(0xFFFEF8F3) → colorScheme.surfaceContainerLowest)
  - Avatar and online indicator colors (Color(0xFFE5FDE6) → colorScheme.tertiaryContainer)
  - Title text colors (Color(0xFF35322D) → colorScheme.onSurface)
  - Empty state UI (circular icon bg, text)
  - Floating input pill colors, gradients, and text colors
  - Alpha value conversions applied correctly throughout

---

## In Progress

### Ready for Migration


---

## Pending Migrations

### Tier 2: Secondary Screens
- ⏳ **liked_pets_screen.dart** (Next target)
- ⏭️ messages_list_screen.dart
- ⏭️ notifications_screen.dart
- ⏭️ order_history_screen.dart
- ⏭️ pet_care_onboarding_screen.dart
- ⏭️ pet_care_screen.dart
- ⏭️ post_detail_screen.dart
- ⏭️ product_detail_screen.dart
- ⏭️ settings_screen.dart
- ⏭️ story_viewer_screen.dart

### Tier 3: Component Widgets
- ⏭️ components/cart_item_tile.dart
- ⏭️ components/chat_thread_tile.dart
- ⏭️ components/match_pet_card.dart
- ⏭️ components/message_bubble.dart
- ⏭️ components/pet_avatar.dart
- ⏭️ components/post_card.dart
- ⏭️ components/product_card.dart
- ⏭️ components/public_care_badges_row.dart

### Tier 4: Validation & Testing
- ⏭️ Device/emulator testing across all migrated screens
- ⏭️ Light/dark mode verification
- ⏭️ Accessibility verification (color contrast)
- ⏭️ Code review for consistency

---

## Migration Pattern Applied

All edits follow this consistent pattern:

```dart
// 1. Extract colorScheme at method entry
final colorScheme = Theme.of(context).colorScheme;

// 2. Replace hardcoded colors with semantic tokens
// Before: color: Colors.red
// After:  color: colorScheme.error

// 3. Handle alpha values using .withAlpha()
// Before: Color(0xFFD4845A).withOpacity(0.2)
// After:  colorScheme.primary.withAlpha(51)  // 0.2 * 255 ≈ 51

// 4. Remove const modifiers when colorScheme is used
// Before: const Icon(Icons.send)
// After:  Icon(Icons.send)  // no const due to dynamic color
```

---

## Key Semantic Color Mappings

| Hardcoded Color | Semantic Token | Usage |
|---|---|---|
| 0xFFD4845A, 0xFF99472C | colorScheme.primary | Primary brand, accents, active states |
| 0xFF4A7C59, 0xFFFFAD93 | colorScheme.secondary | Secondary actions, gradients |
| 0xFF0F0E0C, 0xFF1A1814 | colorScheme.surface/surfaceContainer | Backgrounds, containers |
| 0xFFF2EDE4 | colorScheme.onSurface | Primary text |
| 0xFFB8B0A4, 0xFF625E59 | colorScheme.onSurfaceVariant | Secondary text, disabled state |
| 0xFFE5FDE6 | colorScheme.tertiaryContainer | Light accent backgrounds |
| 0xFF506453, 0xFF99472C | colorScheme.onTertiary | Text on tertiary backgrounds |
| Colors.red | colorScheme.error | Errors, destructive actions |
| Colors.white | colorScheme.onPrimary | Text on primary backgrounds |
| 0xFF2E2B26 | colorScheme.outline | Dividers, borders |

---

## Progress Summary

**Completed**: 6 files
**In Progress**: 1 file  
**Pending**: 20 files

**Overall Progress**: ~23% (6 of 26 screens/components migrated)

**Next Immediate Task**: Complete liked_pets_screen.dart color migration

---

## Notes for Contributors

- All colors must use `Theme.of(context).colorScheme` at runtime
- Never hardcode colors directly in widgets; always extract colorScheme at method entry
- Alpha values must be converted to 0-255 range: `opacity * 255` → use `.withAlpha()`
- Remove `const` modifiers from widgets when they reference dynamic colorScheme values
- Maintain semantic consistency: warm tones (primary/secondary), neutral (surface), text (onSurface/onSurfaceVariant)
- Test on both light and dark modes after each migration

---

**Last Updated**: May 1, 2026
**Maintained by**: AI Assistant (Claude)
