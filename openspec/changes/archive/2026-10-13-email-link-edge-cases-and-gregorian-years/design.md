## Context

Review R7 of MW-32 (2026-10-13). Each fix restores what the user would expect from an existing
requirement, so the design notes only the choices that were open.

## Decisions

**Link errors go over the sheet, routed by `LoginViewModel.showSignInError`.** iOS cannot
present the login screen's error while the email sheet is up, which is why send errors already
go over the sheet. Routing in the ViewModel keeps the choice out of `LoginView` and testable.

**A send that outlives its sheet is detected by counting closings, not by
`isPresentingEmailSignIn`.** A counter bumped in `resetEmailFlow` also covers the sheet being
closed and reopened before the send finishes, where the flag would read "open" again.

**The address is captured before the send awaits.** The old code read `email` after the await,
when closing the sheet had already cleared it, and saved an empty address.

**Years use a fixed Gregorian calendar in the device's time zone.** Edition years are stored
and shared, so they cannot depend on a device setting. Days still begin at local midnight,
matching how the dates were picked. Medal year groups follow so they agree with edition years.

## Risks / Trade-offs

- A user of a non-Gregorian calendar now sees Gregorian year headers and edition years, while
  date pickers and formatted dates still follow their calendar.
