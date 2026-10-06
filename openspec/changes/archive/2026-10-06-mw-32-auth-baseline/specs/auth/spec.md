## MODIFIED Requirements

### Requirement: Email Link Sign-In
The system SHALL allow a user to sign in by requesting a sign-in link sent to their
email address, without a password. Requesting a link SHALL require a connection. Opening the
link SHALL complete the sign-in whether or not the app was running, and a link that cannot
sign the user in SHALL be reported on the login screen rather than ignored.

#### Scenario: Sign in via email link
- **WHEN** a user enters their email, requests a sign-in link, and opens it
- **THEN** the system authenticates the user via Firebase Auth's email-link flow

#### Scenario: Link opened while the app is not running
- **WHEN** the app is closed entirely and the user opens the sign-in link from their email
- **THEN** the app launches and completes the sign-in

#### Scenario: Continuing with email offline
- **WHEN** the user chooses to continue with email while the device has no connection
- **THEN** the email sheet does not open and the system shows `AppError.noInternetConnection`

#### Scenario: Sending the link fails
- **WHEN** the system cannot send the sign-in link
- **THEN** it shows `AppError.sendEmailSignInLinkFailed` with the underlying reason

#### Scenario: Link cannot sign the user in
- **WHEN** the user opens a sign-in link that fails — offline, already used, or expired
- **THEN** the login screen shows `AppError.emailLinkSignInFailed`, and the email the link
  was sent to stays saved so the same link can be opened again

#### Scenario: Link opened on a device that did not request it
- **WHEN** the user opens a sign-in link on a device with no saved email for it — another
  device, or the same device after reinstalling
- **THEN** the login screen shows `AppError.emailLinkFromAnotherDevice` and no sign-in is
  attempted

### Requirement: Google Sign-In
The system SHALL allow a user to sign in using their Google account via the
GoogleSignIn-iOS SDK. Closing Google's sheet SHALL report nothing, and any other failure
SHALL be reported. Only Google Sign-In's own cancel error — its error domain and its cancel
code together — SHALL count as closing the sheet.

#### Scenario: Sign in with Google
- **WHEN** a user completes the Google sign-in flow
- **THEN** the system authenticates the user via a Firebase Google credential

#### Scenario: User closes Google's sheet
- **WHEN** the user closes the Google sign-in sheet
- **THEN** no error is shown and the user stays on the login screen

#### Scenario: Google sign-in fails
- **WHEN** the Google flow or the Firebase sign-in fails, including with an error from
  another domain that happens to share Google's cancel code
- **THEN** the system shows a sign-in error

### Requirement: Apple Sign-In
The system SHALL allow a user to sign in using Sign in with Apple. Closing Apple's sheet
SHALL report nothing, and Apple's `.unknown` authorization error SHALL be treated the same
way. Any other failure SHALL be reported.

#### Scenario: Sign in with Apple
- **WHEN** a user completes the Sign in with Apple flow
- **THEN** the system authenticates the user via a Firebase Apple OAuth credential

#### Scenario: User closes Apple's sheet
- **WHEN** Apple's sheet ends with `ASAuthorizationError.canceled` or `.unknown`
- **THEN** no error is shown and the user stays on the login screen

#### Scenario: Apple sign-in fails
- **WHEN** Apple's sheet ends with any other error, its credential cannot be read, or the
  Firebase sign-in fails
- **THEN** the system shows a sign-in error

### Requirement: Session Validation
The system SHALL verify, by reloading the current Firebase user each time the app comes to
the foreground, that a signed-in user's account can still be used, and SHALL sign the user
out locally if the account was deleted or disabled. A check that cannot reach the server
SHALL leave the session as it is.

#### Scenario: Account deleted server-side
- **WHEN** the current user's account was removed (e.g. via the Firebase console) and
  a session validation check runs
- **THEN** the system signs the user out locally

#### Scenario: Account disabled server-side
- **WHEN** the current user's account was disabled (e.g. via the Firebase console) and a
  session validation check runs
- **THEN** the system signs the user out locally

#### Scenario: Check runs offline
- **WHEN** a session validation check runs while the device has no connection
- **THEN** the user stays signed in

### Requirement: Sign Out
The system SHALL allow a signed-in user to sign out, accessible from the Settings
screen. Signing out SHALL work without a connection. It ends the session only: Firestore's
local copy of the user's data stays on the device.

#### Scenario: User signs out
- **WHEN** a signed-in user taps "Sign out" in Settings
- **THEN** the system ends the Firebase Auth session and returns the user to the
  login screen

#### Scenario: User signs out offline
- **WHEN** a signed-in user signs out while the device has no connection
- **THEN** the session ends and the login screen appears

## ADDED Requirements

### Requirement: Persistent Session
A signed-in session SHALL persist on the device until the user signs out or session
validation ends it. Restoring the session SHALL NOT need a connection.

#### Scenario: App reopened after being closed
- **WHEN** a signed-in user closes the app entirely and opens it again
- **THEN** they are still signed in, without signing in again

#### Scenario: App reopened offline
- **WHEN** a signed-in user opens the app while the device has no connection
- **THEN** the session is restored from the device

### Requirement: Launch Screen
While the app works out whether anyone is signed in, and while a signed-in user's profile
loads, the system SHALL show the launch screen: the MW seal, the app name, and a loading bar
over "Loading your collection". The launch screen SHALL offer no actions, and the app's tabs
SHALL NOT appear until the signed-in user's profile has loaded.

#### Scenario: Nobody is signed in
- **WHEN** the app opens with no saved session
- **THEN** the login screen appears once the check completes

#### Scenario: App opened with a saved session
- **WHEN** a signed-in user opens the app
- **THEN** the launch screen shows until their profile has loaded, then the tabs appear

#### Scenario: Signing in
- **WHEN** a user completes any sign-in method
- **THEN** the launch screen replaces the login screen until their profile has loaded

#### Scenario: Profile cannot load
- **WHEN** the signed-in user's profile cannot load, whatever the reason
- **THEN** the launch screen stays, and the profile is loaded again when the connection
  returns or the app comes back to the foreground

#### Scenario: Reduce Motion is on
- **WHEN** the launch screen shows while Reduce Motion is on
- **THEN** the loading bar holds still instead of sliding across its track

#### Scenario: Different screen widths
- **WHEN** the launch screen shows on any screen width
- **THEN** the loading bar keeps the iOS mockup's proportion of 72 pt on a 390 pt screen

### Requirement: Profile Load at Sign-In
After a sign-in, or when the app opens with a saved session, the system SHALL load the
signed-in user's profile, creating it on first sign-in. It SHALL wait for the server to
accept a new profile before using it, SHALL create a profile only when the server confirms
none exists, and SHALL NOT use a blank profile in place of one that cannot load. A profile
that finishes loading after the signed-in account has changed SHALL be discarded.

#### Scenario: First sign-in
- **WHEN** a user signs in and the server has no profile for them
- **THEN** the system creates the profile and uses it only once the server has accepted it

#### Scenario: Profile missing from the device's copy
- **WHEN** the device is offline and its local copy holds no profile for the user
- **THEN** the system treats the profile as unreachable and does not create one

#### Scenario: Offline with the profile on the device
- **WHEN** the device is offline and its local copy holds the user's profile
- **THEN** the app opens with that copy, which is read-only until the server's profile loads

#### Scenario: Profile cannot load
- **WHEN** fetching the profile fails
- **THEN** no profile is used in its place and the launch screen stays

#### Scenario: Sign-out while the profile loads
- **WHEN** the user signs out before their profile finishes loading
- **THEN** the profile that arrives afterwards is discarded
