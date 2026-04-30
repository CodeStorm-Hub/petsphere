# PetSphere 1-Week Compressed Tech Debt Remediation Plan

**Date**: April 29, 2026  
**Duration**: 1 week (Mon–Fri, 5 days)  
**Compression Strategy**: Focus on Tier 1 critical path items; defer non-blocking enhancements to Week 2+  
**Parallel Execution**: All 3 workstreams run in parallel; Dev 1 focuses on testing, Dev 2 on security/architecture, shared effort on splitting monolithic views

---

## Executive Summary

PetSphere has **9 prioritized tech debt areas** with a weighted score of **154/900**. The audit identified **4 critical blockers** that prevent safe feature development:

1. **Zero test coverage** (Impact 5, Risk 5, Effort 4) → Score: **55/100** — blocks regression detection
2. **OAuth auth replacement** (Impact 4, Risk 5, Effort 4) → Score: **50/100** — security/compliance risk
3. **Monolithic views** (Impact 4, Risk 3, Effort 3) → Score: **48/100** — dev velocity bottleneck
4. **Missing RLS policies** (Impact 3, Risk 5, Effort 2) → Score: **48/100** — data security gap

**1-Week Compression Rationale**:
- **Complete Tier 1 (4 items)**: Address all critical blockers; unblock future development
- **Defer Tier 2 (3 items)**: Database schema cleanup, dependency updates, infrastructure debt — no critical path impact
- **Defer Tier 3 (2 items)**: Documentation/monitoring — important but non-blocking

---

## Timeline: 5 Days, 3 Parallel Workstreams

### Phase 1: Setup & Infrastructure (Mon–Tue, Days 1–2)

#### Workstream A: Testing Infrastructure
**Dev 1** | **Est. Effort**: 8 hours | **Deliverable**: Test skeleton ready, first unit tests written

- **Mon Morning**: Install testing dependencies
  - Add `mocktail` (3.0+), `flutter_test` integration helpers
  - Create `test/` directory structure: `unit/`, `widget/`, `integration/`
  - Run `flutter test --coverage` baseline (expect 0% coverage)
  - **Output**: `test/` directory with empty test files for each controller/repository
  
- **Mon Afternoon**: Write unit tests for **auth_controller** (highest impact, small scope)
  - Test: `login()`, `logout()`, `register()`, error handling
  - Mock `AuthRepository` to isolate controller logic
  - Target: 8–10 test cases, 100% controller coverage
  - **Output**: `test/controllers/auth_controller_test.dart` with passing tests
  
- **Tue Morning**: Write unit tests for **pet_controller** (second priority)
  - Test: `loadPets()`, `createPet()`, `updateActivePet()`, error cases
  - Mock `PetRepository` and `AuthController` dependency
  - Target: 10–12 test cases
  - **Output**: `test/controllers/pet_controller_test.dart`
  
- **Tue Afternoon**: Write repository tests for **auth_repository** and **pet_repository**
  - Mock Supabase client; verify query correctness
  - Test error handling (network, auth, validation)
  - Target: 8 tests per repository
  - **Output**: `test/repositories/auth_repository_test.dart`, `test/repositories/pet_repository_test.dart`
  
- **Deliverable by EOD Tue**: 30+ passing unit tests, ~12% coverage (core auth/pet logic)

---

#### Workstream B: OAuth Migration & Security
**Dev 2** | **Est. Effort**: 8 hours | **Deliverable**: OAuth flow implemented, RLS policies deployed

- **Mon Morning**: Audit current auth flow
  - Review `AuthRepository.login()`, `AuthRepository.register()`
  - Document session handling, token storage (shared_preferences)
  - Identify breakage points: direct email/password, no provider support
  - **Output**: `docs/AUTH_AUDIT.md` (2-page analysis)
  
