---
name: PetFolio Design System
colors:
  surface: '#f9f9ff'
  surface-dim: '#d3daea'
  surface-bright: '#f9f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f0f3ff'
  surface-container: '#e7eefe'
  surface-container-high: '#e2e8f8'
  surface-container-highest: '#dce2f3'
  on-surface: '#151c27'
  on-surface-variant: '#434655'
  inverse-surface: '#2a313d'
  inverse-on-surface: '#ebf1ff'
  outline: '#737686'
  outline-variant: '#c3c6d7'
  surface-tint: '#0053db'
  primary: '#004ac6'
  on-primary: '#ffffff'
  primary-container: '#2563eb'
  on-primary-container: '#eeefff'
  inverse-primary: '#b4c5ff'
  secondary: '#516070'
  on-secondary: '#ffffff'
  secondary-container: '#d5e4f8'
  on-secondary-container: '#576676'
  tertiary: '#00569c'
  on-tertiary: '#ffffff'
  tertiary-container: '#196fc0'
  on-tertiary-container: '#ebf1ff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dbe1ff'
  primary-fixed-dim: '#b4c5ff'
  on-primary-fixed: '#00174b'
  on-primary-fixed-variant: '#003ea8'
  secondary-fixed: '#d5e4f8'
  secondary-fixed-dim: '#b9c8db'
  on-secondary-fixed: '#0e1d2b'
  on-secondary-fixed-variant: '#3a4858'
  tertiary-fixed: '#d4e3ff'
  tertiary-fixed-dim: '#a4c9ff'
  on-tertiary-fixed: '#001c39'
  on-tertiary-fixed-variant: '#004883'
  background: '#f9f9ff'
  on-background: '#151c27'
  surface-variant: '#dce2f3'
typography:
  headline-lg:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
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
  container-margin: 20px
  gutter: 16px
  section-gap: 24px
  element-gap: 12px
  stack-tight: 4px
---

## Brand & Style

The design system is built on the pillars of **reliability, warmth, and clarity**. It caters to pet owners who require a structured environment to manage their pets' health and lifestyle while feeling a sense of emotional connection.

The visual style is **Corporate / Modern**, utilizing a highly organized structure that minimizes cognitive load. It balances professional utility with a friendly approachable feel through the use of soft edges and a vibrant primary palette. The interface prioritizes whitespace to ensure that data-heavy screens (like medical records or schedules) remain legible and stress-free.

## Colors

The palette is centered around **Vibrant Blue (#2563EB)**, which signals trust and technical proficiency. This is supported by a range of blue tints used for non-critical highlights and secondary UI elements.

- **Primary:** Use #2563EB for all high-intent actions, active states, and branding.
- **Secondary/Surface:** Use #DBEAFE for background accents, badges, or selected list item states.
- **Neutral Scale:** Use a cool-toned gray scale. #111827 for primary text, #6B7280 for secondary text and icons, and #F3F4F6 for dividers.
- **Semantic:** Red (#EF4444) is reserved exclusively for destructive actions like "Sign Out," "Delete Profile," or critical health alerts.

## Typography

This design system uses **Inter** exclusively to maintain a utilitarian and modern aesthetic. The typeface is chosen for its exceptional legibility on mobile screens, particularly in data-heavy contexts.

Hierarchy is established primarily through font weight and color rather than drastic size changes. Section headers in lists should utilize `label-sm` with secondary gray coloring to provide organizational structure without competing with primary content.

## Layout & Spacing

The layout follows a **fluid grid** model tailored for mobile devices. It utilizes a 4-column structure with 20px outer margins to provide "breathing room" (generous whitespace).

A consistent 8px spacing scale is used to define relationships between elements.
- **24px (section-gap):** Used between distinct logical blocks or grouped lists.
- **12px (element-gap):** Used between items within a list or card.
- **4px (stack-tight):** Used between a label and its corresponding input or value.

## Elevation & Depth

To maintain a "clean" and "modern" feel, this design system leans on **tonal layers** and **low-contrast shadows**. 

Depth is used sparingly to indicate interactivity:
- **Level 0 (Background):** #F9FAFB. All grouped lists and containers sit on this base.
- **Level 1 (Cards/Surfaces):** White (#FFFFFF) with a very soft, diffused shadow (0px 2px 8px rgba(0, 0, 0, 0.05)).
- **Interactive:** Elevated elements do not use harsh borders; instead, they use 1px subtle strokes (#E5E7EB) to define boundaries against the background.

## Shapes

The shape language is defined by **Soft Roundedness (8px)**. This radius is applied to all primary containers, including buttons, input fields, and cards.

This specific corner radius is large enough to feel "friendly" and "inviting" to pet owners, but sharp enough to remain "professional" and "organized." 
- Small components (chips/tags) may use a fully rounded (pill) style to distinguish them from actionable buttons.
- Profile avatars for pets should use a circular mask to emphasize personality.

## Components

### Buttons
- **Primary:** Solid #2563EB background with white text. 8px border radius. 
- **Secondary:** #DBEAFE background with #2563EB text. Use for secondary actions like "Add Note."
- **Destructive:** Transparent or light gray background with #EF4444 text for "Sign Out."

### Grouped Lists
Items are housed within white containers with subtle 1px #F3F4F6 bottom dividers. Section headers use `label-sm` in gray, positioned 8px above the list group.

### Input Fields
Outlined style with a 1px #D1D5DB border. On focus, the border transitions to #2563EB with a soft blue outer glow.

### Cards
Cards should utilize generous internal padding (16px or 20px) to prevent content from feeling cramped. Use for pet profiles, upcoming appointments, or health summaries.

### Progress Indicators
Thin, rounded horizontal bars using #2563EB for the fill and #E5E7EB for the track, commonly used for pet weight goals or vaccination completion.