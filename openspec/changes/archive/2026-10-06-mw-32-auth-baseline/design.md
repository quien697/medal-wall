## Context

The behaviour this change records is already implemented and tested on
`chore/MW-32-code-organization` (commits `4619754` to `848110c`). It came out of a code review
and a walk through every sign-in situation — offline, signal dropping mid-way, closing the app,
reinstalling. This document keeps the reasoning behind each decision, which the code alone
cannot carry.

Where it lives:
- `UserManager` follows the session through the `AuthService` protocol (`FirebaseAuthService`)
  and the network through `NetworkMonitor` (`NWPathNetworkMonitor`), loads the profile, and
  exposes `sessionState` — `.loading`, `.signedOut`, `.ready` — which `MedalWallApp` switches
  on to show `LaunchView`, `LoginView` or the tabs.
- `UserFirestoreRepository.fetchUser` reports whether the profile came from the server or the
  device's copy, and maps Firestore's "server unreachable" error to
  `AppError.noInternetConnection`.
- `ProgressBar` is the design system's single progress component; the launch screen uses its
  no-progress mode.

## Goals / Non-Goals

**Goals:**
- Make `auth` and `profile` describe what the app does today, including offline and failure
  cases, so later changes have a baseline to diff against.

**Non-Goals:**
- No code changes.
- Saves waiting for the server and offline saves staying in flight: `persistence-integrity`
  already specifies them.
- Content-loading skeletons for the profile, medals and races, and error screens on the
  launch screen. Both are planned as later changes.

## Decisions

- **The first profile write is awaited.** Signing in already needs the network, so the only
  gap is the moment between sign-in and the write. Waiting means a new user never starts on a
  profile the server may not have. *Alternative:* fire-and-forget, which hid failures and
  needed extra test machinery.
- **No blank profile.** A failed fetch used to put `User(uid:email:)` in place of the profile,
  and the next profile save or milestone update overwrote the real one with it. Nothing stands
  in now; the launch screen stays until the real profile loads.
- **Only the server says a profile is missing.** A document absent from the device's copy
  reads as offline, so a first-sign-in create never overwrites a profile the server has.
- **A cached profile is read-only.** It can be older than the server's, so writing it — from
  Edit Profile or a milestone update — could put an old version back. It is replaced on
  reconnect or foreground.
- **One launch screen, no actions.** Checking the session and loading the profile look the
  same to the user, so they are one `.loading` state. The screen follows the iOS mockup's
  Launch screen. *Alternatives tried and dropped:* "Waiting for a Connection" and "Couldn't
  Load Your Profile" screens, which flashed for half a second on a weak signal; and a Sign out
  button on the loading screen, which the launch screen does not need.
- **Retry triggers.** A profile that could not load is retried when `NWPathNetworkMonitor`
  reports the connection back and whenever the app comes to the foreground.
- **Capability split.** Everything up to the tabs appearing is `auth`; what happens to the
  profile afterwards is `profile`.

## Risks / Trade-offs

- [Stuck on the launch screen] With no connection and no profile on the device — for example
  just after reinstalling — the launch screen has no way past it but waiting. → Accepted: it
  clears by itself when the connection returns. Error screens arrive with the skeleton work.
- [Firestore still offline at reconnect] The network can come back a moment before Firestore
  reconnects, so the retry may fail again. → Coming back to the foreground retries too.
- [Apple's `.unknown`] Treated as closing the sheet, so a real failure Apple reports that way
  shows nothing. → Kept as it was; no device evidence yet.
- [Session after reinstalling] iOS keeps the Firebase session in the keychain, which usually
  survives deleting the app, so a reinstalled app can open signed in with an empty local copy.
  This is platform behaviour, not a requirement.

## Open Questions

Verify on a device — the simulator renders could not show these:
- With airplane mode on and no profile on the device, turning airplane mode off clears the
  launch screen by itself.
- A cached profile greys out Edit Profile offline and enables it once back online.
- Opening a sign-in link offline shows the link error.
- The launch screen and its loading bar look right on a real screen, inside the safe area.
