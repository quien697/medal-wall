## Context

A medal has one optional cover photo, `Medal.photoUrl`, picked with `PhotosPicker`, cropped to a
circle by the `CropImage` package, uploaded as JPEG to `users/{uid}/medals/{medalId}/cover/`, and
drawn by `PhotoImage` clipped to a circle inside the gold `MedalRingViewModifier`. `storage.rules`
accepts only `image/jpeg` in a medal's folder.

Design System v4.7.0 and the iOS mock v4.8.0 define the new medal image: a square
(`radius.image`, porcelain fill, ash hairline) at 280 / 96 / 46 pt, a cutout whose shadow follows
its alpha (`elevation.cutout`), a FRONT / BACK face button on the details hero, `motion.flip`,
two `PhotoSlot`s in the edit form, and a reference photo flow. `tokens.json` already records
v4.7.0. Four of its choices are not adopted: the gilt bar under the square, the
background-removed cutout (the image is the framed photo), the face button (a label names the
face on every medal, and the whole medal flips), and the mock's search medal row (which drops the place and
adds the time).

Existing medal data is test data. Firestore documents are read by future web and Android
clients, so stored names must not be iOS-shaped.

## Goals / Non-Goals

**Goals:**
- Optional front and back photos per medal, each an 840 × 840 JPEG framed on the device.
- One square medal image used by the list, search and the details, with no gold on it.
- Tapping the details medal flips it, with a FRONT / BACK label naming the face in view; an
  empty face shows its placeholder.
- Every piece of new logic testable without the camera or Firebase.

**Non-Goals:**
- Removing a photo's background.
- Share cards, a camera with a guide overlay, swiping between medals in the details.
- Migrating `photoUrl` or its `cover/` files.
- Restyling the `CropImage` screen to match the mock's framing step (thirds grid, hint, Reset).
- Any change to search rows beyond their image.

## Decisions

### One `photoUrls` map, keyed by face
`Medal.photoUrl` is replaced by `photoUrls: MedalPhotoUrls?`, stored as
`photoUrls: { front, back }` with a key only for a face that has a photo. The keys are the
faces' Storage folder names. `MedalPhotoUrls` (`Models/Medal`) holds `front: String?` and
`back: String?`, reads a face's URL by `MedalFace` subscript, and reports `isEmpty`; code that
handles both faces loops over `MedalFace.allCases` instead of repeating itself per face.
`MedalFirestoreRepository.medalUpdateFields` swaps `photoUrl` for `photoUrls` (its test fails
if a `Medal` field is missing from the list).
- A medal without photos stores no map: `EditMedalViewModel.save` sets `photoUrls` to `nil`
  when both faces are empty, so the field is omitted on create and deleted on update. An empty
  map another client stores still decodes, as no photos, since both keys are optional.
- An update writes the whole map, as it writes `place`, `raceEvent` and `result`, so a face
  missing from it is dropped from the stored document. A key another client adds inside the
  map does not survive an iOS edit, which the rules below keep from arising.
- *Two flat fields, `frontPhotoUrl` and `backPhotoUrl`*: rejected. Nothing groups them for a
  reader of the document, and every per-face read, write and delete is written twice.
- *Keep `photoUrl` as the front and add `backPhotoUrl`*: rejected. A web or Android client would
  have to know that `photoUrl` means the front. Renaming is free while the data is test data.

A legacy `photoUrl` left in an old document is never read and, as an unlisted field, never
written.

### `MedalFace` names a face everywhere
`enum MedalFace { case front, back }` in `Models/Medal/` keys the edit form's staging, the
storage folder, the slot labels, and the details' face in view. One type keeps "which face"
from being re-derived from a `Bool` in four places.

### JPEG uploads to per-face folders
`PhotoStorage.uploadMedalPhoto(userId:medalId:image:)` becomes
`uploadMedalFace(userId:medalId:face:image:)`, which uploads the face as a JPEG, encoded by
`UIImage.uploadData()` like every other photo, to
`users/{uid}/medals/{medalId}/{front|back}/{UUID}.jpg`. A new name per upload keeps the
existing "never overwrite a file a medal points at" rule. `PhotoOwner.medal` already owns
everything under the medal's folder, so deletes need no change.

