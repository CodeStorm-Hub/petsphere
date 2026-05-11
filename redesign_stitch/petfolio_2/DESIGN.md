---
name: PetFolio
colors:
  surface: '#faf8ff'
  surface-dim: '#d2d9f4'
  surface-bright: '#faf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f3ff'
  surface-container: '#eaedff'
  surface-container-high: '#e2e7ff'
  surface-container-highest: '#dae2fd'
  on-surface: '#131b2e'
  on-surface-variant: '#434655'
  inverse-surface: '#283044'
  inverse-on-surface: '#eef0ff'
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
  tertiary: '#ad0033'
  on-tertiary: '#ffffff'
  tertiary-container: '#d22348'
  on-tertiary-container: '#ffecec'
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
  tertiary-fixed: '#ffdadb'
  tertiary-fixed-dim: '#ffb2b7'
  on-tertiary-fixed: '#40000d'
  on-tertiary-fixed-variant: '#92002a'
  background: '#faf8ff'
  on-background: '#131b2e'
  surface-variant: '#dae2fd'
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
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.02em
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
  base: 8px
  margin-page: 20px
  gutter-grid: 16px
  stack-sm: 4px
  stack-md: 12px
  stack-lg: 24px
  section-padding: 32px
---

## Brand & Style
This design system is built upon a foundation of clarity, warmth, and professional reliability. It targets pet owners who value a sophisticated yet approachable platform for sharing and discovery. The aesthetic identity is **Modern/Corporate**, leaning heavily into high-utility minimalism to ensure that user-generated content—photos and videos of pets—remains the focal point.

The emotional response should be one of "structured joy." By balancing the precision of a professional tool with the friendliness of soft geometry and a vibrant primary blue, the UI communicates that the platform is both a serious utility for pet management and a welcoming space for community interaction.

## Colors
The color palette is anchored by the primary brand blue (#2563EB), utilized for critical actions, active states, and brand-heavy components like badges. To maintain the "clean" requirement, the system uses a sophisticated grayscale palette for text and structural elements.

- **Primary Blue:** Used for CTAs, links, and progress indicators.
- **Surface Neutrals:** A range of ultra-light grays (e.g., #F8FAFC and #F1F5F9) provide subtle separation between content blocks without the heaviness of thick borders.
- **High-Contrast Text:** The primary text color is #0F172A (Slate 900), ensuring maximum legibility against white backgrounds.
- **Semantic Accents:** Tertiary rose (#F43F5E) is reserved for health-related alerts or "favorite" interactions.

## Typography
The typographic system utilizes **Inter** exclusively to achieve a functional, systematic, and modern look. The scale is designed to handle varying lengths of user names and pet descriptions with ease.

Hierarchy is established through weight and size rather than color. Headlines use a tighter letter-spacing and semi-bold/bold weights to feel anchored, while body text maintains standard tracking for readability. Labels and captions use a slightly heavier weight at smaller sizes to ensure they don't get lost against high-density imagery.

## Layout & Spacing
The layout follows a **fluid grid** model optimized for mobile devices, adhering to an 8px base rhythm. To evoke the "generous whitespace" requested, the standard horizontal page margin is set to 20px, providing more breathing room than standard 16px layouts.

Vertical stacking uses 12px for related items (like a user avatar and their name) and 24px or 32px between distinct content cards or sections. This intentional padding prevents the feed from feeling cluttered, emphasizing the premium nature of the community.

## Elevation & Depth
Depth in this design system is achieved through **tonal layers** and **ambient shadows** rather than harsh lines. 

1.  **The Canvas:** The base background is white (#FFFFFF).
2.  **Surface Levels:** Secondary containers (like cards or feed items) use a subtle #F8FAFC fill or a 1px border in #E2E8F0.
3.  **Shadows:** Elevated elements like floating action buttons or primary cards use a very soft, diffused shadow: `0px 4px 12px rgba(15, 23, 42, 0.05)`. 

This approach ensures the interface feels layered and organized without sacrificing the "clean" and "modern" aesthetic.

## Shapes
The shape language is defined by **soft roundedness**. A standard corner radius of 8px (0.5rem) is applied to all primary UI elements, including buttons, input fields, and pet profile cards. 

Larger containers, such as bottom sheets or featured hero images, may scale up to 16px (1rem) to emphasize their enclosure, while smaller elements like tags or badges use a fully circular (pill) radius to distinguish them as interactive or informational markers.

## Components

### Buttons
- **Primary:** Solid #2563EB fill with white text. 8px corner radius. Heavy focus on 48px height for mobile accessibility.
- **Secondary:** White fill with a 1px #E2E8F0 border. Used for less critical actions.
- **Ghost:** No fill or border, using primary blue text for utility actions within cards.

### Input Fields
- Clean, outlined style with 1px #CBD5E1 borders. 
- On focus, the border transitions to #2563EB with a subtle 2px glow.
- Labels are positioned above the field in `label-md` for maximum clarity.

### Cards
- Pet profiles and social posts are housed in cards with an 8px radius.
- Cards use a subtle 1px border or a very light ambient shadow to separate from the background.
- Generous internal padding (16px) ensures content doesn't feel cramped.

### Badges & Chips
- Used for "Pet Species," "Verified," or "Status."
- Feature a light blue tint background (#EFF6FF) with dark blue text (#1D4ED8) for a professional, accessible appearance.

### Navigation
- A clean bottom tab bar with high-contrast icons and 2px active state indicators.
- Significant top-bar whitespace to house the branding and notification triggers.