- **Mon Afternoon**: Design OAuth flow (Google + Facebook)
  - Sketch provider selection UI, callback handling, token exchange
  - Design error cases: user denies, account exists, network failure
  - Update `AuthModel` to store provider + provider_id
  - **Output**: `docs/OAUTH_DESIGN.md` (architecture decision record)
  
- **Tue Morning**: Implement OAuth flow
  - Add dependencies: `google_sign_in`, `flutter_facebook_sdk`
  - Create `oauth_provider.dart` wrapper abstracting Google/Facebook
  - Update `AuthRepository` with `loginWithGoogle()`, `loginWithFacebook()`
  - Update `AuthController` state machine (unauthenticated → authenticating → authenticated)
  - **Output**: OAuth methods in repository, controller state updated
  
- **Tue Afternoon**: Deploy RLS policies + verify
  - Create RLS policy files for: `users`, `pets`, `posts`, `pet_care_logs`, `chat_threads`
  - Policy pattern: Users can only read/write their own records; followers can read public profiles
  - Test in test database; deploy to production
  - Add policy documentation to `lib/utils/supabase_config.dart`
  - **Output**: RLS policies in Supabase, verified in test env, documented

---

#### Workstream C: Monolithic View Splitting (Prep)
**Shared** | **Est. Effort**: 2 hours | **Deliverable**: Decomposition plan for `health_tab.dart`

- **Mon Afternoon** (1 hour):
  - Analyze `health_tab.dart` (2,229 lines)
  - Identify 8 private widget classes: `_VitalsCard`, `_MedicationsList`, etc.
  - Map dependencies between widgets
  - **Output**: `docs/HEALTH_TAB_DECOMPOSITION.md` (file structure, dependency graph)
  
- **Tue Morning** (1 hour):
  - Create empty widget files for each component
  - Move widget classes (no logic changes yet)
  - Run `flutter analyze` — should pass
  - **Output**: Split files, green build

---

### Phase 2: Implementation (Wed–Thu, Days 3–4)

#### Workstream A: Test Coverage Expansion
**Dev 1** | **Est. Effort**: 12 hours

- **Wed Morning**: Write widget tests for core screens (3 hours)
  - `auth_screen_test.dart`: LoginScreen, RegisterScreen (4 tests each)
  - Verify form submission, error display, navigation
  - Mock controllers via `ProviderContainer`
  - **Output**: 8 widget tests, green
  
- **Wed Afternoon**: Write integration test skeleton (2 hours)
  - Create `integration_test/auth_flow_test.dart`
  - Test: Register → Login → Navigate to HomeScreen
  - Leave as TODO for full integration (lower priority)
  - **Output**: Skeleton test, documents what needs full integration
  
- **Wed EOD**: Coverage now ~18% ✅
  
- **Thu Morning**: Write tests for **health_controller** and **pet_care_controller** (4 hours)
  - Unit tests for state transitions, error handling
  - Target: 12 tests per controller
  - **Output**: 24 passing tests
  
- **Thu Afternoon**: Add tests for marketplace, feed, chat controllers (3 hours)
  - Lighter coverage (8–10 tests each) — non-critical path
  - Focus on happy path + error handling
  - **Output**: 30+ additional tests
  
- **EOD Thu**: Coverage target: **25–30%**, core business logic heavily tested ✅

---

#### Workstream B: OAuth Integration Testing + Finalize
**Dev 2** | **Est. Effort**: 10 hours

- **Wed Morning**: Test OAuth flow in Android emulator (2 hours)
  - Verify Google sign-in success/cancel
  - Verify token storage and auto-login
  - Document any platform-specific issues
  - **Output**: Passing OAuth flow on Android
  
- **Wed Afternoon**: Test on iOS simulator (2 hours)
  - Repeat OAuth tests; expect fewer issues (Google is simpler on iOS)
  - Verify Facebook (if added)
  - **Output**: Passing OAuth flow on iOS
  
- **Wed EOD**: OAuth complete, tested, ready for UI integration ✅
  
