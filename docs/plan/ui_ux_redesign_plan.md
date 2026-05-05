# Pet Care UI/UX Redesign & Goal Editing Plan

Based on extensive online research regarding premium 2026 mobile app design and health-warning UX, here is the blueprint for refining the Pet Care user story and UI/UX.

## 1. UI/UX Paradigm Shift (Visuals)
We will transition the Pet Care screens to a **"Premium & Dynamic"** aesthetic:
- **Glassmorphism & Layered Depth:** Cards will have subtle translucency and gradients rather than flat, stark white backgrounds, giving a "liquid glass" look.
- **Bento Grid Layouts:** We will restructure the Care Diary and Health tabs into clean, asymmetrical grids that surface the most critical actionable insights without scrolling.
- **Micro-Animations:** Progress rings, task completions, and tab transitions will feature fluid, physics-based animations to make the UI feel "alive".
- **Dynamic Context:** The top banner won't just be static; it will dynamically change based on whether the pet needs immediate setup, has tasks pending, or has hit their goals.

## 2. Refined User Story Flow
1. **Onboarding:** The user adds a pet and completes the 4-step wizard.
2. **AI Personalization:** The app generates daily tasks, calorie budgets, water needs, and exercise requirements based on veterinary formulas (RER/MER) applied to the user's specific answers.
3. **Daily Management (The Redesign):** 
   - The user opens the **Care Diary** (Bento Grid) to see today's snapshot: a beautiful progress ring for tasks, streak visualizer, and next up activities.
   - The **Feeding Tab** acts as a nutrition hub, breaking down meals vs. treats with an intuitive 10% budget warning system.
   - The **Health Tab** tracks weight, vaccines, and vet visits in an easily scannable format.
4. **User Empowerment & Safeguards (New Feature):** 
   - The user can tap an "Edit Goals" button on the dashboard or feeding tab.
   - They are presented with a slider/input to manually override the AI-generated Calorie, Water, and Exercise goals.
   - **Crucial Warning System:** If the user sets calories < 70% or > 130% of the calculated veterinary baseline, a stark, empathetic warning appears: *"Warning: This calorie target deviates significantly from the recommended baseline. Rapid weight loss/gain can lead to serious health complications like hepatic lipidosis or joint stress. Please consult your vet."* This requires explicit confirmation to save.

## 3. Implementation Steps
- **Step A:** Build the `GoalEditorModal` widget in `lib/views/` to allow editing of Daily Calorie, Water, and Activity goals. Integrate the real-time calculation logic to show warnings if inputs deviate from `CareCalculator` baselines.
- **Step B:** Overhaul `_DashboardTab` (Care Diary) in `pet_care_screen.dart` to use a Bento Grid layout using `Wrap` or `StaggeredGridView` style layouts. Update task checklist items to look like premium, floating cards.
- **Step C:** Overhaul `_FeedingTab` to use premium gradients, glassmorphism cards, and fluid layouts for the calorie ring and meal toggles.
- **Step D:** Update `HealthTab` to match the new UI/UX aesthetic, ensuring consistency across all three tabs.
- **Step E:** Connect the new `GoalEditorModal` to the backend via `PetCareController` mutations (`setDailyGoals`).
