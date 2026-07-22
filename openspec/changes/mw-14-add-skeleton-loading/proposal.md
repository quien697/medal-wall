## Why

While a remote image loads, MedalWall shows a plain `ProgressView` spinner (or, for
medals, a static icon) that neither matches the final layout nor signals *where* content
is about to appear. A shape-matching skeleton placeholder reads as "content loading here"
and makes the wait feel intentional and polished (Jira MW-14).

## What Changes

- Add a reusable `Shimmer` view modifier (`View.shimmering()`) that renders a
  neutral-gray fill with an animated highlight sweeping across it, masked to whatever
  shape the caller applies it to.
- Replace the `AsyncImage` `.empty` (loading) branch in `RaceImage`, `MedalImage`,
  `AvatarImage`, and the medal event-photo gallery with a shimmer skeleton shaped and sized
  to that surface's final image region (rounded-rect for race and event photos, inner
  circle for medal and avatar).
- Respect Reduce Motion: when `accessibilityReduceMotion` is on, show the static neutral
  fill with no sweep.
- No change to the no-photo (nil URL) or failure placeholders, the local-`UIImage` path,
  or the full-screen `LoadingView`.

## Capabilities

### New Capabilities
- `image-loading`: how the app's remote-image components present their loading state — a
  shape-matching shimmer skeleton — and the boundaries around it (reduced-motion fallback;
  loading-only, leaving no-photo and failure states unchanged).

### Modified Capabilities
<!-- None. No existing spec specifies image loading UI; medals/races/profile specs are unaffected. -->

## Impact

- **New file:** `MedalWall/Shared/Modifiers/ShimmerViewModifier.swift` (modifier +
  `View.shimmering()` extension).
- **Edited:** `RaceImage.swift`, `MedalImage.swift`, `AvatarImage.swift`, and
  `MedalDetailEventPhotosSection.swift` — `.empty` branch.
- Reuses the existing `Color.Card.Background.tertiary`; no new colors and no new
  dependencies.
- Visual-only change with no ViewModel logic; verified via `#Preview` (no unit tests), per
  the workflow's per-task exception for non-testable SwiftUI surfaces.
