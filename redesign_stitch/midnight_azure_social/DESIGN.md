---
name: Midnight Azure Social
colors:
  surface: '#111319'
  surface-dim: '#111319'
  surface-bright: '#37393f'
  surface-container-lowest: '#0c0e13'
  surface-container-low: '#1a1b21'
  surface-container: '#1e1f25'
  surface-container-high: '#282a30'
  surface-container-highest: '#33353b'
  on-surface: '#e2e2ea'
  on-surface-variant: '#c3c6d4'
  inverse-surface: '#e2e2ea'
  inverse-on-surface: '#2f3036'
  outline: '#8d909d'
  outline-variant: '#434652'
  surface-tint: '#b0c6ff'
  primary: '#b0c6ff'
  on-primary: '#002d6f'
  primary-container: '#7aa2ff'
  on-primary-container: '#003683'
  inverse-primary: '#2e5bb3'
  secondary: '#7bd0ff'
  on-secondary: '#00354a'
  secondary-container: '#00a6e0'
  on-secondary-container: '#00374d'
  tertiary: '#f1c035'
  on-tertiary: '#3e2e00'
  tertiary-container: '#cb9e07'
  on-tertiary-container: '#4a3800'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#d9e2ff'
  primary-fixed-dim: '#b0c6ff'
  on-primary-fixed: '#001945'
  on-primary-fixed-variant: '#06429a'
  secondary-fixed: '#c4e7ff'
  secondary-fixed-dim: '#7bd0ff'
  on-secondary-fixed: '#001e2c'
  on-secondary-fixed-variant: '#004c69'
  tertiary-fixed: '#ffdf95'
  tertiary-fixed-dim: '#f1c035'
  on-tertiary-fixed: '#251a00'
  on-tertiary-fixed-variant: '#594400'
  background: '#111319'
  on-background: '#e2e2ea'
  surface-variant: '#33353b'
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.02em
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
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
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  gutter: 20px
  margin-mobile: 16px
  margin-desktop: 48px
---

## Brand & Style
This design system centers on a high-end, immersive social media experience tailored for premium pet ownership. The aesthetic is "Cyber-Organic"—blending deep, tech-inspired dark tones with soft, ethereal glows that suggest a nurturing yet modern environment. 

The visual style utilizes a refined **Glassmorphism** approach. Surfaces are not just flat planes; they are translucent layers that feel like polished obsidian. The UI should evoke a sense of exclusivity, calm, and technological sophistication. Motion should be fluid and dampened, reinforcing the "premium" positioning of the product.

## Colors
The palette is engineered for deep immersion. The foundation is a rich midnight navy (`#07111F`), providing a limitless sense of depth. Surfaces (`#0F1B2D`) are slightly lifted to create clear content containment without breaking the dark-mode harmony.

The primary blue (`#7AA2FF`) acts as the "light source" within the interface, used for active states, primary actions, and critical branding moments. Secondary text and iconography use a desaturated slate (`#94A3B8`) to ensure information hierarchy and reduce eye strain. All interactive elements should leverage a soft blue volumetric glow rather than traditional harsh shadows.

## Typography
This design system utilizes **Plus Jakarta Sans** across all levels to maintain a friendly yet modern and geometric appearance. The typeface's open counters and high x-height ensure legibility against high-contrast dark backgrounds.

Headlines should use tighter letter spacing and bolder weights to feel impactful and "editorial." Body text uses a standard weight with generous line-height to ensure long-form social content remains readable. Labels and metadata should utilize the medium weight to stand out even at smaller scales.

## Layout & Spacing
The system employs a **Fluid Grid** model based on an 8px rhythmic scale, with a 4px sub-grid for fine-grained component details. 

- **Mobile:** 4-column layout with 16px margins.
- **Tablet:** 8-column layout with 24px margins.
- **Desktop:** 12-column layout with a maximum container width of 1440px. 

Spacing between cards should be generous (`lg` or `xl`) to allow the "glow" effects of the containers to breathe without overlapping awkwardly. Padding within cards should favor the `lg` (24px) token to emphasize the premium, airy feel of the content.

## Elevation & Depth
Depth in this design system is communicated through **Tonal Layering** and **Luminous Outer Glows** rather than black shadows. 

1.  **Level 0 (Background):** `#07111F`. The deepest layer.
2.  **Level 1 (Cards/Surfaces):** `#0F1B2D`. Subtle 1px inner border using `rgba(255, 255, 255, 0.05)` to define edges.
3.  **Elevation Glow:** Interactive or featured cards use a `0px 0px 20px rgba(122, 162, 255, 0.1)` outer drop shadow.
4.  **Backdrop Blur:** Modals and navigation bars use a `blur(20px)` effect over the background to maintain context while focusing the user.

## Shapes
The shape language is defined by **ROUND_TWELVE** (0.75rem / 12px) for standard UI components. This specific radius balances organic softness with the structural integrity of a high-end social platform.

- **Small elements (Chips/Tags):** 8px radius.
- **Standard elements (Buttons/Cards/Inputs):** 12px radius.
- **Large elements (Modals/Sheet Bottoms):** 24px radius.
- **Media (Photos/Videos):** Must always match the 12px container radius to maintain visual alignment.

## Components
- **Buttons:** Primary buttons use a solid `#7AA2FF` fill with white text. Secondary buttons use a transparent fill with a 1px border of `#7AA2FF` and a subtle hover glow.
- **Cards:** Defined by the surface color with a 12px corner radius. On hover, the card's inner border should brighten slightly, and the blue glow should increase in spread.
- **Inputs:** Darker than the surface (`#07111F`) to create an "inset" feel. Borders are invisible until focused, at which point they transition to a 1px `#7AA2FF` stroke with a soft glow.
- **Chips/Tags:** Used for pet categories or interests. Use a subtle background of `rgba(148, 163, 184, 0.1)` and `#94A3B8` text.
- **Navigation:** A bottom-docked or side-rail bar with high translucency and a `backdrop-filter`. Active icons utilize the primary blue and a small "indicator dot" with a glow.
- **Pet Profiles:** Featured components that use larger radii (24px) and a more pronounced gradient glow to signify high-value content.