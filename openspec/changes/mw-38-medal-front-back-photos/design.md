## Context

A medal has one optional cover photo, `Medal.photoUrl`, picked with `PhotosPicker`, cropped to a
circle by the `CropImage` package, uploaded as JPEG to `users/{uid}/medals/{medalId}/cover/`, and
drawn by `PhotoImage` clipped to a circle inside the gold `MedalRingViewModifier`. `storage.rules`
accepts only `image/jpeg` in a medal's folder.

Design System v4.7.0 and the iOS mock v4.8.0 define the new medal image: a square
(`radius.image`, porcelain fill, ash hairline) at 280 / 96 / 46 pt, a cutout whose shadow follows
its alpha (`elevation.cutout`), a FRONT / BACK face button on the details hero, `motion.flip`,
two `PhotoSlot`s in the edit form, and a reference photo flow. `tokens.json` already records
v4.7.0. Two of its choices are not adopted: the gilt bar under the square, and the mock's search
medal row (which drops the place and adds the time).

Existing medal data is test data. Firestore documents are read by future web and Android
clients, so stored names must not be iOS-shaped.

## Goals / Non-Goals

**Goals:**
- Optional front and back photos per medal, each a transparent 840 × 840 PNG cut out on the
  device.
- One square medal image used by the list, search and the details, with no gold on it.
- A face button that flips the details medal when a back exists.
- Every piece of new logic testable without Vision, the camera or Firebase.

**Non-Goals:**
- Share cards, a camera with a guide overlay, swiping between medals in the details.
- Migrating `photoUrl` or its `cover/` files.
- Restyling the `CropImage` screen to match the mock's framing step (thirds grid, hint, Reset).
- Any change to avatar, race or edition photos, or to search rows beyond their image.

## Decisions

### Two flat fields: `frontPhotoUrl` and `backPhotoUrl`
`Medal.photoUrl` is replaced by `frontPhotoUrl: String?` and `backPhotoUrl: String?`, and
`MedalFirestoreRepository.medalUpdateFields` swaps `photoUrl` for the two (its test fails if a
`Medal` field is missing from the list). Flat keys match `photoUrl` on `User`, `Race` and
`RaceEdition`, and each face is cleared independently by the existing partial-update rule.
- *Keep `photoUrl` as the front and add `backPhotoUrl`*: rejected. A web or Android client would
  have to know that `photoUrl` means the front. Renaming is free while the data is test data.
- *A `photos: { front, back }` map*: rejected. Nothing else in the schema nests photo URLs, and
  it buys nothing over two optional fields.

A legacy `photoUrl` left in an old document is never read and, as an unlisted field, never
written.

### `MedalFace` names a face everywhere
`enum MedalFace { case front, back }` in `Models/Medal/` keys the edit form's staging, the
storage folder, the slot labels, and the details' face in view. One type keeps "which face"
from being re-derived from a `Bool` in four places.

### PNG uploads to per-face folders
`PhotoStorage.uploadMedalPhoto(userId:medalId:image:)` becomes
`uploadMedalFace(userId:medalId:face:image:)`, which writes `pngData()` with
`contentType = "image/png"` to `users/{uid}/medals/{medalId}/{front|back}/{UUID}.png`. A new
name per upload keeps the existing "never overwrite a file a medal points at" rule.
`PhotoOwner.medal` already owns everything under the medal's folder, so deletes need no change.
Event photos stay JPEG.

`storage.rules` splits the medal match: `front/{file}` and `back/{file}` accept only
`image/png`, `eventPhotos/{file}` only `image/jpeg`, and read and delete stay open to the owner
across the whole medal folder so an old `cover/` file can still be deleted. `rules-tests/`
covers each folder with the right type, the wrong type, and another user.

### Frame first, then remove the background
The user frames a square on the original photo; Vision then processes only that square.
Framing cuts off hands and table edges before segmentation, so what is left in the frame is
mostly the medal, and a failure has an obvious fix: reframe tighter with the same photo.
- *Remove the background first, then frame the cutout*: rejected. Segmentation would run on
  the whole scene, where a hand or a table edge competes with the medal as the subject.

