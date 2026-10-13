## Why

The final MW-32 review (R7) found email sign-in edge cases and a calendar bug that the specs
do not cover. A link that failed while the email sheet was open showed nothing until the sheet
closed; a sheet closed mid-send saved an empty address, so the link then failed; the typed
address was never trimmed; and a device set to the ROC, Japanese or Buddhist calendar read
edition years in that calendar, so on an ROC device Add Edition opened on the year 115 and a
picked 2026 got dates in AD 3937, saved into shared race data. Web,
admin and Android clients are planned against the same data, so the rules need writing down.

## What Changes

Specs only; the code ships alongside, test-first.

- A failed sign-in link is shown over the email sheet while it is open, otherwise on the login
  screen. A link that fails after someone signed in, such as the same link opened twice, is
  not reported.
- The entered email address is trimmed for validation, sending and saving.
- A send still running when the email sheet closes no longer changes the sheet's next opening,
  and still saves the address it sent the link to.
- Edition years and medal year groups are Gregorian whatever calendar the device uses.

## Capabilities

### New Capabilities

### Modified Capabilities
- `auth`: Email Link Sign-In reports link failures over an open email sheet, ignores a failure
  after sign-in, and trims the address; Email Sheet Errors covers a sheet closed mid-send.
- `races`: Race Edition Management stores Gregorian years.
- `medal-browsing`: Year Grouping groups by Gregorian year.

## Impact

- Code: `LoginViewModel`, `LoginView`, `SignInWithEmailLinkView` (doc), `UserManager`,
  `Date+Extensions`. Tests in `LoginViewModelTests`, `UserManagerEmailLinkTests`, with new
  hooks in `StubAuthService`.
- The Gregorian change is not unit-tested: the simulator's calendar is always Gregorian. It
  was checked with a script run under `zh_TW@calendar=roc`, `ja_JP@calendar=japanese` and
  `th_TH@calendar=buddhist`.
