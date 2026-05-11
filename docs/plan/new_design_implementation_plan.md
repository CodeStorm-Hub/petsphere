# PetFolio UI/UX & Redesign Implementation Plan

## 1. Design System Foundation (Completed & Verified)
*   **Color Palette Migration:** Changed from Amber (#D4845A) to Vibrant Blue (#2563EB).
*   **Typography:** Migrated from Playfair/DM Sans to modern, highly readable **Inter**.
*   **Design Tokens:** Introduced `PetFolioShadows` for cards, buttons, and hover-lift states to achieve a premium, layered UI feel.
*   **Stitch MCP Setup:** Generated design system and synced with the backend (`PetFolio` project).

## 2. Identity & Profile Restructuring (Phase 2 - Current)
Based on the UX Audit, the profile architecture was pet-centric instead of owner-centric. This phase implements the true structure.
*   [x] Create `owner_profile_screen.dart` to serve as the new Profile Tab root.
*   [x] Create `manage_pets_screen.dart` for multi-pet listing and selection.
*   [x] Create `active_pet_switcher_modal.dart` allowing owners to quickly toggle contexts.
*   [ ] Adjust routing in `router.dart` so the Profile tab points to the owner, and pets sit under `/pet/:id`.
*   [ ] Verify the bottom navigation tab directs to `OwnerProfileScreen`.

## 3. Empty States & User Guidance (Phase 3)
*   **Home/Feed:** Design a compelling empty state if the user follows no one and has no posts. Prompt them to "Find Pets Nearby" or "Add a Pet".
*   **Discovery:** Handle "Failed to load matches" with a friendly error state and a retry mechanism or filter reset option.
*   **Marketplace:** Create a robust empty state for empty categories or searches, suggesting popular tags.

## 4. Feature Completion & Missing Screens (Phase 4)
*   **Auth Enhancements:** Add "Forgot Password" UI, email verification waiting screen, and prepare for OAuth (Google/Apple) true implementation instead of "coming soon" snackbars.
*   **Settings Screen Expansion:** Expand `settings_screen.dart` with dedicated tiles for Account, Privacy, Notifications, Care Data, and Security.
*   **Missing Features:**
    *   Setup the Notification Preferences pane.
    *   Add robust blocking/reporting safety flows for profiles and chats.
    *   Build out seller dashboards and return request UI in the Marketplace.

## 5. Responsive & Adaptive Layout Improvements
*   Implement `LayoutBuilder` across major feed grids to adjust cross-axis count dynamically based on the width.
*   Use a `NavigationRail` alongside the `BottomNavigationBar` for tablet/web support.
*   Constrain max-widths for reading and content authoring on wide screens (800px max width).

## 6. Testing & Quality Assurance
*   Update driver and integration tests to ensure the new owner profile tab does not fail existing CI/CD.
*   Validate `48x48` logical pixel minimum touch targets across all new interactive elements.
*   Add semantic labels for screen readers across the new Switcher Modal and Owner Statistics panel.
