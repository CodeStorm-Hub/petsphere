---
description: "Performance optimization guidance for Flutter UI/state code (rebuilds, lists, images, async work)."
applyTo: "lib/**/*.dart"
---

# Performance Optimization — Flutter

Use these rules when changing UI, controllers, and repositories in `lib/**`.

## Common causes of jank (and what to do)

### Avoid heavy work in `build()`

- Treat `build()` as pure and fast.
- Move parsing, sorting, filtering, and network calls out of `build()`.
- In Riverpod Notifiers, **don’t mutate state in `build()`**; defer initial async work (see `.github/copilot-instructions.md`).

### Control rebuild scope

- Prefer small widgets.
- Use `const` constructors where possible.
- Use `Consumer`/`ConsumerWidget` (or `select`) to watch only what you need.

### Lists & pagination

- Prefer `ListView.builder` / `SliverList` over building large lists eagerly.
- Implement pagination/infinite scrolling for unbounded feeds.
- Avoid nested scrollables that force full layout passes.

### Images

- Use appropriately sized images (don’t decode 4K images into 100px thumbnails).
- Prefer cached/network image strategies (and placeholders) for smooth scrolling.

### Async + UI

- Avoid blocking the UI thread with synchronous loops.
- Use debouncing/throttling for search input and realtime updates.

## Quick verification checklist

- Scrolling a list stays smooth.
- No repeated network calls caused by rebuilds.
- No expensive transformations repeated per frame.

## Source

Inspired by the awesome-copilot instruction:
https://github.com/github/awesome-copilot/blob/main/instructions/performance-optimization.instructions.md
