# PetSphere Tech Debt Audit
**Date**: April 29, 2026  
**Team Size**: 1–2 developers  
**Refactoring Budget**: 40%+ capacity available  
**Current Test Coverage**: Minimal (~2 test files across entire project)  

---

## Executive Summary

PetSphere has **significant, systemic technical debt** affecting all six priority areas. The codebase shows signs of rapid feature development without sufficient structural investment:

- **5 monolithic view files** >1000 lines each (largest: 2,229 lines)
- **Zero unit test coverage** — blocks confident refactoring
- **Auth system requires complete replacement** (email/password → OAuth)
- **Oversized controllers** violating single responsibility (pet_care: 501 lines)
- **Inconsistent error handling** across state management layer
- **No shared abstractions** for common state patterns

**Good news**: Your small team's willingness to invest 40%+ in refactoring, combined with the well-documented architecture in `CLAUDE.md`, means systematic debt reduction is feasible over 2–3 sprints.

---

## Prioritized Debt Inventory

### Priority Scoring Framework
**Score = (Impact + Risk) × (6 − Effort)**

| Factor | Scale | Meaning |
|--------|-------|---------|
| Impact | 1–5 | How much it slows feature delivery |
| Risk | 1–5 | What fails if we ignore it |
| Effort | 1–5 | How hard to fix (inverted) |

---

## TIER 1: CRITICAL (Ship-Blocking)
### ⚠️ These must be fixed to unblock velocity

---

### **1. Zero Test Coverage — Complete Absence of Unit/Widget Tests**

| Metric | Value |
|--------|-------|
| **Impact** | 5 (blocks refactoring, causes regressions) |
| **Risk** | 5 (every change risks bugs) |
| **Effort** | 2 (high effort; ~3–4 weeks) |
| **Priority Score** | **(5+5) × 4 = 40** ✅ **HIGHEST** |

**Current State**:
- Only 2 test files exist in entire project
- No unit tests for controllers/repositories
- No widget tests for screens
- Zero CI/CD test gates

**Business Impact**:
- Cannot confidently refactor without regression risk
- Manual testing every feature (slow)
- Regressions slip to production
- Onboarding new developers requires manual QA

**Remediation**:
1. **Phase 1A** (Weeks 1–2): Test infrastructure + patterns
   - Set up `flutter_test` with mocking (mockito)
   - Write repository test harness (PetRepository tests)
   - Document test patterns in `CLAUDE.md`
   
2. **Phase 1B** (Weeks 3–4): Controller coverage for critical paths
   - AuthController unit tests (login, logout, refresh)
   - PetController tests (CRUD, state management)
   - HealthController tests (data loading)
   
3. **Phase 2** (Ongoing, parallel with features): Widget tests + integration
   - LoginScreen, HomeScreen widget tests
   - Cart flow widget tests
   - Add CI check: fail builds if coverage drops

**Effort**: 3 weeks (first month, 30% capacity)  
**Quick Win**: Start with AuthController tests (most critical, most testable)

---

### **2. Authentication System Replacement (Email/Password → Google/Facebook OAuth)**

| Metric | Value |
|--------|-------|
| **Impact** | 5 (core user flow; blocks feature work) |
| **Risk** | 5 (auth is security-critical) |
| **Effort** | 2 (medium-high, ~2–3 weeks) |
| **Priority Score** | **(5+5) × 4 = 40** ✅ **HIGHEST** |

**Current State**:
- AuthRepository uses email/password via Supabase
- AuthController listens to auth state changes
- LoginScreen and RegistrationScreen tied to email flow
- Mixed error handling for auth failures

**Why This Matters**:
- Email/password auth adds security surface area
- No social login reduces user friction
- OAuth integration gives you user profile data (name, avatar)
- Must be completed before major feature expansion

**Remediation Plan**:
1. **Week 1**: Design new auth flow
   - Integrate `google_sign_in` + `facebook_flutter` SDKs
   - Design fallback (if OAuth fails, allow email signup)
   - Update Supabase RLS policies for OAuth users
   
