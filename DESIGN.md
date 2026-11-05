# EduCore UI Design System: Quiet Editorial Luxury

<!--
HOW TO USE THIS FILE:
This document is the authoritative, single source of truth for the EduCore design system across Web ERP and Mobile Applications (React Native & Flutter). 
Any developer or AI assistant working on the EduCore codebase MUST read this file before generating or modifying UI components or screens.
NEVER introduce a color, font family, font size, border radius, elevation shadow, or spacing increment that is not documented in this file. 
If an interface requirement appears underspecified, consult Section 10 (Mobile Translation) or Section 13 (Open Questions) rather than inventing arbitrary styling.
-->

## Design Philosophy

Quiet editorial luxury: minimal, calm, spacious, and premium. Hierarchy emerges organically from refined typography and intentional whitespace, never from colored boxes or heavy drop shadows. Interfaces feature razor-sharp 1px hairline borders, near-flat elevation, and a single disciplined indigo accent. Semantic colors are reserved strictly for critical status indicators (subtle dot + descriptive text, never loud saturated pills). Sentence case is enforced everywhere with zero uppercase tracking-wide labels. A classic serif typeface elevates page titles and key operational numerals, while a clean geometric sans powers the UI. Every visual element carries information; zero ornament.

---

## 1. Principles and Tone

### Core Design Rules

| Principle | Do | Don't |
| :--- | :--- | :--- |
| **Status Indicators** | **Do** use a 6px semantic dot accompanied by sentence-case text (e.g. `● 4 absent`). | **Don't** use solid saturated rainbow pills that shout across the page. |
| **Elevation & Depth** | **Do** use crisp 1px hairline borders (`#E8E6E1`) and near-flat shadows (`0 1px 2px rgba(24,24,27,0.03)`). | **Don't** use heavy, blurry drop shadows (`0 10px 25px...`) or skeuomorphic bevels. |
| **Accent Discipline** | **Do** reserve Deep Indigo (`#2E2E99`) strictly for the primary call-to-action and active navigation states. | **Don't** tint headers, table headers, card surfaces, or secondary buttons with accent color. |
| **Typography Scale** | **Do** create visual hierarchy using font size, font family, and whitespace padding. | **Don't** wrap cards in thick colored frames or create nested boxed compartments. |
| **Casing & Labels** | **Do** write all section titles, buttons, column headers, and labels in natural sentence case. | **Don't** use uppercase letter-spaced labels (`STUDENT ATTENDANCE`) or title case on buttons. |
| **Numeral Display** | **Do** render critical figures and metrics in Instrument Serif with fixed-width tabular numerals. | **Don't** render financial amounts or counts in proportional sans-serif where figures jitter. |
| **Restraint in Motion** | **Do** use gentle 150–200ms ease-out transitions for tactile touch feedback. | **Don't** use bouncy springs, looping spins, or distracting slide-in cascades. |
| **Single Primary Action** | **Do** limit each screen view or modal dialog to exactly one primary indigo button. | **Don't** render multiple filled indigo buttons in the same visual viewport. |

### Voice and Copy Rules

- **Sentence Case Everywhere:** Every title, button label, table header, and form label must use sentence case (e.g. "Needs your attention", "Fee payments to verify", "Enroll student", "Average rate", "Collapse sidebar"). The only exceptions are proper nouns (EduCore, Pakistan, Sindhi) and standardized acronyms (PKR, CNIC, OTP, ISO, TLS).
- **Concise, Functional Labels:** Buttons state the direct action as an imperative verb: "Sign in", "Save changes", "Verify", "Review", "Cancel", "Renew now". Avoid generic words like "Submit" or verbose text like "Click here to proceed".
- **Calm, Human Empty States:** When lists or queues are empty, reassure administrators rather than showing negative error language: "All caught up" ("No pending leave applications requiring approval") or "No notifications yet" ("You're all caught up with campus updates").
- **Currency Format (PKR):** South Asian comma grouping (Lakhs and Crores) with a space after `Rs.` (e.g. `Rs. 4,820,000`, `Rs. 12,45,000`). For compact metric tiles: `Rs. 2.5 Crore` or `Rs. 1.25 Lakh`.
- **Date Format:** Administrative standard `DD/MM/YYYY` (e.g. `27/10/2026`) or abbreviated date `25 Oct 2026`. Date ranges: `14 Oct–16 Oct`.
- **Time Format:** 12-hour format with lowercase meridian indicator (e.g. `09:30 am`, `02:15 pm`). For activity feeds, use relative time: `Just now`, `5m ago`, `2h ago`, `3d ago`.
- **Identification & Phone Masks:** Pakistani CNIC / B-Form: `XXXXX-XXXXXXX-X` (13 digits). Phone numbers: local `0300-1234567` or international `+92 300 1234567`.

---

## 2. Color

EduCore operates in a disciplined light palette. The primary canvas is a warm editorial off-white (`#FAF9F7`), upon which crisp pure-white surfaces (`#FFFFFF`) rest with subtle 1px hairlines.

### Color Tokens

#### Page Background & Surfaces
| Token Name | Hex | Usage | Source File |
| :--- | :--- | :--- | :--- |
| `--ec-bg` | `#FAF9F7` | Global canvas behind all application cards, headers, and screens | `src/index.css`, `DashboardLayout.tsx` |
| `--ec-surface` / `--color-neutral-0` | `#FFFFFF` | Primary surface for cards, modals, sheets, dropdowns, and form inputs | `src/index.css`, `tokens.css` |
| `--ec-surface-inset` / `--color-neutral-100` | `#F5F4F1` | Inset search bars, segmented control pill tracks, disabled fields | `src/index.css`, `tokens.css` |
| `--ec-surface-hover` | `#F8F7F5` | Hover state background on pure-white cards and interactive rows | `src/index.css` |

#### Hairline Borders & Dividers
| Token Name | Hex | Usage | Source File |
| :--- | :--- | :--- | :--- |
| `--ec-border` / `--color-neutral-200` | `#E8E6E1` | Standard 1px boundary on cards, inputs, table borders, and headers | `src/index.css`, `tokens.css` |
| `--ec-border-faint` | `#F0EEE9` | Internal table row dividers, card sub-dividers, chart grid lines | `src/index.css` |
| `--color-neutral-300` | `#DCDAD4` | Hover state for borders on inputs, checkboxes, and buttons | `src/shared/ui/tokens.css` |

#### Ink (Typography & Content)
| Token Name | Hex | Usage | Source File |
| :--- | :--- | :--- | :--- |
| `--ec-ink` / `--color-neutral-900` | `#18181B` | Primary headings, KPI numerals, active navigation text, high-contrast labels | `src/index.css`, `tokens.css` |
| `--ec-ink-secondary` / `--color-neutral-600` | `#52525B` | Sub-labels, modal body copy, secondary list titles | `src/index.css`, `tokens.css` |
| `--ec-ink-muted` / `--color-neutral-500` | `#71717A` | Captions, relative timestamps, empty-state descriptions, helper text | `src/index.css`, `tokens.css` |
| `--ec-ink-faint` / `--color-neutral-400` | `#A1A1AA` | Input placeholder text, disabled typography, non-semantic neutral dots | `src/index.css`, `tokens.css` |

