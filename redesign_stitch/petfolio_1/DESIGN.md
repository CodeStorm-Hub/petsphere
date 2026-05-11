---
name: PetFolio
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
  secondary: '#505f76'
  on-secondary: '#ffffff'
  secondary-container: '#d0e1fb'
  on-secondary-container: '#54647a'
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
  secondary-fixed: '#d3e4fe'
  secondary-fixed-dim: '#b7c8e1'
  on-secondary-fixed: '#0b1c30'
  on-secondary-fixed-variant: '#38485d'
  tertiary-fixed: '#ffdbcd'
  tertiary-fixed-dim: '#ffb596'
  on-tertiary-fixed: '#360f00'
  on-tertiary-fixed-variant: '#7d2d00'
  background: '#faf8ff'
  on-background: '#191b23'
  surface-variant: '#e1e2ed'
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
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  headline-md:
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
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
  caption:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
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
  container-max: 1280px
  gutter-desktop: 24px
  margin-desktop: 48px
  gutter-mobile: 16px
  margin-mobile: 20px
---

## Brand & Style
The brand personality centers on the intersection of "Trustworthy Expertise" and "Joyful Companionship." This design system employs a **Modern Corporate** style infused with lifestyle warmth. It avoids the cluttered, discount-oriented look of traditional pet retailers in favor of a curated, high-end editorial feel. 

The UI should evoke a sense of reliability (through the vibrant blue) and cleanliness (through generous whitespace). Visuals focus on high-quality photography of pets in bright, natural settings. Soft transitions and subtle blurs enhance the premium positioning, ensuring the user feels they are browsing a boutique experience rather than a warehouse.

## Colors
The palette is dominated by "Vibrant Blue," used strategically for primary actions and brand presence. 

- **Primary:** #2563EB (Active states, primary buttons, brand accents).
- **Secondary:** #64748B (Muted icons, secondary text, utility strokes).
- **Surface:** The background utilizes #FAFAFA to provide a softer contrast than pure white, while cards and containers use pure #FFFFFF to pop against the base.
- **Semantic:** Success and Error states are desaturated slightly to maintain the high-end aesthetic, avoiding neon-bright tones that might disrupt the premium feel.
- **Subtle Gradients:** Use a 15-degree linear gradient for primary buttons, moving from #2563EB to a slightly deeper #1D4ED8.

## Typography
This design system utilizes **Inter** exclusively to achieve a clean, systematic look. 

- **Headlines:** Use a tighter letter-spacing and semi-bold weights to command attention.
- **Body:** Standard weight (400) with generous line heights to ensure readability in product descriptions.
- **Labels:** Use Medium (500) weight for navigation items and small UI labels to maintain visibility at smaller scales.
- **Scalability:** On mobile devices, "Display" and "Headline Large" styles should scale down by 25% to avoid excessive line-breaking.

## Layout & Spacing
The layout follows a **Fixed Grid** model on desktop, centered within a 1280px container, and transitions to a **Fluid Grid** on mobile.

- **Desktop:** 12-column grid with 24px gutters. Use 48px side margins to create a spacious, airy feel.
- **Mobile:** 4-column grid with 16px gutters and 20px margins.
- **Vertical Rhythm:** Follow a 4px baseline. Components should generally use 16px (4 units), 24px (6 units), or 32px (8 units) of padding to maintain consistent internal whitespace.

## Elevation & Depth
Depth is established through **Ambient Shadows** and tonal layering. 

- **Surface Tiers:** Background is #FAFAFA. All primary interaction cards use white (#FFFFFF).
- **Shadow Profile:** Shadows should be extremely soft and slightly tinted with the primary blue (e.g., `rgba(37, 99, 235, 0.05)`). 
- **Levels:**
    - *Low:* 2px blur, 1px Y-offset (Used for default state cards).
    - *Medium:* 12px blur, 4px Y-offset (Used for hover states and dropdowns).
    - *High:* 24px blur, 8px Y-offset (Used for modals and "Add to Cart" sticky bars).

## Shapes
The shape language is consistently **Rounded**, reflecting the friendly and organic nature of the pet industry while remaining modern.

- **Base Radius:** 8px for small components like inputs and buttons.
- **Large Radius:** 16px for product cards and main containers.
- **Extra Large Radius:** 24px for promotional banners and hero image containers.
- **Interactive elements:** Should never be sharp; even the smallest checkbox should have at least a 2px radius.

## Components
- **Buttons:** Primary buttons use a subtle gradient and a soft shadow. Labels are centered with 16px horizontal padding. Secondary buttons use a #F1F5F9 background with #2563EB text.
- **Cards:** Product cards feature a clean border-less look, using shadow to define boundaries. Images within cards must have a 4:5 aspect ratio with a subtle 0.5px gray inner stroke to define white products against white backgrounds.
- **Input Fields:** Use a 1px stroke (#E2E8F0) that thickens to 2px and changes to the primary blue on focus. 
- **Chips/Badges:** Used for categories (e.g., "Organic," "Puppy"). These use a pill shape with a low-opacity background tint of the primary or success color.
- **Product Gallery:** A high-end carousel with a "peek" at the next image, utilizing high-quality transitions and a subtle progress indicator rather than standard arrows.