- **Thu Morning**: Integrate OAuth into LoginScreen (2 hours)
  - Add "Sign in with Google" and "Sign in with Facebook" buttons
  - Update `LoginScreen` to call `ref.read(authProvider.notifier).loginWithGoogle()`
  - Handle errors gracefully (show snackbars)
  - **Output**: LoginScreen with OAuth buttons, tested manually
  
- **Thu Afternoon**: Create migration guide + handle backward compat (2 hours)
  - Document existing users: email login still works until migration period
  - Add "Link Email to Google" flow for seamless migration
  - Document in `docs/OAUTH_MIGRATION.md`
  - **Output**: Migration strategy documented, backward compat confirmed
  
- **EOD Thu**: OAuth fully integrated into UI, backward compatible ✅

---

#### Workstream C: Monolithic View Splitting (Execution)
**Shared** | **Est. Effort**: 8 hours

- **Wed Morning** (2 hours):
  - Move first 3 components from `health_tab.dart` to separate files
  - Extract `_VitalsCard` → `lib/views/components/vitals_card.dart`
  - Extract `_MedicationsList` → `lib/views/components/medications_list.dart`
  - Extract `_DentalConcernsWidget` → `lib/views/components/dental_concerns_widget.dart`
  - Run tests — should all pass
  - **Output**: 3 files split, green build
  
- **Wed Afternoon** (2 hours):
  - Move next 3 components
  - `_CareBadgesWidget` → `lib/views/components/care_badges_widget.dart`
  - `_AllergiesSection` → `lib/views/components/allergies_section.dart`
  - `_ExerciseTrackerWidget` → `lib/views/components/exercise_tracker_widget.dart`
  - **Output**: 6 files total split
  
- **Thu Morning** (2 hours):
  - Move final 2 components
  - `_WeightTrackerWidget` → `lib/views/components/weight_tracker_widget.dart`
  - `_VaccinationTracker` → `lib/views/components/vaccination_tracker.dart`
  - Update imports in `health_tab.dart`
  - **Output**: Full decomposition complete
  
- **Thu Afternoon** (2 hours):
  - Verify all imports, run full test suite
  - Check `health_tab.dart` is now <300 lines (was 2,229)
  - Add component documentation comments
  - **Output**: health_tab.dart split from 2,229 → ~250 lines; all components documented

---

### Phase 3: Validation & Cleanup (Fri, Day 5)

#### All Workstreams: Integration & Finalization

- **Fri Morning** (4 hours):
  - Full test suite run: `flutter test --coverage`
    - **Target**: 25–30% coverage, 80+ passing tests
  - Code quality scan: `flutter analyze`
    - **Target**: Zero errors; <5 warnings (acceptable for stage)
  - Manual testing on device: OAuth flow, pet creation, health tab
  - **Output**: All checks green, manual tests pass
  
- **Fri Afternoon** (4 hours):
  - Create comprehensive README for remediation work
    - What was done: tests, OAuth, RLS, view splitting
    - How to run tests: `flutter test` command and interpreting coverage
    - Known limitations: integration tests deferred, 25% coverage (target 50% by end of Q2)
    - Next steps post-Week 1
  - Commit all changes with detailed messages
  - Create Jira/GitHub issues for deferred Tier 2 work
  - **Output**: Final commit, README.md updated, Tier 2 issues created
  
- **Fri EOD** (by 5 PM):
  - ✅ 80+ unit/widget tests, 25–30% coverage
  - ✅ OAuth flow (Google + Facebook) fully implemented and tested
  - ✅ RLS policies deployed and verified
  - ✅ Monolithic `health_tab.dart` split into 8 focused components
  - ✅ Code quality gates passing: `flutter analyze`, `flutter test`
  - ✅ All Tier 1 critical items resolved

---

## Resource Allocation