#### Accent (Deep Indigo Brand)
| Token Name | Hex | Usage | Source File |
| :--- | :--- | :--- | :--- |
| `--ec-accent` / `--color-primary-500` | `#2E2E99` | Primary CTA button background, interactive links, active tabs underline | `src/index.css`, `tokens.css` |
| `--ec-accent-hover` / `--color-primary-700` | `#24247A` | Hover state on primary buttons | `src/index.css`, `tokens.css` |
| `--color-primary-800` | `#1B1B5C` | Pressed/active state on primary buttons | `src/shared/ui/tokens.css` |
| `--ec-accent-tint` / `--color-primary-50` | `#ECECF9` | Soft indigo background for active row selection, notification chips | `src/index.css`, `tokens.css` |
| `--focus-ring-color` | `rgba(46, 46, 153, 0.20)` | 2px focus ring around inputs and focused buttons | `src/core/layouts/DashboardHeader.tsx` |

#### Semantic Colors (Status Dots, Text, and Subtle Tints)
| Status | Dot & Text Color | Background Tint | Border Hairline | Source File |
| :--- | :--- | :--- | :--- | :--- |
| **Success** | `#2D6A4F` | `#EAF4ED` (or `rgba(45, 106, 79, 0.10)`) | `#C6E2CD` | `src/index.css`, `StatusDot.tsx` |
| **Warning** | `#995D00` | `#FEF6E9` (or `rgba(153, 93, 0, 0.10)`) | `#F8DFB4` | `src/index.css`, `StatusDot.tsx` |
| **Danger** | `#B91C1C` | `#FDF2F2` (or `rgba(185, 28, 28, 0.05)`) | `#F8C8C8` | `src/index.css`, `StatusDot.tsx` |
| **Info** | `#2E2E99` | `#ECECF9` | `#C5C5EE` | `src/shared/ui/tokens.css` |
| **Neutral** | `#A1A1AA` | `#F5F4F1` | `#E8E6E1` | `StatusDot.tsx` |

#### Sidebar-Specific Tokens
| Token Name | Hex | Usage | Source File |
| :--- | :--- | :--- | :--- |
| `--sb-bg` | `#FFFFFF` | Sidebar rail background | `SidebarNavigation.tsx` |
| `--sb-border` | `#ECEBF0` | Sidebar vertical divider border | `SidebarNavigation.tsx` |
| `--sb-ink` | `#17171C` | Unselected navigation item text | `SidebarNavigation.tsx` |
| `--sb-muted` | `#9A99A3` | Search placeholder, collapse chevron icon | `SidebarNavigation.tsx` |
| `--sb-section` | `#8A8780` | Section category header ("Menu") | `SidebarNavigation.tsx` |
| `--sb-active-bg` | `#EEEBF9` | Active parent item background | `SidebarNavigation.tsx` |
| `--sb-active-border` | `#CFC8EC` | Active parent item border | `SidebarNavigation.tsx` |
| `--sb-active-text` | `#2A2470` | Active parent item text and icon | `SidebarNavigation.tsx` |
| `--sb-hover` | `#F5F4F8` | Hover background on unselected items | `SidebarNavigation.tsx` |
| `--sb-rail` | `#DCDAE4` | 1px vertical timeline connecting line for submenus | `SidebarNavigation.tsx` |
| `--sb-rail-dot` | `#B9B3E0` | Active indicator circle centered on timeline rail | `SidebarNavigation.tsx` |
| `--sb-child-gradient-start` | `#D9D4F3` | Active child link horizontal gradient highlight | `SidebarNavigation.tsx` |
| `--sb-badge-count-bg` | `#FDDDBB` | Unread count badge background | `SidebarNavigation.tsx` |
| `--sb-badge-count-text` | `#B36A12` | Unread count badge text | `SidebarNavigation.tsx` |
| `--sb-badge-status-bg` | `#E6F4EA` | Status chip background | `SidebarNavigation.tsx` |
| `--sb-badge-status-text` | `#2E7D4F` | Status chip text | `SidebarNavigation.tsx` |
| `--sb-search-bg` | `#F2F2F4` | Sidebar search input field background | `SidebarNavigation.tsx` |
| `--sb-footer-divider` | `#DDDCE3` | Pinned user footer dashed border | `SidebarNavigation.tsx` |
| `--sb-badge-unread` | `#E5484D` | Unread notification indicator dot | `SidebarNavigation.tsx` |

#### Auth Brand Panel Tokens
| Token Name | Value | Usage | Source File |
| :--- | :--- | :--- | :--- |
| `--auth-brand-bg` | `#141233` | Deep midnight brand background | `AuthLayout.tsx` |
| Radial Ambient Glow | `rgba(59, 47, 143, 0.32)` | Top-left radial gradient spotlight | `AuthLayout.tsx` |
| Grid Overlay Lines | `rgba(255, 255, 255, 0.03)` | 32x32px architectural grid pattern | `AuthLayout.tsx` |
| Auth Hero Text | `#FFFFFF` | Tagline and statistics numerals | `AuthLayout.tsx` |
| Auth Hero Muted | `rgba(255, 255, 255, 0.70)` | Supporting descriptive copy | `AuthLayout.tsx` |
| Auth Hairline Divider | `rgba(255, 255, 255, 0.15)` | Vertical dividing rules between metrics | `AuthLayout.tsx` |

### WCAG 2.1 Contrast Compliance (Light Theme)

| Foreground Color | Background Color | Calculated Contrast Ratio | WCAG AA Normal Text (>=4.5:1) | WCAG AA Large Text (>=3:1) |
| :--- | :--- | :--- | :--- | :--- |
| **Ink (`#18181B`)** | Page Background (`#FAF9F7`) | **15.8:1** | PASS (AAA) | PASS (AAA) |
| **Ink (`#18181B`)** | Surface White (`#FFFFFF`) | **16.7:1** | PASS (AAA) | PASS (AAA) |
| **Secondary Ink (`#52525B`)**| Surface White (`#FFFFFF`) | **7.55:1** | PASS (AAA) | PASS (AAA) |
| **Muted Ink (`#71717A`)** | Surface White (`#FFFFFF`) | **4.77:1** | PASS (AA) | PASS (AAA) |
| **Accent (`#2E2E99`)** | Surface White (`#FFFFFF`) | **10.9:1** | PASS (AAA) | PASS (AAA) |
| **Surface White (`#FFFFFF`)**| Accent CTA (`#2E2E99`) | **10.9:1** | PASS (AAA) | PASS (AAA) |
| **Success Text (`#2D6A4F`)** | Surface White (`#FFFFFF`) | **6.00:1** | PASS (AA) | PASS (AAA) |
| **Warning Text (`#995D00`)** | Surface White (`#FFFFFF`) | **5.33:1** | PASS (AA) | PASS (AAA) |
| **Danger Text (`#B91C1C`)** | Surface White (`#FFFFFF`) | **6.44:1** | PASS (AA) | PASS (AAA) |
| **Sidebar Active (`#2A2470`)**| Active Tint (`#EEEBF9`) | **10.5:1** | PASS (AAA) | PASS (AAA) |
| **Faint Ink (`#A1A1AA`)** | Surface White (`#FFFFFF`) | **2.59:1** | **FAIL** (Rule: Disabled / non-text only) | FAIL |

> [!IMPORTANT]
> Because `#A1A1AA` fails WCAG AA for standard text, it is strictly restricted to non-text decorative borders, subtle watermark icons, and placeholder strings. All readable information must use `#71717A` or darker.

### Accent Rules
1. **Permitted Accent Surfaces:** Primary action buttons, active sidebar item backgrounds, active tab underline bar, focused control border rings, and selected table row tints.
2. **Forbidden Accent Surfaces:** Card backgrounds, modal headers, navigation bar canvases, table header rows, and regular badge fills.
3. **Region Quota:** Exactly **one** accent-filled element per visual screen region or card view.

