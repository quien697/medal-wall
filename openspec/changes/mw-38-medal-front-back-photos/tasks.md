## 1. Declared deviations

- [x] 1.1 Add two rows to `openspec/design-system/deviations.md`, status `unreported`, since
      2026-11-03, ticket MW-38: `component.MedalImage.earnedBar` (code: not drawn; design system:
      gilt bar 3 pt, 2 pt at `.thumb`, along the square's bottom edge), and the iOS mock v4.8.0
      search medal row (code: date, name, place, distance, no time; mock: name, date,
      distance · time, no place). Use the reasons in design.md, What the design system
      states for MW-38
- [x] 1.2 Add a row for `component.MedalImage`, status `unreported`, since 2026-11-12, ticket
      MW-38 (code: drawn by `PhotoImage`, the photo filling the square with no edge and no
      `elevation.cutout`, the shared placeholder labelled with the face; design system: a
      background-removed cutout casting `elevation.cutout`, on porcelain with an ash hairline),
      with the reason in design.md, What the design system
      states for MW-38
- [x] 1.3 Add a row for `component.MedalImage.faceButton`, status `unreported`, since
      2026-11-13, ticket MW-38 (code: a FRONT / BACK label names the face in view on every
      medal and tapping anywhere on it flips it, to an empty face's placeholder too; design
      system: the corner button names the face and flips it, shown only when a back exists),
      with the reason in design.md, What the design system
      states for MW-38

## 2. CropImage output size (`~/Code/Libraries/iOS/CropImage`)

- [x] 2.1 Add a test target to the package and write a failing test: `crop` with a requested
      output side of 840 returns a square image of 840 × 840 pixels, and without one returns
      today's size (the crop side at scale 1)
- [x] 2.2 Add the optional output-side parameter to `CropImageView` and `crop`, defaulting to
      today's behaviour, to pass it; document it in the README
- [x] 2.3 Show the diff, then ask before committing, tagging `1.1.0` and pushing the package
- [x] 2.4 Point MedalWall's four library packages at their remote repositories, up to the next
      major: `CropImage` from 1.1.0, `CachedAsyncImage` from 1.0.1, `PhotoViewer` from 1.1.0,
      `TimePicker` from 1.0.0; resolve them so `Package.resolved` pins all four

## 3. Model and persistence

- [x] 3.1 Create `Models/Medal/MedalFace.swift` (`front`, `back`) and add it to the test target's
      `membershipExceptions` (memory: test target include list)
- [x] 3.2 Write failing tests: a medal update writes `photoUrls` as a map keyed `front` and
      `back`, with no `back` key for a front-only medal, deletes it for a medal without photos,
      and writes no `frontPhotoUrl`, `backPhotoUrl` or `photoUrl` (the existing every-field
      test then guards the list); `MedalPhotoUrlsTests`: each face reads its URL, `isEmpty`,
      and an empty map decodes; saving a medal whose faces are all empty stores no map
- [x] 3.3 Create `Models/Medal/MedalPhotoUrls.swift`, add it to the test target's
      `membershipExceptions`, and replace `Medal.photoUrl` with `photoUrls` to pass them;
      update `medalUpdateFields`, `Medal+SampleData`, and every reader until the app builds
      (list, year section, search, details, edit, delete)
- [x] 3.4 Write failing `rules-tests/firestore.test.js` cases for `photoUrls` (each face alone,
      both and an empty map accepted; a non-map, a non-string URL and an unknown key refused;
      an update can replace or delete the map), then check it in `isValidMedal`

## 4. Storage

- [x] 4.1 Write failing tests for the face path: `users/{uid}/medals/{medalId}/front/<UUID>.jpg`
      and `…/back/<UUID>.jpg`, a new name per call, both owned by `PhotoOwner.medal`
- [x] 4.2 Replace `uploadMedalPhoto` with `uploadMedalFace(userId:medalId:face:image:)`, which
      uploads `uploadData()` as `image/jpeg` like every other photo
- [x] 4.3 `rules-tests/storage.test.js` cases for `front/` and `back/`: the owner can upload a
      JPEG; a PNG is refused; another user cannot upload to `front/`; the owner can still
      delete a file under `cover/`
- [x] 4.4 `storage.rules` matches its committed version (design.md, JPEG uploads to per-face
      folders), and `cd rules-tests && npm test` passes

## 5. EditMedalViewModel

- [x] 5.1 Write failing tests for staging: each face is set and cleared independently; an
      untouched face keeps its URL on save; loading an existing medal loads both faces
- [x] 5.2 Write failing tests: a framed photo is staged for its face only and leaves the other
      face as it was; a framed photo replaces a face's previous photo
- [x] 5.3 Write failing tests for `save()` with `StubPhotoStorage`: a changed face uploads with
      its `MedalFace`; a removed or replaced face is deleted only after the save succeeds; a
      failed save deletes what it uploaded and keeps the stored faces; the other face is
      untouched throughout
- [x] 5.4 Rework `EditMedalViewModel` per design.md, The flow lives in the edit form, to pass
      5.1–5.3, with no background-removal dependency or state

## 6. Shared medal image

- [x] 6.1 Write failing `ImageTypeTests` cases: the three medal types are a
      `radius.image` rounded rect, and `.medal` is 280 pt; then change `ImageType`
- [x] 6.2 Add `Animation+Extensions.swift` with `Animation.Motion.flip` and `flipReduced`
      (design.md, The flip)
- [x] 6.3 `PlaceholderImage(as:text:)` shows an optional text beneath its glyph, and
      `PhotoImage(…, placeholderText:)` passes it through; previews show a labelled medal
      placeholder. No unit test: layout only
- [x] 6.4 Delete `MedalRingViewModifier.swift` and its three call sites, and
      `ElevationViewModifier.swift`, which only the ring used; drop the ring from
      `PhotoImage`'s doc comment and preview
- [x] 6.5 Stop naming `ElevationViewModifier` in `CLAUDE.md` and the `design-system-sync`
      skill, and add the `design-system-sync` delta

## 7. Edit form

- [x] 7.1 Write failing `CameraAccessTests`: without a camera it is `unavailable` whatever the
      authorization status; with one, `authorized` is `granted`, `notDetermined` is
      `undetermined`, and `denied` and `restricted` are `denied`. Then add
      `Shared/UIModels/CameraAccess.swift` to pass them
- [x] 7.2 Move `CameraPickerView` to `Shared/Components`; `NSCameraUsageDescription` is in
      `Info.plist`, with its zh-TW text in `InfoPlist.xcstrings`
- [x] 7.3 `PhotoSlot` in `Shared/Components`: empty, filled and active, drawn at its
      `ImageType`'s size and shrinking to the width given; the source alert (title, optional
      message, Choose Photo, Take Photo while `offersCamera`, Remove Photo when filled, Cancel);
      the photo library; Take Photo through `CameraAccess` (the camera, iOS's prompt, the Allow
      Camera Access alert with Open Settings, the No Camera alert); `CropImageView` with the
      given shape and output side → `onPick`; a photo that fails to load → `onError`. Previews
      for empty, filled, with and without a message, and without the camera
