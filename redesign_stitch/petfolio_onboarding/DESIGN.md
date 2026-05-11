---
name: PetFolio Onboarding
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
  secondary: '#516070'
  on-secondary: '#ffffff'
  secondary-container: '#d5e4f8'
  on-secondary-container: '#576676'
  tertiary: '#00569c'
  on-tertiary: '#ffffff'
  tertiary-container: '#196fc0'
  on-tertiary-container: '#ebf1ff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dbe1ff'
  primary-fixed-dim: '#b4c5ff'
  on-primary-fixed: '#00174b'
  on-primary-fixed-variant: '#003ea8'
  secondary-fixed: '#d5e4f8'
  secondary-fixed-dim: '#b9c8db'
  on-secondary-fixed: '#0e1d2b'
  on-secondary-fixed-variant: '#3a4858'
  tertiary-fixed: '#d4e3ff'
  tertiary-fixed-dim: '#a4c9ff'
  on-tertiary-fixed: '#001c39'
  on-tertiary-fixed-variant: '#004883'
  background: '#f7f9fb'
  on-background: '#191c1e'
  surface-variant: '#e0e3e5'
typography:
  headline-xl:
    fontFamily: Inter
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
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
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
  label-sm:
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
  xs: 0.5rem
  sm: 1rem
  md: 1.5rem
  lg: 2.5rem
  xl: 4rem
  gutter: 1rem
  margin-mobile: 1.25rem
  container-max: 1200px
---

## Brand & Style
The brand identity for this design system is centered on reliability, warmth, and modern efficiency. It targets pet owners who seek a professional yet accessible way to manage their pets' lives. The visual language balances a "Corporate Modern" foundation with "Minimalist" clarity to ensure users feel both supported and secure.

The style utilizes clean, flat illustrations with a limited color palette to guide users through the onboarding flow without cognitive overload. Generous whitespace is a functional requirement, ensuring that the interface feels "airy" and welcoming. The overall emotional response should be one of calm confidence—reducing the friction of data entry through a friendly, organized aesthetic.

## Colors
The palette is anchored by a trustworthy **Primary Blue (#2563EB)**, used for primary actions, progress indicators, and key branding elements. This is supported by a range of functional blues and soft neutrals.

- **Primary Blue:** Used for high-emphasis buttons and active states.
- **Surface Neutrals:** Use #F8FAFC for large background areas and #F1F5F9 for subtle card offsets.
- **Gradients:** Subtle linear gradients (from #2563EB to #60A5FA) are reserved for primary onboarding screens and hero backgrounds to add depth without clutter.
- **Semantic Colors:** Use #EF4444 for errors and #10B981 for success confirmations, ensuring they are used sparingly to maintain the calm blue atmosphere.

## Typography
This design system utilizes **Inter** across all levels to maintain a systematic and utilitarian feel. The hierarchy is strictly enforced to ensure clarity during the onboarding process.

Headlines use bold weights and tighter letter spacing to create a sense of grounded authority. Body text is prioritized for readability with generous line heights. Labels are utilized for form headers and secondary metadata, often using a medium or semi-bold weight to distinguish them from standard body copy. For mobile screens, headlines are scaled down to prevent excessive line-breaking while maintaining their bold visual impact.

## Layout & Spacing
The layout follows a **fluid grid** model with a soft 4px base unit. Onboarding screens should be centered within a 12-column grid on desktop, utilizing a maximum container width of 1200px. 

- **Mobile:** Uses a single-column layout with 20px (1.25rem) side margins.
- **Tablet:** Transitions to an 8-column grid with 32px margins.
- **Desktop:** Employs a 12-column grid. For onboarding forms, content is typically restricted to the central 6 columns to focus the user's attention.

Spacing between form elements should be consistent (1.5rem), while sections are separated by larger gaps (2.5rem to 4rem) to create clear mental breaks between onboarding steps.

## Elevation & Depth
In alignment with the "Clean Flat" style, this design system avoids heavy shadows. Depth is primarily communicated through **Tonal Layers** and **Low-contrast Outlines**.

- **Surfaces:** The primary background is white (#FFFFFF). Secondary containers (like pet profile cards) use a soft neutral surface (#F8FAFC) with a subtle 1px border (#E2E8F0).
- **Shadows:** Use a single "Ambient Blue" shadow for primary call-to-action buttons. This shadow is highly diffused: `0px 4px 12px rgba(37, 99, 235, 0.15)`.
- **Interactions:** When an item is selected (e.g., a pet type chip), it gains a subtle blue glow or a thicker 2px primary border rather than a change in elevation.

## Shapes
The shape language is defined by "ROUND_EIGHT" logic. A consistent 0.5rem (8px) radius is the standard for most components, creating a friendly and approachable feel without appearing overly juvenile.

- **Standard (8px):** Input fields, buttons, and small cards.
- **Large (16px):** Onboarding modal containers and feature cards.
- **Pill:** Used exclusively for tags, status indicators, and progress bars.

## Components
- **Buttons:** Primary buttons use a solid #2563EB fill with white text. Secondary buttons use a #DBEAFE background with #2563EB text. All buttons feature 8px rounded corners and a minimum height of 48px for touch accessibility.
- **Input Fields:** Use a 1px border (#E2E8F0) and 8px rounded corners. The active state is indicated by a 2px #2563EB border and a soft blue outer glow.
- **Chips/Selectables:** Used for pet categorization (e.g., "Dog," "Cat"). These use a #F8FAFC background that transitions to #DBEAFE with a #2563EB border when selected.
- **Progress Indicators:** A horizontal bar at the top of the onboarding flow using a #E2E8F0 track and a #2563EB fill to show completion.
- **Cards:** Pet profile cards use a white background, 16px rounded corners, and a subtle border. They should include a dedicated space for a circular pet avatar image.
- **Lists:** Clean, borderless lists with 16px vertical padding and a thin #F1F5F9 divider between items.