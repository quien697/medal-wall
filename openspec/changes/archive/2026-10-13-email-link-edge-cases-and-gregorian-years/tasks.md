## 1. Email sign-in (TDD)

- [x] 1.1 Link failure shown over the email sheet while open, else on the login screen (`LoginViewModel.showSignInError`)
- [x] 1.2 A link failure after someone signed in is not reported (`UserManager.handleEmailLink`)
- [x] 1.3 Entered address trimmed for `isEmailValid`, sending and saving
- [x] 1.4 A send outliving its sheet saves the address it sent to and leaves the next opening clean

## 2. Gregorian years

- [x] 2.1 `Date.year` and `Date.startOfYear` use a Gregorian calendar (checked by script under ROC, Japanese and Buddhist calendars)

## 3. Verify

- [x] 3.1 Full test suite passes; `swift format lint --strict` and `swiftlint lint --strict` clean
