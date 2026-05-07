---
name: riverpod-inspector
description: Debug and visualize Riverpod state management and provider dependencies
disable-model-invocation: false
user-invocable: true
---

# Riverpod Inspector

Analyze Riverpod providers, trace state mutations, and visualize dependency graphs for PetSphere controllers.

## Quick Usage

```bash
/riverpod-inspector --action trace --provider petProvider
/riverpod-inspector --action deps --controller PetNotifier
/riverpod-inspector --action profile --threshold 50ms
```

## What This Does

- **Trace**: Follow state changes in a provider from action to UI update
- **Deps**: Map dependencies between providers (what watches what)
- **Profile**: Identify slow state computations and unnecessary rebuilds
- **Graph**: Generate ASCII dependency diagram
- **Search**: Find all providers matching a pattern

## Common Workflows

### Debug Why a Widget Isn't Rebuilding

```bash
/riverpod-inspector --action trace --provider petProvider --watch myPetsSelector
```

Output:
```
petProvider
  └─ build() initializes state
  └─ loadPets() updates state.myPets
  └─ Watched by: PetListScreen, PetCardComponent
```

### Find Unused Providers

```bash
/riverpod-inspector --action deps --all --unused
```

Lists providers with no watchers (candidates for removal).

### Visualize Controller Dependencies

```bash
/riverpod-inspector --action graph --controller AuthNotifier
```

Shows what providers `AuthNotifier` depends on and what depends on it:

```
  healthProvider ──┐
                  └─> petProvider ──┐
  feedProvider ────┘                 └─> AuthNotifier
                                        └─> uiStateProvider
```

### Profile Controller Performance

```bash
/riverpod-inspector --action profile --threshold 50ms
```

Lists all state mutations taking >50ms:
```
petProvider.loadPets()      → 245ms (DB query + image processing)
healthProvider.updateVitals → 87ms  (Supabase update)
feedProvider.createPost()   → 1200ms ⚠️ (SLOW: consider memoization)
```

## Key Patterns to Look For

### ✅ Good Patterns

- Providers with `.select()` to watch only needed fields
- `.autoDispose` on temporary providers
- Notifier methods that batch state updates
- Comments explaining why dependency exists

### ❌ Anti-Patterns to Fix

- Watching entire state when only one field is needed
- Circular dependencies (A watches B watches A)
- State mutations in `build()` (should be in methods)
- Providers that listen to everything

## Integration with DevTools

For visual debugging, also use Flutter DevTools:

```bash
flutter run
# In another terminal
flutter devtools
```

Then navigate to Riverpod DevTools tab to inspect state in real-time.

## Reference

- [Riverpod Docs](https://riverpod.dev/)
- [Provider Families & Selectors](https://riverpod.dev/docs/concepts/modifiers/family)
- [Auto-Dispose Pattern](https://riverpod.dev/docs/concepts/modifiers/auto_dispose)
