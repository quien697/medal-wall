## Context

Six screens fetch data when they appear. Medals, Races and Race detail cover themselves with a
dimmed `ProgressView` overlay on every load; the race picker and Edit Race's editions show a
`ProgressView` in place of their list. The You tab renders nothing until `UserManager` has a
`currentUser`; when the profile fails, `UserManager` keeps the reason in a private
`profileLoadError` that drives its retry on reconnect and foreground, and no error reaches the
screen.

Design System v4.5.9 defines `skeleton.onPage` (Stone) and `skeleton.inCard` (Granite) and the
skeleton rules; iOS mockup v4.5.5 draws Profile, Medals, Medal detail and Races loading.
`openspec/design-system/tokens.json` already records the `Skeleton` tokens. Medal detail always
opens with its medal in memory, so it never shows bones.

A spike on 2026-10-19 rendered the Profile sections under `.redacted(reason: .placeholder)`:
the layout came out right, but redaction draws each piece in its own colour, faded — a Text
given the exact Stone colour rendered barely visible — and rings and progress bars kept their
gold and navy.

## Goals / Non-Goals

**Goals:**
- Bones in the token colours, in the shape of the real content, on the six screens.
- One skeleton mechanism shared by every screen, with timing, pulse and Reduce Motion in one
  place.
- A failed profile load reaches the screen as an empty state and an error sheet without
  weakening `UserManager`'s retry.

**Non-Goals:**
- Medal detail, the launch screen, and the save buttons' spinners.
- The spinner a photo shows while downloading after the content is on screen.
- Remembering the screen the user was on, or refreshing when the app returns to the foreground.

## Decisions

### Colour role
`Color.Skeleton` in `Color+Extensions.swift`, after `Progress`:
`onPage = Pigment.stone`, `inCard = Pigment.granite` — the design system's code sample.

### Two modifiers, one file: `Shared/Modifiers/SkeletonViewModifier.swift`
- **`.skeleton(_ isActive:)`** goes on the one view that shows a section's data, and turns it
  into a skeleton while `isActive`; inactive, it changes nothing. A screen therefore builds its
  data view once, and that view keeps its identity when the real data replaces the placeholders.
  Its delay and pulse apply to everything it wraps, so it wraps only data and never a section
  title. While active it applies `.redacted(reason: .placeholder)`, `.allowsHitTesting(false)`
  and `.scrollDisabled(true)`; keeps the view at opacity 0 for its first 300 ms; then pulses
  opacity 0.6 → 1 over 1.2 s and back, easing in and out, repeating. Under
  `accessibilityReduceMotion` it shows at opacity 1 without pulsing (the same environment value
  `ProgressBar` reads). A `TimelineView` drives the pulse from the time since the bones
  appeared, so it stops the moment the skeleton turns off — a repeating SwiftUI animation keeps
  running once started. For VoiceOver the content is hidden and one element labelled "Loading"
  covers it.
- **`.skeletonBone(_:)`** goes on each piece of data. It reads
  `@Environment(\.redactionReasons)`; with `.placeholder` present it renders the content
  `.hidden()` and overlays the bone filled with the bone colour, so the bone sits in the
  content's exact frame. Otherwise it returns the content unchanged, so a bone costs nothing
  outside a skeleton. It takes either a shape or a `BoneSize`:
  - A photo, ring, seal or progress bar passes its own shape and is covered whole.
  - A line of text, a tag or a chip passes a `BoneSize` and becomes a `BarBone`: a bar as wide
    as the content, at the size's height, centred in the content's frame and never taller than
    it. Its corners are `.Radius.tag` (6 pt), a chip's a capsule.
- **`BoneSize`** is the one table of bar heights, named by the type step of the text a bar
  stands in for: overline 10, caption 10, body 12, callout 14, headline 16, Numeric.medium 18,
  title2 24, Numeric.large 30; and tag 20, chip 20. These are the iOS mockup's bars, which follow
  the font rather than the line, so every bar of one text style matches across the app, and a
  tag and a chip share a height so a row of them lines up. The design system names no bone
  sizes or radius; `deviations.md` records them until it does.