---

## 3. Typography

### Font Families
- **Display & Key Numerals:** `Instrument Serif`, fallback `Georgia, serif`.
  - Available weights: `400` (Regular), `400 Italic`.
  - Usage: Page headers (`h1`), login hero tagline, and oversized metric card numbers (`.font-serif-numeral`).
- **UI & Controls:** `Poppins`, fallback `-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif`.
  - Available weights: `300` (Light), `400` (Regular), `500` (Medium), `600` (SemiBold), `700` (Bold).
  - Usage: All navigation items, buttons, form controls, table data, subheadings, and dialog text.
- **Urdu / Arabic Localization:** `Noto Nastaliq Urdu`, fallback `serif`. Line height automatically expands to `1.8` to prevent vertical clipping of Nastaliq descenders.

### Type Scale Table

| Role | Font | Size (px) | Line Height (px) | Weight | Letter Spacing | Example Usage |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Display (Page Title)** | Instrument Serif | 32px (`text-[32px]`) | 40px (`leading-tight`) | 400 | `-0.02em` | `PageHeader` title "Institutional Overview" |
| **Title (Card/Section)** | Poppins | 20px (`text-[20px]`) | 28px (`leading-7`) | 600 | `-0.01em` | "Student attendance trend" chart title |
| **Section Title** | Poppins | 14px (`text-[14px]`) | 20px (`leading-5`) | 600 | `normal` | "Leaves awaiting approval" panel header |
| **Body** | Poppins | 14px (`text-sm`) | 22px (`leading-relaxed`)| 400 | `normal` | General narrative text, descriptions |
| **Body Small** | Poppins | 13px (`text-[13px]`) | 18px (`leading-snug`) | 400 | `normal` | List row secondary line, table cells |
| **Label** | Poppins | 12px–13px (`text-xs`) | 16px (`leading-4`) | 500 | `normal` | Form field labels, column headers |
| **Caption / Micro** | Poppins | 11px–12px (`text-[11px]`)| 16px (`leading-4`) | 400 | `normal` | Timestamps, status captions, metadata |
| **KPI Numeral** | Instrument Serif | 38px (`text-[38px]`) | 40px (`leading-none`) | 400 Italic | `-0.02em` | "92%", "2,400+", "Rs. 12,45,000" |
| **Button** | Poppins | 14px (`text-sm`) | 20px (`leading-5`) | 500 | `normal` | "Sign in", "Save changes", "Review" |
| **Input Text** | Poppins | 14px (`text-sm`) | 20px (`leading-5`) | 400 | `normal` | Form text inputs, select dropdowns |

### Typography Rules
1. **Tabular Numerals Mandatory:** Apply `tabular-nums` (`font-variant-numeric: tabular-nums`) to all currency values, student counts, percentages, and dates. This guarantees column numbers align vertically without jitter.
2. **Tight Tracking on Headings:** Apply `-0.02em` tracking (`tracking-tight`) to all serif numerals and page titles to maintain an editorial, magazine-like finish.
3. **No Uppercase Labels:** Never use all-caps letter-spaced micro labels. Maintain standard sentence case across all section titles and table headers.

---

## 4. Spacing, Layout and Shape

### Spacing Scale (4px Base Grid)

| Token Name | Pixels | Rem Equivalent | Common Usage |
| :--- | :--- | :--- | :--- |
| `--space-1` | 4px | `0.25rem` | Icon-to-text spacing, status dot margins |
| `--space-2` | 8px | `0.5rem` | Button horizontal element gap, input internal gap |
| `--space-3` | 12px | `0.75rem` | Toast padding, compact card padding, dropdown item padding |
| `--space-4` | 16px | `1.0rem` | Standard gutter on mobile, input padding, modal gap |
| `--space-5` | 20px | `1.25rem` | Tablet gutter, panel padding |
| `--space-6` | 24px | `1.5rem` | Card interior padding (`p-6`), section header spacing |
| `--space-8` | 32px | `2.0rem` | Desktop page gutters (`p-8`), major vertical grid gaps |
| `--space-10`| 40px | `2.5rem` | Auth screen vertical gap, desktop section spacing |
| `--space-12`| 48px | `3.0rem` | Page footer margins, hero spacing |
| `--space-16`| 64px | `4.0rem` | Desktop hero section vertical whitespace |

### Corner Radius Table

| Token Name | Radius | Usage | Source File |
| :--- | :--- | :--- | :--- |
| `--radius-xs` | 6px | Checkboxes, toast close buttons, micro count tags | `tokens.css` |
| `--radius-sm` | 10px | Text inputs, dropdown selects, small buttons, search pill | `tokens.css`, `index.css` |
| `--radius-md` | 12px | Standard buttons, toasts, tabs container, notification cards | `tokens.css` |
| `--radius-lg` | 14px | Cards, section containers, KPI strip container, trend chart | `tokens.css`, `index.css` |
| `--radius-xl` | 18px | Desktop modal dialogs, entity drawers | `tokens.css` |
| `--radius-full`| 9999px | Avatars, status chips, notification dot pills, circular icon tiles | `tokens.css` |

### Borders and Elevation

- **Hairline Width:** Strictly `1px`. Never use 2px or 3px solid borders for container outlines.
- **Elevation Shadows:**
  - Card At Rest: `--ec-shadow-subtle` / `0 1px 2px rgba(24, 24, 27, 0.03)`
  - Card Hover: `0 1px 2px rgba(15, 23, 42, 0.05), 0 16px 32px -14px rgba(15, 23, 42, 0.12)`
  - Popover / Dropdown: `0 4px 16px rgba(24, 24, 27, 0.06)`
  - Modal & Entity Drawer: `--elevation-overlay` / `0 24px 48px -16px rgba(15, 23, 42, 0.18)`
  - Toast Card: `0 12px 32px rgba(24, 24, 27, 0.08), 0 2px 6px rgba(24, 24, 27, 0.04)`
  - Button Top Inner Highlight: `--button-primary-highlight` / `inset 0 1px 0 rgba(255, 255, 255, 0.20)`

### Z-Index Hierarchy

| Layer Name | Z-Index | Elements |
| :--- | :--- | :--- |
| **Sticky Navigation** | `40` | Sticky top app bar (`DashboardHeader.tsx`), sticky table headers |
| **Dropdowns & Popovers** | `50` | User profile popover, notification popover, search results menu |
| **Slide Drawers** | `60` | `EntityDrawer.tsx`, mobile navigation sidebar drawer |
| **Modal Dialogs** | `70` | `Modal.tsx`, `DeleteConfirmModal.tsx`, backdrops (`rgba(15, 23, 42, 0.40)`) |
| **Toasts** | `80` | Sonner `AppToaster.tsx` notifications |
| **Tooltips** | `999` | Contextual `Tooltip.tsx` bubbles |

### Page Layout Grid
- **Maximum Content Width:** `1280px` (`max-w-[1280px] mx-auto`).
- **Responsive Gutters:** Mobile: 16px (`p-4`), Tablet: 24px (`p-6`), Desktop: 32px (`p-8`).
- **Standard Dashboard Grid:** 12-column desktop layout (`grid-cols-12 gap-6`). For example: 8 columns for Attendance Trend Chart + 4 columns for Exams & Academic Progress.
- **Breakpoints:** `sm: 640px`, `md: 768px`, `lg: 1024px`, `xl: 1280px`, `2xl: 1536px`.

---

## 5. Iconography and Imagery

