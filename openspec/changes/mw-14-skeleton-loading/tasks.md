## 1. Colour role

- [ ] 1.1 Add `Color.Skeleton` after `Progress` in `Color+Extensions.swift`: `onPage` →
      `Pigment.stone`, `inCard` → `Pigment.granite`; run `design-system-check` and confirm it
      reports `Skeleton` in step with v4.5.9

## 2. Skeleton modifiers

- [ ] 2.1 Create `Shared/Modifiers/SkeletonViewModifier.swift` with the `skeletonSurface`
      environment value (`.page` default, `.card`) and `.skeletonBone(_ shape:)`: under
      `.placeholder` redaction it hides the content and overlays the shape in
      `Color.Skeleton.onPage` or `.inCard`; otherwise it returns the content unchanged; default
      shape a rounded rectangle at `.Radius.tag` (design.md, Two modifiers)
- [ ] 2.2 Add `.skeleton()` in the same file: `.redacted(reason: .placeholder)`, no hit
      testing, scrolling disabled, opacity 0 for 300 ms, then opacity 0.6 → 1 over 1.2 s
      `easeInOut` repeating with autoreverse; opacity 1 and still under
      `accessibilityReduceMotion`; one VoiceOver element labelled "Loading" with its bones hidden
- [ ] 2.3 Make `surfaceStyle()` set `skeletonSurface` to `.card` on its content, and
      `sectionTitleStyle()` apply `.unredacted()`
- [ ] 2.4 Add the "Loading" string to `Localizable.xcstrings` with zh-TW 「載入中」 (memory:
      String Catalog editing)
- [ ] 2.5 Previews for the modifiers: bones on the page and in a card, light and dark, and
      Reduce Motion. No unit-testable surface — verify in the previews

## 3. Bones in shared components

- [ ] 3.1 Give `PhotoImage` a bone in its `imageType.shape`, with no placeholder icon or
      spinner while redacted
- [ ] 3.2 Give `medalRing()` one circular bone covering ring and photo, with no elevation
- [ ] 3.3 Give `RingSeal` a circular bone (covers `TierBadge`) and `ProgressBar` a bone over its
      track
- [ ] 3.4 Give `tagStyle(_:)` a bone in the tag's rectangle, `chipStyle(_:)` a capsule bone
      covering the whole chip, and both lines of `StatCard` bones
- [ ] 3.5 Add a redacted `#Preview` to each component above showing no gold, champagne or navy;
      confirm `TierBadgeTests` and `ChipViewModifierTests` still pass

## 4. Placeholder data

- [ ] 4.1 Add placeholders beside the sample data in `Resources/SampleData/`: a `User`, a
      `[Medal]` spanning two years and two distances with a personal best, a `[Race]` with
      editions, and a `[DraftRaceEdition]`, each list longer than the tallest supported iPhone
      shows (design.md, Placeholder data). Add any new file a test-target file depends on to
      the test target's `membershipExceptions` (memory: test target include list)

## 5. Test stubs

- [ ] 5.1 Let `StubMedalRepository`, `StubRaceRepository` and `StubUserRepository` hold a fetch
      until the test releases it, following `StubUserRepository`'s held-create pattern, so a
      test can observe a load mid-flight

## 6. First load vs reload in the view models

- [ ] 6.1 Write failing `MedalsViewModel` tests: `isShowingSkeleton` is true before any load
      and during a first load; false after success, after failure, and during a reload after
      success; true again during a retry after a failure; the medals of a failed reload are
      kept
- [ ] 6.2 Make them pass: `isLoading` starts true, add `hasLoaded` and `isShowingSkeleton`
      (design.md, First load vs reload)
- [ ] 6.3 Repeat 6.1–6.2 for `RacesViewModel` and `RaceDetailViewModel`; update
      `RaceDetailViewModelTests`' "isLoading starts false" to the new starting state
- [ ] 6.4 Repeat 6.1–6.2 for `RaceEntryPickerViewModel`
- [ ] 6.5 Repeat 6.1–6.2 for `ProfileViewModel`, adding the `isLoading` it lacks
- [ ] 6.6 Write failing `EditRaceViewModel` tests for `isShowingEditionsSkeleton` in edit mode
      (before load, during, after success, after failure) and that add mode never shows it;
      add `hasLoadedEditions` and `isShowingEditionsSkeleton` to pass them

## 7. Profile load state in UserManager

- [ ] 7.1 Write failing `UserManagerTests`: `isProfileLoading` is true while signed in before
      the profile loads, false once it loads and once it fails, and true again while a retry
      after a failure runs; `profileLoadError` is readable after a failure and nil once a
      retry succeeds
- [ ] 7.2 Make `profileLoadError` `private(set)` and add `isProfileLoading` (design.md, Profile)

## 8. Screens

- [ ] 8.1 Mark the data `Text`s in `ProfileHeaderSection` and `ProfileAchievementRow` with
      `.skeletonBone()`
- [ ] 8.2 `ProfileView`: the empty state when the profile failed; otherwise the header and the
      statistics-and-achievements each real or a `.skeleton()` of themselves with placeholder
      data; present `profileLoadError` through `errorWrapper` on change to non-nil without
      clearing it on dismiss. Add the empty-state strings in English and zh-TW (design.md,
      Profile). Named previews: loading, medals loaded before the profile, profile failed
- [ ] 8.3 Mark the data `Text`s in `MedalRow`, `MedalYearHeader` and `MedalPersonalBestCard`;
      `MedalList` shows a `.skeleton()` of the carousel, filter bar and year sections from
      placeholder medals while `isShowingSkeleton`, and the empty state when not
      showing a skeleton and empty; remove `MedalsView`'s overlay. Named preview: loading
- [ ] 8.4 Mark the data `Text`s in `RaceRow`; `RacesView` shows a `.skeleton()` of `RaceList`
      from placeholder races while `isShowingSkeleton`; remove its overlay. Named preview:
      loading
- [ ] 8.5 Mark the data `Text`s in `RaceDetailEditionsSection`'s edition card; the section
      shows a `.skeleton()` of its cards from placeholder editions while the view model's
      `isShowingSkeleton`; remove `RaceDetailView`'s overlay. Named preview: loading
- [ ] 8.6 Mark the data `Text`s in `RaceEntryList` and `RaceEntryEditionRow`; `RaceEntryPicker`
      shows a `.skeleton()` of `RaceEntryList` from placeholder races in place of its
      `ProgressView`. Named preview: loading
- [ ] 8.7 Mark the data `Text`s in `EditRaceEditionSection`'s row; the section shows a
      `.skeleton()` of its rows from placeholder editions, with `skeletonSurface` set to
      `.card`, in place of its `ProgressView`. Named preview: loading

## 9. Verify

- [ ] 9.1 Build and run the full test suite
- [ ] 9.2 On the simulator, light and dark, compare each skeleton with iOS mockup v4.5.5
      (Profile, Medals — whose mockup leaves out the filter bar — Races) and with the skeleton
      rules (Race detail, race picker, Edit Race), using a slowed fetch to see the 300 ms delay
      and the pulse; then with Reduce Motion on; then a fast load showing no bones
- [ ] 9.3 Check that the save buttons' spinners and a downloading photo's spinner are unchanged
- [ ] 9.4 Run `design-system-check`
- [ ] 9.5 At archive, update the `profile` spec's Purpose, which still says the You tab is blank
      until the profile loads
