## Why

Review R9 of MW-32 found that a fast double tap on Send could start two sends before the button
redrew as disabled: two emails went out, and the first to finish re-enabled Send while the
second was still running. Planned web and Android clients should behave the same, so the rule
is written down.

## What Changes

Specs only; the code ships alongside, test-first.

- A second tap on Send while a send is running is ignored, so one tap sends one email.

## Capabilities

### New Capabilities

### Modified Capabilities
- `auth`: Email Sheet Errors ignores a second Send tap while a send is running.

## Impact

- Code: `LoginViewModel.sendEmailLink`. Test in `LoginViewModelTests`.
