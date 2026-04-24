# PetSphere (Flutter) — research-backed improvements & Cursor agent task list

**Purpose:** Guide Cursor agents and developers with **online research findings**, **industry-typical practices** for Flutter in 2025–2026, and a **priority-ranked backlog** aligned with this repo (Riverpod, go_router, Supabase).  
**Project context:** `pet_dating_app` / PetSphere — social + marketplace + messaging; backend Supabase; navigation via `go_router`.

---

## How to use this file (for agents)

- Work **top to bottom** by priority (P0 → P3) unless a task is explicitly unblocked.
- Each task is **independently shippable** when possible; prefer small PRs.
- After completing a task, update the checkbox and add a one-line note in your PR (what changed, how verified).

---

## Research findings (synthesized)

### Architecture & project structure

- **Feature-based / folder-by-feature** structure scales more predictably than large flat `models/` + `views/` + `repositories/` splits as the app grows; **Clean Architecture** (domain / data / presentation) is valuable but can be **incremental** — e.g. repositories + feature folders first, use cases only when business rules grow ([Flutter Studio — Clean Architecture](https://flutterstudio.dev/blog/flutter-clean-architecture.html), [Softaims — Production architecture](https://softaims.com/blog/flutter-production-architecture-clean-code-2026)).
- **Repository pattern** remains the main abstraction over APIs/DB; **navigation stays in the presentation layer** (widgets / router), not inside repositories ([Utku Alp Turen — go_router](https://utkuaturen.com/en/articles/flutter-navigation-go-router), [Very Good Ventures — routing](https://verygood.ventures/blog/routing-best-practices-in-flutter/)).
- **Avoid mixing** multiple state management paradigms in one codebase — pick one primary approach (here: **Riverpod**) ([Startup House — Flutter best practices](https://startup-house.com/blog/flutter-app-best-practices)).

**PetSphere mapping:** Current layout is layer-style (`lib/controllers`, `lib/repositories`, `lib/views`). This is fine for a medium app, but long-term refactors may move toward **feature folders** or a **`core/`** + **`features/`** split as features multiply.

---

### State management (Riverpod)

- Prefer **`ref.watch` in `build`** for reactive UI; use **`ref.read` in event handlers** (e.g. `onPressed`); use **`ref.listen` for side effects** (snackbars, navigation) — misusing `watch` in callbacks can create wasteful or misleading subscriptions ([Riverpod docs — reading providers](https://riverpod.dev/docs/concepts/reading), [DCM — Riverpod / ref lifecycle](https://dcm.dev/blog/2026/03/25/inside-riverpod-source-code-guide-dcm-rules)).
- **Do not use `ref` after async gaps** without checking validity / `mounted` patterns; Riverpod 3+ guards against invalid `Ref` use — design async flows to avoid `UnmountedRefException` (same DCM article).
- **Standardize** on `Notifier` / `AsyncNotifier` patterns; keep notifiers **focused** and testable (community guides, e.g. [Medium — Riverpod 2025 overview](https://medium.com/@alokkumarmaurya5556/master-riverpod-in-flutter-2025-a-complete-beginner-friendly-deep-practical-state-management-57536279483f)).

**PetSphere mapping:** Controllers that load data when **`activePet` is null** should move to a **defined state** (error / empty / “add a pet”) instead of indeterminate loading; align with “never leave users on ambiguous blank states” (Startup House, testing articles below).

---

### Navigation, auth guards, and deep links (go_router)

- Centralize **auth redirects** in one `redirect` callback; **guard against redirect loops** (check current location vs target) ([Very Good Ventures — routing](https://verygood.ventures/blog/routing-best-practices-in-flutter/), [Code With Andrea — deep links & refresh](https://codewithandrea.com/articles/flutter-deep-links/)).
- Use **`refreshListenable`** (or equivalent) so when auth (or other gate state) changes, **redirects re-run** (Stack Overflow / community patterns; [VGV routing](https://verygood.ventures/blog/routing-best-practices-in-flutter/)).
- **Deep links:** validate path params; if id is wrong/missing, show a recoverable error — **do not assume in-memory lists** are populated ([VGV — validate parameters](https://verygood.ventures/blog/routing-best-practices-in-flutter/)).
- Consider **`errorBuilder` / 404** route for unknown paths ([TeachMeIDEA — routing & deep linking](https://teachmeidea.com/flutter-routing-deep-linking-best-practices-2025/)).
- **Optional but valuable:** `redirect` query (e.g. return user to intended screen after login) ([Code With Andrea](https://codewithandrea.com/articles/flutter-deep-links/)).

**PetSphere mapping:** `/post/:id` and `/product/:id` should **fetch by id** when the entity is not in the feed/market list (cold start / share link). **Preserve destination after login** if productizing auth.

---

### Performance & UI hygiene

- Use **`const` constructors** where possible to cut rebuild work ([Startup House](https://startup-house.com/blog/flutter-app-best-practices)).
- Avoid **high `setState` / rebuild fan-out**; prefer localized rebuilds (Riverpod `select` where appropriate) ([Startup House](https://startup-house.com/blog/flutter-app-best-practices), [DCM](https://dcm.dev/blog/2026/03/25/inside-riverpod-source-code-guide-dcm-rules)).
- **Image/network:** use caching, size constraints, and error placeholders (general production guidance: [Startup House](https://startup-house.com/blog/flutter-app-best-practices)).

---

### Testing (testing pyramid)

- **~70% unit, ~20% widget, ~10% integration** (rule of thumb; adjust per team) ([TeachMeIDEA — testing](https://teachmeidea.com/unit-widget-and-integration-testing-in-flutter-best-practices/), [Flutter Studio — testing strategy](https://flutterstudio.dev/blog/flutter-testing-strategy.html)).
- **Mock** external I/O (Supabase, `http`); test **notifiers** and **repositories** with fakes; **widget-test** critical screens (loading / error / empty) ([TeachMeIDEA](https://teachmeidea.com/unit-widget-and-integration-testing-in-flutter-best-practices/)).
- **Integration tests** for few **critical paths** (auth, checkout) — not every screen ([Boundev — testing guide](https://www.boundev.com/blog/flutter-unit-testing-widget-integration-guide), [Yrkan — testing guide](https://yrkan.com/blog/flutter-testing-guide/)).
- Use **stable `Key`s** for integration tests; avoid over-specifying implementation details in assertions ([TeachMeIDEA](https://teachmeidea.com/unit-widget-and-integration-testing-in-flutter-best-practices/)).
- **CI:** run `flutter test` (and `analyze`) on every PR; schedule heavier tests as needed ([OnOn — strategies](https://onon.technology/blog/flutter-testing-strategies)).

**PetSphere mapping:** The repo is light on `test/`; adding **repository + notifier** tests first yields the best ROI.

---

### Accessibility (a11y)

- Flutter’s **semantics tree** underpins TalkBack / VoiceOver; use **`Semantics`**, **`MergeSemantics`**, **`ExcludeSemantics`** as needed; avoid **no-op buttons** (Flutter accessibility checklist: [docs — semantic roles & checklist](https://docs.flutter.dev/accessibility-and-localization/semantic-roles)).
- **Touch targets** ≥ 48×48 (logical pixels); support **text scaling** via `MediaQuery` / `Theme` — don’t clamp font scale without reason ([Himanshu Agarwal — a11y guide](https://himanshu-agarwal.medium.com/mastering-accessibility-a11y-in-flutter-the-only-guide-youll-ever-need-05cfd4dbf664), [DCM — practical a11y](https://dcm.dev/blog/2025/06/30/accessibility-flutter-practical-tips-tools-code-youll-actually-use/)).
- **Test with** VoiceOver / TalkBack on real devices ([Flutter docs — assistive technologies](https://docs.flutter.dev/ui/accessibility/assistive-technologies)).

**PetSphere mapping:** Replace **empty `onPressed` handlers** (settings, forgot password) with real flows or temporary snackbars per Flutter’s own guidance (linked above).

---

### Security & config (Supabase / mobile)

- **No secrets in source**; use **build-time** config (`--dart-define` / CI secrets) — already partial pattern with `String.fromEnvironment` in this project.
- For production hardening, teams often add **token/session handling review**, **SSL pinning** (where applicable), and **principle of least privilege** for keys (general enterprise practice: [Flutter Fever — enterprise arch](https://flutterfever.com/how-to-design-flutter-enterprise-app-architecture-in-2026/); align with your threat model — not all items apply to every app).

---

## Suggested improvements (project-specific, research-aligned)

| Area | Issue / opportunity | Research tie-in |
|------|---------------------|-----------------|
| Deep links | Post/product detail depend on in-memory lists | [VGV](https://verygood.ventures/blog/routing-best-practices-in-flutter/) — validate params + fetch |
| State | `activePet == null` leaves match/chat in awkward states | Loading UX patterns ([Startup House](https://startup-house.com/blog/flutter-app-best-practices)) |
| Supabase + UX | After match, chat thread may be missing if only DB expects triggers | Data + presentation separation ([Clean Architecture guides](https://flutterstudio.dev/blog/flutter-clean-architecture.html)) |
| Completeness | Placeholder actions (settings, forgot password) | [Flutter accessibility — active interactions](https://docs.flutter.dev/accessibility-and-localization/semantic-roles) |
| Quality gates | Little or no automated test suite | [Testing pyramid](https://teachmeidea.com/unit-widget-and-integration-testing-in-flutter-best-practices/) |
| A11y | Icon-only buttons, dense lists | [Semantics & minimum targets](https://docs.flutter.dev/accessibility-and-localization/semantic-roles) |

---

## Priority task list (for Cursor agents)

### P0 — Correctness, security, and user trust

- [ ] **P0-1** — **Deep-link-safe detail screens:** Implement `fetchPostById` / `fetchProductById` (or `FutureProvider.family`) so `/post/:id` and `/product/:id` work when the entity is not in the cached list. Show loading, then error with retry. *Refs:* [VGV routing](https://verygood.ventures/blog/routing-best-practices-in-flutter/), [Code With Andrea](https://codewithandrea.com/articles/flutter-deep-links/).
- [ ] **P0-2** — **No `activePet` / no pets:** Unify **match** and **chat** (and any pet-scoped action) to show a clear **empty state** CTA: “Add a pet” / switch pet; avoid perpetual “loading” or silent failures. *Refs:* Riverpod + UX clarity ([DCM](https://dcm.dev/blog/2026/03/25/inside-riverpod-source-code-guide-dcm-rules), [Startup House](https://startup-house.com/blog/flutter-app-best-practices)).
- [ ] **P0-3** — **Async actions show truthful UI:** e.g. match **accept/decline** should `await` and only show success **after** success; read `ref.listen` for errors. *Refs:* [Riverpod — listen for side effects](https://riverpod.dev/docs/concepts/reading).
- [ ] **P0-4** — **Match → messaging continuity:** On successful match, **create or open** `chat_threads` (call existing `createOrGetThread` from a single orchestration point — notifier or repository), or document/ensure **Supabase trigger** does so; add a **“Message”** entry on pet profile when matched. *Refs:* repository as coordination layer ([Clean Architecture](https://flutterstudio.dev/blog/flutter-clean-architecture.html)).
- [ ] **P0-5** — **Config & environments:** Document `SUPABASE_URL` / `SUPABASE_ANON_KEY` in README; add `flutter` analyze + test to CI (GitHub Actions or similar). *Refs:* environment-based config ([Softaims](https://softaims.com/blog/flutter-production-architecture-clean-code-2026), [FlutterFever](https://flutterfever.com/how-to-design-flutter-enterprise-app-architecture-in-2026/)).

### P1 — Navigation & product polish

- [ ] **P1-1** — **Post-login redirect:** Optional `?from=` (or return location) on login so deep links + auth gate preserve intent. *Refs:* [Code With Andrea](https://codewithandrea.com/articles/flutter-deep-links/), [TeachMeIDEA](https://teachmeidea.com/flutter-routing-deep-linking-best-practices-2025/).
- [ ] **P1-2** — **Global `errorBuilder` / unknown route** page. *Refs:* [VGV](https://verygood.ventures/blog/routing-best-practices-in-flutter/), [TeachMeIDEA](https://teachmeidea.com/flutter-routing-deep-linking-best-practices-2025/).
- [ ] **P1-3** — **Fix misleading chrome:** e.g. home app bar “heart” opening notifications — use icon/semantics that match behavior or change destination. *Refs:* a11y “controls match behavior” ([Flutter docs](https://docs.flutter.dev/accessibility-and-localization/semantic-roles)).
- [ ] **P1-4** — **Share:** Replace clipboard-only with `share_plus` (or platform share) while keeping copy as fallback. *Ref:* product expectations for “Share” (common mobile pattern; supplement general UX guidance: [Startup House](https://startup-house.com/blog/flutter-app-best-practices)).
- [ ] **P1-5** — **Auth UX:** Implement **forgot password** (Supabase reset) or remove button until done; add **terms** link on registration. *Refs:* [Flutter accessibility](https://docs.flutter.dev/accessibility-and-localization/semantic-roles) (no dead controls).

### P2 — Architecture & maintainability (incremental)

- [ ] **P2-1** — **Introduce `core/`** for cross-cutting: config, routing helpers, `Result`/failure type (optional: `fpdart` `Either` per team preference) — keep **one** error style. *Refs:* [Softaims](https://softaims.com/blog/flutter-production-architecture-clean-code-2026), [Flutter Studio](https://flutterstudio.dev/blog/flutter-clean-architecture.html).
- [ ] **P2-2** — **Per-feature folder pilot:** Move one vertical slice (e.g. `feed/`) to `lib/features/feed/...` with colocated repository interface + implementation if desired. *Refs:* [Flutter Studio](https://flutterstudio.dev/blog/flutter-clean-architecture.html), [Utku Alp Turen](https://utkuaturen.com/en/articles/flutter-clean-architecture).
- [ ] **P2-3** — **Repository queries:** e.g. discovery list — align SQL with product rules (hide already-requested pets if required); document in code comment when DB must enforce. *Ref:* [Softaims — repository as policy](https://softaims.com/blog/flutter-production-architecture-clean-code-2026).
- [ ] **P2-4** — **State hygiene audit:** Grep for `ref.watch` in non-build contexts; move to `read` or `listen` per DCM-style guidance. *Ref:* [DCM](https://dcm.dev/blog/2026/03/25/inside-riverpod-source-code-guide-dcm-rules).

### P3 — Quality, a11y, and performance

- [ ] **P3-1** — **Testing pyramid:** Add **unit tests** for notifiers (auth, match, feed) with mocked repositories; add **widget tests** for `PostCard`, empty/error states. *Refs:* [TeachMeIDEA](https://teachmeidea.com/unit-widget-and-integration-testing-in-flutter-best-practices/), [Flutter Studio](https://flutterstudio.dev/blog/flutter-testing-strategy.html).
- [ ] **P3-2** — **One integration test** for login → home shell (optional Supabase test project / mocked client). *Ref:* [Boundev](https://www.boundev.com/blog/flutter-unit-testing-widget-integration-guide).
- [ ] **P3-3** — **A11y pass:** `Semantics` labels for important `IconButton`s; verify contrast against design ([Flutter docs](https://docs.flutter.dev/accessibility-and-localization/semantic-roles), [DCM a11y](https://dcm.dev/blog/2025/06/30/accessibility-flutter-practical-tips-tools-code-youll-actually-use/)).
- [ ] **P3-4** — **Performance pass:** `const` in hot paths, `ListView`/`Sliver` usage review, `cacheExtent` for long feeds ([Startup House](https://startup-house.com/blog/flutter-app-best-practices)).
- [ ] **P3-5** — **Optional: `flutter_riverpod` + `dcm` / `riverpod_lint` / `custom_lint`** in dev_dependencies to enforce Riverpod rules. *Ref:* [DCM](https://dcm.dev/blog/2026/03/25/inside-riverpod-source-code-guide-dcm-rules).

---

## Reference index (primary URLs)

| Topic | Link |
|------|------|
| Clean Architecture (Flutter, 2026) | [flutterstudio.dev](https://flutterstudio.dev/blog/flutter-clean-architecture.html) |
| Production architecture / Riverpod DI | [softaims.com](https://softaims.com/blog/flutter-production-architecture-clean-code-2026) |
| go_router & redirects | [verygood.ventures](https://verygood.ventures/blog/routing-best-practices-in-flutter/) |
| Deep links & refresh | [codewithandrea.com](https://codewithandrea.com/articles/flutter-deep-links/) |
| Riverpod: ref / lifecycle | [dcm.dev](https://dcm.dev/blog/2026/03/25/inside-riverpod-source-code-guide-dcm-rules) |
| Reading providers | [riverpod.dev](https://riverpod.dev/docs/concepts/reading) |
| Testing pyramid | [teachmeidea.com](https://teachmeidea.com/unit-widget-and-integration-testing-in-flutter-best-practices/) |
| Accessibility checklist | [docs.flutter.dev](https://docs.flutter.dev/accessibility-and-localization/semantic-roles) |
| Performance & state pitfalls | [startup-house.com](https://startup-house.com/blog/flutter-app-best-practices) |

---

*Generated for PetSphere / `pet_dating_app`. Update priorities as product scope changes.*
