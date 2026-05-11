---
name: Modern Pet Social
colors:
  surface: '#faf8ff'
  surface-dim: '#d2d9f4'
  surface-bright: '#faf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f3ff'
  surface-container: '#eaedff'
  surface-container-high: '#e2e7ff'
  surface-container-highest: '#dae2fd'
  on-surface: '#131b2e'
  on-surface-variant: '#434655'
  inverse-surface: '#283044'
  inverse-on-surface: '#eef0ff'
  outline: '#737686'
  outline-variant: '#c3c6d7'
  surface-tint: '#0053db'
  primary: '#004ac6'
  on-primary: '#ffffff'
  primary-container: '#2563eb'
  on-primary-container: '#eeefff'
  inverse-primary: '#b4c5ff'
  secondary: '#006686'
  on-secondary: '#ffffff'
  secondary-container: '#7ed4fd'
  on-secondary-container: '#005b78'
  tertiary: '#ad0033'
  on-tertiary: '#ffffff'
  tertiary-container: '#d22348'
  on-tertiary-container: '#ffecec'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dbe1ff'
  primary-fixed-dim: '#b4c5ff'
  on-primary-fixed: '#00174b'
  on-primary-fixed-variant: '#003ea8'
  secondary-fixed: '#c0e8ff'
  secondary-fixed-dim: '#7bd1fa'
  on-secondary-fixed: '#001e2b'
  on-secondary-fixed-variant: '#004d66'
  tertiary-fixed: '#ffdadb'
  tertiary-fixed-dim: '#ffb2b7'
  on-tertiary-fixed: '#40000d'
  on-tertiary-fixed-variant: '#92002a'
  background: '#faf8ff'
  on-background: '#131b2e'
  surface-variant: '#dae2fd'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.05em
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  container-max-width: 1200px
  feed-max-width: 640px
  gutter-desktop: 24px
  gutter-mobile: 16px
  margin-desktop: 48px
  margin-mobile: 20px
---

## Brand & Style
The design system is anchored in a "Premium Social" philosophy, combining the streamlined efficiency of a professional SaaS tool with the warmth and vibrancy of a pet-focused community. It prioritizes clarity, high-quality imagery, and an effortless user flow. 

The aesthetic is **Modern/Minimalist**, leaning heavily on generous whitespace, a restricted color palette, and sophisticated depth. It avoids the cluttered "playful" tropes of traditional pet apps in favor of a clean, editorial feel that treats pet profiles with the same prestige as human-centric luxury platforms. The goal is to evoke a sense of trust, joy, and high-end curation.

## Colors
The palette is built to feel fresh and clinical yet welcoming. 
- **Primary Blue (#2563EB)** acts as the main interactive signal, used for primary actions, active states, and brand identifiers.
- **Surface (#F7FAFF)** is a very cool, tinted off-white used for the global background to provide a soft contrast against the pure white cards.
- **Surface-Container (#FFFFFF)** is reserved for the primary content vessels (cards, feeds, modals), allowing them to "pop" forward in the visual hierarchy.
- **Neutral (#0F172A)** is a deep navy used for primary text to ensure high legibility and a premium feel, avoiding the harshness of pure black.
- **Tertiary (#F43F5E)** is used sparingly for high-emotion actions like "likes" or urgent notifications.

## Typography
This design system utilizes **Inter** for all roles to achieve a systematic, utilitarian, and clean look. 

The type hierarchy is defined by tight tracking in headlines to create a "locked-in" editorial feel and generous line heights in body copy to ensure readability in social posts. **Display-lg** is reserved for high-impact marketing or profile headers. **Label-lg** uses a slight letter-spacing increase and uppercase styling for metadata and section headers to provide clear visual distinction without adding weight.

## Layout & Spacing
The layout follows a **Fixed Grid** philosophy for content discovery. 
- **The Social Feed:** Optimized for a centered 640px column to focus the user’s eye on high-quality pet imagery, mirroring premium social patterns.
- **Desktop:** A 12-column grid with 24px gutters. Sidebars for navigation and trending pets are pinned to the left and right of the central feed.
- **Mobile:** A 4-column grid with 16px gutters and 20px side margins. Elements reflow into a single-column stack.

Spacing is governed by a 4px baseline. Components should primarily use 16px (4x) and 24px (6x) increments for internal padding to maintain a spacious, "breathable" premium atmosphere.

## Elevation & Depth
Depth in this design system is created through **Ambient Shadows** with a distinct color tint. Instead of neutral grays, shadows use a low-opacity version of the Primary Blue (#2563EB).

- **Level 1 (Cards):** 0px 4px 20px rgba(37, 99, 235, 0.08). This creates a soft "lift" that makes cards appear integrated with the surface rather than floating disconnectedly.
- **Level 2 (Dropdowns/Hover):** 0px 8px 30px rgba(37, 99, 235, 0.12).
- **Level 3 (Modals):** 0px 12px 40px rgba(37, 99, 235, 0.16).

Surfaces should not use heavy borders. Interaction depth is communicated by increasing the shadow spread and slightly darkening the Primary Blue background on buttons.

## Shapes
The shape language is consistently **Rounded**, using a 0.5rem (8px) base radius. 

- **Small Components (Buttons, Chips):** 0.5rem radius.
- **Standard Containers (Feed Cards):** 1rem (16px) radius to emphasize a modern, friendly feel.
- **Large Containers (Modals):** 1.5rem (24px) radius.
- **Profile Avatars:** Always 100% circular to differentiate living beings (pets/users) from UI containers.

Interactive elements like "Like" buttons or icons should have a circular hover state to provide soft feedback.

## Components
- **Buttons:** Primary buttons are solid #2563EB with white text and 8px rounded corners. Secondary buttons use a light blue ghost style (transparent fill, 1px #2563EB border) or a subtle #F7FAFF background.
- **Feed Cards:** Pure white (#FFFFFF) backgrounds with 16px rounded corners and Level 1 soft blue shadows. Padding within cards should be a consistent 20px.
- **Inputs:** Text fields use the Surface color (#F7FAFF) as a background with a subtle 1px border in a pale blue tint. On focus, the border transitions to Primary Blue.
- **Chips/Badges:** Used for pet categories (e.g., "Dog", "Cat") or traits. These should have a light blue background (#EFF6FF) and Primary Blue text, using pill-shaped (full) rounding.
- **Action Bar:** The interaction bar under social posts (Like, Comment, Share) should use thin, high-quality outline icons that fill with color upon interaction.
- **Pet Profile Header:** A premium component featuring a large circular avatar with a subtle 4px white border, overlapping a high-resolution cover image.