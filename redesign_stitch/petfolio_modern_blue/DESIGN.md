---
name: PetFolio Modern Blue
colors:
  surface: '#f7f9fb'
  surface-dim: '#d8dadc'
  surface-bright: '#f7f9fb'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f6'
  surface-container: '#eceef0'
  surface-container-high: '#e6e8ea'
  surface-container-highest: '#e0e3e5'
  on-surface: '#191c1e'
  on-surface-variant: '#434655'
  inverse-surface: '#2d3133'
  inverse-on-surface: '#eff1f3'
  outline: '#737686'
  outline-variant: '#c3c6d7'
  surface-tint: '#0053db'
  primary: '#004ac6'
  on-primary: '#ffffff'
  primary-container: '#2563eb'
  on-primary-container: '#eeefff'
  inverse-primary: '#b4c5ff'
  secondary: '#505f76'
  on-secondary: '#ffffff'
  secondary-container: '#d0e1fb'
  on-secondary-container: '#54647a'
  tertiary: '#005a82'
  on-tertiary: '#ffffff'
  tertiary-container: '#0074a6'
  on-tertiary-container: '#e4f2ff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dbe1ff'
  primary-fixed-dim: '#b4c5ff'
  on-primary-fixed: '#00174b'
  on-primary-fixed-variant: '#003ea8'
  secondary-fixed: '#d3e4fe'
  secondary-fixed-dim: '#b7c8e1'
  on-secondary-fixed: '#0b1c30'
  on-secondary-fixed-variant: '#38485d'
  tertiary-fixed: '#c9e6ff'
  tertiary-fixed-dim: '#89ceff'
  on-tertiary-fixed: '#001e2f'
  on-tertiary-fixed-variant: '#004c6e'
  background: '#f7f9fb'
  on-background: '#191c1e'
  surface-variant: '#e0e3e5'
typography:
  headline-lg:
    fontFamily: Inter
    fontSize: 30px
    fontWeight: '700'
    lineHeight: 38px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 14px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  margin-mobile: 1.25rem
  gutter-mobile: 1rem
  stack-sm: 0.5rem
  stack-md: 1rem
  stack-lg: 1.5rem
  section-gap: 2rem
---

## Brand & Style

The design system is anchored in a **Modern Corporate** aesthetic, tailored specifically for high-fidelity mobile experiences. It balances professional reliability with the warmth required for pet-centric content. The primary objective is to create a "gallery-like" environment where pet imagery is the focal point, supported by a structured, utilitarian interface.

The style leverages **Minimalism** with a focus on high-clarity layouts. By utilizing a soft neutral foundation and generous whitespace, the system ensures that the primary blue serves as a clear functional signpost for actions and status, while photography provides the emotional texture.

## Colors

The color palette is architected to maximize legibility and brand recognition.
- **Primary Blue (#2563EB):** Used for critical actions, active states, and primary branding. It provides a high-contrast anchor against the neutral background.
- **Surface & Background:** The background is strictly **#F8FAFC**, providing a subtle coolness that feels cleaner than pure white. Cards and interactive containers use pure **#FFFFFF** to create a distinct secondary layer of depth.
- **Typography & Grayscale:** We use a deep slate (#0F172A) for headings to maintain a premium feel, avoiding the harshness of pure black. Secondary text utilizes #475569 to ensure accessibility standards are met while maintaining visual hierarchy.

## Typography

The design system utilizes **Inter** exclusively to lean into its systematic, utilitarian nature. The scale is optimized for mobile density.

- **Headlines:** Use tighter letter spacing and heavier weights (600-700) to create a strong visual anchor.
- **Body:** Standardized at 16px for primary readability, with a 14px variant for secondary metadata or dense list views.
- **Labels:** Used for tags, captions, and button text. These often employ medium or semi-bold weights to remain legible at smaller scales.

## Layout & Spacing

This design system follows a **Fluid Grid** model optimized for handheld devices. 
- **Margins:** A consistent 20px (1.25rem) outer margin is applied to the viewport edges.
- **Vertical Rhythm:** A base-4 logic is used. Elements within a card are separated by 8px or 12px, while distinct sections on a page are separated by 24px or 32px.
- **Safe Areas:** All content must respect the bottom home indicator and top notch/dynamic island areas, ensuring high-touch actions are placed within the "thumb zone" (the middle to lower third of the screen).

## Elevation & Depth

Hierarchy is established through **Ambient Shadows** and tonal layering. 
- **Level 0 (Background):** #F8FAFC – The canvas.
- **Level 1 (Cards/Surfaces):** #FFFFFF – Raised slightly with a very soft, diffused shadow: `0px 4px 12px rgba(15, 23, 42, 0.05)`.
- **Level 2 (Floating/Active):** Modals and primary action buttons use a slightly more pronounced shadow: `0px 8px 20px rgba(37, 99, 235, 0.15)` to give the impression of being closer to the user.
- **Outlines:** Use a 1px border (#E2E8F0) for input fields and secondary buttons to maintain structure without adding the weight of a shadow.

## Shapes

The shape language is defined by **rounded-2xl** (1rem / 16px) as the standard for major containers.
- **Cards & Imagery:** Large containers and pet photos always use 16px corner radii to convey a friendly, modern feel.
- **Buttons:** Use a fully rounded (pill) or 12px radius to differentiate them from the structural cards.
- **Small Elements:** Chips and labels use an 8px radius to maintain harmony with the larger components.

## Components

- **Buttons:** Primary buttons are solid #2563EB with white text. Secondary buttons use a #F1F5F9 background with #2563EB text. All have a minimum height of 48px for touch targets.
- **Cards:** White surfaces with 16px rounded corners and a soft shadow. Imagery inside cards should ideally bleed to the top and sides, or be inset with an 8px margin.
- **Input Fields:** 1px border (#E2E8F0), 12px corner radius, and 16px horizontal padding. The active state uses a 2px #2563EB border.
- **Avatars:** Always utilize the **rounded-2xl** (16px) radius rather than a circle to align with the card geometry.
- **Chips/Badges:** Small, 8px rounded elements used for pet categories (e.g., "Dog", "Vet Visit"). Use light tinted backgrounds (e.g., 10% opacity of the primary color).
- **Navigation:** A clean bottom tab bar with 24px icons and 11px labels, utilizing #2563EB for the active state and #64748B for inactive.