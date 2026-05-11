---
name: Clinical Vitality
colors:
  surface: '#f7f9fb'
  surface-dim: '#d8dadc'
  surface-bright: '#f7f9fb'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f6'
  surface-container: '#eceef0'
  surface-container-high: '#e6e8ea'
  surface-container-highest: '#e0e3e5'
  on-surface: '#191c1e'
  on-surface-variant: '#434655'
  inverse-surface: '#2d3133'
  inverse-on-surface: '#eff1f3'
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
  tertiary: '#006242'
  on-tertiary: '#ffffff'
  tertiary-container: '#007d55'
  on-tertiary-container: '#bdffdb'
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
  tertiary-fixed: '#6ffbbe'
  tertiary-fixed-dim: '#4edea3'
  on-tertiary-fixed: '#002113'
  on-tertiary-fixed-variant: '#005236'
  background: '#f7f9fb'
  on-background: '#191c1e'
  surface-variant: '#e0e3e5'
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
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
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
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.03em
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
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 48px
---

## Brand & Style
The design system is anchored in clinical precision and empathetic care. It targets pet owners and veterinary professionals who require immediate access to critical health data without the cold, sterile feeling of traditional medical software. 

The visual style is **Corporate / Modern**, leaning heavily into high-legibility patterns and structured information architecture. It evokes a sense of reliability and organized calmness. By utilizing ample whitespace and a restrained color palette, the design system ensures that urgent health alerts stand out while routine information remains secondary. The aesthetic is clean, professional, and trustworthy, prioritizing function and data integrity above decorative elements.

## Colors
The color strategy for this design system prioritizes semantic clarity. The **PetFolio Blue (#2563EB)** serves as the primary brand touchpoint, used for all primary actions, navigation states, and brand-level iconography. 

The background utilizes a **Cool Surface (#F8FAFC)** to provide a clinical, airy feel that reduces ocular fatigue during long sessions of data entry or review. Success, Warning, and Alert colors are applied with high intentionality:
- **Success:** Indicates "Healthy" status or "Up to Date" records.
- **Warning:** Flags non-critical attention needs like upcoming vaccinations or medication reminders.
- **Alert:** Reserved for overdue records, medical emergencies, or critical health anomalies.

## Typography
This design system utilizes **Inter** exclusively to ensure maximum legibility across dense medical data tables and record summaries. The type scale is designed to create a clear hierarchy between biological data (e.g., weight, heart rate) and administrative labels.

- **Headlines:** Use semi-bold weights with slight negative letter-spacing for a modern, compact look.
- **Body:** Standardized for readability with generous line heights to ensure long-form medical notes are easy to scan.
- **Labels:** Used for data headers and metadata. These often use increased letter-spacing and medium-to-bold weights to distinguish them from user-generated content.

## Layout & Spacing
The layout follows a **Fluid Grid** model with a 12-column structure for desktop and a 4-column structure for mobile. A strict 8px spacing rhythm ensures consistent alignment across complex medical dashboards.

- **Desktop:** 12 columns, 24px gutters, and 48px side margins. Cards typically span 3, 4, or 6 columns.
- **Tablet:** 8 columns, 16px gutters, and 24px side margins.
- **Mobile:** 4 columns, 16px gutters, and 16px side margins. All cards reflow to full width.

The spacing philosophy prioritizes "Data Breathing Room," using generous internal padding within cards (24px) to separate distinct medical metrics.

## Elevation & Depth
Depth in the design system is achieved through **Tonal Layers** combined with **Ambient Shadows**. The interface remains primarily flat to maintain a professional medical aesthetic, but uses depth to indicate interactivity and importance.

- **Base Level (0dp):** The #F8FAFC surface.
- **Card Level (1dp):** White (#FFFFFF) surfaces with a soft, diffused shadow (10% opacity, 12px blur) and a subtle 1px border (#E2E8F0) to ensure high-contrast definition.
- **Overlays/Modals (2dp):** Slightly higher elevation with a more pronounced shadow (15% opacity, 24px blur) to focus user attention during critical data entry.
- **Interactive States:** Buttons and actionable chips feature a subtle lift effect on hover to provide tactile feedback.

## Shapes
The shape language is characterized by **Medium Roundedness**, providing a friendly yet professional appearance. 

A base corner radius of **12px (0.75rem)** is applied to primary UI containers, including record cards, health charts, and action buttons. Smaller components like input fields and tags utilize a **8px (0.5rem)** radius. This consistency in rounding softens the clinical nature of the data, making the health record feel accessible and modern rather than bureaucratic.

## Components
Consistent component behavior is vital for the integrity of health records. This design system focuses on high-contrast data visualization:

- **Cards:** White background, 12px radius, 24px internal padding. They must include a subtle 1px stroke to separate them from the surface background.
- **High-Contrast Chips:** Used for status (e.g., "Active," "Chronic," "Resolved"). These use a high-saturation background with white text or a very light tint background with high-saturation text for readability.
- **Data Chips:** Small, 8px rounded tags used for categories like "Vaccine," "Lab Result," or "Surgery."
- **Status Indicators:** Circular dots or icons paired with semantic colors to provide an at-a-glance health overview.
- **Input Fields:** Clean, white backgrounds with 1px slate borders. Focus states utilize a 2px PetFolio Blue ring.
- **Buttons:** Primary buttons are solid PetFolio Blue with white text; secondary buttons use a Ghost style (blue text, no background) for less critical actions.