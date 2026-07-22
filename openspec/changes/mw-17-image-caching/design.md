## Context

All five remote-image surfaces (`RaceImage`, `MedalImage`, `AvatarImage`, and the medal
event-photo grids) use plain `AsyncImage`. `AsyncImage` holds no decoded-image cache, so
navigating away and back re-fetches from Firebase Storage. Separately, `StorageService`
uploads full-resolution JPEGs (`jpegData(0.8)`, no resize), so each display also decodes an
oversized image into a 60–160pt thumbnail. Both contribute to MW-17's "loading too long".

There is no caching layer anywhere in the codebase today. The app already depends on the
author's own small packages (`CropImage`, `PhotoViewer`, `TimePicker`) and otherwise keeps
third-party dependencies minimal.

## Goals / Non-Goals

**Goals:**
- Previously loaded images display instantly, without re-fetching, within a session and
  across app relaunches.
- Images are decoded downsampled to their display size to bound memory and CPU.
- A drop-in replacement for `AsyncImage` that preserves the loading/success/failure phases.
- Reusable across the app and the `PhotoViewer` package via one shared cache.

**Non-Goals:**
- Downsizing images on **upload** and enforcing a Firebase Storage size limit (write path +
  infra — separate ticket). MW-17 fixes the read path only, which also covers the large
  images already in Storage.
- Updating the `PhotoViewer` package itself (separate repo / ticket). MW-17 makes the cache
  extraction-ready so that adoption is trivial.
- Prefetching, animated formats, or a full image-processing pipeline (YAGNI).

## Decisions

**Custom package `quien697/CachedAsyncImage`, not a third-party library.** Fits the
project's minimal-dependency, own-package style; the need (cache decoded images by URL,
downsample) is simple enough to own; and the cache logic is cleanly unit-testable.
*Alternative considered:* Nuke/Kingfisher — more robust out of the box (downsampling,
prefetch) but adds a third-party dependency against the project's pattern.

**Package, developed local-first.** The code lives in its own repo so both MedalWall and
`PhotoViewer` can depend on it (a diamond dependency SPM resolves to one version). During
development it is added to MedalWall as a **local package reference**; once stable it is
pushed, tagged, and pinned to a version. *Alternative considered:* build in-app under
`Shared/` then extract — rejected because it forces rework and delays PhotoViewer reuse.

**One shared `ImageCache.shared`.** Because both consumers link the same package, a single
process-wide cache means a thumbnail loaded in the app warms the disk cache, and opening
`PhotoViewer` on the same URL reads the original from disk instead of re-fetching.

**Two-tier cache.** Memory (`NSCache`) holds decoded, downsampled images keyed by
`url + targetSize` (thumbnail and full-size are distinct entries). Disk holds the
**original** downloaded data keyed by a URL hash, so any display size can be re-derived and
`PhotoViewer`'s full-screen view benefits. Disk lives in the **Caches** directory
(system-purgeable — correct for a cache), bounded by a **~200MB LRU** cap. No TTL: Firebase
object URLs are immutable (replacing a photo yields a new URL).

**Drop-in phase API.** `CachedAsyncImage(url:targetSize:) { phase in … }` mirrors
`AsyncImage`'s `.empty/.success/.failure`, so call sites change minimally and existing
placeholders — and the future MW-14 `.empty` skeleton — keep working.

**Downsampling via ImageIO.** `CGImageSourceCreateThumbnailAtIndex` decodes at ~display
resolution (points → pixels via screen scale), avoiding full-res decode into a small frame.

## Risks / Trade-offs

- **Swift 6 concurrency** → the cache is `actor`-isolated (or `NSCache` + an actor for disk
  IO) so it is `Sendable`; call sites load via `.task` which cancels on disappear.
- **Disk eviction correctness** (LRU, size accounting, thread safety) is the main
  home-grown risk → covered by unit tests in the package (store/retrieve/evict past cap/
  dedup/persist across restart), which is why a custom cache is acceptable here.
- **Package versioning friction** during co-development → mitigated by the local-package
  reference; only publish/tag once the API settles.
- **Existing oversized originals** still cost bandwidth on first load and disk space →
  bounded by the LRU cap; the upload-downsize ticket shrinks them at the source later.
- **PhotoViewer still re-fetches** until its own ticket lands → acceptable; it is a
  secondary (on-tap) surface and the cache is built to be shared when it adopts the package.
