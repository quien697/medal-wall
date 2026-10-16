## Why

Review R8 of MW-32 found two gaps in the email sheet behavior just specified: a send that
outlived its sheet still left the next opening's Send button spinning and disabled, and the
confirmation named the address as typed, stray spaces included, rather than the address the
link went to.

## What Changes

Specs only; the code ships alongside, test-first.

- A send still running when the sheet closes no longer keeps the next opening's Send button
  busy.
- After a send works, the confirmation names the trimmed address the link was sent to.

## Capabilities

### New Capabilities

### Modified Capabilities
- `auth`: Email Link Sign-In's trimmed-address scenario covers the confirmation; Email Sheet
  Errors' sheet-closed-mid-send scenario covers the Send button.

## Impact

- Code: `LoginViewModel` (`sendEmailLink`, `resetEmailFlow`). Tests in `LoginViewModelTests`.
