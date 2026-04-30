# Pet Care: research and product notes

Consolidated references for the Pet Care slice (diary, health, feeding), onboarding, and gamification. **This is not veterinary advice; always follow your licensed veterinarian.**

## Species, households, and enrichment

- **Multi-species / multi-pet homes:** Practice gradual introductions, separate feeding areas, and species-appropriate refuge spaces (e.g. vertical space and hiding for cats, quiet zones for smaller pets). [Hidden Brook Veterinary – multi-pet tips](https://hiddenbrookveterinary.com/best-multi-pet-households-with-dogs-and-cats-tips-for) · [Kitty Cuddles – multi-pet guide](https://cutekittycuddles.com/blogs/news/multi-pet-households-the-complete-guide-to-harmony-between-dogs-cats-birds-and-small-animals) · [Joyfolk Pets – harmony](https://joyfolkpets.com/multi-pet-household-harmony/)
- **Environmental enrichment:** Enrichment should increase normal species-typical behavior and a sense of control; categories include food-based, sensory, novel objects, social, and positive training (Ohio State [Indoor Pet Initiative](https://indoorpet.osu.edu/dogs/environmental_enrichment_dogs); [dvm360 proceedings](https://www.dvm360.com/view/environmental-enrichment-dogs-and-cats-proceedings-0)).
- **Nutrition and diet type:** Species/breed, life stage, and medical diet are highly individual; apps should nudge “measure, observe, review with a vet” rather than prescriptive medical dosing in UI copy (aligned with [WSAVA nutrition toolkit](https://www.wsava.org/Guidelines/WSAVA-Global-Nutrition-Committee-Toolkit) — use as external reference for “talk to your vet” framing).

## Adherence, gentle nudges, and gamification

- **Engagement and adherence:** A randomized trial of a “digital pet” game inside a smoking cessation app found **higher app engagement and tool use** with game access; clinical endpoints were mixed, illustrating that gamification can drive **adherence to the program** even when a single outcome is not guaranteed. [Journal of Medical Internet Research (2024)](https://doi.org/10.2196/57839) · summaries: [Medical Xpress](https://medicalxpress.com/news/2024-11-digital-pet-game-cessation-app.html) · [Healio](https://www.healio.com/news/pulmonology/20241108/adults-use-smoking-cessation-smartphone-app-more-with-access-to-digital-pet-game)
- **Streaks and rewards:** Habit and mindfulness apps often use streaks and rewards to make repetition measurable; the literature on gamified health is broad—MDPI/PMC reviews stress clarity of purpose, metrics, and ethics. [Int. J. Environ. Res. Public Health (2024) — gamification and health psychology](https://www.mdpi.com/1660-4601/21/8/990) · [PMC copy](https://pmc.ncbi.nlm.nih.gov/articles/PMC11353921/)
- **Gentle nudges:** Copy should avoid shame; emphasize small wins, recovery after missed days, and “permission to restart” to reduce abandonment (behavior-change literature commonly contrasts guilt messaging vs. self-efficacy—see the gamification review above for effectiveness metrics and ethics).

## Privacy: public profile badges

- **Principle:** Only **user-selected** badge slugs appear on a public profile; the full unlock list remains private to the owner. Others see badges only if `profiles.show_care_badges_on_profile` is true **and** the badge slug is in `profiles.public_care_badge_slugs`, backed by a row in `pet_care_badge_unlocks` (RLS policy on showcase read).
- **Data minimization:** Onboarding and preferences live in `pet_care_onboarding` (RLS: pet owner only), **not** on the globally readable `public.pets` table—avoiding accidental leakage of health-related questionnaire answers to all authenticated users.

## Stitch design (reference)

- **Stitch project:** `PetSphere Pet Care 2026` — `projects/14818157852263477369` (mobile “Care Diary” screen + “Amber & Oat” theme). Screenshot and HTML export are available in the Stitch UI for that project. Generated in the same session as this document.

## Implementation alignment (this repo)

- **Backend:** Migrations add `pet_care_onboarding`, `pet_care_gamification`, `care_badge_definitions`, `pet_care_badge_unlocks`, and profile columns for public showcase. See `supabase/pet_care_gamification_onboarding_v1.sql` and second migration in Supabase.
- **Mobile:** `PetCareScreen` tabs, onboarding route, `care_gamification_logic.dart` for idempotent point/streak/badges, `match_pet_profile_screen` for public “Care highlights” row.

---

## Implementation notes (2026-04-27)

- **Custom checklists** — Storing `use_custom_checklist` + `custom_tasks[]` in `pet_care_onboarding.data` follows common product guidance: break setup into one idea per step, use defaults with optional personalization, and keep quick one-tap logging so habits stick (Zigpoll pet-app UX overviews, e.g. [pet health tracking + onboarding](https://www.zigpoll.com/content/how-can-i-design-an-intuitive-app-interface-that-encourages-pet-owners-to-regularly-update-their-pet's-health-records-and-care-routines) — general UX, not medical advice).
- **Scoring** — Idempotent “earn up to 10 / day” with `daily_point_award_date` + `daily_point_award_accrued` (no point clawback on uncheck) mirrors transparent XP-style caps described in common habit/XP writeups (e.g. [Gamification Habit Building — XP / caps](https://goalsandprogress.com/gamification-habit-building-system-guide/)). Partial days use 2 points per task checked; a full “care day” (existing `isCompleteForStreak`) reaches 10.
- **Week mask** — Mon–Sun strip shows `week_completed_mask` (bits 0=Mon..6=Sun). Streak UIs in consumer apps often use a week row or activity grid; we kept a minimal row aligned with `AppTheme` (see e.g. heatmap/weekly activity patterns in [shadcn stats patterns](https://www.shadcn.io/blocks/stats-calendar-heatmap-month) for the general “week-at-a-glance” idea, not a Flutter dependency).
- **Totals** — Lifetime total remains `pet_care_gamification.total_care_points` (cumulative); a ~7 day client window is only for the diary and badge helpers that need recent rows. The `first_log` badge also unlocks if `totalCarePoints` is already positive so older users are not stuck after seven days of history.
- **Pets RLS** — `supabase/migrations/20260427120000_pet_care_scoring_and_pets_select_rls.sql` replaces open `SELECT` on `public.pets` with a union of: owner, `is_breeding_listed`, posts/stories, chat threads, match requests, and follows, so feed/discovery/messages keep working. Apply on Supabase and re-run the Security/Performance advisors.

## Follow-up ideas (not implemented)

- Server-side “streak freeze” or rest-day policy (PawTrack-style) would need product rules and extra columns. See marketing-style comparison on [Paw Track](https://rushabhjsoni.github.io/pawtrack/) for industry feature expectations (informational; not an endorsement).
- Deeper 30-day challenge should read more than 7 days of logs or use a single source of truth in SQL to avoid under-counting on the client.
