## ADDED Requirements

### Requirement: Shape-Matching Skeleton While Loading
The system SHALL display, while a remote image is loading, a skeleton placeholder that
matches the final image's shape and size, in place of a generic spinner. This applies to
the race, medal, and avatar image components.

#### Scenario: Race image loading
- **WHEN** a race image is loading from a remote URL
- **THEN** the system shows a rounded-rectangle skeleton at the image's final size

#### Scenario: Medal image loading
- **WHEN** a medal image is loading from a remote URL
- **THEN** the system shows a circular skeleton in the medal's inner image region, inside
  the medal's existing gold border

#### Scenario: Avatar image loading
- **WHEN** an avatar image is loading from a remote URL
- **THEN** the system shows a circular skeleton in the avatar's inner region, inside the
  avatar's existing gold ring

### Requirement: Animated Shimmer Treatment
The system SHALL render the skeleton as a neutral fill with a highlight that sweeps across
it in a continuous, repeating animation, signalling that content is loading.

#### Scenario: Shimmer animates during load
- **WHEN** a skeleton placeholder is shown for a loading image
- **THEN** a highlight sweeps across the neutral fill and repeats until the image resolves

### Requirement: Reduced-Motion Fallback
The system SHALL respect the system Reduce Motion setting: when it is enabled, the skeleton
SHALL show the static neutral fill without the sweeping highlight.

#### Scenario: Reduce Motion enabled
- **WHEN** the system Reduce Motion setting is enabled and an image is loading
- **THEN** the skeleton shows a static neutral fill with no sweep animation

### Requirement: Skeleton Is Loading-Only
The skeleton SHALL be shown only while a remote image is actively loading. The system SHALL
NOT replace the existing no-photo or load-failure placeholders, and SHALL NOT show a
skeleton for a locally supplied image that renders immediately.

#### Scenario: No remote photo set
- **WHEN** an image component has no photo URL
- **THEN** the system shows the existing placeholder, not a skeleton

#### Scenario: Remote image fails to load
- **WHEN** a remote image fails to load
- **THEN** the system shows the existing failure placeholder, not a skeleton

#### Scenario: Local image supplied
- **WHEN** an image component is given a local image already in memory
- **THEN** the system renders it directly with no skeleton
