## ADDED Requirements

### Requirement: Email Sheet Errors
An error from sending an email sign-in link SHALL be shown over the email sheet while it is open,
not held until the sheet closes. Sending SHALL check the connection first and, when offline,
SHALL show `AppError.noInternetConnection` without attempting to send. Errors raised outside the
email sheet SHALL still be shown on the login screen.

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
