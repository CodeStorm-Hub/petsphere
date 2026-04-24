# Design System Specification: The Nurtured Atelier

---
tokens:
  color:
    mode: LIGHT
    primary:
      value: "#D67657"
      description: "Warm, earthy terracotta used for primary actions and brand highlights."
    background:
      value: "#FEF8F3"
      description: "Soft cream background that creates a warm, paper-like feel."
    surface:
      value: "#F3EDE6"
      description: "Secondary surface color for cards and subtle backgrounds."
    text:
      primary: "#35322D"
      secondary: "#625E59"
      on_primary: "#FFFFFF"
    accent_green: "#E8F5E9"
    accent_yellow: "#FFF4E0"
  typography:
    font_family: "Plus Jakarta SANS"
    scale:
      base: 16px
      h1: 32px
      h2: 24px
      body: 16px
      caption: 12px
    weight:
      regular: 400
      medium: 500
      bold: 700
      black: 900
  spacing:
    unit: 4px
    xs: 4px
    sm: 8px
    md: 16px
    lg: 24px
    xl: 32px
  radius:
    small: 8px
    medium: 16px
    large: 24px
    full: 9999px
  shadow:
    soft: "0 8px 24px rgba(153, 71, 44, 0.08)"
---

## 1. Overview & Creative North Star: "The Nurtured Nest"

The Nurtured Atelier is a design system crafted for a mindful pet companion community. It rejects the clinical, rigid grids of traditional marketplaces in favor of a warm, organic, and inviting atmosphere. 

The core philosophy is **"Nurtured Warmth"**—every interaction should feel as soft and comforting as a sunbeam hitting a sleeping cat. This is achieved through the use of a cream-based palette, rounded geometry, and spacious layouts.

## 2. Visual Language

### Color Palette
- **Primary (Amber/Terracotta):** Represents the warmth of the hearth. It's used sparingly but effectively for call-to-actions (CTAs) and important brand moments.
- **Base (Cream/Bone):** Replaces harsh whites to reduce eye strain and create a "homely" feel.
- **Accents:** Muted sage greens and soft yellows are used to denote categories like "Organic" or "Member Exclusive," reinforcing the natural and premium positioning.

### Typography
- **Plus Jakarta Sans:** A modern geometric sans-serif that maintains high legibility while feeling approachable.
- **Hierarchy:** We use bold, tight-tracking headlines to create a strong editorial feel, contrasted with generous leading in body text for a relaxed reading experience.

### Shape & Form
- **Roundness:** "ROUND_FULL" is our default. Buttons, search bars, and navigation items use high corner radii to eliminate sharp edges, contributing to the "safe" and "friendly" brand personality.
- **Containers:** Cards often feature soft shadows (`shadow-soft`) rather than borders, creating depth that feels layered and physical rather than flat and digital.

## 3. Component Intent

### Top App Bar
Fixed and semi-transparent with a backdrop blur, ensuring the brand identity ("The Nurtured Atelier") remains visible while the warm content scrolls beneath it.

### Bottom Navigation
The "docked" design with a high top radius and a prominent, pill-shaped active state provides a tactile, app-like experience that feels anchored and reliable.

### Cards
Product and profile cards use large imagery and clear, bold labels. They are designed to be "scannable but savory"—inviting the user to linger on the photography.
