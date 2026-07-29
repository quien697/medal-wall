# image-caching Specification

## Purpose
Let the app load remote images (race, medal, avatar, and event photos) efficiently — a
previously loaded image displays from cache without re-fetching, remote images decode at
their display size rather than full resolution, and the on-disk cache stays bounded and
purgeable.

## Requirements
### Requirement: Cached Remote Image Loading
The system SHALL cache remote images it loads, so that a previously loaded image is
displayed from cache without re-fetching from the network. The cache SHALL have an
in-memory tier and an on-disk tier, and the on-disk tier SHALL persist across app
relaunches.

#### Scenario: Second appearance uses the cache
- **WHEN** an image that was already loaded is displayed again during the same session
- **THEN** the system displays it from the in-memory cache without a network fetch

#### Scenario: Image survives an app relaunch
- **WHEN** an image was loaded in a previous session and is displayed after relaunch
- **THEN** the system displays it from the on-disk cache without re-fetching from the network

#### Scenario: Concurrent requests are de-duplicated
- **WHEN** the same image URL is requested by more than one view before it has finished
  loading
- **THEN** the system performs a single fetch and serves all requesters from it

### Requirement: Downsampled Decoding
The system SHALL decode a remote image downsampled to its display size rather than at full
resolution, to bound memory and decode cost.

#### Scenario: Large image shown at thumbnail size
- **WHEN** an image whose stored resolution far exceeds its display size is loaded
- **THEN** the system decodes it at approximately the display size, not at full resolution

### Requirement: Bounded, Purgeable Disk Cache
The on-disk cache SHALL reside in a system-purgeable location and SHALL be bounded by a
maximum size, evicting least-recently-used entries when the bound is exceeded. Cached
entries SHALL NOT expire by time, since image URLs are treated as immutable.

#### Scenario: Cache exceeds its size bound
- **WHEN** adding an image would push the on-disk cache past its maximum size
- **THEN** the system evicts least-recently-used entries until the cache is within bounds

### Requirement: Preserved Loading Phases
The caching image view SHALL expose loading, success, and failure phases so callers can
render their own placeholders. A failed load SHALL NOT be cached.

#### Scenario: Loading and failure states
- **WHEN** an image is loading, and separately when a load fails
- **THEN** the view reports a loading phase while fetching and a failure phase on error, and
  the caller's placeholder is shown for each

#### Scenario: Failure is not cached
- **WHEN** an image load fails and the same URL is requested again
- **THEN** the system attempts the fetch again rather than serving a cached failure
