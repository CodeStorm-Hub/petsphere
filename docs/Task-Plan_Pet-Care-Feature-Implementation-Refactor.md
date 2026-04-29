### Task Plan: Pet Care Feature Implementation & Refactor

Based on the audit of `lib/views/pet_care_screen.dart` and the recorded behavior in the app demonstration, the following plan outlines the steps required to transition the feature from a hardcoded mockup to a functional, state-driven system.

---

#### **Phase 1: State Management & Data Modeling**
**Goal:** Replace ephemeral local widget state with a global, pet-specific source of truth.

* **Define Care Models:** Create `PetCareLog` and `DailyTask` models to represent feeding, water intake, and checklist completion.
* **Implement Care Notifier:** Develop a `PetCareNotifier` using Riverpod to manage the state of the active pet’s logs.
* **Sync with Active Pet:** Ensure the notifier automatically switches data sets when the `activePetProvider` updates.

#### **Phase 2: Logic Refactoring (Dashboard Tab)**
**Goal:** Remove hardcoded "Magic Numbers" and bind the UI to the care state.

* **Reactive Progress Rings:** Replace hardcoded values (e.g., `0.65` for calories) with dynamic calculations: `totalConsumed / dailyGoal`.
* **Checklist Integration:** Map the `Daily Checklist` section to the `PetCareNotifier` so toggling a task updates the global completion percentage.
* **Dynamic Streak Logic:** Refactor the streak banner to calculate the actual streak based on historical log data rather than a fixed "D1-D5" loop.

#### **Phase 3: Tab Synchronization (Feeding & Health)**
**Goal:** Ensure actions in one tab are immediately reflected across the entire feature.

* **Feeding to Dashboard Link:** Bind the `Switch` in `_FeedingTab` to the `PetCareNotifier` so toggling "Breakfast" immediately updates the Calorie Ring on the Dashboard.
* **Water Intake Sync:** Update the `_DashboardTab` water ring to reflect the actual count from the `_FeedingTab` water glass selector.
* **Health Tab Data Binding:** Transition the `_HealthLogTab` from a static mockup to a dynamic view that reads from a `HealthRepository`.

#### **Phase 4: Persistence & Backend Integration**
**Goal:** Ensure data survives app restarts and persists in the database.

* **Supabase Integration:** Create a `pet_care_logs` table in Supabase to store daily activity.
* **Repository Pattern:** Implement a `PetCareRepository` to handle fetching and uploading logs.
* **Offline Support:** Utilize the existing `bootstrap_controller.dart` logic to cache care data for offline viewing.

#### **Phase 5: UX & UI Polishing**
**Goal:** Address visual inconsistencies and enhance feedback.

* **Mood Persistence:** Ensure the selected mood is saved to the daily log and visible upon returning to the screen.
* **Dynamic Goals:** Allow users to set specific calorie and water goals based on pet breed and weight rather than the hardcoded 500kcal/8 cups limit.
* **Verification:** Cross-verify that the weight tracking chart in `_HealthLogTab` correctly calculates the "vs yesterday" difference.