- **Icon Library:** Lucide React (`lucide-react`).
- **Stroke Width:** Strictly `1.5px` (rendered via `strokeWidth={1.5}` or `stroke-[1.5]`).
- **Default Sizes:**
  - Sidebar icons: `18px`
  - Top bar actions: `18px`
  - Form field adornments: `18px`
  - Button icons: `14px`–`16px`
  - List row / inline status icons: `14px`
- **Icon Colors:** Default muted `#71717A`; Active `#2E2E99` (UI) or `#2A2470` (Sidebar).
- **Avatar Specifications:**
  - Top Bar: 28x28px (`w-7 h-7`), 1px border `#E8E6E1`.
  - Sidebar User: 32x32px (`w-8 h-8`), 1px border `#ECEBF0`.
  - List Rows: 28x28px (`w-7 h-7`), 1px border `#E8E6E1`.
  - Fallback Initials: 2 uppercase letters, font-weight 500, font-size 10px–12px, background `#ECECF9` with `#2E2E99` text.
- **Logo Mark:** 36x36px rounded square (10px radius) with deep indigo gradient (`linear-gradient(135deg, #3B2F8F 0%, #231A5C 100%)`), white `GraduationCap` icon (18px, 1.5px stroke), and soft violet glow shadow (`0 6px 16px rgba(76, 58, 170, 0.28)`). Clear space: minimum 12px padding around mark.

---

## 6. Motion

- **Durations & Easings:**
  - Micro-interactions (hover, toggle, active press): `150ms`–`160ms` `ease-out`.
  - Expand/collapse accordions & tabs: `200ms` `cubic-bezier(0.4, 0, 0.2, 1)`.
  - Slide Drawers (Enter): `250ms` `ease-out` (`slide-in-right`).
  - Slide Drawers (Exit): `320ms` `cubic-bezier(0.16, 1, 0.3, 1)`.
  - Modal Dialogs: `200ms` `ease-out` (scale 0.95 to 1.0, opacity 0 to 1).
- **Allowed Animations:** Tab indicator slide, accordion chevron 180° rotation, modal scale-up, drawer slide-over, notification bell chime ring (`bell-ring 0.5s ease-in-out`), and button press tactile scale (`active:scale-[0.99]`).
- **Disallowed Animations:** Bouncing physics, spinning icons outside loaders, and layout-shifting transitions.
- **Reduced Motion:** If `prefers-reduced-motion: reduce` is active, all durations collapse to `0.01ms` and transforms are disabled (`motion-reduce:transition-none`).
- **Skeleton Shimmer:** Background `#F5F4F1` with 1px border `#E8E6E1`, pulsing smoothly at `1000ms`.
- **Number Count-Up:** `2.0s` duration with tabular numerals and comma separators.

---

## 7. Components

### 7.1 Button

```
Anatomy: [Icon(16px)]? + Label(14px/500) + [Icon(16px)]?
```

| Variant | Default BG | Text Color | Border | Hover State | Pressed State | Disabled State |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Primary** | `#2E2E99` (`--ec-accent`) | `#FFFFFF` | `#2E2E99` | `#24247A` + primary glow | `#1B1B5C` (`active:scale-99`) | `#F5F4F1`, text `#A1A1AA`, border `#E8E6E1` |
| **Secondary** | `#FFFFFF` | `#18181B` | `#E8E6E1` | `#FAF9F7`, border `#DCDAD4` | `#F5F4F1` | `#F5F4F1`, text `#A1A1AA` |
| **Outline** | `#FFFFFF` | `#52525B` | `#DCDAD4` | `#FAF9F7`, text `#18181B` | `#F5F4F1` | `#F5F4F1`, text `#A1A1AA` |
| **Ghost** | `transparent` | `#52525B` | `transparent` | `#F5F4F1`, text `#18181B` | `#E8E6E1` | Opacity 50%, no hover |
| **Destructive** | `#FFFFFF` | `#B91C1C` | `#F8C8C8` | `#B91C1C`, text `#FFFFFF` | `#881337` | `#F5F4F1`, text `#A1A1AA` |
| **Success** | `#FFFFFF` | `#2D6A4F` | `#C6E2CD` | `#2D6A4F`, text `#FFFFFF` | `#064E3B` | `#F5F4F1`, text `#A1A1AA` |

- **Sizes:**
  - `sm`: Height 36px (`min-h-[36px]`), padding 12px (`px-3`), radius 10px (`--radius-sm`), font 12px.
  - `md`: Height 44px (`min-h-[44px]`), padding 16px (`px-4`), radius 12px (`--radius-md`), font 14px.
  - `lg`: Height 52px (`min-h-[52px]`), padding 24px (`px-6`), radius 12px (`--radius-md`), font 16px.
- **States:** Default, Hover (`-translate-y-[1px]`), Focus (`ring-2 ring-[var(--focus-ring-color)] ring-offset-2`), Pressed (`translate-y-0`), Disabled (`opacity-60 cursor-not-allowed`), Loading (shows centered 16px spinner, button width preserved).

---

### 7.2 Input Family

```
Anatomy: Label(12-13px) + Helper? + [Leading Icon(18px)]? + Input Field(44px) + [Trailing Action/Validation Icon]? + Error Text?
```

| Control Type | Height | Surface Fill | Border Hairline | Radius | Focus State | Error State |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Text Field** | 44px | `#FFFFFF` | `#E8E6E1` | 10px (`--radius-sm`) | Border `#2E2E99`, ring 2px `rgba(46,46,153,0.2)` | Border `#B91C1C`, ring 2px `rgba(185,28,28,0.2)` |
| **Password Field** | 44px | `#FFFFFF` | `#E8E6E1` | 10px (`--radius-sm`) | Border `#2E2E99`, 36px Eye/EyeOff toggle | Border `#B91C1C`, validation alert |
| **Phone Field** | 44px | `#FFFFFF` | `#E8E6E1` | 10px (`--radius-sm`) | Dial code pill (`🇵🇰 +92`), LTR input | Border `#B91C1C`, inline error |
| **Select Dropdown** | 44px | `#FFFFFF` | `#E8E6E1` | 10px (`--radius-sm`) | 16px ChevronDown, options in white panel | Border `#B91C1C` |
| **Multi-Select** | 44px (compact) / 96px | `#FFFFFF` | `#E8E6E1` | 10px / 12px | Searchable chip panel, removable tags | Border `#B91C1C` |
| **Date Picker** | 44px | `#FFFFFF` | `#E8E6E1` | 10px (`--radius-sm`) | Calendar icon, floating date popover | Border `#B91C1C` |
| **Textarea** | Min 88px (3 rows) | `#FFFFFF` | `#E8E6E1` | 10px (`--radius-sm`) | Resizable vertical only, padding 14px | Border `#B91C1C` |
| **Checkbox** | 20x20px | `#FFFFFF` | `#DCDAD4` | 6px (`--radius-xs`) | Checked: solid `#2E2E99` + white checkmark | Border `#B91C1C` |

- **States:** Default, Hover (`border-[#DCDAD4]`), Focus (Indigo border + ring), Read-only (Surface `#F5F4F1`, dashed border `#DCDAD4`), Disabled (Surface `#F5F4F1`, text `#A1A1AA`, opacity 75%), Error (Border `#B91C1C`, message with `AlertCircle` 14px icon below).

---

### 7.3 Badge and Status Dot

```
Anatomy (Status Dot): Outer Pulse Ring? + Inner Dot(6px/8px) + Label Text(11px/500)
Anatomy (Badge Pill): Surface Tint + 1px Border + [Dot(6px)]? + Label Text(10-12px) + [Remove X]?
```