### Background removal: Vision, behind a protocol
`BackgroundRemovalService` (behind `protocol BackgroundRemoval`) runs
`VNGenerateForegroundInstanceMaskRequest` on the framed square, masks **all** foreground
instances with `croppedToInstancesExtent: false`, so the medal keeps the position the user
framed it in, and renders the result at 840 × 840 into a non-opaque renderer at scale 1. No
foreground instance throws `noMedalFound`. The work runs off the main actor.
- *VisionKit subject lifting (`ImageAnalyzer`)*: rejected. It is built for interactive lifting
  from a view, and is harder to drive and test headless.
- *A bundled Core ML segmentation model*: rejected. Vision already ships one on the device.
- *Only the instance under the square's centre*: rejected for now. A medal with an open centre
  would be lost, and framing already removes the surroundings. Revisit if hands inside the
  square survive the cutout.

`EditMedalViewModel` takes `(any BackgroundRemoval)? = nil`, resolved with
`?? BackgroundRemovalService()`, like its other dependencies, so tests use a stub.

### Framing reuses `CropImage`, with a new output-size option
`CropImageView` with `.square` provides the pinch-and-drag framing. Its `crop` renders through
`ImageRenderer` at the renderer's default scale of 1, so a square comes out at its on-screen
side in pixels — roughly 300 px on a 402 pt wide phone — well under 840. `CropImage` gains an
optional output side (or render scale): an additive, non-breaking **1.1.0** whose default keeps
today's output for existing callers. MedalWall bumps its dependency and asks for at least 840 px.
The package's own screen is used as it is; the mock's framing screen is a reference.
- *Upscale the ~300 px crop*: rejected. The details draw the medal at 280 pt, 840 px at @3x, and
  an upscaled crop would be visibly soft.
- *A framing view inside MedalWall*: rejected. It would duplicate the gesture and clamping logic
  the package already has and tests.

### The flow lives in the edit form
Each face runs: tip sheet → library or camera → `CropImageView(.square)` → clearing → slot.
- `MedalPhotoTipsView` (sheet) names the face and offers Choose photo and, when
  `isCameraAvailable`, Take photo. The view model reads camera availability from an injected
  closure that defaults to `UIImagePickerController.isSourceTypeAvailable(.camera)`, so tests
  can set it.
- `CameraPickerView` wraps `UIImagePickerController` with `.camera`. There is no SwiftUI
  camera picker. `NSCameraUsageDescription` goes in `Info.plist`, with a new
  `InfoPlist.xcstrings` for its zh-TW text.
- Clearing shows in the slot itself (a spinner and "Clearing background…") while the rest of
  the form stays usable. Save is disabled until it finishes, because saving mid-clear would
  silently drop the photo.
- *A full-screen clearing step, as in the mock*: rejected. Keeping the user in the form is
  simpler, and the mock flow is a reference.
- No medal found shows an alert with **Reframe** (re-presents the crop sheet with the same
  picked photo) and **Cancel**. It is not an `AppError` through `ErrorView`, because that sheet
  offers only Continue.

`EditMedalViewModel` stages `frontPhoto` and `backPhoto` (`UIImage?`), a set of changed faces,
`clearingFace: MedalFace?` and `unrecognizedFace: MedalFace?`. `save()` resolves each face as the
cover photo resolves today: unchanged keeps its URL, changed uploads, removed becomes `nil`. A
replaced or removed face is deleted only after the save succeeds. The view holds only
presentation state: which sheet is up, and the picked photo kept for Reframe.

### One `MedalImage` component, no ring
`MedalImage` (Shared/Components) draws the square: `Surface.primary` fill, `Border.primary`
hairline, `radius.image`, the cutout drawn `.scaledToFit` inside, `.elevation(.cutout(side:))`,
and, without an image, the `medal.fill` glyph labelled "Front" (glyph alone at 46 pt). It wraps
`PhotoImage`, so caching, downsampling and the loading spinner are unchanged. `ImageType`'s
medal cases become `.rect(cornerRadius: .Radius.image)`, `.medal` grows to 280 pt, and the
skeleton bone follows `ImageType.shape`, so it turns square on its own.

