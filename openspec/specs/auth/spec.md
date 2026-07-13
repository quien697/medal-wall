# auth Specification

## Purpose
TBD - created by archiving change baseline-current-capabilities. Update Purpose after archive.
## Requirements
### Requirement: Email Link Sign-In
The system SHALL allow a user to sign in by requesting a sign-in link sent to their
email address, without a password.

#### Scenario: Sign in via email link
- **WHEN** a user enters their email, requests a sign-in link, and opens it
- **THEN** the system authenticates the user via Firebase Auth's email-link flow

### Requirement: Google Sign-In
The system SHALL allow a user to sign in using their Google account via the
GoogleSignIn-iOS SDK.

#### Scenario: Sign in with Google
- **WHEN** a user completes the Google sign-in flow
- **THEN** the system authenticates the user via a Firebase Google credential

### Requirement: Apple Sign-In
The system SHALL allow a user to sign in using Sign in with Apple.

#### Scenario: Sign in with Apple
- **WHEN** a user completes the Sign in with Apple flow
- **THEN** the system authenticates the user via a Firebase Apple OAuth credential

### Requirement: Session Validation
The system SHALL verify, by reloading the current Firebase user, that a signed-in
user's account still exists, and SHALL sign the user out locally if it does not.

#### Scenario: Account deleted server-side
- **WHEN** the current user's account was removed (e.g. via the Firebase console) and
  a session validation check runs
- **THEN** the system signs the user out locally

### Requirement: Sign Out
The system SHALL allow a signed-in user to sign out, accessible from the Settings
screen.

#### Scenario: User signs out
- **WHEN** a signed-in user taps "Sign out" in Settings
- **THEN** the system ends the Firebase Auth session and returns the user to the
  login screen

