## Context

`UserManager.sessionState` drives the root screen in `MedalWallApp`: `.loading` → `LaunchView`,
`.signedOut` → `LoginView`, `.ready` → `ContentView`'s tabs. Today `.ready` needs both a known
session and a loaded `currentUser`, so a profile that never loads leaves the user on
`LaunchView`, which has no actions. `ProfileView` disables Edit Profile without a profile
(through `canEditProfile`) but would otherwise show a "Runner" header and medal statistics.
Medals and Races load their own data inside their tabs, so nothing outside the You tab needs
the profile.

`handleOpenURL` ignores an email sign-in link when `currentUserID != nil`. At a cold launch,
`currentUserID` is nil until Firebase's auth listener has reported the restored session, so a
link that opened the app is used even when a session is saved.

## Goals / Non-Goals

**Goals:**
- The launch screen waits only for the session check; the tabs never wait for the profile.
- Until the profile loads, the You tab's content is blank; its title and toolbar stay.
- An email link behaves the same whether it opens the app from closed or from the background.

**Non-Goals:**
- Skeleton loading for the profile, medals or races — a later change.
- Showing why a profile failed to load, or a retry button.
- Changing the launch screen's copy or look.
- `UserName.fullName`'s "Runner" fallback for a loaded profile with no name — unchanged.

## Decisions

**`sessionState` depends on the session only.** `.loading` while `isLoadingAuth`, then
`.signedOut` or `.ready` from `currentUserID`. The profile's loading, retry on reconnect or
foreground, cached-copy read-only rule and `profileLoadError` stay as they are; they just no
longer gate the root screen. `SessionState.loading`'s doc comment changes to match.

**`ProfileView` shows its content only with a profile.** The header, summary and
achievements sections sit inside `if let user = userManager.currentUser`; the header reads
`user.name`. That leaves `UserManager.currentUserName` with no caller, so it is removed — its
"Runner" fallback could no longer be reached. The summary and progress are hidden too, even
though they come from the medal list, so the tab is wholly blank until skeletons replace it.
Medals still load on appear, so the statistics are ready when the profile arrives.

**Hold a link that arrives before the session is known** (`pendingSignInLink: String?`).
`handleOpenURL` stores the link when `isLoadingAuth` is true. `authStateDidChange` takes it on
the first report: used through `handleEmailLink` when nobody is signed in, dropped when
someone is.
- *Alternative: ask Firebase directly* — a synchronous `currentAccount` on `AuthService`
  returning `Auth.auth().currentUser`, which Firebase restores during `configure()`. Less code,
  but it leans on undocumented restore timing and the stub has to imitate it.
- *Alternative: await the first auth report* — a continuation `handleOpenURL` suspends on.
  Same result as holding, with more async plumbing.

**Forget the saved email on any sign-in.** `authStateDidChange` removes the
`pendingEmailSignIn` key whenever an account is reported, beside dropping `signInError`. Before,
only a successful email-link sign-in cleared it, so a link requested and then bypassed with Apple
or Google stayed usable after a later sign-out. A link that fails keeps the email as before,
since no account is reported.

Holding the link makes the existing `signInError = nil` on sign-in a backstop rather than the
fix; it stays, since it costs nothing.

## Risks / Trade-offs

- [The You tab is briefly blank on every launch] → Expected until skeletons land; the
  profile is usually on the device and fills in almost at once.
- [Existing email-link tests open a link before any auth report] → They now need
  `report(nil)` first, or they test the held path; tasks call this out.
- [A held link is lost if the auth listener never reports] → Firebase always reports once
  after `configure()`; the launch screen would be stuck anyway in that case.
