# MedalWall — Design System

Documents the visual language actually shipping in the app today, extracted from
`Assets.xcassets/Colors` and the `Shared/Modifiers/` style modifiers. This is the
baseline for consistency as new features are added, and the reference point if
MedalWall ever expands to web or Android — those platforms would need to translate
these token values themselves, since SwiftUI color sets and semantic fonts don't
transfer directly.

## Colors

All colors are defined with light/dark variants in `Assets.xcassets/Colors`, except
Gold (same in both modes).

| Token | Light | Dark |
|---|---|---|
| Background.primary | `#F0EEE8` | `#0C0D12` |
| Card.Background.primary | `#FFFFFF` | `#161820` |
| Card.Background.secondary | `#F5F3EE` | `#1D1F2C` |
| Card.Background.tertiary | `#ECEAE4` | `#232638` |
| Text.primary | `#1A1B22` | `#EEF0FF` |
| Text.secondary | `#6B6E80` | `#8890B0` |
| Text.tertiary | `#A0A3B0` | `#545870` |
| Border.gray | black 10% | white 10% |
| Gold.primary (Xcode: `AccentColor`) | `#C8A84B` | `#C8A84B` |
| Gold.secondary | `#F0D080` | `#F0D080` |

## Typography

No custom fonts — SF system font only, via SwiftUI's Dynamic Type semantic styles.
Keep it this way; a custom typeface is explicitly out of scope for now.

Scale in active use: `.largeTitle`, `.title`, `.title2`, `.title3`, `.headline`,
`.subheadline` (most common), `.body`, `.footnote`, `.caption`, `.caption2`.

**Named pattern:** `sectionTitleStyle()` — `.headline` + `.fontWeight(.heavy)` +
`.textCase(.uppercase)` + `Color.Text.tertiary`. Used for section headers.

**Known drift:** `ExpandedNavigationTitle.swift` hardcodes
`.font(.system(size: 34, weight: .bold))` instead of `.largeTitle`. Same visual size,
but opts out of Dynamic Type scaling. Worth fixing opportunistically, not urgent.

## Spacing & Radius

**Scale: 4 / 8 / 12 / 16 / 20 / 24 / 32.** This is the documented standard going
forward. 8pt and 16pt are already the dominant values in the codebase.

**Known drift (not urgent, reconcile opportunistically):** 2, 5, 6, 10, 15, 30 appear
scattered across the app, most notably 10pt, which is used almost as often as 8pt or
16pt. Don't chase these down proactively — align to the 4pt scale whenever a screen is
touched for other reasons.

**Corner radius:** 16px is standard for cards and buttons (`SurfaceViewModifier`,
`ButtonViewModifier`). Smaller radii (3/6/8/12px) appear in a few one-off spots.

## Components

Existing reusable style modifiers, in `Shared/Modifiers/`:

- **`surfaceStyle()`** — card surface: background color, 16px corner radius, 1px
  border, configurable padding. Default background `Card.Background.primary`,
  default border `Border.gray`.
- **Button styles** — `primaryButtonStyle()`, `secondaryButtonStyle()`,
  `tertiaryButtonStyle()`, `goldFillButtonStyle()`, `goldOutLineButtonStyle()`. All
  share `ButtonViewModifier`: capsule shape, 1px `Border.gray` stroke, `.subheadline`
  `.semibold` by default. They differ only in foreground/background color pairing
  (e.g. gold-outline = `Gold.primary` text on `Gold.primary` at 10% opacity).
- **`sectionTitleStyle()`** — see Typography above.
- **`fromLabelStyle()`** — bold + `Text.tertiary`, used for form field labels.

## Icons

SF Symbols exclusively. No custom icon set. Sizes are set ad hoc per usage
(`.font(.system(size: N))` on the symbol) rather than a documented icon-size scale —
e.g. 18pt for inline glyphs, 50–100pt for large illustrative icons (login screen,
error states).

## Portability Notes (future web/Android)

If MedalWall ever expands beyond iOS, these tokens are the ones that need re-expressing
in that platform's system:

- Color hex values above translate directly (CSS custom properties, Android color
  resources) — the light/dark pairing is the only structural thing to preserve.
- The type scale is iOS-specific (SwiftUI semantic styles map to San Francisco's
  Dynamic Type metrics) — a web/Android port needs its own type scale, ideally
  proportioned similarly (subheadline-equivalent as the workhorse size).
- Spacing scale (4/8/12/16/20/24/32) and the 16px card radius are unit-based and
  portable as-is.
- SF Symbols has no direct equivalent outside Apple platforms — a web/Android version
  needs its own icon set chosen or built from scratch.
