---
name: Premium Pet Care & Social
colors:
  surface: '#f9f9ff'
  surface-dim: '#cfdaf2'
  surface-bright: '#f9f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f0f3ff'
  surface-container: '#e7eeff'
  surface-container-high: '#dee8ff'
  surface-container-highest: '#d8e3fb'
  on-surface: '#111c2d'
  on-surface-variant: '#434655'
  inverse-surface: '#263143'
  inverse-on-surface: '#ecf1ff'
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
  tertiary: '#52565a'
  on-tertiary: '#ffffff'
  tertiary-container: '#6a6e72'
  on-tertiary-container: '#eef1f6'
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
  tertiary-fixed: '#dfe3e8'
  tertiary-fixed-dim: '#c3c7cc'
  on-tertiary-fixed: '#181c20'
  on-tertiary-fixed-variant: '#43474b'
  background: '#f9f9ff'
  on-background: '#111c2d'
  surface-variant: '#d8e3fb'
typography:
  display-lg:
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
    lineHeight: '1.5'
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: '1.5'
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: '1.2'
    letterSpacing: 0.05em
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: '1.2'
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 12px
  md: 24px
  lg: 40px
  xl: 64px
  gutter: 24px
  margin-mobile: 16px
  max-width: 1280px
---

## Brand & Style
The design system is anchored in a philosophy of **Premium Minimalism**. It balances the emotional warmth of a pet-centric platform with the rigorous professionalism of a high-end care service. The aesthetic is clean and spacious, intentionally avoiding the cluttered look of traditional social media to prioritize clarity and trust.

The visual style draws from **Corporate Modern** movements, utilizing precision-engineered layouts and a restrained color palette. It evokes an atmosphere of reliability—essential for users entrusting their pets' data and care to the platform—while maintaining a friendly, accessible interface through soft geometry and subtle depth.

## Colors
The palette is built around a confident primary blue, signifying professionalism and medical-grade trust. This is supported by a range of atmospheric blues and whites to create a sense of airiness.

- **Primary Blue (#2563EB):** Used for primary actions, branding, and active states.
- **Surface Gradient:** A signature transition from **#F7FAFF** to **White** is applied to large background areas to prevent visual fatigue and add a premium, "gallery" feel.
- **Neutrals:** Deep slates (#1E293B) are used for high-contrast typography, while cooler greys (#94A3B8) handle secondary metadata and borders.
- **Accents:** Semantic colors (Success: #10B981, Error: #EF4444) follow the same saturation levels as the primary blue to ensure a cohesive system.

## Typography
This design system utilizes **Inter** exclusively to maintain a systematic and utilitarian feel. The hierarchy is established through extreme weight contrast: bold headings provide a strong architectural anchor, while medium and regular body weights ensure legibility for long-form care instructions and social feeds.

To maintain a high-end feel, headings use a slightly tighter letter-spacing to appear more customized and "editorial." Body text uses a generous line height (1.5–1.6) to maximize white space and readability.

## Layout & Spacing
The layout follows a **Fixed Grid** model for desktop to ensure content remains centered and premium, transitioning to a **Fluid Grid** for mobile devices.

- **Desktop:** 12-column grid with a 1280px max-width, 24px gutters.
- **Tablet:** 8-column grid with 24px margins.
- **Mobile:** 4-column grid with 16px margins.

Spacing is governed by an 8px rhythm. Vertical rhythm should be generous; use `lg` (40px) or `xl` (64px) between major sections to emphasize the minimal, high-end aesthetic. Group related pet data (e.g., weight, age) using `sm` (12px) to maintain proximity.

## Elevation & Depth
Depth is achieved through **Ambient Shadows** and **Tonal Layers** rather than harsh lines. 

1.  **Level 0 (Base):** The #F7FAFF gradient surface.
2.  **Level 1 (Cards):** White surfaces with a subtle 1px border (#E2E8F0) and an ultra-diffused shadow (0px 4px 20px rgba(37, 99, 235, 0.04)).
3.  **Level 2 (Dropdowns/Modals):** Pure white surfaces with a more pronounced shadow (0px 12px 32px rgba(30, 41, 59, 0.08)) to indicate interactivity and separation from the base content.

Background blurs (10px–15px) may be used on navigation bars to allow the soft blue background to peek through, maintaining the "Glassmorphism" influence without sacrificing professional clarity.

## Shapes
The shape language is defined by **Soft, Modern Corners**. This approach removes the "sharpness" of medical apps while avoiding the "bubble-like" appearance of casual toy brands.

- **Standard Elements:** Buttons and input fields use a 0.5rem radius.
- **Containers:** Content cards and pet profile modules use a 1rem (rounded-lg) radius to feel welcoming.
- **Feature Elements:** Avatar frames for pets and owner profiles should be fully circular to provide a soft contrast to the rectangular grid of the platform.

## Components
### Buttons
Primary buttons use the solid Primary Blue with white text. Secondary buttons use a transparent background with a 1px border in #2563EB. Transitions should be soft (200ms) with a slight lift on hover.

### Cards
Cards are the primary vehicle for pet profiles and care logs. They feature a white background, Level 1 elevation, and a 16px internal padding. Headers within cards should use `headline-md`.

### Input Fields
Inputs are minimalist: a subtle #F1F5F9 background, no initial border, and a transition to a 1px Primary Blue border on focus. Labels should always use `label-md` for clarity.

### Chips & Badges
Used for pet categories (e.g., "Vaccinated," "Friendly"). These use highly desaturated versions of the category color (e.g., light blue background with dark blue text) and a pill-shaped radius to distinguish them from actionable buttons.

### Pet Profiles
A specialized component featuring a large circular avatar, a "Trust Badge" (verified care status), and a structured list of vital stats using `body-sm`.