- **Status Dot Specs:**
  - Size `sm`: 6px (`h-1.5 w-1.5`); Size `md`: 8px (`h-2 w-2`).
  - Colors: Success `#2D6A4F`, Warning `#995D00`, Danger `#B91C1C`, Neutral `#A1A1AA`.
  - Pulse: Optional `animate-ping` opacity-50 ring for live states.
- **Badge Pill Specs:**
  - Radius: Full pill 9999px (`--radius-full`).
  - Border: 1px solid semantic border.
  - Typography: 10px (`sm`), 11px (`md`), 12px (`lg`), font-weight 500.
  - Colors:
    - Primary: Bg `#ECECF9`, Text `#2E2E99`, Border `#C5C5EE`.
    - Success: Bg `#EAF4ED`, Text `#2D6A4F`, Border `#C6E2CD`.
    - Warning: Bg `#FEF6E9`, Text `#995D00`, Border `#F8DFB4`.
    - Danger: Bg `#FDF2F2`, Text `#B91C1C`, Border `#F8C8C8`.
    - Neutral: Bg `#F5F4F1`, Text `#71717A`, Border `#E8E6E1`.

---

### 7.4 Tabs and Segmented Control

```
Anatomy (Pills): Track Container(#F5F4F1) + Sliding White Card Active Tab + Inactive Tab Labels + Count Badge?
Anatomy (Underline): Bottom Border(#E8E6E1) + Tab Items + 2px Indigo Sliding Bar Indicator
```

- **Pill Variant:**
  - Track: Background `#F5F4F1`, border 1px `#E8E6E1`, padding 4px (`p-1`), radius 10px.
  - Active Tab: Pure white card background, 1px border `#E8E6E1`, radius 8px, shadow `0 1px 2px rgba(24,24,27,0.04)`.
  - Inactive Tab: Text `#71717A`, hover `#18181B`.
  - Count Badge: Pill with tabular numerals (`bg-[#ECECF9] text-[#2E2E99]` when active; `bg-[#E8E6E1] text-[#71717A]` when inactive).
- **Underline Variant:**
  - Border: Bottom 1px solid `#E8E6E1`.
  - Active Indicator: Bottom 2px solid `#2E2E99` sliding bar with rounded caps.
  - Tab Padding: 16px horizontal, 12px vertical (`px-4 py-3`).
- **Date Range Segmented Control:** Inset pill track `#F5F4F1`, radius 8px, buttons (`7d`, `14d`, `30d`), active button white with subtle shadow.

---

### 7.5 Card and Section Card

```
Anatomy: Container Card(White, Radius 14px, 1px Border) + [Header: Number Badge(32px) + Title(14px) + Hairline Divider]? + Body(Padding 24px)
```

- **Card Container:** Pure white surface (`#FFFFFF`), radius 14px (`--radius-lg`), border 1px solid `#E8E6E1`, padding 24px (`p-6`), shadow `0 1px 2px rgba(24,24,27,0.03)`.
- **Clickable Card:** Elevates on hover (`-translate-y-0.5`, shadow `0 16px 32px -14px rgba(15,23,42,0.12)`, border `#DCDAD4`).
- **Section Card Header:** Background `#FAF9F7`, bottom border 1px solid `#E8E6E1`, padding 16px horizontal, 24px vertical. Numbered circular badge: 32x32px (`w-8 h-8 rounded-full`), background `#ECECF9`, border `#C5C5EE`, text 12px font-semibold `#2E2E99` tabular numerals (`01`, `02`).

---

### 7.6 KPI / Metric Cell (MetricStrip & MetricCard)

```
Anatomy: Top Label(Sentence Case, 12px) + Serif Numeral(32-38px, Italic) + Supporting Text(12px) + [Dot + Status Text]?
```

- **MetricStrip Container:** Single continuous pure white card, radius 14px, border 1px solid `#E8E6E1`, internal columns separated by vertical 1px hairlines (`divide-x divide-[#E8E6E1]`).
- **Cell Dimensions:** Minimum height 136px, padding 24px vertical, 28px horizontal (`px-7 py-6`).
- **Cell Hover:** Soft background tint `hover:bg-[#F5F4F1]/60` with 160ms transition.
- **Top Label:** Sentence case, 12px font-medium text `#71717A`.
- **Middle Numeral:** 38px Instrument Serif italic numeral, color `#18181B`, line-height 1.0, tabular numbers.
- **Bottom Metadata:** 12px text `#A1A1AA` paired with right-aligned status chip (`StatusDot` 6px + 11px font-medium text).

---

### 7.7 Data Table and List Row

```
Anatomy (Desktop): Header Row(Bg #FAF9F7, Hairline, 11px Label) + Data Rows(56px, Hairline Dividers, Hover #FAF9F7) + Paging Bar
Anatomy (Mobile): Stacked Card Rows(Bg #FFFFFF, Border #E8E6E1, 2-line Content, Chevron Right)
```

- **Desktop Table:**
  - Header: Sticky top, height 44px, background `#FAF9F7`, border-bottom 1px solid `#E8E6E1`, text 11px font-semibold sentence case `#52525B`.
  - Data Rows: Height 52px–56px, border-bottom 1px solid `#E8E6E1`, hover background `#FAF9F7`, selected row background `#ECECF9`.
  - Numerals: Financial figures and counts are right-aligned with `tabular-nums`.
  - Row Actions: Grouped right-aligned icon buttons (28x28px, radius 10px, border 1px `#E8E6E1`).
- **Mobile List Rows:**
  - Line 1: Primary entity name (14px font-semibold `#18181B`) + primary figure (e.g. `Rs. 15,000` or `Class-3`).
  - Line 2: Secondary detail (12px text `#71717A`) + status dot + date badge.

---

### 7.8 Empty State

```
Anatomy: Dashed Placeholder Waveform/Icon(48px) + Message Title(13px/500) + Description(12px/400) + Action Button?
```

- **Container:** Centered column, padding 40px vertical, 16px horizontal (`py-10 px-4`).
- **Icon / Waveform:** Subtle dashed SVG waveform or 22px Lucide icon in `#A1A1AA` stroke 1.5px.
- **Title:** 13px font-medium text `#18181B` ("All caught up", "No notifications yet").
- **Description:** 12px font-normal text `#71717A` with max-width 320px.
- **Action Button:** Optional quiet secondary outline button (height 36px, radius 10px, border `#E8E6E1`).

---

### 7.9 Skeleton Loader

```
Anatomy: Rectangular / Circular / Text Placeholder(Bg #F5F4F1, Border #E8E6E1, Pulse Animation)
```

- **Variants:**
  - Text: Height 16px (`h-4`), width 60%–100%, radius 6px (`--radius-xs`).
  - Circular: 40x40px (`h-10 w-10`), radius full pill 9999px.
  - Rectangular / Card: Height 96px (`h-24`), width 100%, radius 12px (`--radius-md`).
- **Styling:** Fill `#F5F4F1`, border 1px solid `#E8E6E1`, animation `animate-pulse` at 1000ms.

---

### 7.10 Modal Dialog and Entity Drawer

```
Anatomy (Modal): Backdrop Blur + Dialog Window(Max-width 420-512px, Radius 18px, Border 1px) + Header + Body + Sticky Footer
Anatomy (Drawer): Backdrop Blur + Slide-over Panel(480/640px, Height 100%) + Header + Scrollable Form + Pinned Action Bar
```

