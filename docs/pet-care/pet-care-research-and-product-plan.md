# Pet Care: Research, Product Plan, and Implementation Notes

**PetSphere** — synthesized research (2024–2026), Stitch UI direction, database alignment, and MVP scope for **Care Diary**, **Health**, and **Feeding**, plus onboarding, tasks, streaks, points, and public profile badges.

---

## 1. Market and behavior research

### 1.1 Personalized, multi-species care

- **Species-aware profiles and tracking**: Consumer apps increasingly emphasize **per-species** (and per-breed) defaults for activity, nutrition, and health logging, not one-size-fits-all dog/cat flows. Examples: [VetGPT](https://vetgpt.app/) (multi-species health tracking and journaling), [PokiPaw](https://pokipaw.com/) (18+ species, breed-specific targets where depth allows), and [DogCat App (Play listing)](https://play.google.com/store/apps/details?hl=en_US&id=dogcat.app.android) (broad species list for medical and schedule tracking).
- **Questionnaires → recommendations**: Onboarding that captures **goals** (weight, meds, activity), **environment** (multi-pet home), and **diet** supports tailored reminders and copy without replacing veterinary advice. PerkyPet and similar position “family wellness” and expert/community context: [PerkyPet AI](https://perkypetai.com/).
- **AI-assisted interpretation** (optional roadmap): Apps like [Purrfect](https://purrfectapp.pet/) combine tracking with **breed benchmarks** and guided Q&A; useful as a **second phase** after structured data (logs, weight, vaccines) is reliable in-app.

### 1.2 Nutrition, weight, and routines

- Daily **calorie and water** targets adjusted per pet match how standalone trackers and vet-led weight programs operate; pairing **feeding logs** with **weight history** is a standard adherence pattern (see Play-store descriptions and feature lists for [DogCat App](https://play.google.com/store/apps/details?hl=en_US&id=dogcat.app.android) and [PokiPaw](https://pokipaw.com/)).
- **Routines** (AM/PM meals, meds, walks) map cleanly to **checklists** and calendar-style reminders; PetSphere’s `pet_care_logs.tasks` JSON and meal toggles align with this.

### 1.3 Gamification: streaks, points, challenges, badges

- **Streaks and achievements** improve consistency when framed as support, not pressure. Trade press and program descriptions highlight points, quests, and badges tied to **walks and daily goals**: [Gamified pet care — Digital Journal (2024)](https://www.digitaljournal.com/pr/news/binary-news-network/gamified-pet-care-rewards-11848872.html); [Biscuit case study — White Label Loyalty](https://whitelabel-loyalty.com/case-studies/biscuit) (quests, badges, XP, high engagement at scale).
- **Product patterns**: (1) **Daily completion** → streak; (2) **Weekly mask / full week** → badge; (3) **30-day challenge** counter; (4) **Lifetime points**; (5) **Public subset** of badges on profile for social proof — implemented in PetSphere via `profiles.public_care_badge_slugs` and `pet_care_badge_unlocks`.
- **General engagement evidence**: Gamified “digital pet” mechanics increased app engagement in a **JMIR (2024)** smoking-cessation RCT — supporting the principle that lightweight game loops can reinforce habit apps when ethically applied: [Medical Xpress summary](https://medicalxpress.com/news/2024-11-digital-pet-game-cessation-app.html) (DOI: 10.2196/57839).

### 1.4 Positioning for PetSphere MVP

| Pillar | MVP | Next |
|--------|-----|------|
| Care Diary | Daily log, tasks, mood, streak UI, points + 30-day counter | Species-specific default tasks from onboarding |
| Health | Weight, symptoms, vaccines, vet appointments (existing) | Export PDF, richer clinical timelines |
| Feeding | Meals + water vs goals | Barcode / brand presets, vet diet flags |
| Onboarding | Per-pet questionnaire → `pet_care_onboarding.data` | Recommendation engine / optional AI |
| Social | Up to 3 badges on public profile | Leaderboards only if aligned with brand |

---

## 2. Supabase schema (authoritative in production)

The **petsphere** project already includes (RLS-aligned, no `user_metadata` for authz):

| Table | Role |
|-------|------|
| `pet_care_logs` | One row per pet per day: feeding, water, `tasks` jsonb, mood, goal snapshot |
| `pet_care_onboarding` | Per-pet `data` jsonb + `completed_at` |
| `pet_care_gamification` | Per pet: `total_care_points`, `best_streak_days`, weekly bitmask, 30-day challenge fields |
| `care_badge_definitions` | Catalog keyed by **`slug`** (not `id`) |
| `pet_care_badge_unlocks` | Unlock rows per `user_id`, `pet_id`, `badge_slug` |
| `profiles` | `public_care_badge_slugs`, `show_care_badges_on_profile` for showcase |

**Cleanup applied**: duplicate empty table `owner_care_onboarding` was removed from the remote project after a mistaken migration attempt; the app uses **`pet_care_onboarding`** (pet-scoped) only.

---

## 3. Stitch UI / UX direction

**Project**: PetSphere App Redesign — Stitch `projectId` **`14543694831110821666`**.  
**Session** (generation): **`16050730833400991797`**.

Generated **mobile** screens (screenshot + HTML export in Stitch):

| Screen title | Stitch `screen` resource id | Screenshot (export URL) |
|--------------|----------------------------|-------------------------|
| Onboarding Questionnaire | `projects/14543694831110821666/screens/0ff8fe30cf6f4abeadaf3769c4dc85ad` | [PNG preview](https://lh3.googleusercontent.com/aida/ADBb0uiiGcxWwRNA14O14HN4VlMl66MnZiM6hLvoEKKe7IddJanVBH4dijkp7XHyEv2LGBOtha0RIKSaMI3CI0b5ZmQWtfrPdl1VYLxMeWWXXACEnD8noUS5d2JHTp48dnwbw2u6k5TJKonqFqRzIMzWgC_WIL8iTo0mS47fy-a6FRjCvRUvL1SZN28ES0znxMPLW7tMdgjpXKMvVRrrHfMNnUtBBD9h6VaPqzGdORZWEriMvVmRz-Ad173vGvE) |
| Care Dashboard | `projects/14543694831110821666/screens/669ea88d2f00430183fe8ed1ff8a1d36` | [PNG preview](https://lh3.googleusercontent.com/aida/ADBb0uj_NCKDOGyqdbJoNmd53LRYsJet42aMvfSs9t4WkKvYzaySuH32gS8J3Ho7R3L0hdfkRGAMB-8yFxhaASqWEm2eZwbZ7e3euTaqboy9xmCeBSaiggINOZTsylTdr0rRdzB06R3bHeoI_CftZXX_3F0JVz277d317Vfgeax0qJXSMkfCuoO_G0chugNejx3HNII5pZ9qXBaCYwFH_lyHZxRwBVzq_ING-_jdmF2gq5kQXcRzE6FdA-2ZVaMu) |
| Daily Tasks | `projects/14543694831110821666/screens/fbe20995886a4fc4a9c3d9093d6a5b21` | [PNG preview](https://lh3.googleusercontent.com/aida/ADBb0ugOgFrV3eODqCctY9cjgpQwD1ZHaMuQIgVyJ_xU2VVTrE4drZiV4ywP0ayuzjp70fLMCou_raGugXF6ARer0yNDRKYlS6TGzDONgFavdQul9VPoRkbQSP8C9UbfaH2JhKV8v3OSeQTulkIo5sbGGxUmnn8I2qfaSbN5x6gTQ1Ac0_XzxFyryDWVBNeVa9Mr4YmKmw2MZs1Sy6wHZgcTB5bjcwdQHkA8KHD7bn6gt9aGE5bOCP7EWsaij3GT) |
| Achievements & Badges | `projects/14543694831110821666/screens/2e5daae4dbd2489ba826bcf14695390b` | [PNG preview](https://lh3.googleusercontent.com/aida/ADBb0ug_esPiBvvRl1Fi4Z21fdnQmPGrIp4SyGtQcTJcLQnnq39NjAnq5O8dkmOicHsWQ99lauFU_DJicAWraMC0h06xtaGCUzB5ZYFhKILbLYeFIaq_rHawvbaDDRLtSNd8cWEu-JSc2h1tbX4oZY84QEM0aUjrZfH7hERulmIjhrXPsAkvnMI3SK-cU6_qL0AEu1CX-AwoW_SnQOHEEZ-tXmq27fbgZs3Rzm4xqHQ2OZSqG3bCB8PHmLiqGnUZ) |

**Design system**: “The Nurtured Nest” / **The Nurtured Atelier** — Plus Jakarta Sans, terracotta + sage, rounded cards, minimal hard borders (tonal surfaces). Aligns with existing `AppTheme` warm accents.

---

## 4. Flutter app wiring (current)

- **Routes**: `/pet_care`, `/pet_care_onboarding?petId=…`
- **State**: `PetCareNotifier` loads logs, onboarding, gamification, unlocks; `_flushTodayLog` → `_syncCareRewards` → `CareGamificationLogic` + `pet_care_badge_unlocks`
- **Profile**: `PublicCareBadgesRow` resolves showcase badges via `publicCareBadgeShowcaseProvider` on **My Account** and **Match** profile owner tab

---

## 5. What remains (optional)

- **Per-task micro-points** (distinct from “day complete” points) if product wants faster feedback loops — may need a small migration (e.g. last partial-credit date) to avoid double counting.
- **Weekly challenge UI** surfacing `week_completed_mask` as Mon–Sun chips (data already computed server-side in logic).
- **Vet triage / health vault** screens (Stitch suggestions in session output).

---

## 6. Running checks locally

```bash
cd g:\Pet\petsphere
dart format lib test
flutter analyze lib test
flutter test test/care_gamification_logic_test.dart
```

---

*Document version: April 2026.*
