---
name: Serene Guardian
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
  secondary: '#006b5f'
  on-secondary: '#ffffff'
  secondary-container: '#6df5e1'
  on-secondary-container: '#006f64'
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
  secondary-fixed: '#71f8e4'
  secondary-fixed-dim: '#4fdbc8'
  on-secondary-fixed: '#00201c'
  on-secondary-fixed-variant: '#005048'
  tertiary-fixed: '#c9e6ff'
  tertiary-fixed-dim: '#89ceff'
  on-tertiary-fixed: '#001e2f'
  on-tertiary-fixed-variant: '#004c6e'
  background: '#faf8ff'
  on-background: '#191b23'
  surface-variant: '#e1e2ed'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  title-lg:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
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
  label-bold:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
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
  base_unit: 4px
  margin_mobile: 16px
  gutter: 12px
  card_padding: 16px
  stack_gap: 8px
---

## Brand & Style

This design system is built to instill immediate confidence in pet owners. It balances high-utility professional tools with a soft, approachable aesthetic. The visual narrative centers on "The Organized Caregiver"—utilizing a structured **Bento Grid** layout to modularize complex health data into digestible, friendly segments. 

The style is a blend of **Minimalism** and **Modern Corporate**, utilizing heavy whitespace to reduce cognitive load and soft elevations to create a tactile, organized environment. The interface should feel like a premium concierge service: precise, calm, and always reliable.

## Colors

The palette is anchored by a deep, authoritative Blue (#2563EB), signaling medical-grade reliability and professional care. To differentiate health metrics, we employ a functional color-coding strategy:
- **Teal (#14B8A6)** is reserved for biological health, calorie tracking, and veterinary records.
- **Sky Blue (#0EA5E9)** is dedicated to hydration, grooming, and fluid-based reminders.

The background uses a subtle Slate tint (#F8FAFC) to allow white cards to pop with minimal effort. Text is kept in a high-contrast Slate-800 to ensure legibility for users of all ages and under various lighting conditions.

## Typography

The design system utilizes **Inter** exclusively to lean into its utilitarian and highly legible nature. By varying weights rather than font families, we maintain a clean, "app-first" appearance. 

- **Headlines:** Use Semi-Bold to Bold weights with slight negative letter-spacing to feel modern and tight.
- **Body:** Standardized on 16px for primary information to ensure accessibility.
- **Labels:** Uppercase styles should be used sparingly for category headers or small data tags to create clear hierarchy without overwhelming the bento modules.

## Layout & Spacing

The layout philosophy follows a **Fluid Bento Grid** model. On mobile, content is organized into cards that span either 50% or 100% of the screen width. 

- **Grid:** A 4-column grid for mobile devices.
- **Gaps:** A tight 12px gutter is used between bento cards to maintain a high-density, "dashboard" feel while preserving clear separation.
- **Margins:** A standard 16px safe area on the left and right edges.
- **Rhythm:** Use an 8px-based spatial system for all internal component spacing to ensure visual harmony.

## Elevation & Depth

To achieve a "calm" atmosphere, the design system avoids harsh borders. Instead, depth is communicated through **Ambient Shadows** and **Tonal Layering**.

1.  **Level 0 (Background):** #F8FAFC (Neutral tint).
2.  **Level 1 (Bento Cards):** White surface with a very soft, diffused shadow (0px 4px 20px rgba(37, 99, 235, 0.04)). Note the slight primary color tint in the shadow to keep the UI "warm."
3.  **Level 2 (Active/Floating):** Higher elevation (0px 10px 30px rgba(0, 0, 0, 0.08)) reserved for bottom sheets and active modal states.

Glassmorphism is used exclusively for the Bottom Navigation Bar (Backdrop blur: 10px, 80% opacity) to provide a sense of persistent context.

## Shapes

The shape language is defined by **Medium-High roundedness**. This removes the clinical "sharpness" often found in medical apps, replacing it with a friendlier, organic feel suitable for pet care.

- **Standard Cards:** 16px radius (rounded-xl) to create the soft bento effect.
- **Interactive Elements:** Buttons and input fields use a 12px radius (rounded-lg).
- **Small Indicators:** Chips and status tags use a full pill-shape (999px) to contrast against the rectangular bento grid.

## Components

### Buttons
- **Primary:** Solid #2563EB with white text. 12px roundedness. Subtle scale-down effect on tap.
- **Secondary:** Light blue tint background (#EFF6FF) with #2563EB text.

### Bento Cards
The core of the design system. Every card should have a white background, 16px padding, and 16px corner radius. Headlines within cards should use `title-lg`.

### Input Fields
Soft Slate-100 background with no border in default state. On focus, a 2px solid #2563EB border appears. 12px roundedness.

### Chips & Tags
Used for "Pet Profiles" or "Health Status." High-saturation backgrounds with 10% opacity and 100% opacity text of the same hue (e.g., Teal bg at 10% for health status).

### Specialized Components
- **Health Progress Ring:** Uses the Teal (#14B8A6) color for a circular gauge representing calorie or activity goals.
- **Hydration Wave:** A Sky Blue (#0EA5E9) filled container with a subtle wave animation for water tracking.
- **Timeline Item:** A vertical stepped list with 2px dotted connectors for veterinary history.