`storage.rules` does not change: its medal match, `users/{uid}/medals/{medalId}/{allPaths=**}`,
already lets the owner read, delete and upload a JPEG anywhere in the folder, so the new
`front/` and `back/` folders and an old `cover/` file are covered. `rules-tests/` adds cases for
`front/` and `back/` — the owner's JPEG is accepted, a PNG is refused, another user is refused —
so a later split of the medal match cannot drop them unnoticed.

`firestore.rules`' `isValidMedal` accepts `photoUrls` when it is absent or null, or a map whose
keys are only `front` and `back`, each absent, null or a string, mirroring how it checks
`result`. `rules-tests/` covers each face alone, both, an empty map, a non-map, a non-string
URL, an unknown key, and an update that replaces or deletes the map.

### Framing reuses `CropImage`'s screen, at 840 px
`CropImageView(image:cropShape: .square, outputSide: 840)` provides the pinch-and-drag framing
and returns the square at 840 × 840 pixels. Without `outputSide`, `CropImage` renders the square
at its on-screen side at scale 1, roughly 300 px on a 402 pt wide phone. `outputSide` arrived in
`CropImage` **1.1.0**, an additive release whose default keeps the old output for the avatar,
race and edition crops. MedalWall requires `CropImage` from 1.1.0 (up to the next major) from
its remote repository, like its other packages, because CI checks out only this repository.
The package's own screen is used as it is; the mock's framing screen is a reference.
- *Upscale the ~300 px crop*: rejected. The details draw the medal at 280 pt, 840 px at @3x, and
  an upscaled crop would be visibly soft.
- *A framing screen built on `CropArea`, with the mock's thirds grid, hint and Reset*: not
  needed. The ready-made screen frames a square at 840 px, which is all this change asks of it.

### `PhotoSlot` runs the flow
Each face runs: slot → source alert → library or camera → `CropImageView` → slot. The design
system's `PhotoSlot`, in `Shared/Components`, owns all of it, so a form hands it a photo and
receives a framed one:
`PhotoSlot(photo:imageType:cropShape:outputSide:title:message:placeholderText:offersCamera:onPick:onRemove:onError:)`.
It holds presentation state (which alert, picker or sheet is up, and the picked photo for the
crop sheet), and its view model, `PhotoSlotViewModel`, decides what Take Photo leads to, turns
a picked or taken photo into the one the crop sheet frames, and decides what the slot shows and
what VoiceOver reads for it. It passes a photo that fails to load to `onError`, which the
form shows as it shows any other error. The crop sheet is presented from the picked photo itself,
`.sheet(item:)` with a `PickedPhoto`, never from a flag beside it: a sheet's content reading
`@State` its view's body never reads gets the value from before the first presentation, so the
first crop screen would open without the photo. Every form photo goes through it, so the flow
exists once (see Every form photo is a `PhotoSlot`).
- Tapping a slot opens an alert titled by the form, here "Front photo" or "Back photo",
  offering **Choose Photo**, **Take Photo** while `offersCamera` is true, **Remove Photo**
  (destructive) when the slot is filled, and **Cancel**, stacked as full-width buttons in the
  middle of the screen. Replacing a face is choosing or taking a new photo from the same alert.
  The buttons are verbs, as alert buttons are: "Take Photo" and "Choose Photo", not "Camera"
  and "Photo Library".
- The medal form's message says how to shoot the medal: flat on a plain surface from straight
  above, or hung on a plain wall, with everything else out of the shot, in even light with no
  flash. A clear background makes a clean photo now, and it is what a later background removal
  needs from the stored 840 px squares. The message names no background removal, which the app
  does not do.
- Take Photo is offered whether or not the camera can open, and tapping it reads
  `CameraAccess`, from whether the device has a camera
  (`UIImagePickerController.isSourceTypeAvailable(.camera)`) and
  `AVCaptureDevice.authorizationStatus(for: .video)`:
  - `granted`: the camera opens.
  - `undetermined`: iOS asks, and the camera opens if the user allows it.
  - `denied` (access turned off, or restricted by Screen Time): an alert, "Allow Camera Access",
    "Turn on camera access in Settings to take a photo.", with **Open Settings** and **Cancel**.
  - `unavailable` (the device has no camera): an alert, "No Camera", "This device has no
    camera. Choose a photo instead.", with the system's OK.
  `CameraAccess` is a plain mapping of the two inputs, so its tests cover every case without
  a device.
