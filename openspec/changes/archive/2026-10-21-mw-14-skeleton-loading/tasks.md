## 1. Colour role

- [x] 1.1 Add `Color.Skeleton` after `Progress` in `Color+Extensions.swift`: `onPage` →
      `Pigment.stone`, `inCard` → `Pigment.granite`; run `design-system-check` and confirm it
      reports `Skeleton` in step with v4.5.9

## 2. Skeleton modifiers

- [x] 2.1 Create `Shared/Modifiers/SkeletonViewModifier.swift` with the `skeletonSurface`
      environment value (`.page` default, `.card`) and `.skeletonBone(_:)`: under
      `.placeholder` redaction it hides the content and overlays its bone in
      `Color.Skeleton.onPage` or `.inCard`; otherwise it returns the content unchanged. It
      takes a shape, covered whole, or a `BoneSize`, drawn as a `BarBone`. Test first that a
      `BarBone` is centred at its height, full width and never taller than its frame, and that
      the tag and chip sizes match (design.md, Two modifiers)
- [x] 2.2 Add `.skeleton(_ isActive:)` in the same file: while active `.redacted(reason:
      .placeholder)`, no hit testing, scrolling disabled, opacity 0 for 300 ms, then a
      `TimelineView` pulse 0.6 → 1 over 1.2 s and back; opacity 1 and still under
      `accessibilityReduceMotion`; one VoiceOver element labelled "Loading" over the hidden
      content; inactive it changes nothing. Test the opacity function first
- [x] 2.3 Make `surfaceStyle()` set `skeletonSurface` to `.card` on its content
- [x] 2.4 Add the "Loading" string to `Localizable.xcstrings` with zh-TW 「載入中」 (memory:
      String Catalog editing)
- [x] 2.5 A preview for the modifiers: bones on the page and in a card. Check light, dark and
      Reduce Motion on the simulator — a preview cannot turn Reduce Motion on

## 3. Bones in shared components

- [x] 3.1 Give `PhotoImage` a bone in its `imageType.shape`, with no placeholder icon or
      spinner while redacted
- [x] 3.2 Give `medalRing()` one circular bone covering ring and photo, with no elevation
- [x] 3.3 Give `RingSeal` a circular bone (covers `TierBadge`) and `ProgressBar` a bone over its
      track
- [x] 3.4 Give `tagStyle(_:)` the `.tag` bar, `chipStyle(_:)` the `.chip` bar, and both lines
      of `StatCard` bars, its title's `BoneSize` passed beside its title font
- [x] 3.5 Add a redacted `#Preview` to each component above showing no gold, champagne or navy;
      confirm `TierBadgeTests` and `ChipViewModifierTests` still pass

## 4. Placeholder data

- [x] 4.1 Add placeholders beside the sample data in `Resources/SampleData/`: a `User`, a
      `[Medal]` spanning two years and two distances with a personal best, a `[Race]` with
      editions, and a `[DraftRaceEdition]`, each list longer than the tallest supported iPhone
      shows (design.md, Placeholder data). Add any new file a test-target file depends on to
      the test target's `membershipExceptions` (memory: test target include list)

## 5. Test stubs

- [x] 5.1 Let `StubMedalRepository`, `StubRaceRepository` and `StubUserRepository` hold a fetch
      until the test releases it, following `StubUserRepository`'s held-create pattern, so a
      test can observe a load mid-flight

## 6. First load vs reload in the view models

- [x] 6.1 Write failing `MedalsViewModel` tests: `isShowingSkeleton` is true before any load
      and during a first load; false after success, after failure, and during a reload after
      success; true again during a retry after a failure; the medals of a failed reload are
      kept
- [x] 6.2 Make them pass: `isLoading` starts true, add `hasLoaded` and `isShowingSkeleton`
      (design.md, First load vs reload)
- [x] 6.3 Repeat 6.1–6.2 for `RacesViewModel` and `RaceDetailViewModel`; update
      `RaceDetailViewModelTests`' "isLoading starts false" to the new starting state
- [x] 6.4 Repeat 6.1–6.2 for `RaceEntryPickerViewModel`
- [x] 6.5 Repeat 6.1–6.2 for `ProfileViewModel`, adding the `isLoading` it lacks
- [x] 6.6 Write failing `EditRaceViewModel` tests for `isShowingEditionsSkeleton` in edit mode
      (before load, during, after success, after failure) and that add mode never shows it;
      add `hasLoadedEditions` and `isShowingEditionsSkeleton` to pass them
