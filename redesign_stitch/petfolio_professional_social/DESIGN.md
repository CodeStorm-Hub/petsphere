---
name: PetFolio Professional Social
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
  display-hero:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  stat-value:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '700'
    lineHeight: 24px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-caps:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  margin-main: 1.25rem
  gutter-grid: 1rem
  stack-sm: 0.5rem
  stack-md: 1rem
  stack-lg: 1.5rem
---

## Brand & Style
The design system is centered on a "Premium Pet Lifestyle" aesthetic. It balances the emotional warmth of pet ownership with a high-end, professional social media execution. The style is **Modern Corporate**, utilizing significant white space, high-quality photography, and a refined color palette to move away from typical "cute" pet apps toward a more sophisticated "portfolio" feel for animals.

The emotional response should be one of trust and admiration. By using an immersive approach—where the pet's imagery is the focal point—the interface acts as a quiet, elegant frame. The interaction model is smooth and intentional, favoring clarity and structure over decorative clutter.

## Colors
The palette is anchored by **Modern Blue (#2563EB)**, which provides a sense of reliability and digital fluency. This is complemented by a range of neutral slates to keep the focus on user-generated content.

- **Primary:** Used for high-emphasis actions, active states, and brand signifiers.
- **Secondary (Sky):** Used for subtle accents, background washes for tags, and progress indicators.
- **Tertiary (Amber):** Reserved for "Premium" or "Verified" badges and achievement milestones.
- **Surface & Backgrounds:** The primary background is a crisp white (#FFFFFF), with a secondary surface level in a very light cool gray (#F8FAFC) to define structured sections like stat bars.

## Typography
This design system utilizes **Inter** exclusively to ensure a clean, functional, and highly legible experience across all mobile densities. 

- **Hierarchy:** We use a tight scale where weight differentiates importance more than size. 
- **Hero Typography:** Names and titles appearing over imagery should use a subtle text shadow or be placed over a 40% opacity black-to-transparent gradient overlay to ensure WCAG AA legibility.
- **Stats:** Numbers are emphasized with bold weights to make "Pet Stats" (Followers, Age, Breed) immediately scannable.

## Layout & Spacing
The layout follows a **Fluid Mobile Grid** with a 20px (1.25rem) outer margin. 

- **Hero Area:** The top 40% of the profile view is dedicated to a full-bleed hero image.
- **Content Block:** Content below the hero is housed in a structured vertical stack.
- **Stat Bar:** A horizontal flex-row layout is used for profile statistics, evenly distributed across the screen width with subtle vertical dividers between items.
- **Tabs:** A sticky top navigation bar sits below the profile header to toggle between "Gallery," "Achievements," and "Details."

## Elevation & Depth
Depth is handled through **Tonal Layers** and **Ambient Shadows**. 

- **Level 0 (Background):** #FFFFFF.
- **Level 1 (Cards/Surface):** #FFFFFF with a 4px blur, 2% opacity black shadow. This is used for the main profile information card that slightly overlaps the hero image.
- **Overlays:** Hero images utilize a bottom-weighted linear gradient (rgba(0,0,0,0) to rgba(0,0,0,0.6)) to ground the white text placed on top of them.
- **Interactions:** Buttons gain a slightly more pronounced shadow on tap to simulate physical depression.

## Shapes
A consistent 8px (0.5rem) corner radius is applied to all primary UI elements, including cards, input fields, and action buttons. 

- **Profile Avatars:** While most elements are rounded-rects, the primary pet avatar uses a circular mask with a 3px white border to pop against the hero background.
- **Small Elements:** Chips and tags use a fully rounded (pill) shape to distinguish them from functional buttons.

## Components
- **Buttons:** Primary buttons use the Modern Blue background with white text. They are full-width in modals but auto-width in headers.
- **Stats Row:** A clean, 3-column layout displaying "Followers," "Posts," and "Rank." The label uses `label-caps` in a muted gray, and the value uses `stat-value` in primary blue or deep slate.
- **Tabs:** Material-style underlined tabs. The active state uses a 3px bottom border in Modern Blue and a bold font weight.
- **Pet Cards:** Used in discovery feeds; these feature a large image, a bottom-aligned name label, and a small "Breed" chip in the top right corner.
- **Input Fields:** Outlined style with a 1px border (#E2E8F0). On focus, the border transitions to Modern Blue with a soft 2px outer glow.
- **Action Chips:** Small, interactive badges for "Message," "Follow," or "Compare," using a light blue tint background with primary blue text.