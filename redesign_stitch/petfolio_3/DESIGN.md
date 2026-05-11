---
name: PetFolio
colors:
  surface: '#f8f9ff'
  surface-dim: '#cbdbf5'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e5eeff'
  surface-container-high: '#dce9ff'
  surface-container-highest: '#d3e4fe'
  on-surface: '#0b1c30'
  on-surface-variant: '#434655'
  inverse-surface: '#213145'
  inverse-on-surface: '#eaf1ff'
  outline: '#737686'
  outline-variant: '#c3c6d7'
  surface-tint: '#0053db'
  primary: '#004ac6'
  on-primary: '#ffffff'
  primary-container: '#2563eb'
  on-primary-container: '#eeefff'
  inverse-primary: '#b4c5ff'
  secondary: '#006a61'
  on-secondary: '#ffffff'
  secondary-container: '#86f2e4'
  on-secondary-container: '#006f66'
  tertiary: '#ac0031'
  on-tertiary: '#ffffff'
  tertiary-container: '#d71142'
  on-tertiary-container: '#ffecec'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dbe1ff'
  primary-fixed-dim: '#b4c5ff'
  on-primary-fixed: '#00174b'
  on-primary-fixed-variant: '#003ea8'
  secondary-fixed: '#89f5e7'
  secondary-fixed-dim: '#6bd8cb'
  on-secondary-fixed: '#00201d'
  on-secondary-fixed-variant: '#005049'
  tertiary-fixed: '#ffdada'
  tertiary-fixed-dim: '#ffb3b6'
  on-tertiary-fixed: '#40000c'
  on-tertiary-fixed-variant: '#920028'
  background: '#f8f9ff'
  on-background: '#0b1c30'
  surface-variant: '#d3e4fe'
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
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
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
  container-margin: 1.5rem
  gutter: 1rem
  stack-sm: 0.5rem
  stack-md: 1rem
  stack-lg: 2rem
  section-gap: 3rem
---

## Brand & Style

This design system is built to evoke a sense of optimism, reliability, and warmth. The target audience includes potential pet adopters and animal enthusiasts who value a frictionless, high-trust experience. 

The aesthetic is **Modern Corporate with a Friendly Edge**, leaning into clean minimalism to ensure pet photography remains the focal point. It utilizes soft depth and large radii to feel approachable rather than clinical. The emotional response should be one of "joyful security"—users should feel the app is a professional platform that cares deeply about the well-being of the animals it showcases.

## Colors

The palette is centered around a trustworthy **Primary Blue (#2563EB)**, which anchors the interface in stability and professionalism. 

- **Success/Action:** A refined Teal (#0D9488) is used for positive matches and successful adoption steps, offering a softer alternative to standard green.
- **Error/Urgency:** A vibrant Red (#E11D48) handles destructive actions and critical alerts.
- **Neutrals:** A slate-based neutral scale is used for text and UI borders to maintain a cool, modern temperature.
- **Gradients:** Use soft linear gradients (Primary Blue to a slightly lighter sky tint) for primary action buttons to add tactile dimension without breaking the clean aesthetic.

## Typography

The design system utilizes **Inter** exclusively to achieve a systematic, highly legible, and neutral look. 

- **Headlines:** Use Bold weights with slight negative letter-spacing for a modern, "tighter" feel in discovery titles.
- **Body:** Regular weights with generous line heights ensure that pet descriptions and adoption requirements are easy to digest.
- **Labels:** Semibold weights are used for metadata (e.g., age, breed, distance) to create clear information hierarchy against body text.

## Layout & Spacing

This design system follows a **Fluid Grid** model centered on an 8px spacing scale. 

- **Mobile:** A 4-column grid with 24px (1.5rem) side margins. 
- **Tablet/Desktop:** A 12-column grid with a max-width of 1280px. 
- **The "Swipe" Zone:** Content cards should have a consistent bottom margin to allow for ergonomic thumb movement during swipe interactions. High-quality photography should utilize full-bleed containers or very thin margins to maximize visual impact.

## Elevation & Depth

Depth is conveyed through **Ambient Shadows** and **Tonal Layering**. 

1. **Surface Level (0dp):** The main background, using a very light gray (#F8FAFC) to reduce eye strain.
2. **Card Level (1dp):** White surfaces with a soft, diffused shadow (Y: 4px, Blur: 12px, 5% Opacity Black). This is the primary container for pet profiles.
3. **Interactive Level (2dp):** Floating Action Buttons (FABs) and active "swipe" cards use a more pronounced shadow (Y: 8px, Blur: 20px, 10% Opacity Primary Blue) to signify they are "lifted" and draggable.
4. **Modals:** Backdrop blurs (10px) are applied to the background when modals are active to maintain focus on the matching process.

## Shapes

The shape language is defined by **Large, Friendly Radii**. 

The standard border radius is **16px (1rem)** for all cards and primary containers. This "Rounded" approach softens the corporate blue and aligns with the friendly nature of the pet discovery niche. 

- **Buttons:** Fully rounded (pill-shaped) to encourage tapping.
- **Input Fields:** Follow the 16px standard to match card aesthetics.
- **Selection Indicators:** Small chips use an 8px radius to maintain distinctness from larger containers.

## Components

- **Swipe Cards:** The centerpiece of the design system. Features 16px corners, full-bleed images at the top, and a gradient overlay at the bottom for text legibility.
- **Action Buttons:** Large (min-height 56px) with soft primary gradients. Iconography within buttons should use rounded strokes to match the shape language.
- **Pet Tags (Chips):** Low-contrast Teal or Blue backgrounds with 8px radii, used to display attributes like "House-trained" or "Good with kids."
- **Input Fields:** 16px rounded corners with a 1px slate-200 border. Focus states should use a 2px Primary Blue glow.
- **Progress Steppers:** Thin, rounded bars at the top of the screen during the "Matching Quiz" to show progress without distracting from the questions.
- **Match Modal:** A full-screen overlay with a celebratory soft-blue-to-teal gradient background, highlighting the two matched profile images.