- [x] 6.7 Write failing tests for each view model's displayed data — the placeholders before a
      load, the real data after success, none after a failed first load — then add
      `RacesViewModel.displayedRaces`, `RaceDetailViewModel.displayedEditions`,
      `RaceEntryPickerViewModel.displayedRaces` and `displayedEditions`, the placeholders in
      `EditRaceViewModel.displayedEditions`, and `ProfileViewModel`'s statistics and progress
      from the placeholder medals (design.md, First load vs reload)

## 7. Profile load state in UserManager

- [x] 7.1 Write failing `UserManagerTests`: `isProfileLoading` is true while signed in before
      the profile loads, false once it loads and once it fails, and true again while a retry
      after a failure runs; `profileLoadError` is readable after a failure and nil once a
      retry succeeds
- [x] 7.2 Make `profileLoadError` `private(set)` and add `isProfileLoading` (design.md, Profile)

## 8. Screens

- [x] 8.1 Mark the data `Text`s in `ProfileHeaderSection` and `ProfileAchievementRow` with
      `.skeletonBone(_:)` and their font's `BoneSize`
- [x] 8.2 `ProfileView`: the empty state when the profile failed; otherwise the current or the
      placeholder user's header under `.skeleton(userManager.isProfileLoading)`, and
      `ProfileSummarySection` and `ProfileAchievementsSection` showing `ProfileViewModel`'s
      values under `.skeleton(viewModel.isShowingSkeleton)`;
      present `profileLoadError` through `errorWrapper` on change to non-nil, and on appear,
      without clearing it on dismiss. Add the empty-state strings in English and zh-TW
      (design.md, Profile). Named previews: loading, on `ProfileView` and on each section
- [x] 8.3 Mark the data `Text`s in `MedalRow`, `MedalYearHeader` and `MedalPersonalBestCard`;
      `MedalsView` builds one `MedalList` — carousel, filter bar and year sections — passing
      it the placeholder view model while `isShowingSkeleton`, under
      `.skeleton(viewModel.isShowingSkeleton)`; `MedalList` shows the empty state when empty;
      remove `MedalsView`'s overlay. Named preview: loading
- [x] 8.4 Mark the data `Text`s in `RaceRow`; `RacesView` builds one `RaceList` from
      `displayedRaces` under `.skeleton(viewModel.isShowingSkeleton)`; remove its overlay.
      Named preview: loading, on `RaceList`
- [x] 8.5 Mark the data `Text`s in `RaceDetailEditionsSection`'s edition card; the section
      shows `displayedEditions` under `.skeleton(isShowingSkeleton)` below its title; remove
      `RaceDetailView`'s overlay. Named preview: loading
- [x] 8.6 Mark the data `Text`s in `RaceEntryList` and `RaceEntryEditionRow`; `RaceEntryPicker`
      builds one `RaceEntryList` from the displayed races and editions under
      `.skeleton(viewModel.isShowingSkeleton)` in place of its `ProgressView`. Named preview:
      loading, on `RaceEntryList`
- [x] 8.7 Mark the data `Text`s in `EditRaceEditionSection`'s row; the section shows
      `displayedEditions`, each row under `.skeleton(isShowingSkeleton)` with
      `skeletonSurface` set to `.card` and `.deleteDisabled` while showing a skeleton, in place
      of its `ProgressView`. Named preview: loading
- [x] 8.8 Record the bone sizes in `openspec/design-system/deviations.md` as unreported

## 9. Verify

- [x] 9.1 Build and run the full test suite
- [x] 9.2 On the simulator, light and dark, compare each skeleton with iOS mockup v4.5.5
      (Profile, Medals — whose mockup leaves out the filter bar — Races) and with the skeleton
      rules (Race detail, race picker, Edit Race), using a slowed fetch to see the 300 ms delay
      and the pulse, and that the pulse stops once the content shows; then with Reduce Motion
      on; then a fast load showing no bones
- [x] 9.3 Check that the save buttons' spinners and a downloading photo's spinner are unchanged
- [x] 9.4 Run `design-system-check`
- [x] 9.5 At archive, update the `profile` spec's Purpose, which still says the You tab is blank
      until the profile loads
