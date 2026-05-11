---
name: PetFolio Blue
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
  secondary: '#006686'
  on-secondary: '#ffffff'
  secondary-container: '#7ed4fd'
  on-secondary-container: '#005b78'
  tertiary: '#784b00'
  on-tertiary: '#ffffff'
  tertiary-container: '#996100'
  on-tertiary-container: '#ffeedd'
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
  tertiary-fixed: '#ffddb8'
  tertiary-fixed-dim: '#ffb95f'
  on-tertiary-fixed: '#2a1700'
  on-tertiary-fixed-variant: '#653e00'
  background: '#f8f9ff'
  on-background: '#0b1c30'
  surface-variant: '#d3e4fe'
typography:
  headline-lg:
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
  headline-sm:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
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
    letterSpacing: 0.01em
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  container-padding: 1.5rem
  gutter: 1rem
  stack-sm: 0.5rem
  stack-md: 1rem
  stack-lg: 2rem
---

## Brand & Style

This design system is built to balance clinical professionalism with the warmth required for pet care. The brand personality is dependable, organized, and empathetic. It targets pet owners who value high-quality care and streamlined management of their pets' health and schedules.

The visual style is **Corporate / Modern** with a lean toward soft, tactile interfaces. It utilizes ample whitespace to reduce cognitive load and high-clarity layouts to ensure users feel in control. Depth is achieved through layering rather than complex ornamentation, ensuring the interface feels "light" and responsive.

## Colors

The palette is anchored by a vibrant, trustworthy blue that serves as the primary action color. To support the friendly nature of the app, a soft sky-blue secondary color is used for backgrounds and accents. A warm amber tertiary color is reserved for alerts, reminders, and "urgent care" status indicators. 

The neutral palette uses slate grays to maintain a clean, high-contrast environment for text. Backgrounds should primarily use a very light off-white (#F8FAFC) to differentiate from pure white content cards, creating a subtle layered effect.

## Typography

This design system leverages **Inter** for all roles to maintain a systematic and functional appearance. The typographic hierarchy relies on weight and subtle tracking adjustments to distinguish between navigational elements and informational content. 

Headlines utilize tighter tracking and heavier weights to feel grounded. Body copy is set with generous line height to ensure readability during quick scans. Labels are slightly tracked out and use medium to semi-bold weights to ensure clear categorization of data.

## Layout & Spacing

This design system uses a **fluid grid** model optimized for mobile-first interactions. A 12-column grid is used for desktop (max-width 1200px), while a 4-column grid with 24px side margins is used for mobile. 

Spacing follows a strict 4px baseline grid. Elements should be grouped using "Stack" patterns (8px, 16px, or 32px) to create a clear visual rhythm. Generous whitespace between sections (48px+) is encouraged to maintain the "clean" and "approachable" feel of the interface.

## Elevation & Depth

Depth is conveyed through **ambient shadows** and **tonal layers**. Surfaces are rarely flat; instead, they use a soft "Natural Shadow" (0px 4px 12px rgba(37, 99, 235, 0.08)) to lift cards from the background. 

Primary buttons use a subtle vertical gradient (Primary Hex to a 10% darker shade) to provide a tactile, pressable feel. Background blurs are used sparingly for navigation bars and overlays to maintain context without cluttering the view.

## Shapes

The shape language is defined by **ROUND_EIGHT** (0.5rem base radius). This specific level of roundedness is critical to achieving the "friendly but professional" balance; it is soft enough to feel safe and modern, but structured enough to feel like a serious utility. 

Large containers like cards should utilize `rounded-xl` (1.5rem), while smaller interactive elements like buttons and chips should adhere to the base `rounded` (0.5rem) or `rounded-lg` (1rem) for specific call-to-actions.

## Components

### Buttons
Primary buttons feature the vibrant blue with white text and a 0.5rem corner radius. Secondary buttons should use the sky-blue tint with primary blue text for a "ghost" effect that is still highly visible.

### Input Fields
Form fields must be clearly labeled using `label-lg` above the input. The inputs themselves feature a 0.5rem radius, a 1px border in a light neutral, and a 16px internal padding. On focus, the border transitions to the primary blue with a soft outer glow.

### Cards
Cards are the primary container for pet profiles and health records. They should use a white background, the defined ambient shadow, and a 1.5rem corner radius.

### Chips & Badges
Used for pet categories (e.g., "Dog", "Cat") or status (e.g., "Vaccinated"). These should be pill-shaped with high-contrast text and a subtle background fill of the category color.

### Progress Indicators
Health milestones or treatment completion should be displayed using rounded progress bars with a subtle gradient fill using the primary color.