- The bone colour comes from a new environment value, `skeletonSurface` (`.page` by default,
  or `.card`). `surfaceStyle()` sets `.card` on its content, so a bone inside any card picks
  `Skeleton.inCard` without knowing where it sits. A container that is a card without using
  `surfaceStyle()` (Edit Race's form section) sets `.card` itself.

`.redacted` is the switch because it reaches every descendant. A piece that misses its
`.skeletonBone` still renders as the system's placeholder, not as placeholder data.

### Where bones go
Everything inside a skeleton is a bone; section titles sit outside it.
- **Shared components carry their own bones**, so every screen gets them:
  `PhotoImage` (the photo's own `imageType.shape`, with no placeholder icon or spinner),
  `medalRing()` (one circle covering ring and photo, no elevation), `RingSeal` (a circle —
  covers `TierBadge`), `ProgressBar` (its track), `tagStyle(_:)` (`.tag`), `chipStyle(_:)`
  (`.chip`), `StatCard` (both lines; it takes its title's `BoneSize` beside its title font).
- **A section with a title holds its own skeleton**: `ProfileAchievementsSection`,
  `RaceDetailEditionsSection` and `EditRaceEditionSection` take `isShowingSkeleton` and pass it
  to `.skeleton(_:)` on their rows, below the real title. An untitled section or list gets
  `.skeleton(_:)` from the screen that shows it.
- **Row components mark their own `Text`s** with `.skeletonBone(_:)` and the `BoneSize` of
  their font: `ProfileHeaderSection`,
  `ProfileAchievementRow`, `MedalRow`, `MedalYearHeader`, `MedalPersonalBestCard`, `RaceRow`,
  `RaceDetailEditionsSection`'s edition card, `RaceEntryList`, `RaceEntryEditionRow`, and
  `EditRaceEditionSection`'s row. The avatar is a circle through `PhotoImage`'s `.avatar` shape.
- Chevrons are not data and get no bone; redaction draws each as a small placeholder where it
  will be.
- The Medals skeleton shows the personal best carousel, the distance filter bar and the year
  sections. Each filter chip is a bone, since its label and count come from the medals.
- Edit Race's placeholder rows cannot be swiped to delete (`.deleteDisabled`).

### Placeholder data
Static placeholders live beside the sample data in `Resources/SampleData/`: a placeholder
`User`, `[Medal]`, `[Race]` with editions, and `[DraftRaceEdition]`. Strings are chosen so bar
widths read like the mockup (a 14-character name, a one-line bio). A list skeleton holds more
placeholder rows than the tallest supported iPhone shows; the skeleton disables scrolling, so
the rows fill the visible area and the rest is clipped. The Medals skeleton is `MedalList`
driven by a second `MedalsViewModel` holding the placeholder medals, so its year groups,
records and filter options come from the same code as the real collection's.
`ProfileViewModel` derives the statistics and achievement progress from the placeholder medals
while it shows a skeleton.

### First load vs reload in the view models
`MedalsViewModel`, `RacesViewModel`, `RaceDetailViewModel`, `RaceEntryPickerViewModel` and
`ProfileViewModel` gain `private(set) var hasLoaded = false`, set `true` when a load succeeds,
and a computed `isShowingSkeleton: Bool { isLoading && !hasLoaded }`. `isLoading` starts
`true`, as `RaceEntryPickerViewModel`'s already does: each screen loads as soon as it appears,
and until then its empty data is not yet known to be empty, so the first frame is a skeleton
rather than the empty state. `ProfileViewModel` gains the `isLoading` it lacks.
`EditRaceViewModel` already starts `isEditionsLoading` true in edit mode and gains
`hasLoadedEditions` and `isShowingEditionsSkeleton`; the overlays and in-list `ProgressView`s
go. A screen's empty state shows when it is not showing a skeleton and its data is empty — so
after a failed first load, and after a successful load of nothing. A reload keeps `hasLoaded`
true and so shows the current content until the new data replaces it.

Each view model also hands its screen the data to show, so the screen builds its list once and
passes `isShowingSkeleton` to `.skeleton(_:)`: `RacesViewModel.displayedRaces`,
`RaceDetailViewModel.displayedEditions`, `RaceEntryPickerViewModel.displayedRaces` and
`displayedEditions`, and `EditRaceViewModel.displayedEditions` return the placeholders while
showing a skeleton and the real data otherwise. `MedalList` reads a whole `MedalsViewModel`, so
`MedalsView` passes it the placeholder view model while `isShowingSkeleton`; deriving the
collection's values from placeholders inside `MedalsViewModel` would tie every one of them to
the load state.

### Profile
- `UserManager.profileLoadError` becomes `private(set)` (readable), and a computed
  `isProfileLoading` is true while signed in with neither a `currentUser` nor a
  `profileLoadError`. `loadProfile()` already clears the error when it starts, so a retry
  turns the screen back to bones.
- `ProfileView`: when `profileLoadError` is set and there is no `currentUser`, the content is
  an `EmptyState` with no header, statistics or achievements. Otherwise the header shows the
  current user, or the placeholder user under `.skeleton(userManager.isProfileLoading)`, and
  `ProfileSummarySection` and `ProfileAchievementsSection` show `ProfileViewModel`'s values
  under `.skeleton(viewModel.isShowingSkeleton)`. Each section has its own skeleton, so each
  turns real when its own data arrives.
- The view presents `profileLoadError` through its existing `errorWrapper` sheet on
  `.onChange` to a non-nil value, and when the tab first appears with one — the profile loads
  at sign-in, usually before the You tab is opened. It does **not** clear it on dismiss: it is
  what keeps the empty state up and what `reloadProfileIfNeeded()` checks before retrying.
  Each failed load goes nil → error, so each one presents the sheet, as the lists do.
- Empty-state copy, worded like an `AppError`'s title, message and guidance:
  **"Profile Unavailable"** / "We couldn't load your profile. Please check your connection and
  try again." — zh-TW **「個人資料無法使用」** / 「我們無法載入你的個人資料。請檢查網路連線後再試一次。」
  `EmptyState` has one description, so the message and the guidance share it.

### Tests
Swift Testing against the existing stub repositories: each view model's `isShowingSkeleton`
before a load, during a first load, after success, after a failure, during a retry after a
failure, and during a reload after success; each view model's displayed data before a load,
after success and after a failed first load; `UserManager.isProfileLoading` and
`profileLoadError` across load, failure and retry. Observing a load mid-flight needs the stubs'
fetches to be able to suspend until the test releases them; the stubs gain that. `hasLoaded`
changes nothing about the data a load produces, so the existing load tests stand. The
skeleton's opacity is a pure function of whether it is active, the time since its bones
appeared and Reduce Motion, so its delay, pulse and Reduce Motion are unit-tested;
`BarBone`'s geometry, the tag and chip sizes and each surface's bone colour are too. What the
bones look like is checked in previews (light and dark) and on the simulator against the
mockup.

## Risks / Trade-offs

- [A data `Text` added later without `.skeletonBone`] → It renders as a faded system placeholder
  rather than wrong data; previews of each skeleton show it.
- [Profile's sections start their 300 ms delays separately] → All start on appear, so their
  pulses run in step; a section whose data is cached never shows bones.
- [The error sheet appears on every failed profile retry while offline] → The same as a list
  reloading while offline; retries come only from reconnecting or returning to the app.
- [Placeholder rows are wider or narrower than a user's real data] → Rows keep their structure
  and height class; only bar widths differ, which the rules accept.
- [Changing the language or distance unit rebuilds every screen through the root `.id`] → The
  view models start over, so a slow first load shows bones again, where today it shows the
  spinner.
