## 1. Declared deviations

- [ ] 1.1 Add two rows to `openspec/design-system/deviations.md`, status `unreported`, since
      2026-11-03, ticket MW-38: `component.MedalImage.earnedBar` (code: not drawn; design system:
      gilt bar 3 pt, 2 pt at `.thumb`, along the square's bottom edge), and the iOS mock v4.8.0
      search medal row (code: date, name, place, distance, no time; mock: name, date,
      distance · time, no place). Use the reasons in design.md, Declared deviations

## 2. CropImage output size (`~/Code/Libraries/iOS/CropImage`)

- [ ] 2.1 Add a test target to the package and write a failing test: `crop` with a requested
      output side of 840 returns a square image of 840 × 840 pixels, and without one returns
      today's size (the crop side at scale 1)
- [ ] 2.2 Add the optional output-side parameter to `CropImageView` and `crop`, defaulting to
      today's behaviour, to pass it; document it in the README
- [ ] 2.3 Show the diff, then ask before committing, tagging `1.1.0` and pushing the package
- [ ] 2.4 Bump MedalWall's `CropImage` requirement to 1.1.0 and resolve the package

## 3. Model and persistence

- [ ] 3.1 Create `Models/Medal/MedalFace.swift` (`front`, `back`) and add it to the test target's
      `membershipExceptions` (memory: test target include list)
- [ ] 3.2 Write failing tests: a `Medal` encodes and decodes `frontPhotoUrl` and `backPhotoUrl`
      and no `photoUrl`; `MedalFirestoreRepository.medalUpdateFields` lists both and not
      `photoUrl` (the existing every-field test then guards it)
- [ ] 3.3 Replace `Medal.photoUrl` with `frontPhotoUrl` and `backPhotoUrl` to pass them; update
      `medalUpdateFields`, `Medal+SampleData`, and every reader until the app builds (list, year
      section, search, details, edit)

## 4. Storage

- [ ] 4.1 Write failing tests for the face path: `users/{uid}/medals/{medalId}/front/<UUID>.png`
      and `…/back/<UUID>.png`, a new name per call, both owned by `PhotoOwner.medal`
- [ ] 4.2 Replace `uploadMedalPhoto` with `uploadMedalFace(userId:medalId:face:image:)`, which
      uploads `pngData()` as `image/png`; event photos and every other upload stay JPEG
- [ ] 4.3 Write failing `rules-tests/storage.test.js` cases: the owner can upload PNG to `front/`
      and `back/`; JPEG there is refused; PNG in `eventPhotos/` is refused; another user cannot
      upload to `front/`; the owner can still delete a file under `cover/`
- [ ] 4.4 Split the medal match in `storage.rules` per design.md, PNG uploads to per-face
      folders, until `cd rules-tests && npm test` passes
- [ ] 4.5 Ask before deploying the rules (`cd rules-tests && npm run deploy`); deploy before any
      build that uploads a face runs against the live project

## 5. Background removal

- [ ] 5.1 Create `protocol BackgroundRemoval` (nonisolated, `async throws -> UIImage`) with a
      `noMedalFound` error, and a stub for tests in `MedalWallTests/Support`
- [ ] 5.2 Write failing tests for the output step on its own: a cutout rendered to 840 × 840 is
      840 × 840 pixels and keeps transparent pixels transparent
- [ ] 5.3 Create `Services/BackgroundRemovalService.swift`
      (`VNGenerateForegroundInstanceMaskRequest`, all instances, `croppedToInstancesExtent: false`,
      off the main actor) to pass 5.2; no instance throws `noMedalFound`
- [ ] 5.4 Find out whether the request runs in the iOS 26.5 Simulator. If it does, add an
      integration test with a bundled medal photo (a cutout comes back) and a blank image
      (`noMedalFound`); if it does not, say so and check the service on a device before task 8

## 6. EditMedalViewModel

- [ ] 6.1 Write failing tests for staging: each face is set and cleared independently; an
      untouched face keeps its URL on save; loading an existing medal loads both faces;
      `isCameraAvailable` comes from the injected closure
- [ ] 6.2 Write failing tests for clearing with the `BackgroundRemoval` stub: framing a face
      sets `clearingFace` and blocks saving until it finishes; success stages the cutout for
      that face only; `noMedalFound` sets `unrecognizedFace` and keeps the face's previous photo;
      Reframe and Cancel both clear `unrecognizedFace`
- [ ] 6.3 Write failing tests for `save()` with `StubPhotoStorage`: a changed face uploads with
      its `MedalFace`; a removed or replaced face is deleted only after the save succeeds; a
      failed save deletes what it uploaded and keeps the stored faces; the other face is
      untouched throughout
- [ ] 6.4 Rework `EditMedalViewModel` per design.md, The flow lives in the edit form, to pass
      6.1–6.3

## 7. Shared medal image

- [ ] 7.1 Write failing `ImageTypeTests` cases: the three medal types are a
      `radius.image` rounded rect, and `.medal` is 280 pt; then change `ImageType`
- [ ] 7.2 Write failing tests for `Elevation.cutout(side:)`'s offsets and blurs at 96 and 280
      (light and dark, per the token list), then add the case to `ElevationViewModifier`
- [ ] 7.3 Add `Animation+Extensions.swift` with `Animation.Motion.flip` and `flipReduced`
      (design.md, The flip)
- [ ] 7.4 Create `Shared/Components/MedalImage.swift`: square, `Surface.primary` fill,
      `Border.primary` hairline, cutout `.scaledToFit` with `.elevation(.cutout(side:))`,
      placeholder glyph labelled "Front" (glyph only at 46 pt). Previews: each size filled
      and empty, light and dark. No unit test: layout only
- [ ] 7.5 Delete `MedalRingViewModifier.swift` and its three call sites; drop the ring from
      `PhotoImage`'s doc comment and preview

## 8. Edit form

- [ ] 8.1 Create `MedalPhotoSlot` (empty, filled, clearing, active) and `EditMedalPhotosSection`
      (Front then Back, the Replace / Remove / Cancel dialog titled per face), with previews
- [ ] 8.2 Create `MedalPhotoTipsView` (title per face, both tips, Choose photo, Take photo only
      when the camera is available), with previews for front, back and no camera
- [ ] 8.3 Create `CameraPickerView`; add `NSCameraUsageDescription` to `Info.plist` and an
      `InfoPlist.xcstrings` with its zh-TW text
- [ ] 8.4 Wire the flow in `EditMedalView`: slot → tips → photo library or camera →
      `CropImageView(.square, 840)` → view model; the no-medal alert with Reframe and Cancel;
      remove the circle crop and the old cover photo picker from the medal form

## 9. List, search and details

- [ ] 9.1 Use `MedalImage` with the front in `MedalRow` (96) and `SearchMedalRow` (46); the
      search row's text stays as it is
- [ ] 9.2 Write failing `MedalDetailViewModel` tests: opens on the front; `hasBack` follows
      `backPhotoUrl`; `toggleFace()` alternates and the label follows; deleting a medal deletes
      its front, its back and its event photos
- [ ] 9.3 Implement them; build `MedalFaceButton` and the hero's flip in
      `MedalDetailHeroSection` (rotation at 90°, crossfade under Reduce Motion, no tap action
      on the image), with previews for front only, both faces, and back only

## 10. Localization

- [ ] 10.1 Add the new strings with zh-TW translations to `Localizable.xcstrings` (slot labels,
      Add front / Add back, the tip sheet, Choose photo / Take photo, Clearing background…, the
      no-medal message, Reframe, Front photo / Back photo, Replace Photo / Remove Photo, the face
      button's labels and hints), in `localizedStandardCompare` order (memory: String Catalog
      editing)

## 11. Verify

- [ ] 11.1 Run the full test suite and `rules-tests`; confirm the new test names ran (memory:
      xcodebuild can run stale tests)
- [ ] 11.2 On a device: cut out a medal laid flat, one hanging, and one held in a hand; take a
      photo with the camera; flip in light and dark, and with Reduce Motion; relaunch and check
      the list still shows transparency (cache)
- [ ] 11.3 Run `design-system-check`; it should report only the two declared deviations for
      this change

## 12. Archive

- [ ] 12.1 Archive per memory (OpenSpec can't drop a scenario): replace each MODIFIED block in
      `openspec/specs/` by script, create `openspec/specs/medal-photos/spec.md` (with a
      Purpose) from the ADDED requirements, check `git diff`, run
      `openspec validate --specs --strict`, then `openspec archive mw-38-medal-front-back-photos
      --yes --skip-specs`
