# AGENTS.md — Bondly Mobile Design & Architecture Guidelines

You are an expert Flutter UI/UX engineer building **Bondly**, a high-craft, private relationship-tracking and messaging app. Adhere strictly to these rules across every widget, screen, and feature.

---

## 1. Zero Tolerance for Overflow & Layout Bugs
- **Never use fixed heights on content cards:** Cards inside grids or lists must derive height dynamically from child content and padding. Never hardcode widget heights like `height: 120` for items containing dynamic text.
- **Always handle scrollability:** Any screen body with potential vertical overflow must be wrapped in `SingleChildScrollView`, `ListView`, or `CustomScrollView` (Slivers).
- **Safe Grid Pattern:** When displaying 2-column modules, use a `GridView` with `shrinkWrap: true`, `physics: const NeverScrollableScrollPhysics()`, and set an appropriate `childAspectRatio` (e.g., `1.1` to `1.25`) so labels and icons have generous breathing room without triggering `RenderFlex` bottom overflow errors.

---

## 2. Visual Style & Color Tokens (Dark Modern Theme)
Never use raw Flutter Material 3 seed-color tinting or default purple/indigo accents. Adhere to these exact tokens:

- **Canvas / Background:** `#0A0D14` (Deep obsidian/navy)
- **Elevated Surfaces / Cards:** `#121824`
- **Subtle Borders:** `#1E293B` (1px width on all cards, inputs, and sheet edges)
- **Primary Accent / Brand:** `#FF6B50` (Warm coral/terracotta for greeting banners and primary actions)
- **Privacy Accent:** `#8B5CF6` (Muted violet for privacy notes and owner-only indicators)
- **Typography Colors:**
  - Headings / Active Text: `#FFFFFF` or `#F8FAFC`
  - Body / Subtext: `#94A3B8` (Muted slate)
  - Micro-labels: `#64748B`

---

## 3. Component Styling Rules (Anti-Default Material)
- **Cards & Surfaces:**
  - Construct using `Container` or `DecoratedBox`.
  - Use `BorderRadius.circular(20)`.
  - Include a 1px border: `border: Border.all(color: const Color(0xFF1E293B), width: 1)`.
  - Do not use harsh black elevation shadows; prefer flat bordered surfaces or subtle low-opacity blurs (`Colors.black.withOpacity(0.25)`).
- **Icons & Badges:**
  - Icons inside module cards must be wrapped in a soft circular or rounded container with 10–15% background tint matching the icon's intent color.
- **Top AppBar:**
  - Background: Transparent or matching canvas `#0A0D14`.
  - `elevation: 0`.
  - Title: Bold, left-aligned (`centerTitle: false`), 24–28pt font size.
- **Bottom Navigation Bar:**
  - Background: Solid `#0A0D14` or elevated `#121824` with a 1px top border `#1E293B`.
  - Selected tab: Active brand icon with filled style and label.
  - Unselected tabs: Muted `#64748B` with outlined style.

---

## 4. Privacy Presentation Standard
- Bondly is built on an owner-only confidential model.
- Any screen or section displaying confidential data (relationships, interaction notes, follow-up schedules) must include the privacy status component:
  - Surface: `#121824` or `#161327` (subtle violet hue).
  - Border: `#2E2856` or `#1E293B`.
  - Leading Icon: `Icons.lock_rounded` (16px, violet).
  - Micro-copy: "Owner-Only Privacy: Your contact notes, logs, and follow-ups are visible only to you." (12pt, medium weight).

---

## 5. Clean Architecture File Conventions
- Place full pages in `lib/features/<feature_name>/presentation/pages/`.
- Extract sub-components into `lib/features/<feature_name>/presentation/widgets/`.
- Do not build monolithic 500-line widget files; break modules into reusable atomic widgets.