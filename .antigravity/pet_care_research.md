# PetSphere Pet Care — Comprehensive Research Documentation

## 1. Pet Nutrition Science

### Calorie Calculation Formulas

#### Resting Energy Requirement (RER)
- **Dogs:** `RER = 70 × (body_weight_kg)^0.75`
- **Cats:** `RER = 30 × (body_weight_kg) + 70`
- For pets < 2kg or > 45kg, use the exponential formula for all species

#### Maintenance Energy Requirement (MER) Multipliers

| Life Stage / Activity | Multiplier |
|---|---|
| Sedentary / Very Senior | 1.0 – 1.2 |
| Neutered Adult (moderate) | 1.4 – 1.6 |
| Intact Adult (moderate) | 1.6 – 1.8 |
| Active / Working Dog | 1.6 – 2.0+ |
| Puppy / Kitten (growing) | 1.75 – 2.0 |
| Overweight (weight loss) | 1.0 (at ideal weight) |

#### Example Calculation
- 30 lb (13.6 kg) adult moderate dog: RER = 70 × 13.6^0.75 ≈ 490 kcal → MER = 490 × 1.4 = **686 kcal/day**

### Key Factors
- **Body Condition Score (BCS):** 1-9 scale; 4-5 is ideal
- **Treats:** Should not exceed 10% of daily caloric intake
- **Use ideal weight** for calculations, not current weight if over/underweight

### Species-Specific Diet Types
- **Dogs:** Kibble, wet, raw (vet-guided), home-cooked, prescription
- **Cats:** High-protein, taurine-essential, moisture-important
- **Birds:** Species-specific seed/pellet ratios, fresh produce
- **Rabbits:** Unlimited timothy hay, limited pellets, fresh greens

---

## 2. Exercise Requirements by Species

### Dogs
| Category | Daily Exercise |
|---|---|
| High-Energy (Border Collie, Husky, GSD) | 1.5–2+ hours vigorous |
| Terriers | 60+ minutes |
| Medium breeds (moderate) | 45–90 minutes |
| Giant breeds (Great Dane) | 30–60 min low-impact |
| Brachycephalic (Pug, Bulldog) | 30–60 min short bouts |
| Toy/Companion | 20–30 minutes |
| Puppies | Short, frequent sessions |
| Seniors | Low-impact, adjusted |

### Cats
- **Total:** 20–45 minutes/day
- **Pattern:** 2–3 intense 10–15 min play sessions (dawn/dusk)
- **Activities:** Wand toys, climbing, puzzle feeders

### Rabbits
- **Minimum:** 3–4 hours daily free-roaming
- **Pattern:** Crepuscular (dawn/dusk most active)
- **Activities:** Hopping, running, jumping, digging, foraging

### Birds
- **Outside cage:** 1–2 hours daily
- **Activities:** Supervised flight, climbing, foraging toys

---

## 3. Personalization Onboarding Questions

### Tier 1: Essential (Must-Have at Setup)
1. **Species** — Dog, Cat, Bird, Rabbit, Other
2. **Breed** — Free-text or dropdown by species
3. **Age / Date of Birth** — For life-stage calculations
4. **Weight** — For calorie/water calculations
5. **Gender + Spayed/Neutered** — Affects MER multiplier
6. **Activity Level** — Low / Moderate / High

### Tier 2: Personalization (Progressive — Next Visit)
7. **Personality** — High-energy, Couch potato, Anxious, Social butterfly, Independent
8. **Living Situation** — Apartment, House with yard, Farm
9. **Multi-pet household** — Yes/No + how many
10. **Known Health Conditions** — Allergies, joint issues, dental, weight management
11. **Diet Type** — Kibble, wet, raw, home-cooked, prescription
12. **Feeding Schedule** — 1x, 2x, 3x daily + times

### Tier 3: Goals (Owner Preferences)
13. **Primary Care Goal** — Weight management, Longevity, Training, Socialization
14. **Reminder Preferences** — Push notifications, gentle nudges, aggressive
15. **Exercise Preferences** — Walking, running, swimming, indoor play
16. **Grooming Frequency** — Daily, weekly, monthly

### Design Principles
- **Progressive disclosure** — Don't overwhelm; ask essentials first
- **Conversational tone** — "Tell us about your furry friend!"
- **Dynamic branching** — Different questions for dogs vs. cats
- **Skip option** — Allow "Answer later" for non-critical questions
- **Value explanation** — Show why each question matters

---

## 4. Gamification System Design

### Core Mechanics

