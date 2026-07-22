## 1. Package scaffold (local-first)

- [ ] 1.1 Create the `CachedAsyncImage` Swift package — library target + test target, no third-party dependencies (Foundation / SwiftUI / UIKit / ImageIO). Add a README.
- [ ] 1.2 Add the package to MedalWall as a **local** package reference so it can be co-developed against the app.

## 2. ImageCache (TDD)

- [ ] 2.1 Write failing tests, then implement the in-memory tier: `NSCache` of decoded images keyed by `url + targetSize` (store/retrieve/miss).
- [ ] 2.2 Write failing tests, then implement the on-disk tier: original downloaded data keyed by a URL hash, in the Caches directory; persists across restart.
- [ ] 2.3 Write failing tests, then implement LRU eviction when the on-disk cache exceeds its ~200MB cap.
- [ ] 2.4 Write failing tests, then implement in-flight de-duplication (one fetch shared by concurrent same-URL requests).
- [ ] 2.5 Write failing tests, then implement ImageIO downsampling to `targetSize` (points → pixels via screen scale).
- [ ] 2.6 Make the cache `actor`-isolated / `Sendable`; expose a shared `ImageCache.shared`.

## 3. CachedAsyncImage view

- [ ] 3.1 Implement `CachedAsyncImage(url:targetSize:) { phase in … }` mirroring `AsyncImage`'s `.empty/.success/.failure`, loading via `ImageCache.shared` in a `.task` (cancels on disappear); never cache failures.
- [ ] 3.2 Add a `#Preview`.

## 4. Wire into MedalWall

- [ ] 4.1 Replace `AsyncImage` with `CachedAsyncImage` in `RaceImage`, `MedalImage`, `AvatarImage`, and `MedalDetailEventPhotosSection` (and edit-side event photos where they show remote URLs), passing each site's `ImageType.size` as `targetSize`; keep the existing no-photo/failure placeholders.

## 5. Verify

- [ ] 5.1 Package tests pass (`swift test` in the package / via Xcode).
- [ ] 5.2 App builds (`xcodebuild ... build`), SwiftLint clean.
- [ ] 5.3 Device check: revisiting a previously viewed image is instant (no reload), and images survive an app relaunch.

## 6. Publish (after the API settles)

- [ ] 6.1 Push `quien697/CachedAsyncImage`, tag a version (e.g. `1.0.0`), and switch MedalWall from the local reference to the versioned remote dependency.
