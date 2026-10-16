## Why

The sign-in and profile-loading flow was reworked on `chore/MW-32-code-organization`, and the
`auth` and `profile` specs still describe the July baseline: three sign-in methods, a session
check for deleted accounts, and sign-out. They say nothing about what the app does offline, when
a sign-in link fails, what the user sees while their profile loads, or when a profile may be
written — the decisions that commits `4619754` to `848110c` settled. This change records that
behaviour as the baseline. It does not change code: everything here is already implemented and
tested.

## What Changes

- Record how long a session lasts and what ends it, including a disabled account.
- Record what each sign-in method reports when it fails, and that closing a sign-in sheet
  reports nothing.
- Record the email sign-in link's failure cases: offline, used or expired, and opened on a
  device that did not request it.
- Record the launch screen, shown until the session is known and the signed-in user's profile
  has loaded, with no way past it while the profile cannot load.
- Record how the profile loads at sign-in: created on first sign-in and waited for, never
  created on the phone's word alone, never replaced by a blank profile, and dropped if the
  account changes before it arrives.
- Record that a profile read from the phone's copy is shown but never written, until the
  server's copy replaces it.
- Record that a removed profile photo is deleted only after the profile save succeeds.
- No code changes.

## Capabilities

### New Capabilities
None.

### Modified Capabilities
- `auth`: adds the session's lifetime, sign-in failure and cancel reporting, email-link failure
  cases, the launch screen, and loading the profile at sign-in; extends session validation to
  disabled accounts and sign-out to offline use.
- `profile`: adds the read-only cached profile and the order in which a removed profile photo
  is deleted.

## Impact

None to running code. `openspec/specs/auth/spec.md` and `openspec/specs/profile/spec.md` gain
the requirements above, so later changes — the content-loading skeletons, error screens on the
launch screen — have this behaviour to diff against. Acknowledged writes and offline saves stay
in `persistence-integrity`, which already covers them.
