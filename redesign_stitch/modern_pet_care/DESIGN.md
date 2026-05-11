---
name: Modern Pet Care
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
  secondary: '#9d4300'
  on-secondary: '#ffffff'
  secondary-container: '#fd761a'
  on-secondary-container: '#5c2400'
  tertiary: '#006229'
  on-tertiary: '#ffffff'
  tertiary-container: '#007e37'
  on-tertiary-container: '#c1ffc5'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dbe1ff'
  primary-fixed-dim: '#b4c5ff'
  on-primary-fixed: '#00174b'
  on-primary-fixed-variant: '#003ea8'
  secondary-fixed: '#ffdbca'
  secondary-fixed-dim: '#ffb690'
  on-secondary-fixed: '#341100'
  on-secondary-fixed-variant: '#783200'
  tertiary-fixed: '#6bff8f'
  tertiary-fixed-dim: '#4ae176'
  on-tertiary-fixed: '#002109'
  on-tertiary-fixed-variant: '#005321'
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
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
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
  unit: 8px
  container-margin: 24px
  gutter: 16px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 32px
---

## Brand & Style

This design system is built to balance the clinical reliability of a health-tracking platform with the warmth of a social community. The aesthetic leans into a **Corporate / Modern** style, emphasizing clarity, structured information, and high-quality photography of pets. 

The emotional goal is to provide pet owners with a sense of "organized love"—where logistics (vaccines, appointments) are handled with professional precision, while social interactions feel light and welcoming. The interface utilizes generous whitespace and a light, surface-driven hierarchy to prevent information density from feeling overwhelming.

## Colors

The color strategy uses the Primary Blue (#2563EB) as the anchor for trust and action. To distinguish between social updates and critical care information, the system employs a functional secondary palette: 

- **Warning Orange (#F97316)**: Reserved strictly for care alerts, missed medications, or urgent health reminders.
- **Success Green (#22C55E)**: Used for completed tasks, health check approvals, and successful updates.
- **Interaction states**: Hover and active states utilize a 10% opacity overlay of the Primary Blue. 
- **Unread States**: To provide a clear but soft distinction in feeds and inboxes, unread items utilize a background tint of `#EFF6FF`.

## Typography

This design system exclusively uses **Inter** to maintain a clean, utilitarian aesthetic that performs exceptionally well at small sizes—crucial for detailed care logs. 

- **Weight usage**: Use Bold (700) for primary page headers and SemiBold (600) for sub-sections. Regular (400) is used for all descriptive text.
- **Legibility**: Increased line height on body text ensures that medical instructions or pet history are easy to scan.
- **Mobile scaling**: For mobile views, `headline-lg` should scale down to 24px to ensure headers do not push primary content below the fold.

## Layout & Spacing

The design follows a **Fluid Grid** model based on an 8px spacing logic. 

- **Mobile**: 4-column grid with 16px gutters and 24px side margins. 
- **Tablet/Desktop**: 12-column grid with 24px gutters.
- **Vertical Rhythm**: Content blocks are separated by `stack-lg` (32px), while internal card elements use `stack-sm` (8px) or `stack-md` (16px) to maintain grouping.
- **Alignment**: All icons and avatars must align to the baseline of the accompanying text to maintain a professional, structured appearance.

## Elevation & Depth

This design system uses **Tonal Layers** combined with **Ambient Shadows** to create a sense of organized hierarchy. 

- **Level 0 (Background)**: `#F8FAFC`. Used for the main canvas.
- **Level 1 (Cards/Surfaces)**: White background with a subtle 1px border of `#E2E8F0`. 
- **Level 2 (Interactive Elements)**: Floating buttons or active modals use a soft, diffused shadow: `0px 4px 12px rgba(15, 23, 42, 0.08)`.
- **Depth Cues**: Avoid heavy drop shadows. Depth should primarily be communicated through color shifts (e.g., a slightly darker gray for a pressed state) or the 1px border.

## Shapes

The shape language is consistently **Rounded**, using a base radius of **8px**.

- **Small elements (Checkboxes, Tags)**: Use 4px radius.
- **Standard elements (Buttons, Input Fields, Cards)**: Use 8px radius.
- **Large elements (Modals, Feature Banners)**: Use 16px radius.
- **Avatars**: Pet and user profile images must always be circular to soften the UI and differentiate people/animals from functional UI components.

## Components

### Buttons
Primary buttons use the Primary Blue background with white text. Secondary buttons use a transparent background with a 1px Blue border. All buttons have an 8px corner radius and height-matched padding (12px top/bottom for standard size).

### Cards
Cards are the primary container for pet profiles and social posts. They feature a white background, a 1px `#E2E8F0` border, and an 8px radius. Padding within cards is fixed at 16px to ensure a consistent internal margin.

### Input Fields
Inputs use a white background, 8px radius, and a 1px border of `#E2E8F0`. On focus, the border transitions to Primary Blue with a subtle 2px outer glow (10% opacity blue).

### Care Alerts (Specialty Component)
Alert banners use a light orange background (`#FFF7ED`) with Warning Orange text and icons. These are pinned to the top of the "Care" dashboard for high visibility.

### Unread Indicators
In social and notification feeds, unread items are identified by the `#EFF6FF` background tint and a 4px solid Primary Blue dot placed to the left of the content.