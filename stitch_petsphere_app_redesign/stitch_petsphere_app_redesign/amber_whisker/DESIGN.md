# Design System Specification: The Nurtured Atelier

## 1. Overview & Creative North Star: "The Nurtured Nest"
This design system rejects the clinical, rigid grids of traditional marketplaces. Instead, it adopts a **"High-End Editorial"** approach to pet companionship. The Creative North Star is **The Nurtured Nest**: a digital environment that feels as soft, safe, and tactile as a hand-woven pet basket.

To break the "template" look, we employ **Intentional Asymmetry**. Layouts should favor generous whitespace and overlapping elements—such as a pet portrait breaking the bounds of its container—to create a sense of life and movement. We avoid symmetry in favor of balanced weights, ensuring the experience feels bespoke rather than generated.

---

## 2. Colors: Tonal Depth & The No-Line Rule
The palette is a sophisticated blend of earthen Terracotta, sun-drenched Yellow, and organic Sage. 

### The "No-Line" Rule
**Explicit Instruction:** Designers are prohibited from using 1px solid borders for sectioning. Boundaries must be defined solely through background color shifts. Use `surface_container_low` to sit atop `background`, or `surface_container_highest` to highlight a specific interaction zone.

### Surface Hierarchy & Nesting
Treat the UI as a series of physical layers—like stacked sheets of fine, heavy-weight paper.
*   **Base:** `surface` (#fef8f3)
*   **Secondary Layer:** `surface_container` (#f3ede6)
*   **Focus Elements:** `surface_container_lowest` (#ffffff) for high-contrast cards.
*   **The "Glass & Gradient" Rule:** Floating navigation or top bars must utilize Glassmorphism. Apply `surface` at 80% opacity with a 16px backdrop blur. 
*   **Signature Textures:** Use subtle linear gradients for primary CTAs, transitioning from `primary` (#99472c) to `primary_container` (#ffad93) at a 135-degree angle. This adds a "soul" to the buttons that flat color cannot replicate.

---

## 3. Typography: Friendly Precision
We use **Plus Jakarta Sans** for its geometric clarity and friendly, open counters. 

*   **Display (lg/md/sm):** Used for "Hero" moments and emotional headlines. Keep letter-spacing at -0.02em to make the letterforms feel "tighter" and more premium.
*   **Headline & Title:** Use `headline-lg` (#35322d) for pet names and category titles. The rounded nature of the typeface should be complemented by generous line-height (1.4+).
*   **Body & Labels:** `body-lg` is your workhorse for descriptions. For metadata (weight, breed, age), use `label-md` in `on_surface_variant` (#625e59) to create a clear informational hierarchy.

---

## 4. Elevation & Depth: Tonal Layering
Traditional material shadows are too heavy for this aesthetic. We achieve depth through **Ambient Light**.

*   **The Layering Principle:** Place a `surface_container_lowest` card on a `surface_container_low` section. The slight delta in hex value creates a soft, natural lift.
*   **Ambient Shadows:** When a floating effect is required (e.g., a "Match" button), use a diffused shadow: 
    *   `blur: 24px`, `y: 8px`, `color: rgba(153, 71, 44, 0.08)` (a tinted version of our Primary Terracotta).
*   **The "Ghost Border":** If accessibility requires a stroke, use `outline_variant` (#b7b1aa) at **15% opacity**. Never use 100% opaque borders.
*   **Roundedness:** Adhere strictly to the scale. Use `lg` (2rem) for standard cards and `xl` (3rem) or `full` for interactive elements to maintain the "playful" DNA.

---

## 5. Components

### Buttons
*   **Primary:** Rounded `full` (9999px). Background: Gradient (`primary` to `primary_dim`). Text: `on_primary`. 
*   **Secondary:** Rounded `full`. Background: `secondary_container`. Text: `on_secondary_container`.
*   **Tertiary:** No background. Text: `primary`. Use for low-emphasis actions like "Cancel" or "Skip."

### Pet Profile Cards
*   **Structure:** No divider lines. Use a `lg` (2rem) corner radius. 
*   **Imagery:** Photos should have a subtle inner glow or be masked with an organic, slightly asymmetrical "blob" shape to feel playful.
*   **Content:** Separate the pet name (`headline-sm`) from the location (`body-sm`) using 12px of vertical white space, not a line.

### Input Fields
*   **Style:** `surface_container_highest` background with a `md` (1.5rem) corner radius.
*   **States:** On focus, transition the background to `surface_container_lowest` and apply a 2px "Ghost Border" using the `primary` color at 20% opacity.

### Selection Chips
*   **Filter Chips:** Use `tertiary_container` (#e5fde6) for unselected states. On selection, switch to `tertiary` (#506453) with `on_tertiary` text. This "Sage" shift signals a grounded, calm selection.

---

## 6. Do's and Don'ts

### Do
*   **Do** use asymmetrical margins. A profile card can be slightly offset from the header to create an "Editorial" feel.
*   **Do** use the `secondary_fixed_dim` (#fad04b) for "Success" or "High-Joy" moments (like a successful match).
*   **Do** prioritize "Breathing Room." If you think you have enough padding, add 8px more.

### Don'ts
*   **Don't** use pure black (#000000) for text. Always use `on_surface` (#35322d).
*   **Don't** use `none` or `sm` roundedness. Everything in this system must feel soft to the touch.
*   **Don't** use standard "drop shadows." If it doesn't look like ambient light, it's too heavy.
*   **Don't** use horizontal rules (`<hr>`). Use a `surface` color shift to denote a new section.