#### Streaks (Daily Engagement)
- Track consecutive days of completing care tasks
- **Streak freeze** — Allow 1-2 "free passes" per week to prevent frustration
- **Low barrier** — Completing ANY task counts toward keeping the streak
- **Visual feedback** — Fire emoji, animated counter, celebratory animations

#### Points System
- **Task completion:** 2 points per task checked
- **Full day completion:** 10 points (bonus for completing all)
- **Streak bonuses:** Multiplier at 3, 7, 14, 30 day milestones
- **Daily cap:** 10 points/day to prevent gaming

#### Achievement Badges (Milestone Recognition)

| Badge | Trigger | Emoji | Category |
|---|---|---|---|
| First Steps | Complete first care day | 🐾 | Onboarding |
| 3-Day Streak | 3 consecutive days | 🔥 | Streak |
| Week Warrior | 7 consecutive days | ⚡ | Streak |
| Fortnight Force | 14 consecutive days | 💪 | Streak |
| 30-Day Champion | Complete 30-day challenge | 🏆 | Challenge |
| Century Club | Earn 100 care points | 💯 | Points |
| 500 Club | Earn 500 care points | 🌟 | Points |
| Health Hero | Log all vitals in a week | 🩺 | Health |
| Nutrition Ninja | Track feeding for 7 days | 🥗 | Feeding |
| Hydration Station | Meet water goals 7 days | 💧 | Feeding |
| Perfect Week | Complete all tasks Mon-Sun | 🗓️ | Weekly |
| Vet Ready | Schedule & attend vet visit | 🏥 | Health |
| Weight Watcher | Log weight 4 weeks running | ⚖️ | Health |
| Dental Devotee | Log dental care 4x/month | 🦷 | Health |
| Mood Tracker | Log mood 7 consecutive days | 😊 | Engagement |
| Social Star | Share 3 badges on profile | ⭐ | Social |
| Multi-Pet Master | Maintain streaks for 2+ pets | 🎭 | Multi-pet |

### Design Principles (Inspired by Duolingo/Fitbit)
1. **Encouraging, not punishing** — Never penalize; totals never decrease
2. **Grace days / streak freezes** — Prevent anxiety from missed days
3. **Celebration animations** — Confetti, haptic feedback on milestones
4. **Social sharing** — Badge showcase on public profile (max 3)
5. **Tiered progression** — Bronze → Silver → Gold → Platinum levels
6. **AI-driven nudges** — Personalized encouragement based on patterns

---

## 5. Species-Specific Personalized Recommendations

### Dogs
- **Puppy:** More frequent meals (3-4x/day), shorter exercise, socialization tasks
- **Adult:** 2x daily feeding, breed-appropriate exercise, dental care
- **Senior:** Joint supplements tracking, reduced calories, gentle walks

### Cats
- **Kitten:** High-protein diet tracking, play sessions, litter monitoring
- **Adult:** Indoor enrichment activities, weight management, dental
- **Senior:** Kidney health monitoring, reduced activity, hydration focus

### Birds
- **Social time tracking** — Daily interaction minutes
- **Cage cleaning** schedule reminders
- **Foraging enrichment** activities

### Rabbits
- **Hay intake** tracking (should be unlimited)
- **Free-roam time** logging
- **Nail trimming** reminders

---

## 6. Multi-Pet Management Strategies
- **Separate profiles** with distinct dashboards
- **Aggregate view** — "All pets" summary
- **Pet switcher** — Quick toggle between active pets
- **Shared tasks** — Some tasks apply to household (e.g., "Clean water bowls")
- **Individual streaks** — Each pet has its own streak/points
- **Cross-pet badges** — Special badges for multi-pet consistency

---

## 7. Water Intake Guidelines

| Pet Type | Daily Water (General) |
|---|---|
| Dogs | ~1 oz per pound of body weight |
| Cats | 3.5–4.5 oz per 5 lbs body weight |
| Rabbits | 50–100 ml per kg body weight |
| Birds | Variable by species; ensure always available |

---

## 8. Key Implementation Priorities
1. **Enhanced Onboarding** — More questions for better personalization
2. **Smart Calorie Calculator** — RER/MER-based instead of static defaults
3. **Species-Specific Task Templates** — Different defaults for different pets
4. **Expanded Badge System** — 15+ badges covering all care areas
5. **Streak Freeze Feature** — Prevent streak loss anxiety
6. **Personalized Recommendations Engine** — Based on onboarding answers
7. **Enhanced Feeding Tab** — Meal planning, portion calculator, treat tracking
8. **Activity/Exercise Tracking** — Species-appropriate exercise logging
9. **Weekly/Monthly Reports** — Progress summaries
10. **Public Profile Badge Showcase** — Already partially implemented
