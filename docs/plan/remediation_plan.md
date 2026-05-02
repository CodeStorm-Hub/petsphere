# Implementation Plan: PetSphere UI/UX Remediation

This plan outlines the steps to implement the findings of the [QA_UX_Audit_Report.md](file:///g:/Pet/petsphere/QA_UX_Audit_Report.md) while adhering to the [flutter-apply-architecture-best-practices](file:///g:/Pet/petsphere/.agents/skills/flutter-apply-architecture-best-practices/SKILL.md) and other referenced workflows.

## 🗺️ Application Mapping

### Core Functionalities
- **Authentication**: Managed via Supabase Auth (`lib/controllers/auth_controller.dart`).
- **Social Feed**: Discovery of pet posts and stories (`lib/views/home_screen.dart`).
- **Discovery (Breeding/Adoption)**: Card-based swiping and filtering (`lib/views/discovery_screen.dart`).
- **Pet Care**: Wellness, feeding, and nutrition goal tracking (`lib/views/pet_care_screen.dart`).
- **Marketplace**: Product grid, detail, and cart system (`lib/views/marketplace_screen.dart`).
- **Messaging**: Real-time chat threads and notifications (`lib/views/chat_screen.dart`).
- **Gamification**: Badges and care points for pet care activities (`lib/views/gamification_screen.dart`).

### Technical Stack
- **State Management**: Riverpod (`flutter_riverpod`).
- **Routing**: Declarative routing with `go_router`.
- **Database/Auth**: Supabase (`supabase_flutter`).
- **UI System**: Material 3 with custom Glassmorphism/Amber Whisker styling.

---

## 🏗️ Phase 1: Architecture & Routing Foundation

### 1.1 Architecture Realignment
Migrate the existing structure to the recommended layered approach:
- [ ] Move repositories to `lib/data/repositories/`.
- [ ] Move models to `lib/data/models/`.
- [ ] Create `lib/data/services/` for raw API/Supabase wrappers.
- [ ] Organize UI into `lib/ui/features/`.

### 1.2 Declarative Routing Upgrade
- [ ] Refactor `lib/utils/routes.dart` to use `StatefulShellRoute`.
- [ ] Ensure persistent bottom navigation state.

---

## 🚀 Phase 2: Sprint 1 - High Priority & Critical Fixes

### 2.1 Content Moderation (BUG-009) 🔴
- [ ] Implement client-side profanity filtering for message previews in `lib/views/messages_list_screen.dart`.
- [ ] Add "[Message hidden]" logic for detected violations.

### 2.2 Login Experience (BUG-001, BUG-002) 🟠
- [ ] Fix email truncation by optimizing `TextEditingController` initialization in `lib/views/login_screen.dart`.
- [ ] Implement keyboard-aware layout using `SingleChildScrollView` and `resizeToAvoidBottomInset`.

### 2.3 Shop Feedback (BUG-007, BUG-008) 🟠
- [ ] Add `SnackBar` confirmation after "Add to Cart" in `lib/views/product_detail_screen.dart`.
- [ ] Expand product card hit targets to cover the entire card area in `lib/views/marketplace_screen.dart`.

---

## 🛠️ Phase 3: Sprint 2 - UX Refinement

### 3.1 Pet Care Precision (BUG-013, BUG-014) 🟡
- [ ] Add `+/-` precision buttons to sliders in `lib/views/care_goal_editor_modal.dart`.
- [ ] Increase hit-box size for "Edit Goals" link in `lib/views/pet_care_screen.dart`.

### 3.2 Navigation & Discoverability (BUG-011, BUG-015, BUG-003, BUG-005) 🟡
- [ ] Add labels/tooltips to the Profile sign-out icon.
- [ ] Make chat headers tappable to view user profiles.
- [ ] Improve story row discoverability.
- [ ] Update empty state copy in Discovery.

---

## ♿ Phase 4: Sprint 3 - Accessibility & Polish

- [ ] Add `Semantics` labels to all action icons (Like, Comment, Share).
- [ ] Add `semanticLabel` to all network and asset images.
- [ ] Handle location permission edge cases in Discovery.

---

## 🧪 Phase 5: Validation
- [ ] Execute manual QA check on Android Emulator.
- [ ] Run `flutter test` for critical logic.
- [ ] Update [QA_UX_Audit_Report.md](file:///g:/Pet/petsphere/QA_UX_Audit_Report.md) with fix statuses.