- **Backdrop:** `rgba(15, 23, 42, 0.40)` with `backdrop-blur-xs` filter.
- **Modal Dialog:** Max width 420px (delete confirm) to 512px (forms), radius 18px (`--radius-xl`), border 1px solid `#E8E6E1`, padding 28px (`p-7`), shadow `0 24px 48px -16px rgba(15,23,42,0.18)`. Circular close button: 32x32px, radius full, border 1px `#E8E6E1`.
- **Entity Drawer:** Width 480px (`md`) or 640px (`lg`), slide from right, full screen height (`h-full`). Header height 68px, body padded 24px (`p-6`), pinned footer with Cancel (`Button outline`) and Submit (`Button primary`).

---

### 7.11 Tooltip

```
Anatomy: Bubble Container(#18181B, Radius 7px) + Text(#FAF9F7, 11.5px) + 4px Pointer Arrow
```

- **Surface:** Dark ink `#18181B`, border 1px solid `#27272A`, radius 7px, padding 4px vertical, 10px horizontal (`px-2.5 py-1`).
- **Typography:** 11.5px font-medium text `#FAF9F7`, line-height tight.
- **Arrow:** 4px triangle pointing toward trigger target.
- **Contrast:** Exceeds 15:1 against tooltip bubble.

---

### 7.12 Toast (AppToaster / Sonner)

```
Anatomy: Card(#FFFFFF, Radius 12px, Border #E8E6E1) + Semantic Icon(16px) + Title(13.5px) + Description(12px) + Close Button(20px)
```

- **Host Specs:** Position `bottom-right`, duration `4000ms`, visible limit `3`, gap `8px`, desktop offset 24px, mobile offset 16px.
- **Card Styling:** Pure white background (`#FFFFFF`), border 1px solid `#E8E6E1`, radius 12px, shadow `0 12px 32px rgba(24,24,27,0.08), 0 2px 6px rgba(24,24,27,0.04)`.
- **Typography:** Title 13.5px font-medium `#18181B`; description 12px font-normal `#71717A`.
- **Close Button:** 20x20px (`w-5 h-5`), radius 6px, border 1px solid `#E8E6E1`, hover background `#F5F4F1`.

---

### 7.13 Navigation (Sidebar, Top Bar, Breadcrumb)

```
Anatomy (Sidebar): Header(Logo Mark + "EduCore" 17px) + Search Pill(⌘K) + Section "Menu" + Accordion Items + Submenu Rail + User Footer
Anatomy (Top Bar): Mobile Menu Toggle? + Breadcrumb + Center Search(Max 480px) + Notification Bell(Unread Dot) + User Profile Menu
```

- **Sidebar Rail:** Width 280px expanded, 72px collapsed. Header height 68px. Navigation row height 38px, radius 10px, row gap 3px. Active row: background `#EEEBF9`, border 1px `#CFC8EC`, text `#2A2470`. Submenu timeline rail: 1px line `#DCDAE4`, active dot 7x7px `#B9B3E0`.
- **Top Bar:** Height 56px (`h-14`), sticky top `z-40`, background `white/85` with `backdrop-blur-md`, border-bottom 1px solid `#E8E6E1`. Center search input: max-width 480px, height 36px, radius 10px, background `#F5F4F1`, keyboard hint ⌘K badge. Right action bell: 36x36px ghost button with 6px red unread indicator dot (`#B91C1C`).
- **Breadcrumb:** Font size 13px; parent link `#71717A` hover `#18181B`; separator 12px `ChevronRight` in `#A1A1AA`; active current page font-medium `#18181B`.

---

### 7.14 Auth Screens (Login Shell & Security Controls)

```
Anatomy: Desktop Split(50% Midnight Brand Panel #141233 + 50% Off-White Form Area) + Centered White Form Card(Max 442px)
```

- **Layout:** Desktop: 50% brand panel (`#141233`, architectural grid, stat counters, encryption badge) + 50% content canvas (`#FAF9F7`). Mobile: Single column, compact logo header at top.
- **Card Container:** Pure white surface (`#FFFFFF`), radius 14px, border 1px solid `#E8E6E1`, padding 24px–32px (`p-6 sm:p-8`), max-width 442px.
- **Form Controls:** 44px text inputs, 44px primary action button with inner highlight shadow and tactile press.
- **OTP Verification Boxes (Mobile Spec):** Standard 4–6 digit PIN boxes, size 48x52px, radius 10px, border 1px `#E8E6E1`, active focus border `#2E2E99`, font Instrument Serif 24px tabular numerals.

---

### 7.15 Page Header

```
Anatomy: Title(Instrument Serif 32px) + Subtitle(13px Muted) + [Live Status Dot]? + Action Buttons Cluster(Primary + Outlines)
```

- **Container:** Flex row, bottom border 1px solid `#E8E6E1`, padding bottom 8px (`pb-2`), margin bottom 32px (`mb-8`).
- **Title:** 32px Instrument Serif, font-weight 400, color `#18181B`.
- **Live Badge:** Dot 6px `#2D6A4F` with active pulse ring, background `rgba(45,106,79,0.10)`, text 11px font-medium "Live".
- **Action Cluster:** Max 1 primary button (`#2E2E99`, height 36px, radius 10px) + supporting ghost/outline action buttons.

---

## 8. Patterns

### 8.1 Attention List Rows
Operational action queues (e.g. pending leave requests, student fee deposit slips) follow an editorial card pattern:
- 3-column card grid on desktop, each card featuring a section header with item count badge (`#F5F4F1`, text `#71717A`).
- Rows separated by 1px faint dividers (`#F0EEE9`).
- Each row contains:
  1. Circular avatar (28x28px) with student or teacher initials.
  2. Two-line descriptive lockup: Name (12px font-medium `#18181B`) on line 1; category, date range, and duration (11px `#71717A`) on line 2.
  3. Action CTA: Right-aligned quiet outline button (`Review`, height 28px, radius 8px, border `#E8E6E1`).

### 8.2 KPI Strip
Five continuous metrics unified in a single horizontal container:
- Top: Sentence-case metric title (12px font-medium `#71717A`).
- Center: Oversized italic numeral (38px Instrument Serif `#18181B`).
- Bottom: Supporting detail caption (`#A1A1AA`) + semantic status indicator (6px dot + 11px text).
- Divider: Vertical 1px hairline (`#E8E6E1`) between each cell.

### 8.3 Trend Chart Styling
Data visualization (attendance trajectories, academic marks) built with Recharts:
- **Chart Type:** Smooth monotone area chart.
- **Stroke:** Deep Indigo (`#2E2E99`), stroke width `1.75px`.
- **Gradient Fill:** Vertical gradient from Indigo at 14% opacity (`rgba(46, 46, 153, 0.14)`) down to 0% opacity at bottom.
- **Axes:** Horizontal X and vertical Y axes hide axis lines and tick marks; labels rendered in 11px font-normal `#A1A1AA`.
- **Grid Lines:** Horizontal-only dashed rules (`strokeDasharray="3 3"`, color `#F0EEE9`). Zero vertical grid lines.
- **Tooltip:** Floating pure-white card (radius 10px, border 1px `#E8E6E1`, shadow `0 4px 16px rgba(24,24,27,0.06)`).

### 8.4 Filter Bars
Contextual query controls placed immediately above lists or charts:
- Filter Selects: Height 32px (`h-8`), radius 8px, border 1px solid `#E8E6E1`, font 11px font-medium `#71717A`.
- Range Segmented Control: Inset pill `#F5F4F1`, radius 8px, padding 2px.