- `CameraPickerView`, in `Shared/Components`, wraps `UIImagePickerController` with `.camera`.
  There is no SwiftUI camera picker. `NSCameraUsageDescription` goes in `Info.plist`, with a new
  `InfoPlist.xcstrings` for its zh-TW text.
- *A tip sheet before the source, as in the mock*: rejected. The alert's message carries the
  tips without adding a step.

`EditMedalViewModel` stages `frontPhoto` and `backPhoto` (`UIImage?`) and a set of changed
faces. A framed photo is staged for its face as it arrives, and removing a face stages `nil`;
neither touches the other face. `save()` resolves each face as the cover photo resolves today:
unchanged keeps its URL, changed uploads, removed becomes `nil`. A replaced or removed face is
deleted only after the save succeeds.

### Medals use `PhotoImage`, with no ring
A medal is drawn by `PhotoImage`, like every other photo, so caching, downsampling, the loading
spinner and the skeleton bone are shared. `ImageType`'s medal cases become
`.rect(cornerRadius: .Radius.image)` and `.medal` grows to 280 pt, so the photo fills a square,
and the bone, which follows `ImageType.shape`, turns square on its own. Without a photo,
`PhotoImage` shows `PlaceholderImage`, which takes an optional text beneath its glyph:
`PhotoImage(…, placeholderText:)` passes it through. The list and the details label a missing
face with `MedalFace.title` ("Front", "Back"); search's 46 pt square shows the glyph alone.
- *A medal-only image component, with the design system's porcelain fill and ash hairline*:
  rejected. Without a cutout a medal is a photo like any other, and a second component would
  copy `PhotoImage`'s loading for a fill no photo shows and a hairline.

`MedalRingViewModifier` is deleted with its three call sites (`MedalRow`, `SearchMedalRow`,
`MedalDetailHeroSection`), and `ElevationViewModifier` with it: the ring was the only view that
cast a design system shadow. The square casts none. `elevation.cutout` follows a cutout's
alpha, and on an opaque photo it would shadow the whole square, which the design system keeps
flat.

### The flip: state and its math in the view model, motion in the view
`MedalDetailViewModel` holds `faceInView`, the face the user turned to whether or not it has a
photo, with `toggleFace()` and `flipHint`. It also holds the flip's math
as static functions, so it is tested without a view: `flipAngle(showing:)` (0 for the front,
180 for the back), `rotation(showing:turns:)` (that angle while the medal turns, none under
Reduce Motion), `faceOpacity(_:flipAngle:turns:)` (a face shows only while it faces the viewer,
swapping at 90°, or crossfades under Reduce Motion) and `flipAnimation(turns:)`
(`Animation.Motion.flip`, `.spring(response: 0.45, dampingFraction: 0.78)`, or
`Animation.Motion.flipReduced`, `.easeInOut(duration: 0.2)`). A new `Animation+Extensions.swift`
holds both motions, beside the other token extensions.

`MedalFlipImage` draws the two faces back to back and turns them with `rotation3DEffect` about
the y axis, passing `turns: !reduceMotion` to those functions, since Reduce Motion is read from
the environment. Each face wears `MedalFaceVisibilityViewModifier` (in `MedalDetail/Modifiers`),
which animates the flip angle alongside the turn so every frame asks `faceOpacity` for that
angle. An empty face shows the photo placeholder labelled with that face. The face label, an
ink chip (`.chipStyle(.primary)`, since chips name things), sits in the medal's top-right
corner on every medal, inset `.Space.stack`, outside the turning faces so it never mirrors. The
label has no action of its own. `MedalDetailHeroSection` makes the whole medal one plain button
that flips it. The button's VoiceOver label is the face in view, with the hint "Shows the back"
or "Shows the front".

### Edit form slots
`EditMedalPhotosSection` lays out two `PhotoSlot`s, Front then Back, each labelled with its face
beneath. A slot is empty (`EmptyPhotoSlot`, the one dashed pewter slot every form shows, here
"+ Add front"), filled, or active: it takes a 2 pt ink
ring while its alert is up. It is drawn at its `ImageType`'s size, shrinking to the width it is
given, so the two 280 pt `.medal` slots share the row.

### Every form photo is a `PhotoSlot`
Edit Profile, Edit Race and Edit Edition set their photo through `PhotoSlot` too, and
`EditPhotoPicker` is deleted with their own picker, loading and crop sheet. Each slot is drawn
at its `ImageType`'s size and offers Take Photo like a medal face, so every form behaves the
same:
- Edit Profile: "Profile photo", `.avatar`, framed in a circle.
- Edit Race: "Race logo", `.raceHero`, framed in a square.
- Edit Edition: "Edition photo", `.raceHero`, framed in a square, with the message "Leave it
  empty to use the race logo." in its alert.

