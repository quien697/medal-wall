## Why

Medal photos are often unusable for showing off a collection or sharing: messy backgrounds,
hands holding the medal, inconsistent framing. Every medal should look like a clean
collector's item. Design System v4.7.0 and the iOS mock v4.8.0 now draw the medal visuals
this needs.

## What Changes

- **BREAKING (data):** a medal holds an optional **front** photo and an optional **back**
  photo, replacing its single cover photo. Firestore stores `frontPhotoUrl` and
  `backPhotoUrl`; `photoUrl` is no longer read or written. Existing medals are test data and
  are not migrated.
- New photo flow for each face: a tip sheet (lay it flat in good light, or hang it) offering
  **Choose photo** and **Take photo** (the system camera, no guide overlay) → frame the medal
  in a square on the original photo → the background is removed on the device from the framed
  square → the result drops into the slot as a transparent PNG. When no medal can be picked
  out, the user can reframe the same photo or cancel.
- This square framing replaces the circle crop for medals. Avatar, race and edition photos
  are unchanged.
- The edit form shows two square slots, Front and Back. An empty slot starts the flow; a
  filled slot offers Replace Photo and Remove Photo. Removing one face leaves the other in
  place.
- Medal images show as a square (`radius.image`, card fill, hairline border) at 280 pt in
  the details, 96 pt in the list and 46 pt in search, always showing the front, with a
  labelled placeholder when there is no front. The cutout casts `elevation.cutout`.
- **No gold ring or bar on medal images.** The circular earned ring is removed from medal
  images, and the gilt bar Design System v4.7.0 draws under the square is not adopted
  (declared in `deviations.md`). The list and the details already say "No time recorded"
  for a medal without a finish time.
- Details: a FRONT / BACK button in the medal's top-right corner names the face in view and
  flips the medal. It shows only when a back exists; tapping the medal itself does not flip
  it. The flip uses `motion.flip`, and a fade under Reduce Motion.
- Search medal rows keep their place line and show no finish time, unlike the v4.8.0 mock
  (declared in `deviations.md`). Only their image changes.
- The personal-best carousel keeps showing no medal image.
- The medal skeleton bone becomes a square with `radius.image`.
- Storage accepts PNG uploads in a medal's front and back folders.

Out of scope: share cards, a camera with a shape guide overlay, migrating existing photos,
swiping between medals in the details.

## Capabilities

### New Capabilities
- `medal-photos`: a medal's front and back photos — the photo flow (tips, source, square
  framing, on-device background removal, failure), the stored image, the edit form's photo
  slots, and how a medal image is presented across the app.

### Modified Capabilities
- `medals`: a medal records optional front and back photos instead of one cover photo; the
  storage lifecycle rules apply to each.
- `medal-detail`: the identity band shows the medal's front in a square with no earned ring,
  and a face button flips it when a back exists.
- `search`: a medal result shows the medal's front photo, with no gold ring.
- `skeleton-loading`: bone appearance no longer refers to a medal ring, which no longer
  exists.

## Impact

- **Model and persistence:** `Medal` (`photoUrl` → `frontPhotoUrl`, `backPhotoUrl`), its
  sample data, `MedalFirestoreRepository`'s owned-field list, and every reader of the medal
  photo (list, search, details, delete).
- **Storage:** `PhotoStorage` / `StorageService` gain a PNG upload for a medal face, at
  `users/{uid}/medals/{medalId}/front/` and `…/back/`; `storage.rules` and `rules-tests/`
  change, and the rules need a deploy.
- **New code:** background removal (Vision, on device, behind a protocol), the tip sheet, the
  camera wrapper, the photo slots, the medal image component and the face button.
- **Edit Medal:** `EditMedalViewModel` stages two faces instead of one cover photo;
  `EditMedalView` replaces its circle crop with the square flow.
- **Shared UI:** `ImageType` medal cases become squares (hero 280); `MedalRingViewModifier`
  is removed; `ElevationViewModifier` gains `cutout`; a flip motion constant is added.
- **Dependency:** the `CropImage` package (the user's own library) needs an output-resolution
  option so a framed square can be saved at 840 × 840 — an additive, non-breaking release.
- **App configuration:** `NSCameraUsageDescription`, localized for zh-TW.
- **Localization:** new strings for the slots, tip sheet, framing, processing and failure, in
  English and zh-TW.
- **Design system:** two new `deviations.md` entries (the gilt bar, the search row).
- **Specs:** the `medals` delta replaces the scenario "Replace a medal's cover photo" with
  "Replace a medal's front photo", so archiving merges that requirement by hand (OpenSpec's
  archive refuses a MODIFIED block that drops a scenario).
