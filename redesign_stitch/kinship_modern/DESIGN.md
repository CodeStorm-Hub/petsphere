---
name: Kinship Modern
colors:
  surface: '#faf8ff'
  surface-dim: '#d9d9e5'
  surface-bright: '#faf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f3fe'
  surface-container: '#ededf9'
  surface-container-high: '#e7e7f3'
  surface-container-highest: '#e1e2ed'
  on-surface: '#191b23'
  on-surface-variant: '#434655'
  inverse-surface: '#2e3039'
  inverse-on-surface: '#f0f0fb'
  outline: '#737686'
  outline-variant: '#c3c6d7'
  surface-tint: '#0053db'
  primary: '#004ac6'
  on-primary: '#ffffff'
  primary-container: '#2563eb'
  on-primary-container: '#eeefff'
  inverse-primary: '#b4c5ff'
  secondary: '#0058be'
  on-secondary: '#ffffff'
  secondary-container: '#2170e4'
  on-secondary-container: '#fefcff'
  tertiary: '#943700'
  on-tertiary: '#ffffff'
  tertiary-container: '#bc4800'
  on-tertiary-container: '#ffede6'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dbe1ff'
  primary-fixed-dim: '#b4c5ff'
  on-primary-fixed: '#00174b'
  on-primary-fixed-variant: '#003ea8'
  secondary-fixed: '#d8e2ff'
  secondary-fixed-dim: '#adc6ff'
  on-secondary-fixed: '#001a42'
  on-secondary-fixed-variant: '#004395'
  tertiary-fixed: '#ffdbcd'
  tertiary-fixed-dim: '#ffb596'
  on-tertiary-fixed: '#360f00'
  on-tertiary-fixed-variant: '#7d2d00'
  background: '#faf8ff'
  on-background: '#191b23'
  surface-variant: '#e1e2ed'
typography:
  display:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: '700'
    lineHeight: '1.1'
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: '1.2'
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: '1.2'
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: '1.3'
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: '1.6'
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.6'
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: '1.2'
    letterSpacing: 0.05em
  caption:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: '1.4'
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  xs: 0.5rem
  sm: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  container-max: 1280px
  gutter: 24px
---

## Brand & Style

The design system is anchored in a **Premium Corporate-Modern** aesthetic, tailored specifically for the emotional yet organized world of pet care. It balances the reliability of a health platform with the vibrancy of a social network. The UI should feel airy, trustworthy, and effortlessly sophisticated.

The visual language utilizes heavy whitespace and a refined "light-mode-first" approach to ensure clarity and focus. It borrows elements of glassmorphism—specifically in navigation and overlays—to add depth without clutter. The goal is to evoke a sense of calm efficiency for pet owners while maintaining a playful energy through high-contrast accents and fluid motion.

## Colors

The palette is centered on a high-energy "Vibrant Blue" that signals both technology and trust. 

- **Primary:** The #2563EB blue is the core of the identity. Use the `accent_gradient` for primary call-to-action buttons and hero highlights to create a sense of premium depth.
- **Background:** The #F7FAFF tint is essential. It provides a softer, more modern canvas than pure white, reducing eye strain while making pure white card surfaces "pop" against the background.
- **Neutrals:** Use Slate-based grays (#1E293B for headings, #64748B for body) to maintain a cool, cohesive temperature throughout the UI. Avoid pure black.
- **Semantic Colors:** Use a soft emerald for health status and a warm amber for pet reminders, ensuring they harmonize with the cool blue primary tone.

## Typography

The design system utilizes **Inter** exclusively to achieve a clean, systematic feel. The type hierarchy relies on significant weight contrasts—pairing heavy, tight-tracked bold headers with spacious, legible regular-weight body text.

- **Headings:** Use bold weights (600-700) with slight negative letter spacing for a "designed" look.
- **Body:** Stick to 16px as the baseline for readability. Ensure a generous line height (1.6) to support the "premium and airy" brand promise.
- **Labels:** Use uppercase for utility labels (e.g., pet categories, status tags) to differentiate from interactive text.

## Layout & Spacing

This design system follows a **12-column fluid grid** for desktop and a **4-column grid** for mobile. 

- **The 8px Rhythm:** All spacing must be multiples of 8px (or 4px for tight internal component spacing). 
- **Whitespace:** Prioritize "Generous Whitespace." Margins between major sections should lean toward the `xl` (48px) range to allow the pet photography to breathe.
- **Safe Areas:** Maintain a minimum 24px gutter on mobile devices to prevent content from touching the screen edges, reinforcing the premium feel.

## Elevation & Depth

Hierarchy in this design system is created through **Ambient Shadows** and **Tonal Layering** rather than heavy borders.

- **Level 0 (Background):** #F7FAFF.
- **Level 1 (Cards/Surface):** Pure White (#FFFFFF) with a very soft, diffused shadow (Offset: 0, 4px; Blur: 20px; Color: rgba(37, 99, 235, 0.05)).
- **Level 2 (Interactive/Hover):** Increased shadow spread and a slight lift (Y-offset).
- **Glassmorphism:** Navigation bars and modal backdrops should use a 12px background blur with a 70% white opacity tint to maintain context of the underlying content.

## Shapes

The shape language is friendly and approachable, utilizing large corner radii to echo the softness of the pets the platform serves.

- **Standard Components:** Use `1rem` (rounded-lg) for buttons and input fields.
- **Container Elements:** Use `1.5rem` (rounded-xl) for main content cards and pet profile avatars.
- **Media:** Pet photos should always feature the maximum rounded-xl setting to maintain the system's soft, premium visual signature.

## Components

- **Buttons:** Primary buttons use the `accent_gradient` with white text. High-contrast interactive elements should have a slight scale transform (1.02) on hover.
- **Cards:** Cards are white with `rounded-xl` corners and ambient shadows. They should never have a visible border unless used in a "selected" state, where a 2px Primary Blue border is applied.
- **Inputs:** Text fields use a light gray fill (#F1F5F9) and transition to a white background with a Primary Blue glow on focus.
- **Chips/Tags:** Use rounded-pill shapes with low-opacity tints of the primary color (e.g., 10% Blue fill with 100% Blue text).
- **Pet Profiles:** Dedicated circular or highly-rounded image masks with a "status ring" (gradient border) to indicate if a pet is "Active" or "In Care."
- **Navigation:** A floating bottom tab bar for mobile with a glassmorphic background blur, ensuring the pet feed is always the focal point.