- [x] 7.4 `EditMedalPhotosSection` lays out two `PhotoSlot`s, Front then Back (`.medal`,
      `.square`, 840, the face's photo title, the shooting message, "Add front" / "Add back"),
      each labelled with its face; `EditMedalView` keeps no picker, camera or crop state, with
      the circle crop and the old cover photo picker gone; `EditMedalViewModel` has no camera
      dependency

## 8. List, search and details

- [x] 8.1 Use `PhotoImage` with the front in `MedalRow` (96, placeholder labelled with
      `MedalFace.front.title`) and `SearchMedalRow` (46, glyph alone); the search row's text
      stays as it is
- [x] 8.2 Write failing `MedalDetailViewModel` tests: opens on the front; `toggleFace()`
      alternates and the label follows, with or without a back photo, and a back a reload
      removes leaves the back in view; deleting a medal deletes its front, its back and its
      event photos
- [x] 8.3 Implement them; build `MedalFlipImage` (rotation, swap at 90°, crossfade under
      Reduce Motion, through `MedalFaceVisibilityViewModifier`), the face label, and the
      hero's button making the whole medal the tap target, with previews for both faces, no
      photos, and the back in view in dark
- [x] 8.4 Write failing `MedalDetailViewModelFaceTests` cases for the flip's math: the angle
      showing each face, no rotation under Reduce Motion, each face's opacity while turning
      and crossfading, and the animation per Reduce Motion; then move the math into
      `MedalDetailViewModel` (add `Animation+Extensions.swift` to the test target's include
      list, since the view model compiles into it)

## 9. Localization

- [x] 9.1 `Localizable.xcstrings` holds, with zh-TW translations, exactly the strings this
      change uses: slot labels, Add front / Add back, Front photo / Back photo, Choose Photo /
      Take Photo / Remove Photo, the alert's shooting message, the camera access alerts with
      Open Settings, and the face label and flip hints, in `localizedStandardCompare` order
      (memory: String Catalog editing)

## 10. Verify

- [x] 10.1 Run the full test suite and `rules-tests`; confirm the new test names ran (memory:
      xcodebuild can run stale tests)
- [x] 10.2 On a device: frame a medal from the library and one taken with the camera; check
      the front fills its square in the list, search and the details; flip in light and dark,
      and with Reduce Motion; tap Take Photo before camera access is asked, once allowed, and
      with it turned off
- [x] 10.3 Run `design-system-sync`: no problems; Design System v4.7.1 and Mockup - iOS
      v4.8.2 state MW-38's four choices, so their entries are resolved
- [ ] 10.4 Deploy `firestore.rules` (`cd rules-tests && npm run deploy`) once the user agrees

## 11. Code review

- [x] 11.1 `PhotoSlot` draws its empty state with `EmptyPhotoSlot`, which takes an optional
      label beneath a `title1` plus and shrinks to the space it is given, so every empty photo
      slot is the same 2 pt dashed pewter edge. No unit test: layout only
- [x] 11.2 Write failing `PhotoSlotViewModelTests` for what Take Photo presents for each
      `CameraAccess` and for the slot's VoiceOver label; then move that logic out of the view
      into `PhotoSlotViewModel` (`Shared/Components/PhotoSlot/`)
- [x] 11.3 Drop `// MARK:` from `MedalFlipImage` and `CameraPickerView`, which have fewer than
      5 properties
- [x] 11.4 Edit Profile, Edit Race and Edit Edition present their crop sheets from a
      `PickedPhoto` with `.sheet(item:)`, as `PhotoSlot` does, so the first crop screen opens
      with the photo. No unit test: presentation only
- [x] 11.5 Edit Medal and Edit Race disable their form while saving, as Edit Profile does
      (`edit-sheets` delta). No unit test: a view modifier

## 12. Every form photo is a PhotoSlot

- [x] 12.1 Write failing `PhotoSlotViewModelTests`: a picked photo's data becomes the photo to
      frame, or `.photoDataInvalid`; a photo taken becomes the photo to frame once the camera
      closes, and closing it without one frames nothing; `content(photo:storedPhotoStatus:)`
      gives photo, loading, failed or empty, and every state but empty offers Remove Photo and
      reads the title. Then move that logic out of `PhotoSlot` into `PhotoSlotViewModel`
- [x] 12.2 Add `StoredPhotoStatus` (`Shared/UIModels`, on the test target's include list). Write
      failing tests for `EditMedalViewModel` (per face), `EditProfileViewModel`,
      `EditRaceViewModel` and `EditRaceEditionViewModel`: a stored photo is `loading` until it
      downloads, cleared when it does, `failed` when it can't, and cleared by picking or
      removing a photo; a form with no stored photo has none. Then add it
- [x] 12.3 `PhotoSlot` takes `storedPhotoStatus` and draws loading and failed with a hairline,
      Remove Photo offered; previews for both. No unit test beyond 12.1: layout only
- [x] 12.4 Edit Profile, Edit Race and Edit Edition use `PhotoSlot` (design.md, Every form photo
      is a `PhotoSlot`); delete `EditPhotoPicker` and `photoHint` with its tests; remove the old
      picker's strings and add the new ones with zh-TW, covered by `StringCatalogTests`
- [x] 12.5 Run the full suite; render the three forms' slots in every state, light and dark,
      with a temporary test

## 13. Design system in Claude

- [x] 13.1 Point `CLAUDE.md`, the `design-system-sync` skill and `docs/development-workflow.md`
      at the canvas's Design System and iOS pages, found by name (design.md, The design system
      lives in Claude); add the `design-system-sync` delta for token capture and the
      every-session check
- [x] 13.2 Run `design-system-sync` against the canvas (10.3), writing `tokens.json`'s new
      `source`
- [x] 13.3 The check deletes the ledger entries a release resolves (skill, `design-system-sync`
      delta, workflow doc); delete MW-38's four resolved entries and the ledger's notes on past
      resolutions
- [x] 13.4 `CLAUDE.md`: how to take a "Hand off to Claude Code" prompt from the canvas
- [x] 13.5 Rename the skill `design-system-sync`; it compares and, once the user agrees, writes
      every shared token file — adding `Animation.Motion`, `ImageType`'s medal sizes, `BoneSize`,
      `ProgressBar` and `PhotoSlotContent` to its scope (`design-system-sync` delta)

## 14. Archive

- [ ] 14.1 Archive per memory (OpenSpec can't drop a scenario): replace each MODIFIED block in
      `openspec/specs/` by script, create `openspec/specs/medal-photos/spec.md` (with a
      Purpose) from the ADDED requirements, check `git diff`, run
      `openspec validate --specs --strict`, then `openspec archive mw-38-medal-front-back-photos
      --yes --skip-specs`