### 8.5 Form Layout and Validation
- Vertical Stack: Field spacing `space-y-4` (16px) or `space-y-5` (20px). Multi-column grids: 2 columns on tablet/desktop, 1 column on mobile.
- Validation Messaging: Never use color alone. Invalid inputs display a red border (`#B91C1C`), a 14px `AlertCircle` icon, and an explicit inline error sentence immediately below the input.

### 8.6 Destructive Action Confirmation
Irreversible operations (e.g. deleting fee records, removing student profiles):
- Modal max-width 420px, radius 18px (`--radius-xl`).
- 64x64px circular danger icon tile (`bg-[#FDF2F2] border-[#F8C8C8] text-[#B91C1C]`).
- Mandatory "I understand this action is irreversible" safety checkbox before the delete button becomes active.

---

## 9. Accessibility

- **Contrast Ratios:** All body text and form labels maintain a minimum contrast ratio of `4.77:1` against their respective backgrounds, fully exceeding WCAG 2.1 AA (`4.5:1`). Headings and large numerals exceed `10:1`.
- **Minimum Touch / Click Targets:** 
  - Desktop: Minimum 36x36px for compact buttons, 44x44px for primary form controls.
  - Mobile: Minimum 44x44pt on iOS, 48x48dp on Android.
- **Focus Ring Specification:** Visible on keyboard navigation (`focus-visible`). 2px solid Deep Indigo (`#2E2E99`) with a 2px offset (`ring-2 ring-[#2E2E99]/20 ring-offset-2 ring-offset-white`).
- **Color Independence:** Color is never the sole communicator of state. Every semantic status dot is accompanied by an adjacent text string (e.g. "4 absent", "all clear", "needs review") or an accessibility `sr-only` label.
- **Semantic HTML & ARIA:** Modals use `role="dialog"` with `aria-modal="true"`. Expandable menus declare `aria-expanded` and `aria-controls`. Form errors link to inputs via `aria-describedby` and declare `role="alert"`.
- **Reduced Motion Support:** Respects user operating system preferences (`prefers-reduced-motion`). Transitions drop to zero and animations are disabled.

---

## 10. MOBILE APP TRANSLATION (React Native & Flutter)

This section maps web ERP rules to native mobile platforms (iOS and Android). A mobile developer must be able to construct native screens that are visually indistinguishable in spirit, proportions, and luxury feel.

### Unit System & Base Scaling
- **Coordinate Equality:** `1 CSS px` = `1 React Native pt` = `1 Flutter dp`.
- **Screen Canvas:** Mobile uses `--ec-bg` (`#FAF9F7`) edge-to-edge behind all views.
- **Safe Area Insets:** Content must be bound within safe area boundaries (notch/Dynamic Island and bottom home indicator bar).

### Mobile Token Scale Adjustments

| Design Element | Web ERP Spec | Mobile App (iOS / Android) Spec | Rationale |
| :--- | :--- | :--- | :--- |
| **Minimum Touch Target** | 36px–44px | **44pt (iOS) / 48dp (Android)** | Human finger touch accuracy (Apple HIG & Material 3) |
| **Input Field Height** | 44px (`--control-height-md`) | **48dp–52dp** | Comfortable thumb tap, prevents iOS auto-zoom |
| **Button Height (Primary/Sec)**| 44px | **48dp–52dp** | Full-width thumb ergonomics on glass |
| **Body Font Size** | 14px | **15pt–16dp** | Legibility on high-DPI smartphone displays |
| **Body Small / Captions** | 12px–13px | **13pt–14dp** | Subtitle readability |
| **Page Title** | 32px | **26pt–28dp** | Fits mobile screen width without wrapping awkwardly |
| **Card Interior Padding** | 24px (`p-6`) | **16dp–20dp** | Preserves horizontal real estate on 375-400dp screens |
| **Screen Edge Gutter** | 32px (`p-8`) | **16dp** | Standard mobile screen margin |
| **Modal Corner Radius** | 18px (`--radius-xl`) | **20dp (Top Corners of Bottom Sheet)** | Native bottom sheet presentation |

### Mobile Font Loading & Bundling
Both platforms must bundle the exact font files to ensure typestyle parity:
1. `InstrumentSerif-Regular.ttf` & `InstrumentSerif-Italic.ttf` (Display & Numeral)
2. `Poppins-Regular.ttf`, `Poppins-Medium.ttf`, `Poppins-SemiBold.ttf`, `Poppins-Bold.ttf` (UI Sans)
3. `NotoNastaliqUrdu-Regular.ttf` & `NotoNastaliqUrdu-Bold.ttf` (Pakistan Urdu Localization)

**Fallback Stacks:**
- iOS: `Instrument Serif` -> `Georgia` -> `serif`; `Poppins` -> `System (-apple-system)` -> `Helvetica Neue`.
- Android: `Instrument Serif` -> `serif`; `Poppins` -> `sans-serif` -> `Roboto`.

### Navigation Architecture Mapping

```
Web 280px Desktop Sidebar Navigation   ────────►   Mobile 5-Tab Bottom Bar + "More" Modal Sheet
Web 56px Top Header Bar               ────────►   Mobile 56dp Compact App Bar
Web Nested Multi-Level Submenus        ────────►   Mobile Native Stack Push Screens
```

#### Web Navigation Item to Mobile Location Mapping Table

| Web ERP Nav Item | Mobile Location | Presentation Type | Icon (Lucide / Cupertino) |
| :--- | :--- | :--- | :--- |
| **Dashboard** | Bottom Tab 1 | Direct tab | `LayoutDashboard` |
| **Students / Classes** | Bottom Tab 2 | Direct tab | `GraduationCap` |
| **Attendance** | Bottom Tab 3 | Direct tab | `CalendarCheck` |
| **Fees & Billing** | Bottom Tab 4 | Direct tab | `Banknote` |
| **More (All Other Workflows)**| Bottom Tab 5 | Modal Bottom Sheet | `Menu` / `MoreHorizontal` |
| **Exams & Timetable** | Inside "More" Sheet | Stack push navigation | `Award` |
| **Staff & Leaves** | Inside "More" Sheet | Stack push navigation | `UserCheck` |
| **Reports & Analytics** | Inside "More" Sheet | Stack push navigation | `BarChart3` |
| **Settings & Alerts** | Inside "More" Sheet | Stack push navigation | `Settings` |
| **User Profile** | Top App Bar Avatar tap | Stack push navigation | Avatar (28dp) |

#### Mobile Top App Bar
- **Height:** 56dp.
- **Left:** Screen title (20dp font-semibold `#18181B`) or Back chevron (20dp).
- **Right Action Group:**
  1. Search Icon button (opens full-screen native search).
  2. Notification Bell (with 6dp red unread badge dot `#B91C1C`).
  3. User Avatar (28dp circular avatar, taps to open Profile).

### Layout & Component Translations

| Web Component Pattern | Mobile Translation | Implementation Behavior |
| :--- | :--- | :--- |
| **5-Column MetricStrip** | **Horizontal Snap Scroll Row or 2x2 Grid** | Horizontal `ScrollView` with `pagingEnabled` or 2-column card grid with 12dp spacing |
| **3-Column Attention Cards** | **Segmented Control + Stacked List** | 3-tab segmented control ("Leaves", "Fees", "Staff") switching a single full-width list |
| **Multi-Column Data Table** | **Structured Card List Rows** | Vertical list rows: Line 1 has primary title + amount; Line 2 has status dot + date |
| **Modal Dialog** | **Interactive Bottom Sheet** | Slides up from bottom, top radius 20dp, top drag grabber handle (36x4dp `#DCDAD4`) |
| **Entity Slide Drawer** | **Full-Screen Push Screen** | Native stack navigation push transition with standard top-bar "Save" action |
| **Dropdown Menus** | **Bottom Action Sheet / Picker** | Native iOS `UIActionSheet` / Android modal bottom sheet |

