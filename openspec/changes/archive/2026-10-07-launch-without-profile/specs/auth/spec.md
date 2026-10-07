## MODIFIED Requirements

### Requirement: Email Link Sign-In
The system SHALL allow a user to sign in by requesting a sign-in link sent to their
email address, without a password. Requesting a link SHALL require a connection. Opening the
link SHALL complete the sign-in whether or not the app was running, and a link that cannot
sign the user in SHALL be reported on the login screen rather than ignored. A link opened
while someone is signed in SHALL be ignored, so it can neither switch accounts nor leave an
error for a later login screen. A link that opens the app before the saved session is known
SHALL be held until it is, then used only if nobody is signed in. A sign-in by any method
SHALL forget the email a link was sent to, so an unused link cannot sign in after a later
sign-out.

#### Scenario: Sign in via email link
- **WHEN** a user enters their email, requests a sign-in link, and opens it
- **THEN** the system authenticates the user via Firebase Auth's email-link flow

#### Scenario: Link opened while the app is not running
- **WHEN** the app is closed entirely, nobody is signed in, and the user opens the sign-in
  link from their email
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

#### Scenario: Link opened while signed in
- **WHEN** a signed-in user opens an email sign-in link
- **THEN** no sign-in is attempted and no error is shown, now or after a later sign-out

#### Scenario: Link opens the app while a session is saved
- **WHEN** a signed-in user's app is closed entirely and they open an email sign-in link —
  for example one requested before signing in with Apple instead
- **THEN** once the saved session is restored, no sign-in is attempted and no error is shown,
  now or after a later sign-out

#### Scenario: Signed in another way after requesting a link
- **WHEN** a user requests a sign-in link, signs in with Apple or Google instead, later signs
  out, and then opens the link
- **THEN** no sign-in is attempted and the login screen shows
  `AppError.emailLinkFromAnotherDevice`

### Requirement: Launch Screen
While the app works out whether anyone is signed in, the system SHALL show the launch screen:
the MW seal, the app name, and a loading bar over "Loading your collection". The launch screen
SHALL offer no actions. Once the check completes, a signed-in user SHALL see the app's tabs
whether or not their profile has loaded.

#### Scenario: Nobody is signed in
- **WHEN** the app opens with no saved session
- **THEN** the login screen appears once the check completes

#### Scenario: App opened with a saved session
- **WHEN** a signed-in user opens the app
- **THEN** the launch screen shows until the saved session is restored, then the tabs appear
  without waiting for the profile

#### Scenario: Signing in
- **WHEN** a user completes any sign-in method
- **THEN** the tabs replace the login screen without waiting for the profile

#### Scenario: Profile cannot load
- **WHEN** the signed-in user's profile cannot load, whatever the reason
- **THEN** the tabs still appear, and the profile is loaded again when the connection returns
  or the app comes back to the foreground

#### Scenario: Reduce Motion is on
- **WHEN** the launch screen shows while Reduce Motion is on
- **THEN** the loading bar holds still instead of sliding across its track

#### Scenario: Different screen widths
- **WHEN** the launch screen shows on any screen width
- **THEN** the loading bar keeps the iOS mockup's proportion of 72 pt on a 390 pt screen

### Requirement: Profile Load at Sign-In
After a sign-in, or when the app opens with a saved session, the system SHALL load the
signed-in user's profile in the background, creating it on first sign-in. It SHALL wait for
the server to accept a new profile before using it, SHALL create a profile only when the
server confirms none exists, and SHALL NOT use a blank profile in place of one that cannot
load. A profile that finishes loading after the signed-in account has changed SHALL be
discarded.

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
- **THEN** no profile is used in its place, and the tabs show with the profile empty

#### Scenario: Sign-out while the profile loads
- **WHEN** the user signs out before their profile finishes loading
- **THEN** the profile that arrives afterwards is discarded
