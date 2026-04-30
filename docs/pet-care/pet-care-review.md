# Pet Care — internal code map, behavior, and review

## File / route map (under `lib/`)

| Area | Path | Role |
| --- | --- | --- |
| **Route** | `utils/routes.dart` | `/pet_care`, `/pet_care_onboarding?petId=` |
| **Care Diary + shell** | `views/pet_care_screen.dart` | Three tabs: Care Diary, `HealthTab`, Feeding. |
| **Health** | `views/health_tab.dart`, `controllers/health_controller.dart`, `repositories/health_repository.dart` | Meds, allergies, weight, teeth, etc. (large file). |
| **Feeding** | `_FeedingTab` in `pet_care_screen.dart` | Kcal ring, meal toggles, water cups. |
| **State** | `controllers/pet_care_controller.dart` | `PetCareState`, loads logs/weights/health + onboarding + gamification + unlocks. |
| **Persistence** | `repositories/pet_care_repository.dart` | `pet_care_logs`, `pet_weight_logs`, … + onboarding, gamification, badges. |
| **Models** | `models/pet_care_log_model.dart`, `models/care_badge_model.dart` | `DailyTask`, `PetCareLog`, onboarding/gamification DTOs. |
| **Cache** | `utils/care_cache.dart` | Local JSON cache for logs/weights. |
| **Profile (public)** | `views/match_pet_profile_screen.dart` | “Care highlights” when viewing owner; uses showcase RLS. |
| **Pets** | `controllers/pet_controller.dart`, `repositories/pet_repository.dart` | `activePet`, CRUD. |

## Current behavior (short)

- **Care Diary:** Progress rings, streak banner and dots, task checklist, mood, optional setup banner, points + 30-day path, achievement chips, showcase modal.
- **Health / Feeding:** Unchanged structurally; feeding adds diet hint from onboarding.
- **Gamification:** After logs sync, client updates `pet_care_gamification` and unlocks rows in `pet_care_badge_unlocks` when thresholds hit.

## Gaps (product / engineering)

- **Tests:** Repository and integration tests for Pet Care are still thin; one unit test was added in `test/care_streak_test.dart` for streak shape.
- **Task customization:** Onboarding does not yet rewrite `tasks` in `pet_care_logs` (still default JSON seeds).
- **7-day log window vs. long streaks / points:** `CareGamificationLogic` uses the **rolling UI window**; very old history is not fully reflected in “total points” without a SQL aggregate job.

## Code review — findings (by severity)

### High

1. **Public read on `public.pets`:** RLS is `USING (true)` for all authenticated users on `SELECT` (`table_policies.sql`). **Any** column on `pets` is world-readable, including if we ever add sensitive fields. **Mitigation in this work:** sensitive onboarding is in `pet_care_onboarding` (owner-only RLS), not on `pets`. **Follow-up:** avoid storing PII/health in `pets`; consider tightening SELECT for non-essential columns or a `pets_public` view for discovery.

### Medium

2. **Error strings to UI:** `pet_care_controller` can surface `e.toString()` in `error` state; ensure no internal IDs are displayed to end users in production toasts (existing pattern; worth centralizing).  
3. **Double `_syncCareRewards`:** Can run on both load and save; idempotent for points **if** `last_care_point_awarded_on` is set correctly; worth monitoring for race conditions on very slow networks.

### Low

4. **No automated tests** for `CareGamificationLogic` or `saveOnboarding` merge behavior.  
5. **Stitch** output is a reference; Flutter still uses `AppTheme` (by design for consistency).

## Security checklist (this slice)

- **RLS:** `pet_care_onboarding`, `pet_care_gamification` — owner (`pets.user_id = auth.uid()`), except gamification is keyed by `user_id = auth.uid()` for reads. Badges: showcase secondary SELECT on `pet_care_badge_unlocks` for profile chips. **Review** policies after any new columns.  
- **Anon key:** Remains in client `supabase_config.dart` (expected for Supabase); **no service role in app.**