### Safe Areas, Keyboard, and Haptics
- **Keyboard Avoidance:** Use `KeyboardAvoidingView` (iOS behavior `padding`) or `resizeToAvoidBottomInset: true` in Flutter.
- **Status Bar Style:** Light background requires dark icons (`UIStatusBarStyleDarkContent` / `SystemUiOverlayStyle.dark`).
- **Pull-to-Refresh:** Native `RefreshControl` / `RefreshIndicator` with primary indigo spinner (`#2E2E99`).
- **Tactile Haptic Feedback:**
  - Tab Switch: Light impact (`UIImpactFeedbackGenerator(light)` / `HapticFeedback.lightImpact`).
  - Primary CTA Tap: Medium impact (`UIImpactFeedbackGenerator(medium)`).
  - Verification / Approval: Success notification (`UINotificationFeedbackGenerator(success)`).
  - Delete / Irreversible Action: Warning notification.
- **Swipe Actions on List Rows:** Swiping a list row left reveals a quiet 44dp "Review" action button.

### What Does NOT Carry Over & What Replaces It

| Web ERP Element | Mobile Translation / Replacement |
| :--- | :--- |
| **Hover States (`:hover`)** | Replaced by active press states (`activeOpacity: 0.85`, tactile scale `0.98`, or Android ripple) |
| **Desktop Tooltips (`Tooltip.tsx`)** | Replaced by explicit inline helper text or tap-activated informational bottom sheets |
| **Keyboard Hints (`⌘K`)** | Replaced by a dedicated Search magnifying glass icon button in the top app bar |
| **Pagination Controls (Page 1 of 10)**| Replaced by infinite scroll with pull-to-refresh and a loading skeleton indicator at list bottom |
| **Multi-level Hover Dropdowns** | Replaced by stacked drill-down list menus |

### Platform Notes: iOS vs. Android Parity
- **Back Navigation:** iOS uses interactive edge-swipe gesture; Android uses the system back button and predictive back gesture. Both must preserve form dirty-state discard warnings.
- **Touch Feedback:** iOS uses subtle opacity fading (`activeOpacity={0.82}`); Android uses bounded ripple effects (`android_ripple={{ color: 'rgba(46, 46, 153, 0.08)' }}`).
- **Blur Effects:** iOS applies native translucent blur (`BlurView` `extraLight`); Android falls back to clean solid `#FAF9F7` with a 1px hairline border `#E8E6E1`.

---

## 11. Implementation Snippets for Mobile

## 12. Do and Don't Gallery

Use this checklist to review any new screen (Web or Mobile) before deployment:

1. **No Uppercase Labels:** Do use natural sentence case for every header, field label, and button. Do not use uppercase text (`ATTENDANCE QUEUE`).
2. **One Primary Button Per View:** Do ensure exactly one solid indigo CTA exists per screen view or modal. Do not render two competing solid primary buttons side-by-side.
3. **Status = Dot + Text:** Do represent status with a 6px dot paired with concise text (`● 4 absent`). Do not use heavily saturated full-bleed rainbow pills.
4. **No Drop Shadows on Content:** Do keep card surfaces virtually flat with razor 1px borders (`#E8E6E1`). Do not use elevated blurry shadows except for floating overlays (modals, dropdowns, toasts).
5. **Serif Only for Headings & Numerals:** Do use Instrument Serif exclusively for page titles and oversized metric numbers. Do not use serif fonts for body text, inputs, or buttons.
6. **All Spacing on 4/8 Grid:** Do construct all margins, paddings, and gaps from the 4px base scale (`4, 8, 12, 16, 20, 24, 32, 40, 48`). Do not use arbitrary numbers (`17px`, `23px`).
7. **Tabular Numerals for Data:** Do apply `tabular-nums` to every count, date, and currency value. Do not allow jittering proportional numbers in lists and tables.
8. **Pakistani Rupee Standards:** Do format currency with South Asian comma grouping (e.g. `Rs. 12,45,000`). Do not use Western grouping (`Rs. 1,245,000`) or bare numbers.
9. **No Colored Card Backgrounds:** Do keep card backgrounds pure white (`#FFFFFF`) on top of the `#FAF9F7` canvas. Do not fill card bodies with blue, yellow, or red tints.
10. **Touch Targets at 44/48:** Do enforce minimum touch targets of 44pt (iOS) / 48dp (Android) on all interactive controls. Do not create tiny tap zones.
11. **Inline Field Errors with Icons:** Do pair error text with an alert icon and red border. Do not signal form errors solely through red border color.
12. **Quiet Empty States:** Do use encouraging, calm empty states ("All caught up"). Do not display abrasive warning banners when a work queue is clear.
13. **Hairline Table Dividers:** Do use 1px horizontal hairlines (`#E8E6E1`) with row hover tints. Do not use alternating zebra-striped rows.
14. **No Arbitrary Radii:** Do use 10px for controls, 14px for cards, and 18px–20px for sheets/modals. Do not mix 4px, 7px, and 25px arbitrarily.

---

## 13. Open Questions

Every inconsistency identified during codebase extraction is documented below for administrative confirmation:

| # | Conflict / Gap | Codebase Sources | Impact & Recommended Resolution |
| :--- | :--- | :--- | :--- |
| **1** | **Serif Display Font Discrepancy** | `src/index.css` imports **`Instrument Serif`**, whereas `src/shared/ui/tokens.css` imports **`Fraunces`**. | **TODO: confirm.** `Instrument Serif` is actively used in `.font-serif-numeral` and layout headers. Recommended: Standardize on `Instrument Serif` across both web and mobile bundles. |
| **2** | **UI Sans Font Stack Discrepancy** | `src/index.css` sets `--font-sans: 'Poppins'`, while `tokens.css` sets `--font-ui: "Plus Jakarta Sans"`. | **TODO: confirm.** `src/index.css` defines the primary Tailwind theme variable (`--font-sans: 'Poppins'`). Recommended: Confirm `Poppins` as primary UI font or migrate to `Plus Jakarta Sans`. |
| **3** | **OTP Input Component Absence** | No dedicated multi-box OTP input component exists in `src/shared/ui/` (web auth relies on email recovery links). | **TODO: confirm.** Mobile apps often require SMS/WhatsApp 6-digit OTP codes. Specification provided in Section 7.14 (48x52px boxes, radius 10px). Confirm before building mobile 2FA screens. |
| **4** | **Neutral Gray Palette Variations** | `src/index.css` uses Tailwind Zinc (`#18181B`, `#52525B`, `#71717A`, `#A1A1AA`), while `tokens.css` references Slate (`rgba(15, 23, 42, ...)`). | **TODO: confirm.** The Zinc/warm-neutral palette matches the "Quiet Luxury" aesthetic. Recommended: Lock Zinc (`#18181B` series) as the canonical ink tokens. |
| **5** | **Legacy Primary Indigo Shade** | `tokens.css` has some legacy references to `#4F46E5` / `#6366F1`, whereas `src/index.css` and `SidebarNavigation.tsx` define `--ec-accent: #2E2E99` and `--sb-active-text: #2A2470`. | **TODO: confirm.** The deep editorial indigo `#2E2E99` is the approved brand color. All legacy `#4F46E5` references in older components should be refactored to `#2E2E99`. |