`MedalRingViewModifier` is deleted with its three call sites (`MedalRow`, `SearchMedalRow`,
`MedalDetailHeroSection`). `Elevation.ring` stays, because it is still a design system token.

`Elevation` gains `case cutout(side: CGFloat)`, from the token list: light, y 0.08·s, blur
0.1·s, ink 28%; dark, a 1 pt paper rim at 50% plus y 0.08·s, blur 0.12·s, black 55%. The
modifier reads the colour scheme. SwiftUI's shadow follows an image's alpha, so the medal casts
the shadow and the square does not.

`CachedAsyncImage` writes the downloaded bytes to disk and downsamples them with ImageIO, which
keeps alpha, so it needs no change.

### The flip: state in the view model, motion in the view
`MedalDetailViewModel` holds `visibleFace: MedalFace = .front`, `hasBack` and `toggleFace()`,
and exposes the button's label. `MedalDetailHeroSection` turns the medal with `rotation3DEffect`
about the y axis using `Animation.Motion.flip` (`.spring(response: 0.45, dampingFraction:
0.78)`), swapping faces at 90°. Under Reduce Motion it crossfades with
`Animation.Motion.flipReduced` (`.easeInOut(duration: 0.2)`). A new `Animation+Extensions.swift`
holds both, beside the other token extensions. `MedalFaceButton` is an ink capsule in the
image's top-right corner. Its VoiceOver label is the face in view, with the hint "Shows the
back" or "Shows the front". The image itself has no tap action.

### Edit form slots
`EditMedalPhotosSection` lays out two `MedalPhotoSlot`s, Front then Back. An empty slot
(dashed pewter, "+ Add front") starts the flow. A filled slot opens a `confirmationDialog`
titled "Front photo" or "Back photo" with Replace Photo, Remove Photo (destructive) and Cancel,
and takes a 2 pt ink ring while the dialog is up.

### Declared deviations
`openspec/design-system/deviations.md` gains two entries, both `unreported` until the designer
confirms:
- `component.MedalImage.earnedBar`: not drawn. The list and the details already state "No time
  recorded", the bar would mark the default rather than the exception, and gold under a gold
  medal competes with the photo.
- iOS mock v4.8.0 search medal row: keeps the place and shows no time. The place is how a match
  by place explains itself (`search` spec, "A medal found by its place").

## Risks / Trade-offs

- [Vision's foreground mask may not run in the iOS Simulator] → Unit tests never call Vision:
  they use the `BackgroundRemoval` stub. The real service is checked on a device, early, before
  the UI is built on top of it.
- [The camera is unavailable in the Simulator] → Take photo is hidden there by the availability
  check. It is verified on a device.
- [The `elevation.cutout` formula may not match the mock's rendered shadows] → The token list
  wins. If it looks wrong on a device, record a deviation rather than copying the mock.
- [An 840 × 840 PNG is far larger than the JPEGs] → It holds one medal on transparency, and
  Storage has no size cap yet (MW-25). CachedAsyncImage downsamples it for the 96 and 46 pt
  squares.
- [Old test medals keep their `cover/` files in Storage] → They are test data. Deleting such a
  medal no longer finds the file, which stays until cleaned up by hand.
- [The live rules reject PNG until deployed] → Deploy `storage.rules` before any build that
  uploads a face runs against the live project.
- [`CropImage` is a public package] → The new option is additive with today's behaviour as the
  default, released as a minor version.

## Migration Plan

1. Release `CropImage` 1.1.0 and bump MedalWall's dependency.
2. Deploy `storage.rules` (`cd rules-tests && npm run deploy`) once `rules-tests` passes, before
   running a build that uploads faces.
3. No data migration. Medals saved before this change show the front placeholder.

Rollback: revert the branch; the PNG rules only widen what the owner may upload, so they can
stay.

## Open Questions

- Does `VNGenerateForegroundInstanceMaskRequest` run in the iOS 26.5 Simulator? This only
  decides where the real service is exercised, not the design.
