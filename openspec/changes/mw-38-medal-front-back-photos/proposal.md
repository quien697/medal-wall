## Why

Medal photos are often unusable for showing off a collection or sharing: hands and table edges
in the shot, inconsistent framing, and a single photo that has no room for the back. Every
medal should show its front and its back, framed the same way. Design System v4.7.0 and the
iOS mock v4.8.0 now draw the medal visuals this needs.

## What Changes

- **BREAKING (data):** a medal holds an optional **front** photo and an optional **back**
  photo, replacing its single cover photo. Firestore stores them as one `photoUrls` map,
  `{ front, back }`, with a key only for a face that has a photo; `photoUrl` is no longer read
  or written. Existing medals are test data and are not migrated.
- New photo flow for each face: **Choose Photo** or **Take Photo** (the system camera, no
  guide overlay) → frame the medal in a square on the original photo → the framed square drops
  into the slot as an 840 × 840 JPEG.
- This square framing replaces the circle crop for medals. Avatar, race and edition photos
  are unchanged.
- The edit form shows two square slots, Front and Back, drawn by a new shared `PhotoSlot`.
  Tapping a slot offers Choose Photo and Take Photo, and a filled slot also offers Remove Photo.
  Removing one face leaves the other in place.
- Take Photo is always offered. Tapping it opens the camera when camera access allows it, lets
  iOS ask for access when it has not asked yet, and otherwise says why the camera cannot open:
  access is off (with a way to Settings), or the device has no camera.
- Medal images show as a square (`radius.image`) at 280 pt in the details, 96 pt in the list
  and 46 pt in search, always showing the front, with a labelled placeholder when there is no
  front. The photo fills the square, drawn by the same component as every other photo.
- **No gold ring or bar on medal images.** The circular earned ring is removed from medal
  images, and the gilt bar Design System v4.7.0 draws under the square is not adopted
  (declared in `deviations.md`). The list and the details already say "No time recorded"
  for a medal without a finish time.
- **The medal image is the framed photo, not a background-removed cutout** on porcelain with an
  ash hairline, as Design System v4.7.0 draws it (declared in `deviations.md`).
- Details: tapping anywhere on the medal flips it, and a FRONT / BACK label in its top-right
  corner names the face in view; an empty face shows its placeholder. The label is not a button
  of its own and shows on every medal, where Design System v4.7.0 makes it the flip button,
  shown only when a back exists (declared in `deviations.md`). The flip
  uses `motion.flip`, and a fade under Reduce Motion.
- Search medal rows keep their place line and show no finish time, unlike the v4.8.0 mock
  (declared in `deviations.md`). Only their image changes.
- The personal-best carousel keeps showing no medal image.
- The medal skeleton bone becomes a square with `radius.image`.

Out of scope: removing a photo's background, share cards, a camera with a shape guide overlay,
migrating existing photos, swiping between medals in the details, and moving the avatar, race
and edition photos to `PhotoSlot`.

## Capabilities

### New Capabilities
- `medal-photos`: a medal's front and back photos — the photo flow (source, square framing),
  the stored image, the edit form's photo slots, and how a medal image is presented across the
  app.

### Modified Capabilities
- `medals`: a medal records optional front and back photos instead of one cover photo; the
  storage lifecycle rules apply to each.
- `medal-detail`: the identity band shows the medal's front in a square with no earned ring,
  and tapping it flips it, with a label naming the face in view and an empty face's
  placeholder.
- `search`: a medal result shows the medal's front photo, with no gold ring.
- `skeleton-loading`: bone appearance no longer refers to a medal ring, which no longer
  exists.
- `design-system-sync`: the check pairs `elevation.hairline` with the border `surfaceStyle`
  draws, and reports every shadow level as unimplemented while the code defines no
  `Elevation`.

## Impact

- **Model and persistence:** `Medal` (`photoUrl` → `photoUrls: MedalPhotoUrls?`), its
  sample data, `MedalFirestoreRepository`'s owned-field list, and every reader of the medal
  photo (list, search, details, delete).
- **Firestore rules:** `firestore.rules` accepts a medal's `photoUrls` only as a map holding
  nothing but a `front` and a `back` string; `rules-tests/` covers it, and the rules are
  deployed with the change.
- **Storage:** `PhotoStorage` / `StorageService` upload a medal face as a JPEG to
  `users/{uid}/medals/{medalId}/front/` and `…/back/`. The current `storage.rules` already
  accept a JPEG anywhere in a medal's folder, so the rules do not change; `rules-tests/` gains
  cases for the two folders.
- **New code:** `PhotoSlot` in `Shared/Components` (the slot, its source alert, and the
  library, camera and framing it runs), `CameraAccess`, the camera wrapper, and the details
  medal's flip image, face label and face visibility modifier.
- **Edit Medal:** `EditMedalViewModel` stages two faces instead of one cover photo;
  `EditMedalView` replaces its circle crop with the square flow.
- **Shared UI:** `ImageType` medal cases become squares (hero 280); `PlaceholderImage` takes
  an optional text beneath its glyph, passed through `PhotoImage`; `MedalRingViewModifier` is
  removed, and `ElevationViewModifier` with it (the ring was its only user); a flip motion
  constant is added.
- **Dependency:** `CropImage` 1.1.0 (the user's own library) adds an output size, so a framed
  square is saved at 840 × 840. MedalWall requires it from the package's remote repository.
- **App configuration:** `NSCameraUsageDescription`, localized for zh-TW.
- **Localization:** new strings for the slots, the source alert, the camera access alerts and
  the face label and flip hints, in English and zh-TW.
- **Design system:** four new `deviations.md` entries (the gilt bar, the photo in place of a
  cutout, the face label in place of the face button, the search row); `CLAUDE.md` and the
  `design-system-check` skill stop naming `ElevationViewModifier`.
- **Specs:** the `medals` delta replaces the scenario "Replace a medal's cover photo" with
  "Replace a medal's front photo", so archiving merges that requirement by hand (OpenSpec's
  archive refuses a MODIFIED block that drops a scenario).
