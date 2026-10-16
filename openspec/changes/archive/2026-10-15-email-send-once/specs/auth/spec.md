## MODIFIED Requirements

### Requirement: Email Sheet Errors
An error from sending an email sign-in link SHALL be shown over the email sheet while it is open,
not held until the sheet closes. Sending SHALL check the connection first and, when offline,
SHALL show `AppError.noInternetConnection` without attempting to send. A sign-in link that
fails while the sheet is open SHALL be reported over the sheet too; other errors raised outside
the email sheet SHALL still be shown on the login screen. A send still
running when the sheet closes SHALL NOT change what the sheet shows when it next opens; if it
sent the link, the address SHALL still be saved so the link works. A second tap on Send while
a send is running SHALL be ignored, so one tap sends one email.

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

#### Scenario: Send tapped twice
- **WHEN** the user taps Send twice in quick succession
- **THEN** one sign-in link is sent, and the Send button stays busy until that send finishes
