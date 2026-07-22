## Context

Three shared components render remote images via `AsyncImage`: `RaceImage`, `MedalImage`,
and `AvatarImage`. Their loading (`.empty`) state is inconsistent — `RaceImage` and
`AvatarImage` overlay a `ProgressView` spinner, while `MedalImage` shows its static gold
icon. None of these match the final image's footprint, so the layout visibly shifts when
the image arrives.

`ImageType` already encodes each image's `shape` (circle for avatar/medal, 16pt
rounded-rect for race/event) and `size`, and the no-photo placeholder already fills with
`Color.Card.Background.tertiary`. So the pieces needed to draw a shape-matching skeleton
already exist; what's missing is a reusable shimmer treatment and the wiring into each
`.empty` branch.

This is a presentation-only change: no models, repositories, ViewModels, or data flow are
touched.

## Goals / Non-Goals

**Goals:**
- A single reusable shimmer treatment usable by any component, adapting to that
  component's own shape and frame.
- Each image's loading state visually matches its final layout (shape + size + position).
- Respect Reduce Motion.

**Non-Goals:**
- No change to the no-photo (nil URL) or failure placeholders — skeleton is loading-only.
- No skeleton for the local-`UIImage` path (renders instantly, no load).
- No change to the full-screen `LoadingView`.
- No minimum-display / anti-flash delay for fast (cached) loads (YAGNI).
- No new colors, no new dependencies.

## Decisions

**A reusable `View` modifier, not a per-`ImageType` skeleton view.**
The three components load into *different* regions: `RaceImage` fills its whole frame,
`MedalImage` into an inner circle at `size × 0.72` inside its gold hexagon, `AvatarImage`
into the inner circle inside its ring. A single `ImageSkeleton(imageType:)` view would
need extra scale/offset parameters to fit all three, leaking layout knowledge across the
boundary. Instead, `Shimmer: ViewModifier` + `View.shimmering()` lets each component fill
its own shape at its own frame and apply the sweep — the component keeps its layout, the
modifier owns only the animation. *Alternative considered:* `.redacted(reason:
.placeholder)` + overlay — rejected because there is no real content to redact (the
loading region is a blank shape), so redaction adds indirection with no gain and still
needs a separate shimmer.

**Shimmer sweep over pulse/static.** A neutral-gray fill with a white highlight sweeping
left→right (~1.4s, repeating) is the established "content streaming in" cue and tested
better than a pulse (reads as "waiting") or a static fill (no feedback). Chosen via visual
mockups during brainstorming.

**Neutral gray, reusing `Color.Card.Background.tertiary`.** The medal and avatar keep
their gold borders while loading; a neutral fill inside keeps contrast and lets the gold
border stay the only accent. Reusing the existing placeholder color makes the loading and
no-photo states read as one family and adds no color to the palette.

**Implementation shape.** The sweep is a moving `LinearGradient` overlay masked to the
content (`.mask`/`.overlay` on the filled shape), animated with a repeating
`withAnimation`/`.linear(...).repeatForever(autoreverses: false)` driven by an
`onAppear`-toggled `@State` phase. Reduce Motion (`@Environment(\.accessibilityReduceMotion)`)
short-circuits to the static fill with the sweep overlay omitted.

## Risks / Trade-offs

- **Animation left running off-screen** → the sweep is scoped to the `.empty` branch only,
  which SwiftUI removes from the tree once `AsyncImage` transitions to `.success`/failure,
  so the animation stops with it.
- **Flash on fast/cached loads** (skeleton appears for a frame) → accepted; adding a
  minimum-display delay would make *every* load feel slower to avoid a rare flicker.
- **Purely visual, so no unit coverage** → verified on a physical device (the shimmer shows
  and animates during real remote-image loads), plus the `Shimmer` modifier's `#Preview`,
  per the workflow's per-task exception for non-testable SwiftUI surfaces. The Xcode preview
  canvas can't exercise a real load, and Reduce Motion cannot be forced in a preview
  (read-only environment value), so that path is code-verified.
