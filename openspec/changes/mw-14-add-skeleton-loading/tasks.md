## 1. Shimmer modifier

- [x] 1.1 Create `MedalWall/Shared/Modifiers/ShimmerViewModifier.swift` with a `Shimmer: ViewModifier` that overlays a moving `LinearGradient` highlight masked to the content, animated with a repeating `.linear` `repeatForever(autoreverses: false)` driven by an `onAppear`-toggled `@State` phase; add a `View.shimmering()` extension. Follow conventions (`///` docs, brace annotations, `// MARK:` only if ≥ 5 members).
- [x] 1.2 Add the Reduce Motion branch: read `@Environment(\.accessibilityReduceMotion)`; when enabled, render the content as-is (static neutral fill) with no sweep overlay or animation.
- [x] 1.3 Add a `#Preview` for the modifier: a neutral-filled shape with `.shimmering()`. (No reduce-motion preview variant: `accessibilityReduceMotion` is a read-only environment value and cannot be forced in a preview; that path is verified by code inspection / toggling the system setting.)

## 2. Wire the skeleton into the image components

- [x] 2.1 `RaceImage`: replace the `.empty` branch (icon + `ProgressView` overlay) with `imageType.shape` filled `Color.Card.Background.tertiary` at `imageType.size`, `.shimmering()`. Leave the nil-URL and failure placeholders unchanged.
- [x] 2.2 `MedalImage`: add an explicit `.empty` case rendering a circle skeleton at the inner image region (`size × 0.72`) inside the existing gold hexagon; keep the `default` (failure) gold-icon placeholder.
- [x] 2.3 `AvatarImage`: replace the `.empty` `ProgressView` with a circle skeleton in the inner region inside the gold ring; keep the `default` (failure) person-icon placeholder.
- [x] 2.4 `MedalDetailEventPhotosSection`: add an explicit `.empty` case rendering a shimmer skeleton (framed/clipped to the 140×110 rounded-rect thumbnail like the loaded image); keep the flat gray fill for the `default` (failure) case.

  (Note: per-component "loading" `#Preview`s were added during implementation, then removed — a fake URL never enters a real loading state in the Xcode preview canvas, so they showed no shimmer and were misleading. The `Shimmer` modifier keeps its own `#Preview`.)

## 3. Verify

- [x] 3.1 Build succeeds (`xcodebuild ... build`) and SwiftLint / swift-format are clean.
- [x] 3.2 Verified on a physical device: the shimmer skeleton shows and animates while real remote images load (race, medal, avatar). The event-photo surface (2.4) builds but has not yet been device-checked. (The Xcode preview canvas can't exercise this — a fake URL never enters a real `.empty` load — which is why the component loading previews were removed; the `Shimmer` modifier's own `#Preview` remains.) The reduce-motion static fallback is code-verified (`accessibilityReduceMotion` can't be forced in a preview).
