# MedalWall — Project Context

Product framing and forward-looking ideas that no capability spec owns. Architecture, data
model, and conventions live in `CLAUDE.md`; what the app does today lives in
`openspec/specs/`. This file is the "why" and the "next", not the "what".

## Purpose & Audience

MedalWall is a personal digital archive for runners: log race results, showcase medal photos,
and relive each race in one organized, visual record. Running-only for now, with room to grow
into other medal-based endurance events later.

Target audience: recreational and competitive runners, marathon collectors, and athletes who
value storytelling over pace charts.

## Capability Map

Built, each with a spec in `openspec/specs/`:

| Capability | Notes |
|---|---|
| `races` | Race + RaceEdition CRUD |
| `medals` | Medal CRUD, filtering, year grouping, personal records |
| `profile` | Editable fields + computed stats |
| `achievements` | Full/Half milestone tracks with sticky tiers |
| `auth` | Email link, Google, Apple |
| `settings` | Appearance |
| `distance-units` | km ↔ mi |
| `localization` | en / zh-TW |
| `image-caching` | Remote photo caching |
| `place-entry` | Location picker |

Planned, no spec yet: data export, notification preferences, LINE sign-in (relevant given the
app's race data skews toward the Taiwan market).

## Roadmap Ideas

Not committed, not ordered — the pool future proposals get drawn from:

- Race reminders and registration-deadline notifications
- Calendar integration
- Map visualization of completed races
- Share/export achievements or profile
- Strava / Apple Health integration
- Home-screen widgets
- Yearly summaries, and a total-countries stat on Profile
- Monetization strategy — paid, free, subscription, IAP, or ads; undecided

## Open Questions

- **Race identity.** Races are freeform manual entries with no link to a race registry. Several
  ideas above — Majors-club achievements, race-API import, deadline reminders — are blocked on
  canonical race identity. Solving it once would unblock all of them.
- **Monetization.** Undecided, and it shapes what "export" and "sharing" should mean.
