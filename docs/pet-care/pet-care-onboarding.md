# Pet Care onboarding: questions → recommendations

## Question set (per pet, stored in `pet_care_onboarding.data` as JSON)

| Key | UI options | Use in-app |
| --- | --- | --- |
| `species` | Dog, Cat, Bird, Rabbit, Other | Reconcile with `pets.animal_type` for copy; nudge if mismatch. |
| `age_band` | puppy_kitten, adult, senior | Softer nudges for young/old; more rest emphasis for senior. |
| `activity` | low, moderate, high | Checklist encouragement tone (`care_personalization.dart`). |
| `diet_type` | kibble, mixed, raw, home_cooked, prescription | Feeding tab diet hints. |
| `health_focus` | none, weight, allergy, dental, joint | Suggested Health-tab priorities (copy only; not diagnosis). |
| `multi_pet_home` | bool | Add multi-pet stress/reduction nudge in daily checklist. |

`completed_at` is set when the user taps **Save & return** on `PetCareOnboardingScreen`.

## How answers map to experience

- **Routines and tasks:** The daily checklist still uses `DailyTask.defaults` in `pet_care_log_model.dart`; future work can materialize custom tasks from `activity` + `health_focus`. The **nudge** line under “Daily Checklist” already reflects `activity` and `multi_pet_home`.
- **Diet hints:** The Feeding tab shows one line from `careFeedingHint()` from diet type.
- **Health (tab):** Existing medications, weight, etc.; onboarding does not replace medical records.
- **Activities / enrichment:** Research doc links enrichment categories; the app can extend tips later using `age_band` + `species` without schema changes (JSON is flexible).

## Routes

- `/pet_care_onboarding?petId=<uuid>` — opened from the Pet Care banner or manually.

## Privacy

- Data is in **`pet_care_onboarding`**, RLS-locked to the pet **owner** only (see `docs/pet-care-review.md`).
