## Why

Race, medal, avatar, and medal event photos use plain `AsyncImage`, which keeps no
decoded-image cache — every reappearance re-fetches from Firebase Storage, so photos
reload slowly even when previously viewed (Jira MW-17). Compounding it, uploads are stored
at full resolution, so each view also re-decodes an oversized JPEG into a small thumbnail.

## What Changes

- Introduce a reusable **`CachedAsyncImage`** — a drop-in replacement for `AsyncImage` that
  caches loaded images and downsamples them to their display size. Built as a new,
  self-contained package (`quien697/CachedAsyncImage`), developed local-first and consumed
  by MedalWall; later adopted by `quien697/PhotoViewer` so both share one cache.
- A process-wide **`ImageCache`**: in-memory (`NSCache`, decoded images keyed by URL +
  target size) backed by an on-disk store (original data keyed by URL, in the Caches
  directory, ~200MB LRU cap). No TTL — Firebase object URLs are treated as immutable.
- **Downsampling on decode** to the display size (via ImageIO), driven by each call site's
  `ImageType.size`.
- **In-flight de-duplication** so concurrent requests for the same URL share one fetch.
- Replace `AsyncImage` with `CachedAsyncImage` at MedalWall's image surfaces: `RaceImage`,
  `MedalImage`, `AvatarImage`, and the medal event-photo grid. The phase API is preserved
  so existing placeholders (and the future MW-14 skeleton) keep working.

## Capabilities

### New Capabilities
- `image-caching`: how the app loads remote images so previously viewed images display
  without re-fetching, decoded at display size, within bounded memory/disk.

### Modified Capabilities
<!-- None on this branch. The image-loading capability (MW-14 skeleton) lives on a
     separate branch and is not present here; the two integrate later via the preserved
     phase API. -->

## Impact

- **New package:** `quien697/CachedAsyncImage` (`CachedAsyncImage` view + `ImageCache`),
  no third-party dependencies (Foundation / SwiftUI / UIKit / ImageIO only). Wired into
  MedalWall as a local package during development; published and pinned to a version once
  stable.
- **Edited:** `RaceImage.swift`, `MedalImage.swift`, `AvatarImage.swift`,
  `MedalDetailEventPhotosSection.swift` (and edit-side event photos where they show remote
  URLs) — swap `AsyncImage` → `CachedAsyncImage`.
- **Out of scope (separate tickets):** downsizing images on upload + a Firebase Storage
  size rule (write path); updating `PhotoViewer` to adopt the shared cache (separate repo).