| Workstream | Dev | Hours/Day | Total Hours | EOD Fri Deliverable |
|---|---|---|---|---|
| Testing (Tier 1 blocker) | Dev 1 | 8 | 32 | 80+ tests, 25–30% coverage |
| OAuth (Tier 1 blocker) | Dev 2 | 8 | 32 | OAuth flow, RLS, LoginScreen UI |
| View Splitting (Tier 1 blocker) | Shared | 2–4 | 12 | health_tab split 2,229 → 250 LOC |
| **Total** | 2 devs | — | **76 hours** | **All Tier 1 complete** |

---

## Rollback & Risk Mitigation

| Risk | Probability | Mitigation |
|---|---|---|
| OAuth breaks existing email login | Medium | Backward compat layer; email still works during transition period |
| Test infrastructure delays feature work | Low | Tests run parallel; minimal impact to feature dev |
| RLS policies break queries | Medium | Deploy to test env first; verify with sample queries before production |
| View splitting introduces bugs | Low | Component tests validate each widget in isolation |
| Coverage tooling misconfiguration | Low | Use `flutter test --coverage`; standard setup (no custom config) |

---

## Success Criteria (Fri EOD)

- [ ] **Test Coverage**: ≥25% (auth, pet, health, pet_care controllers; repositories)
- [ ] **OAuth**: Google + Facebook sign-in working on Android & iOS
- [ ] **RLS**: Policies deployed; 1–2 production sample queries verified
- [ ] **View Splitting**: `health_tab.dart` split to 8 components; imports updated; zero errors
- [ ] **Code Quality**: `flutter analyze` passes; zero errors, <5 warnings
- [ ] **Regression Tests**: Manual smoke test on device (register, login, create pet, view health tab)

---

## Deferred (Week 2+)

**Tier 2 Tech Debt** (not on critical path; address next week):
1. Database schema cleanup (enum normalization, denormalization review)
2. Dependency updates (riverpod, go_router minor versions)
3. Infrastructure hardening (monitoring, error tracking)

**Tier 3 Tech Debt** (Weeks 3–4):
1. Documentation debt (runbooks, API docs, component library)
2. Monitoring & observability (Sentry integration, analytics)

---

## Tools & Setup

**Required**:
- `mocktail` 3.0+ (mocking)
- `flutter_test` (built-in widget testing)
- `google_sign_in`, `flutter_facebook_sdk` (OAuth)
- Supabase project with test database for RLS testing

**Recommended**:
- `coverage` package (visualize coverage reports)
- GitHub Actions for CI (run tests on each commit)

---

## Post-Week-1 Roadmap

**Week 2**: 
- Expand test coverage to 40% (marketplace, feed, chat, match controllers)
- Refactor `pet_care_controller.dart` (501 lines → 250)
- Add widget tests for remaining core screens

**Week 3–4**:
- Integration tests (auth, pet creation, marketplace checkout)
- Dependency updates (safe, with test validation)
- Database schema normalization

**Week 5–6**:
- Full design system documentation (tokens, components, accessibility)
- Multi-platform responsive UI refinements
- Monitoring & error tracking

---

## FAQ

**Q: Can we add more items to Week 1?**  
A: No. Tier 1 items are critical path; adding Tier 2 items increases risk of partial/failed deliverables. Tier 2 is scheduled for Week 2 with full team capacity.

**Q: What if OAuth takes longer?**  
A: Fallback: Keep email-only auth, schedule OAuth for Week 2. This does NOT block Tier 1 (tests + RLS remain on track).

**Q: Do we need 2 developers?**  
A: Yes. 1 dev cannot complete 4 Tier 1 items (tests + OAuth + RLS + view splitting) in 1 week safely. Parallel execution is critical to timeline.

**Q: What's the minimum coverage target?**  
A: 25% for Tier 1 logic (auth, pet, health, care). 50% overall by end of Q2.

---

**Prepared**: April 29, 2026 | **Review Date**: May 2, 2026 (EOW review)
