---
trigger: always_on
---

Here are the **PetSphere Antigravity Rules**, formatted in Markdown for your project documentation. These rules distill the core architectural, styling, and development standards found in **CLAUDE.md**[cite: 1] and **rules.md**[cite: 2].

---

# 🚀 PetSphere Antigravity Rules

## 1. Architectural Integrity
*   **Layered Feature-Based Structure**: Organize the codebase by feature (e.g., `auth`, `pet`, `health`) rather than function[cite: 1, 2].
*   **The MVC+R Pattern**: Maintain a strict separation between **Models** (data), **Views** (UI), **Controllers** (logic/Riverpod), and **Repositories** (Supabase data access)[cite: 1].
*   **Single Entry Point**: All app initialization, including Supabase and routing, must reside in `lib/main.dart`[cite: 1].
*   **Repository Abstraction**: UI components must never interact with the database directly; all data fetching must flow through a Repository[cite: 1].

## 2. State Management (Riverpod)
*   **Immutability First**: State must be immutable. Use `copyWith()` for all state transitions within your `Notifier` classes[cite: 1, 2].
*   **Notifier Pattern**: Favor `Notifier` and `AsyncNotifier` for complex logic. Use `Provider` only for read-only values[cite: 1].
*   **Selective Watching**: Optimize performance by watching specific parts of the state using `ref.watch(provider.select((s) => s.property))`[cite: 1, 2].
*   **Provider Placement**: Declare providers at the end of their respective controller files to keep logic and access centralized[cite: 1].

## 3. UI & Design System (Amber Whisker)
*   **Material 3**: Follow Material 3 guidelines and use `ColorScheme.fromSeed` with the seed color `#D4845A`[cite: 1, 2].
*   **Typography**: Use **Playfair Display** for headlines and hero text, and **DM Sans** for body and UI elements via `google_fonts`[cite: 1, 2].
*   **Composition over Inheritance**: Build complex UIs by composing small, reusable `StatelessWidget` classes[cite: 1, 2].
*   **Design Tokens**: Use `ThemeExtension` to define custom colors or styles that fall outside the standard `ThemeData`[cite: 2].
*   **Visual Premium**: Apply subtle noise textures to backgrounds and multi-layered shadows to cards to create depth[cite: 2].

## 4. Performance & Best Practices
*   **Const Constructors**: Always use `const` constructors for widgets and lists to minimize unnecessary rebuilds[cite: 1, 2].
*   **Lazy Loading**: Use `ListView.builder` or `SliverList` for long data collections to ensure smooth scrolling[cite: 2].
*   **Off-Thread Processing**: Use `compute()` or Isolates for heavy operations like complex JSON parsing to keep the UI thread responsive[cite: 2].
*   **Null Safety**: Leverage Dart's sound null safety. Avoid the `!` operator unless a value is strictly guaranteed to be non-null[cite: 1, 2].

## 5. Navigation (GoRouter)
*   **Declarative Routing**: Use `go_router` for all navigation. Define routes, paths, and parameters in `lib/utils/routes.dart`[cite: 1, 2].
*   **Auth Redirection**: Implement a central `redirect` logic in the router to handle session-based access control[cite: 1, 2].
*   **Context Nav**: Use `context.go()` for state-aware jumps and `context.push()` for simple stack additions[cite: 1].

## 6. Code Quality & Collaboration
*   **Conciseness**: Keep functions short (ideally < 20 lines) and focused on a single purpose[cite: 1, 2].
*   **Naming Conventions**: Use `PascalCase` for classes, `camelCase` for variables, and `snake_case` for files[cite: 1, 2].
*   **Error Handling**: Implement `try-catch` blocks at the repository and controller layers. Never let an app fail silently[cite: 1, 2].
*   **Structured Logging**: Use the `logging` package or `dart:developer`'s `log()` function instead of `print()`[cite: 1, 2].
*   **Testing**: Follow the **Arrange-Act-Assert** pattern. Aim for high coverage across Unit, Widget, and Integration tests[cite: 1, 2].

---
*Last Updated: April 2026*[cite: 1]