## MODIFIED Requirements

### Requirement: Email Link Sign-In
The system SHALL allow a user to sign in by requesting a sign-in link sent to their
email address, without a password. Requesting a link SHALL require a connection. Opening the
link SHALL complete the sign-in whether or not the app was running, and a link that cannot
sign the user in SHALL be reported rather than ignored: over the email sheet while it is
open, otherwise on the login screen. A link opened while someone is signed in SHALL be
ignored, so it can neither switch accounts nor leave an error for a later login screen, and a
link that fails after someone has signed in, such as the same link opened twice, SHALL NOT be
reported. The entered email address SHALL be used without the whitespace and line breaks
around it, both to judge whether it is valid and to send the link and save the address. A link that opens the app before the saved session is known
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
- **THEN** it shows `AppError.sendEmailSignInLinkFailed` with the underlying reason over the
  email sheet (see Email Sheet Errors)

#### Scenario: Link cannot sign the user in
- **WHEN** the user opens a sign-in link that fails — offline, already used, or expired
- **THEN** `AppError.emailLinkSignInFailed` is shown, over the email sheet if it is still
  open and otherwise on the login screen, and the email the link was sent to stays saved so
  the same link can be opened again

#### Scenario: Link opened on a device that did not request it
- **WHEN** the user opens a sign-in link on a device with no saved email for it — another
  device, or the same device after reinstalling
- **THEN** `AppError.emailLinkFromAnotherDevice` is shown, over the email sheet if it is open
  and otherwise on the login screen, and no sign-in is attempted

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

#### Scenario: Same link opened twice
- **WHEN** the user opens a sign-in link twice in quick succession and the first opening signs
  them in
- **THEN** the second opening's failure is not shown, now or after a later sign-out

#### Scenario: Email entered with spaces around it
- **WHEN** the user enters " runner@example.com" followed by a line break and sends the link
- **THEN** the link is sent to, and the address saved as, "runner@example.com", and the
  confirmation names that address

### Requirement: Email Sheet Errors
An error from sending an email sign-in link SHALL be shown over the email sheet while it is open,
not held until the sheet closes. Sending SHALL check the connection first and, when offline,
SHALL show `AppError.noInternetConnection` without attempting to send. A sign-in link that
fails while the sheet is open SHALL be reported over the sheet too; other errors raised outside
the email sheet SHALL still be shown on the login screen. A send still
running when the sheet closes SHALL NOT change what the sheet shows when it next opens; if it
sent the link, the address SHALL still be saved so the link works.

#### Scenario: Device goes offline after the sheet opens
- **WHEN** the user opens the email sheet, the device goes offline, and the user taps Send
- **THEN** `AppError.noInternetConnection` appears over the sheet at once, no link is sent, and
  no email is saved

#### Scenario: Sending fails while online
- **WHEN** the user taps Send and sending the link fails
- **THEN** `AppError.sendEmailSignInLinkFailed` with the underlying reason appears over the
  sheet, and the sheet stays open so the user can try again

#### Scenario: Error closed
- **WHEN** the user closes the error shown over the sheet
- **THEN** the email sheet is still open with the email they entered, and no error appears on
  the login screen afterwards

#### Scenario: Sheet closed while sending
- **WHEN** the user taps Send and closes the email sheet before sending finishes
- **THEN** the address is saved if the link was sent, and the sheet next opens empty with no
  error, no confirmation, and a Send button that is not busy
