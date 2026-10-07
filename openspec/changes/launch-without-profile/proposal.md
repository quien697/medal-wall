## Why

A signed-in user reaches the tabs only once their profile has loaded, so a profile that never
loads — bad data, a permission change — keeps them on the launch screen, which has no actions,
until they delete the app. Each tab already loads its own data, so the profile has no reason to
gate the whole app. Separately, an email sign-in link that opens the app from closed is handled
before the saved session is known, so it can switch a signed-in user to another account — for
example from an Apple "Hide My Email" account to an empty email account.

## What Changes

- The launch screen covers only the check for a saved session. A signed-in user goes straight
  to the tabs, whether or not their profile has loaded.
- The You tab's content stays blank — no header, statistics or progress — until the profile
  loads; the title and toolbar stay, with Edit Profile disabled. The profile is still loaded
  again when the connection returns or the app comes back to the foreground. No error is
  shown.
- An email sign-in link that arrives before the saved session is known is held until it is:
  used if nobody is signed in, dropped silently if someone is.
- A sign-in by any method forgets the email a link was sent to, so a link requested and then
  left unused cannot sign in after a later sign-out.

## Capabilities

### New Capabilities

### Modified Capabilities
- `auth`: Launch Screen covers the session check only; Profile Load at Sign-In no longer keeps
  the launch screen up; Email Link Sign-In ignores a link that opens the app while a session is
  saved.
- `profile`: until the profile loads, the You tab's content is blank and it cannot be edited.

## Impact

- `MedalWall/Managers/UserManager.swift` — `sessionState`, `handleOpenURL`,
  `authStateDidChange`; `currentUserName` removed.
- `MedalWall/Features/Profile/Profile/Views/ProfileView.swift` — content shown only with a
  profile.
- `MedalWallTests/Unit/User/UserManagerTests.swift` — new and updated tests.
- No change to `LaunchView`, Medals or Races, or to Firestore data.
