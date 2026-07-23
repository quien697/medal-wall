## 1. Package scaffold (local-first)

- [x] 1.1 Create the `CachedAsyncImage` Swift package — library target + test target, no third-party dependencies (Foundation / SwiftUI / UIKit / ImageIO). Add a README.
- [x] 1.2 Add the package to MedalWall as a **local** package reference so it can be co-developed against the app.

## 2. ImageCache (TDD)

- [x] 2.1 Write failing tests, then implement the in-memory tier: `NSCache` of decoded images keyed by `url + targetSize` (store/retrieve/miss).
- [x] 2.2 Write failing tests, then implement the on-disk tier: original downloaded data keyed by a URL hash, in the Caches directory; persists across restart.
- [x] 2.3 Write failing tests, then implement LRU eviction when the on-disk cache exceeds its ~200MB cap.
- [x] 2.4 Write failing tests, then implement in-flight de-duplication (one fetch shared by concurrent same-URL requests).
- [x] 2.5 Write failing tests, then implement ImageIO downsampling to `targetSize` (points → pixels via screen scale).
- [x] 2.6 Make the cache `actor`-isolated / `Sendable`; expose a shared `ImageCache.shared`.

## 3. CachedAsyncImage view

- [x] 3.1 Implement `CachedAsyncImage(url:targetSize:) { phase in … }` mirroring `AsyncImage`'s `.empty/.success/.failure`, loading via `ImageCache.shared` in a `.task` (cancels on disappear); never cache failures.
- [x] 3.2 Add a `#Preview`.

## 4. Wire into MedalWall

- [x] 4.1 Replace `AsyncImage` with `CachedAsyncImage` in `RaceImage`, `MedalImage`, `AvatarImage`, `MedalDetailEventPhotosSection`, and the edit-side `EditMedalEventPhotosSection` (remote-URL branch), passing each site's display size as `targetSize`; keep the existing no-photo/failure placeholders. All plain remote `AsyncImage` uses are now removed.

## 5. Verify

- [x] 5.1 Package tests pass — 8 tests across `DiskCacheTests`, `ImageDownsamplerTests`, `ImageCacheTests` (`swift test` on macOS host and `xcodebuild test` on iOS simulator both green).
- [x] 5.2 App builds (`xcodebuild ... build` → BUILD SUCCEEDED), SwiftLint clean.
- [x] 5.3 Device check: revisiting a previously viewed image is instant (no reload), and images survive an app relaunch.

## 6. Publish (after the API settles)

- [x] 6.1 Push `quien697/CachedAsyncImage`, tag a version (e.g. `1.0.0`), and switch MedalWall from the local reference to the versioned remote dependency.
