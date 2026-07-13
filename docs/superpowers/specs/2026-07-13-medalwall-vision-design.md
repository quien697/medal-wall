# MedalWall — Vision & Architecture

The baseline reference for MedalWall's product and technical design, used as the
foundation for future OpenSpec change proposals.

## 1. Purpose & Audience

MedalWall is a personal digital archive for runners: log race results, showcase medal
photos, and relive each race in one organized, visual record. Running-only for now,
with room to grow into other medal-based endurance events later.

Target audience: recreational and competitive runners, marathon collectors, and
athletes who value storytelling over pace charts.

## 2. Core Features

**Race List** — A structured list of race events. Full CRUD.
Each `Race` can have multiple `RaceEdition`s (e.g. Marathon 2024, Marathon 2025),
separating the race's identity (name, location, photo, website) from a given year's
specifics (date, distances offered). Manual entry today; regional race-API integration
(e.g. Race Roster) remains a future direction.

**Medal List** — A visual archive of every completed race. Full CRUD, grid layout. Each medal records race name, date, bib
number, location, distance, finish time, placements (overall/division/gender),
division + age group, notes, tags, a cover photo, and an event photo gallery.

**Profile** — A personal dashboard: profile photo, display name, bio, gender, birthday
(all editable), plus computed stats — total medals, full/half marathon counts, and
best full/half marathon times.

**Achievements** — Open design question, see §6. Not currently built.

**Settings** — Appearance (light/dark/system theme) is implemented. Planned:
data export, distance units (km ↔ mi), and notification preferences.

**Auth** — Email link, Google, and Apple sign-in via `AuthService`. Planned addition:
LINE sign-in, relevant given the app's race data skews toward the Taiwan market.

## 3. Architecture

Firestore is the persistence layer for all data; Firebase Storage holds photos and
returns download URLs stored on the models. No local persistence layer (no SwiftData).

MVVM throughout: Views → ViewModels → Repositories → Firebase. Repositories are
stateless and return values only. Edit flows use a draft pattern — edit ViewModels
stage changes in local draft structs, and writes only reach Firestore on explicit save.
`UserManager` is the single source of truth for auth state and the current user,
injected via `@Environment`.

## 4. Data Model

- **User** — name, bio, photo, gender, birthday, plus computed stats.
- **Race** — name, photo, location, website URL; owns a subcollection of `RaceEdition`s.
- **RaceEdition** — a specific year's running of a race: date(s), distances offered.
- **RaceDistance** / **RaceDistanceCategory** / **RaceDistanceType** — distance value
  types (full, half, 10K, 5K, custom) and participation mode (in-person/virtual).
- **Medal** — race name, date, bib number, location, distance, finish time,
  placements, division + age group, notes, tags, cover photo, event photos.
- **Division** — gender + age group, stored as a space-separated string
  (`"male from30to34"`), parsed by splitting on the last space.
- **AgeGroup**, **EventPhoto** — supporting value types for `Medal`.
- **MeasurementUnit** (km ↔ mi) — planned, not yet implemented; distances are
  currently unit-less.

## 5. Roadmap Ideas

Race reminders / registration-deadline notifications, calendar integration, map
visualization of completed races, share/export achievements or profile, Strava/Apple
Health integration, home-screen widgets, yearly summaries and total-countries stat on
Profile, monetization strategy (paid/free/subscription/IAP/ads — undecided).

## 6. Open Design Questions

**Achievements** — needs a fresh brainstorm. Current UI
(`ProfileAchievementsSection`, `ProfileAchievementRow`) is placeholder-only, showing
static example rows, and isn't even wired into `ProfileView.body`. Treat this as
undesigned until a dedicated brainstorming session happens.

## 7. OpenSpec Capability Map

Baseline capability specs to write next:

- `races` — Race + RaceEdition CRUD
- `medals` — Medal CRUD
- `profile` — editable fields + computed stats
- `settings` — appearance (built); export/units/notifications (planned)
- `auth` — Email/Google/Apple (built); LINE (planned)
- `achievements` — deferred until the design question in #6 is resolved; no baseline
  spec until then

Each becomes an `openspec/specs/<capability>/spec.md`. Future feature work becomes an
`openspec new change` proposal that diffs against these baselines.
