## Why

While a screen fetches its data, the app covers it with a dimmed spinner (Medals, Races, Race
detail, the race picker, Edit Race's editions) or leaves it blank (the You tab). Neither shows
what is about to appear, and a profile that fails to load leaves the You tab blank with no
explanation. Design System v4.5.9 and iOS mockup v4.5.5 now define skeleton loading — bones in
the shape of the coming content, in two fixed colours — so the screens can adopt it (Jira MW-14).

## What Changes

- Screens that fetch data show **skeleton bones** in place of their content until their first
  load completes: the You tab (Profile), Medals, Races, Race detail's editions, the race picker
  in Add Medal, and the editions list in Edit Race. Each screen's data-loading spinner is removed.
- Only data becomes bones. Titles, toolbars, the search field, section titles and the tab bar
  are real from the first frame. Bones take the size and shape of the real content they stand
  in for, and cover its colours — gold, navy and text colours included — with
  `Color.Skeleton.onPage` on the page or `Color.Skeleton.inCard` inside a card.
- Bones appear only once a load has taken 300 ms, pulse in opacity 0.6 → 1 over 1.2 s, and hold
  still under Reduce Motion.
- Bones show only while a screen has nothing to show. A reload of a screen that already shows
  content swaps the new data in without bones or a spinner.
- On the You tab, the header turns real when the profile loads; the statistics and achievements
  turn real when the medals load.
- A profile that cannot load now shows an empty state across the whole You tab and an error
  sheet. **This replaces** the current rule that the tab stays blank with no error.
- New `Color.Skeleton` role (`onPage` → Stone, `inCard` → Granite) in `Color+Extensions.swift`.
- Unchanged: the spinner inside a photo while it downloads, and the spinners on save buttons.

## Capabilities

### New Capabilities
- `skeleton-loading`: which screens show skeleton bones, when they appear and go away, how bones
  look and move, and how a failed first load or reload is presented.

### Modified Capabilities
- `profile`: *Profile Not Yet Loaded* — the You tab shows bones while the profile loads and, when
  it cannot load, an empty state with an error sheet instead of staying blank with no error.
  *Computed Race Statistics* — the statistics turn real when the medals load, not when the
  profile does.

## Impact

- **Design tokens:** `MedalWall/Shared/Extensions/Color+Extensions.swift` gains `Color.Skeleton`;
  `openspec/design-system/tokens.json` already records it (v4.5.9).
- **New shared code:** a screen-level skeleton modifier (redaction switch, 300 ms delay, pulse,
  Reduce Motion) and a bone modifier for individual pieces of data, under `MedalWall/Shared/`.
- **Placeholder data** for the bones: a placeholder `User`, medals, races and editions.
- **View models:** `MedalsViewModel`, `RacesViewModel`, `RaceDetailViewModel`,
  `RaceEntryPickerViewModel`, `EditRaceViewModel` and `ProfileViewModel` tell a first load
  apart from a reload.
- **`UserManager`:** exposes whether the profile is loading or has failed, and why, without
  letting the error sheet's dismissal affect the retry on reconnect or foreground.
- **Views:** `ProfileView`, `MedalsView`/`MedalList` and their rows, `RacesView`/`RaceList`/`RaceRow`,
  `RaceDetailView`/`RaceDetailEditionsSection`, `RaceEntryPicker`/`RaceEntryList`,
  `EditRaceEditionSection`, plus `StatCard`, `TierBadge`, `ProgressBar` and the profile
  sections, which gain bones.
- **Localization:** the You tab's new empty-state title and description, and the "Loading" label
  VoiceOver reads for a skeleton, in English and zh-TW.
- No Firestore schema, repository or dependency changes.