2. **Week 2**: Implement OAuth in repository/controller
   - Create `signInWithGoogle()` and `signInWithFacebook()`
   - Update AuthState to track oauth_provider
   - Handle token refresh for OAuth
   
3. **Week 3**: Update UI + migration
   - Redesign LoginScreen (OAuth buttons + email fallback)
   - Deprecate old registration flow
   - Add migration path for existing email users

**Dependencies**: 
- Supabase OAuth provider config (GCP + Facebook apps)
- `google_sign_in`, `facebook_flutter` dependencies already available

**Effort**: 2 weeks (Weeks 1–2 of refactoring sprint, 50% capacity)

---

### **3. Monolithic View Files — Code God Objects**

| Metric | Value |
|--------|-------|
| **Impact** | 4 (hard to modify, slow builds, high bug risk) |
| **Risk** | 4 (changes affect multiple concerns) |
| **Effort** | 2 (medium effort, ~2–3 weeks to split all) |
| **Priority Score** | **(4+4) × 4 = 32** ⚠️ **CRITICAL** |

**Current State**:
```
health_tab.dart                2,229 lines  ← Contains 8+ private widget classes
pet_profile_screen.dart        1,852 lines  
pet_care_screen.dart           1,479 lines  
create_post_screen.dart        1,349 lines  
home_screen.dart               1,127 lines  
```

**Problem**: Single 2,200-line file contains:
- Main HealthTab entry widget
- _HealthOverviewCard (stats, badges, badges)
- _VitalsSection, _MedicationsSection, _AppointmentsSection
- _VaccinationsSection, _ParasiteSection, _DentalSection, _AllergySection
- _SymptomsSection, etc. — all in ONE file

