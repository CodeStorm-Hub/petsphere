---
name: PetFolio Premium Social
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
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: '1.2'
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: '1.3'
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: '1.4'
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.6'
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: '1.5'
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: '1.2'
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: '1.2'
    letterSpacing: 0.01em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: '1.2'
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  container-margin: 16px
  gutter: 12px
---

## Brand & Style

The brand personality is high-end, trustworthy, and community-centric. This design system bridges the gap between a high-utility social utility and a premium lifestyle platform for pet owners. It prioritizes the visual content—pet photography and videos—by utilizing a "Gallery-First" philosophy.

The chosen style is **Modern Corporate**, drawing heavily from the refined aesthetics of top-tier social platforms like Instagram while incorporating "Soft-UI" elements. The interface emphasizes clarity through ample whitespace, purposeful motion, and a cohesive "blue-tinted" neutral palette that makes the brand's primary blue feel integrated rather than isolated.

## Colors

The palette is anchored by **PetFolio Blue (#2563EB)**, used primarily for call-to-action elements, active states, and brand identifiers. The background uses a specific cool-white (#F7FAFF) to reduce eye strain and provide a subtle distinction from pure white surface cards.

- **Primary:** PetFolio Blue for core interactions.
- **Secondary:** Slate Grays for metadata and secondary icons.
- **Surface:** Pure white for cards, modals, and navigation bars to create a "lifted" effect against the background.
- **Accent:** A warm amber is reserved for "premium" features or "Golden Paw" awards within the community.

## Typography

This design system utilizes **Inter** exclusively to achieve a clean, systematic, and highly legible look. The type hierarchy is designed to manage high-density information (like comments and pet stats) without feeling cluttered.

- **Headlines:** Use tighter letter-spacing and heavier weights to create a strong visual anchor.
- **Body Text:** Uses a generous line height (1.6) for longer captions and pet bios to ensure readability.
- **Labels:** Small caps or medium weights are used for categorizing pet breeds and locations.

## Layout & Spacing

This design system employs a **Fluid Grid** model with a base-4 spatial scale.

- **Mobile:** A 4-column grid with 16px side margins. Content cards typically span the full width of the margins.
- **Desktop/Tablet:** A 12-column centered grid with a maximum content width of 1200px. 
- **Rhythm:** Spacing between related items (like a user's avatar and name) uses 8px (sm), while spacing between distinct sections (like a post and the comment field) uses 24px (lg).

## Elevation & Depth

The system uses **Ambient Shadows** to create a sense of organized layering. Shadows are never pure black; they are tinted with the brand's blue to maintain a "clean" look.

- **Level 1 (Feed Cards):** Subtle 4px blur with 2% opacity blue-tinted shadow.
- **Level 2 (Navigation/Headers):** 8px blur with 4% opacity, creating a slight lift to indicate they sit above the scrollable content.
- **Level 3 (Modals/Pop-overs):** 20px blur with 10% opacity for maximum focus.

Depth is also reinforced through **Tonal Layers**, where interactive elements like input fields use a slight gray-blue inset rather than a heavy border.

## Shapes

The shape language is defined by **Rounded** corners to evoke friendliness and approachability, essential for a pet-focused brand.

- **Small Components (Buttons, Chips):** 8px radius.
- **Medium Components (Feed Cards, Modals):** 12px radius.
- **Large Components (Profile Banners):** 16px radius.
- **Avatars:** Always circular (100% radius) to differentiate pet/owner icons from post content.

## Components

- **Buttons:** Primary buttons use a solid PetFolio Blue fill with white text. Secondary buttons use a light blue tint (#EFF6FF) with blue text.
- **Cards:** White surfaces with a 12px corner radius and Level 1 shadow. Padding is fixed at 16px (md).
- **Chips:** Used for pet categories (e.g., "Golden Retriever", "Adoptable"). They feature a light gray stroke and 8px radius.
- **Input Fields:** 12px radius with a 1px border (#E2E8F0). On focus, the border transitions to PetFolio Blue with a soft blue glow.
- **Bottom Navigation:** Uses high-clarity line icons (24px) with a persistent 4pt blue indicator for the active state.
- **Pet Story Circles:** 2px border offset with a gradient of PetFolio Blue to represent "New Content," similar to Instagram stories but using brand-specific hues.