None carries text beneath it: the slot's plus says what tapping does, so the old "Tap to add a
photo" hints and the edition's `photoHint` are gone. Their framed output keeps `CropImage`'s
default size.

### A stored photo while it downloads
A form downloads its stored photo when it opens, and a download can be slow or fail.
`StoredPhotoStatus` (`Shared/UIModels`) is `loading` or `failed`; each edit view model holds
one per stored photo (one per face for a medal), `loading` from its init while there is a
stored URL, cleared when the photo arrives or the user picks or removes one, and `failed` when
the download returns nothing. `PhotoSlot` takes it as `storedPhotoStatus`, and
`PhotoSlotViewModel.content(photo:storedPhotoStatus:)` decides what the slot shows:
- `photo`: the photo, with a 1 pt hairline.
- `loading`: a spinner, with the hairline.
- `failed`: a warning glyph over "Couldn't load", with the hairline.
- `empty`: `EmptyPhotoSlot`.

Every state but `empty` offers Remove Photo and reads its title to VoiceOver. A stored photo
that could not load is kept on save unless the user replaces or removes it, because the view
models only write a photo the user changed. There is no retry control; reopening the form
downloads again.

### The design system lives in Claude
The design system and the iOS mockups are pages of one Claude design canvas, linked from
`CLAUDE.md`: "Design System v…" and "Mockup - iOS v…". Claude Code reads them with the Artifact tool, so a
session always checks against the current page and nothing has to be copied into the repo when
the designer releases a version. `tokens.json` stays the committed record of what the code was
last checked against.
- The canvas index, `project/canvas.json`, names each page and gives every artboard its page.
  The `#page-…` links in `CLAUDE.md` are the editor's own ids and are not in the index, so a
  page is found by its name — the one starting "Design System", the one containing "iOS v" —
  and its version is read from the name.
- `tokens.json`'s `source` records the canvas, the page, its version, the artifact version
  read, and a hash of that page's artboards in canvas order. The artifact version moves with
  an edit to any page; the hash moves only when the Design System page does.
- The check that runs every session reads only the index's page names.

### What the design system states for MW-38
Design System v4.7.1 and Mockup - iOS v4.8.2 state these choices, so `deviations.md` holds no
entry for MW-38:
- No earned mark on a medal image. The list and the details already state "No time recorded", a
  gilt bar would mark the default rather than the exception, and gold under a gold medal
  competes with the photo.
- The medal image is the framed photo, drawn by `PhotoImage` like every other photo: it fills
  the square with no edge and no shadow, and without one the shared placeholder is labelled with
  the face. Removing the background is left to a later change, and a shadow from an opaque
  photo would shadow the whole square.
- A FRONT / BACK label names the face in view on every medal, and tapping anywhere on the medal
  flips it, to an empty face's placeholder too. The whole medal is the target, so turning it
  over needs no aim at a small corner control; an empty face in view invites adding its photo.
  With no gilt on the medal, tapping it breaks no rule.
- The search medal row keeps the place and shows no time: the place is how a match by place
  explains itself (`search` spec, "A medal found by its place").
- A face is saved as an 840 × 840 JPEG, and `PhotoSlot` has loading and failed states.

## Risks / Trade-offs

- [The camera itself is verified only on a device] → What Take Photo leads to for each kind
  of camera access is covered by `PhotoSlotViewModel`'s tests.
- [A photo's background stays in the medal image] → Framing a tight square leaves little of
  it, and the design system names background removal as a later version.
- [Old test medals keep their `cover/` files in Storage] → They are test data. Deleting such a
  medal no longer finds the file, which stays until cleaned up by hand.
- [`CropImage` is a public package] → `outputSide` is additive with the old output as the
  default, released as the minor version 1.1.0.

## Migration Plan

1. Require `CropImage` 1.1.0 (released).
2. Deploy `firestore.rules` (`cd rules-tests && npm run deploy`), which checks the `photoUrls`
   map. `storage.rules` is unchanged.
3. No data migration. Medals saved before this change show the front placeholder.

Rollback: revert the branch.

## Open Questions

None.