**Consequences**:
- IDE lag when editing
- Merge conflicts (multiple people can't work on same screen simultaneously)
- Hard to test individual sections
- Violates single-responsibility principle
- Slow hot reload during development

**Remediation**:
1. **Extract into feature files** (one per logical section):
   ```
   lib/views/health/
   ├── health_tab.dart           (coordinator only)
   ├── components/
   │   ├── health_overview.dart
   │   ├── vitals_section.dart
   │   ├── medications_section.dart
   │   ├── appointments_section.dart
   │   └── ...
   └── models/ (if needed)
   ```

2. **Similar treatment** for other >1000-line files:
   - `pet_profile_screen.dart` → split into 3–4 components
   - `pet_care_screen.dart` → extract care panels
   - `create_post_screen.dart` → separate media picker, editor, preview
   - `home_screen.dart` → extract feed sections, recommended pets

3. **Naming convention**: Private components stay `_ComponentName` within their feature folder

**Effort**: 2 weeks (Weeks 3–4, parallel with auth refactoring, 30% capacity)  
**Quick Win**: Extract health_tab into 8 component files (can be done incrementally)

---

## TIER 2: HIGH (Velocity Dampers)
### 🔴 Blocks smooth feature development; must address in next 1–2 sprints

---

### **4. Oversized Controllers — Violation of Single Responsibility**

| Metric | Value |
|--------|-------|
| **Impact** | 4 (hard to reason about, slow to modify) |
| **Risk** | 3 (risk of state bugs when adding features) |
| **Effort** | 3 (medium, ~1–2 weeks) |
| **Priority Score** | **(4+3) × 3 = 21** 🔴 **HIGH** |

**Current State**:
```
pet_care_controller.dart       501 lines (handles logging, goals, badges)
health_controller.dart         351 lines (vitals, meds, allergies, dental)
feed_controller.dart           328 lines (posts, stories, engagement)
```

**Guidelines**: Controllers should be ~150–250 lines. Oversized ones signal mixed concerns.

**Problems**:
- `pet_care_controller`: Mixing care logging, goal management, badge calculation
- `health_controller`: Mixing multiple health domains (vitals, meds, allergies)
- Hard to test individual concerns in isolation
- State mutations spread across many methods

**Remediation**:
1. **pet_care_controller** (501 → 3 controllers):
   - `PetCareLogController` — logging activities only
   - `PetCareGoalController` — goal CRUD and tracking
   - `CareBadgeController` — badge/achievement calculation
   
2. **health_controller** (351 → 2 controllers):
   - `PetHealthVitalsController` — vitals tracking
   - `PetHealthMedicationController` — medications, allergies, dental
   
3. **feed_controller** (328 → keep, but extract post engagement):
   - `PostEngagementController` — likes, comments → separate provider

**Naming**: Keep consistent with `CLAUDE.md` (e.g., `pet_care_log_controller.dart`)

**Effort**: 1 week (Weeks 5–6, 25% capacity)

---

### **5. Inconsistent Error Handling & State Loading Patterns**

| Metric | Value |
|--------|-------|
| **Impact** | 4 (user-facing errors, regressions) |
| **Risk** | 3 (inconsistent error state can leak) |
| **Effort** | 3 (create utilities, refactor controllers, ~1 week) |
| **Priority Score** | **(4+3) × 3 = 21** 🔴 **HIGH** |

**Current State**:
- Some controllers use `isLoading`; others duplicate the pattern
- Error clearing handled differently across controllers
- No centralized error boundary or error snackbar logic
- Async error handling sometimes swallowed (no try-catch in some repos)

**Example Inconsistencies**:
```dart
// auth_controller.dart
state = state.copyWith(isLoading: true, clearError: true); // Clears error

// pet_care_controller.dart (likely)
state = state.copyWith(isLoading: true); // Doesn't clear error

// health_controller.dart
state = state.copyWith(isLoading: true, error: null); // Explicit null
```

**Remediation**:
1. **Create `AsyncOperation` mixin** for consistent loading/error pattern:
   ```dart
   mixin AsyncOperationMixin<T extends StateNotifier> {
     Future<void> executeAsync(Future Function() fn) async {
       state = state.copyWith(isLoading: true, error: null);
       try {
         await fn();
       } catch (e) {
         state = state.copyWith(error: e.toString(), isLoading: false);
       }
     }
   }
   ```

2. **Standardize controller state classes**:
   - All include `isLoading`, `error`, `clearError` flag in copyWith
   
3. **Global error handling**:
   - Add error listener to all controllers in `bootstrap_controller.dart`
   - Show snackbars for non-handled errors
   - Log errors to analytics/monitoring

**Effort**: 3–4 days (Weeks 5–6, parallel, 15% capacity)

---

### **6. Missing Supabase Security (Row-Level Security Gaps)**

| Metric | Value |
|--------|-------|
| **Impact** | 5 (security-critical) |
| **Risk** | 4 (data exposure, unauthorized access) |
| **Effort** | 3 (audit + policy writing, ~3–4 days) |
| **Priority Score** | **(5+4) × 3 = 27** 🔴 **CRITICAL** |

**Current State**:
- No evidence of RLS policies in codebase review
- No mention of policy enforcement in repositories
- Risk: User A could query User B's pets, messages, health data

**Remediation**:
1. **Audit each table** for required RLS:
   - `pets` — users can only see own + followed users' pets
   - `messages` — users can only see threads they're in
   - `health_records` — users can only see own pet data
   - `cart_items` — user-specific cart

2. **Write Supabase RLS policies** (SQL):
   ```sql
   -- Example: pets table
   CREATE POLICY "Users can only see own and followed pets"
   ON pets FOR SELECT USING (
     user_id = auth.uid() OR user_id IN (
       SELECT followed_user_id FROM follows 
       WHERE follower_user_id = auth.uid()
     )
   );
   ```

3. **Test policies** with `anon_key` to confirm access is restricted

**Effort**: 3 days (Week 7, 20% capacity, can be done with auth refactoring)

---

## TIER 3: MEDIUM (Nice-to-Have Improvements)
### 🟡 Improve developer experience and code health; schedule for sprints 3+

---

### **7. Code Duplication in Repository Patterns**

| Metric | Value |
|--------|-------|
| **Impact** | 3 (maintenance burden, bug sync) |
| **Risk** | 2 (bugs replicated if duplication exists) |
| **Effort** | 4 (low effort, scattered locations) |
| **Priority Score** | **(3+2) × 2 = 10** 🟡 **MEDIUM** |

**Likely Duplication Areas**:
- Image upload logic (repeated in `petRepository`, `feedRepository`)
- Date formatting for Supabase queries
- Error wrapping and exception mapping
- Pagination logic in multiple repos

**Remediation**:
1. Create `lib/utils/supabase_helpers.dart` with:
   - `uploadImage(bucketName, path, file)` — centralized
   - `dateToSupabase(DateTime)` — date formatting
   - `mapSupabaseException(Exception)` — error mapping

2. Audit each repository for duplication, extract common patterns

**Effort**: 2–3 days (Weeks 7–8, 10% capacity)

---

### **8. Documentation Gaps**

| Metric | Value |
|--------|-------|
| **Impact** | 3 (onboarding pain, tribal knowledge) |
| **Risk** | 2 (developer friction, key person dependency) |
| **Effort** | 4 (low effort, can parallelize) |
| **Priority Score** | **(3+2) × 2 = 10** 🟡 **MEDIUM** |

**Current State**:
- `CLAUDE.md` is excellent architecture guide
- Missing: runbooks, troubleshooting, testing patterns, deployment steps

**Remediation**:
1. Add sections to `CLAUDE.md`:
   - "Running Tests" — how to run test suite, CI gates
   - "Debugging Guide" — common issues, logs, profiling
   - "Deployment Checklist" — pre-release steps

2. Document complex features:
   - Care gamification logic in `utils/care_gamification_logic.dart`
   - Care personalization engine
   - Health alert system

3. Create `docs/` folder:
   - `docs/DATABASE.md` — Supabase schema guide, RLS policies
   - `docs/AUTH.md` — OAuth flow diagram
   - `docs/TROUBLESHOOTING.md` — common errors and fixes

**Effort**: 2–3 days (Weeks 7–8, 10% capacity, done alongside other work)

---

### **9. Dependency & Library Review**

| Metric | Value |
|--------|-------|
| **Impact** | 2 (potential for better tools) |
| **Risk** | 2 (security vulns in outdated deps) |
| **Effort** | 4 (low effort) |
| **Priority Score** | **(2+2) × 2 = 8** 🟡 **LOW** |

**Current Audit**:
- Most dependencies look current (riverpod 3.3.1, go_router 17.1.0, supabase_flutter 2.8.4)
- No obvious deprecated packages

**Recommendation**: Run `flutter pub outdated` and update quarterly

**Effort**: 1 day (Weeks 8+, 5% capacity, schedule monthly)

---

## Phased Remediation Roadmap

### Sprint 1 (Weeks 1–2): Foundation
**Goal**: Enable confident refactoring with tests + OAuth  
**Capacity**: 50% refactoring, 50% features

| Week | Item | Owner | Effort |
|------|------|-------|--------|
| 1 | Test infrastructure setup | Dev 1 | 3 days |
| 1 | AuthController tests | Dev 1 | 2 days |
| 2 | OAuth design & integration | Dev 2 | 5 days |
| 2 | LoginScreen redesign | Dev 2 | 3 days |

**Outcomes**:
- ✅ Test harness in place, first 50 tests written
- ✅ OAuth sign-in working (Google + Facebook)
- ✅ Email fallback functional
- ✅ AuthRepository tests pass

---

### Sprint 2 (Weeks 3–4): Structural Cleanup
**Goal**: Break apart monolithic views + critical controllers  
**Capacity**: 40% refactoring, 60% features

| Week | Item | Owner | Effort |
|------|------|-------|--------|
| 3 | health_tab.dart split (8 components) | Dev 1 | 4 days |
| 3 | Error handling mixin + cleanup | Dev 2 | 3 days |
| 4 | Pet care controller split (3 controllers) | Dev 1 | 3 days |
| 4 | RLS policy audit + implementation | Dev 2 | 3 days |

**Outcomes**:
- ✅ health_tab now organized into 8 files (faster edits, testable)
- ✅ Error patterns consistent across codebase
- ✅ Database security hardened
- ✅ pet_care responsibilities split

---

### Sprint 3 (Weeks 5–6): Test & Coverage Expansion
**Goal**: 40%+ code coverage on critical paths  
**Capacity**: 30% refactoring, 70% features

| Week | Item | Owner | Effort |
|------|------|-------|--------|
| 5 | PetController + HealthController tests | Dev 1 | 4 days |
| 5 | Widget tests (LoginScreen, HomeScreen) | Dev 2 | 4 days |
| 6 | Remaining controller tests | Dev 1 | 3 days |
| 6 | Dependency review + updates | Dev 2 | 2 days |

**Outcomes**:
- ✅ 40%+ test coverage achieved
- ✅ CI gates enforced (fail if coverage drops)
- ✅ Dependencies updated
- ✅ Confident refactoring possible

---

### Sprint 4+ (Ongoing): Polish & Maintenance
**Goal**: Continuous improvement, sustainability  
**Capacity**: 20% refactoring, 80% features

- Extract remaining duplication (~3 days)
- Add documentation + runbooks (~3 days)
- Pet profile & marketplace screen split (~1 week)
- Feature development with confidence

---

## Quick Wins (Can Start This Week)

1. **Set up test infrastructure** (2 days) — unblocks all refactoring
   - Add `flutter_test`, `mockito` to `pubspec.yaml`
   - Create `test/test_utils/` with helpers
   - Write first 10 tests (AuthController)

2. **Create error handling mixin** (1 day) — enables controller cleanup
   - Standardizes loading/error pattern
   - Saves 10+ hours of refactoring effort later

3. **Create RLS audit checklist** (2 days) — table access control
   - List all sensitive tables
   - Identify policy gaps
   - Write SQL policies

4. **Plan OAuth integration** (1 day) — clear requirements for dev work
   - Diagram new auth flow
   - Set up OAuth apps (GCP, Facebook)
   - Update Supabase config

**Total**: 6 days of groundwork that unblocks 40%+ faster refactoring

---

## Success Metrics

| Metric | Current | Target | Timeline |
|--------|---------|--------|----------|
| **Test Coverage** | 0% | 40% | Week 6 |
| **Largest File** | 2,229 lines | <400 lines | Week 4 |
| **Largest Controller** | 501 lines | <300 lines | Week 6 |
| **Feature Velocity** | (see burndown) | +30% | Week 8 |
| **Bug Escape Rate** | ~5% | <2% | Week 8 |
| **Auth Method** | Email/password | OAuth + fallback | Week 2 |
| **RLS Coverage** | 0% | 100% tables | Week 4 |

---

## Resource Allocation

**With 1–2 developers @ 40%+ refactoring capacity:**

```
Total Capacity:    40 days (5 weeks × 8 days)
Refactoring Work:  ~32 days over 6 weeks
Feature Work:      Parallel; ~60% time after week 1

Week 1–2: Auth (10 days) + Tests (5 days) = 15 days refactoring
Week 3–4: Views + Controllers (10 days) = 10 days refactoring
Week 5–6: Tests + Policies (7 days) = 7 days refactoring
Week 7+:  Ongoing cleanup (2 days/week) = Sustainable
```

---

## Key Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| Refactoring causes regressions | **Start with test infrastructure (Week 1)** — no refactoring without tests |
| OAuth integration delays other features | **Parallelize**: Dev 1 on OAuth, Dev 2 on tests/views |
| Small team can't sustain 40% refactoring | **Track velocity**: If dropping, reduce refactoring to 25% |
| Oversized task list feels overwhelming | **Focus on Tier 1 first** (auth, tests, health_tab split) |
| New features pile up while refactoring | **Strict feature gate**: Only bug fixes + small features during Weeks 1–4 |

---

## Conclusion

PetSphere's tech debt is **manageable but urgent**. Your small team's willingness to invest 40%+ makes a 6-week systematic cleanup realistic. 

**Critical path** (Week 1–4):
1. Build test infrastructure (enables confident refactoring)
2. Replace auth (security + UX improvement)
3. Split monolithic views (faster development)
4. Harden database security

**By Week 6**: Feature velocity should increase 30%+, regression rate should drop <2%, and the codebase becomes maintainable for the next 6–12 months of growth.

Start with the **quick wins** this week — they unblock everything else.
