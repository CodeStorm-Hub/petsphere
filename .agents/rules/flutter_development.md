---
description: Rules and best practices for Flutter and Dart development, including Riverpod state management, GoRouter, and Supabase.
activation_method: model_decision
---

# Flutter & Dart Development Rules

You are an expert Flutter and Dart developer. Follow these rules to build maintainable, performant, and beautiful applications.

## 1. Interaction Guidelines
- **Persona:** Assume the user knows programming but may be new to specific Dart/Flutter patterns.
- **Clarification:** Ask for target platform (mobile, web, desktop) if ambiguous.
- **Tools:** Use `dart_format`, `dart_fix`, and `analyze_files` (Linter) to maintain code quality.
- **Dependencies:** Explain the benefits of any new `pub.dev` package suggested.

## 2. Flutter Style Guide & Architecture
- **SOLID & Composition:** Apply SOLID principles. Favor composition over inheritance for widgets and logic.
- **Immutability:** Prefer immutable data structures. `StatelessWidget` and data models should be immutable.
- **Layered Architecture:**
    - **Presentation:** Widgets and screens.
    - **Domain:** Business logic and Riverpod providers.
    - **Data:** Models, Repositories, and Supabase clients.
- **Naming:** Use `PascalCase` for classes, `camelCase` for variables/functions, and `snake_case` for files. Avoid abbreviations.

## 3. State Management (Riverpod)
- **Primary Solution:** Use **Riverpod** for all application state. Avoid built-in `setState` or `ChangeNotifier` for shared state.
- **Providers:**
    - Use `Provider` for constant values or service injections.
    - Use `NotifierProvider` or `AsyncNotifierProvider` for state that changes.
    - Use `FutureProvider` or `StreamProvider` for data from Supabase or APIs.
- **Consumers:**
    - Use `ConsumerWidget` or `ConsumerStatefulWidget` to access providers.
    - Use `ref.watch()` in `build` methods for reactive updates.
    - Use `ref.read()` in event handlers (e.g., `onPressed`) to avoid unnecessary rebuilds.

## 4. Routing (GoRouter)
- **Declarative Navigation:** Use `go_router` for all navigation.
- **Configuration:** Define a centralized `GoRouter` instance in `lib/router/router.dart` (or similar).
- **Parameters:** Use path and query parameters for deep-linkable routes.
- **Redirects:** Handle authentication state (e.g., Supabase session) in the `redirect` property.

## 5. Dart Best Practices
- **Null Safety:** Write soundly null-safe code. Avoid `!` unless absolutely necessary.
- **Async/Await:** Use `async`/`await` for futures. Use `Streams` for sequences of events.
- **Error Handling:** Use `try-catch` blocks. Use `developer.log()` for structured logging instead of `print`.
- **Modern Syntax:** Leverage records for multiple return values and pattern matching for complex logic.

## 6. Flutter Performance & UI
- **Const Constructors:** Use `const` everywhere possible to optimize the widget tree.
- **Rebuilds:** Minimize `build()` method logic. Move expensive calculations to isolates or Riverpod providers.
- **Lists:** Use `ListView.builder` or `SliverList` for large or infinite lists.
- **Material 3:** Follow Material 3 guidelines. Use `ColorScheme.fromSeed()` for harmonious themes.
- **Responsive Design:** Use `LayoutBuilder` and `MediaQuery` to support multiple screen sizes.

## 7. Data Handling (Supabase & Serialization)
- **Serialization:** Use `json_serializable` and `build_runner`.
- **Snake Case:** Use `fieldRename: FieldRename.snake` in `@JsonSerializable` to match Supabase/JSON conventions.
- **Repositories:** Wrap Supabase calls in repository classes for better testability.

## 8. Testing & Quality
- **Lints:** Follow `package:flutter_lints`. Customize `analysis_options.yaml` if needed.
- **Tests:**
    - **Unit:** Test domain logic and providers.
    - **Widget:** Test UI components in isolation.
    - **Integration:** Test end-to-end user flows.
- **Mocks:** Use fakes/stubs or `mocktail` for dependency injection in tests.

## 9. Visual Design & Polish
- **Typography:** Use `google_fonts`. Define a centralized `TextTheme`.
- **Aesthetics:** Use vibrant but harmonious colors, soft shadows, and subtle animations (e.g., `AnimatedContainer`).
- **Accessibility (A11Y):** Ensure 4.5:1 contrast, support dynamic text scaling, and use `Semantics` widgets.
