## Context

`LoginView` presents both the email sheet and the error sheet. SwiftUI lets a view present one
sheet at a time, so an error raised while the email sheet is open waits until it closes. Sheets
that raise their own errors elsewhere — `EditProfileView`, `EditMedalView` — present the error
from inside themselves. `LoginViewModel` builds `FirebaseAuthService`, an `NWPathMonitor` and
`UserDefaults.standard` itself, so none of this can be tested.

## Goals / Non-Goals

**Goals:** send errors appear over the email sheet; sending offline is refused at once; the
email flow is testable.

**Non-Goals:** testing the Apple and Google flows, which stay on the concrete
`FirebaseAuthService`; changing the sheet's layout or copy.

## Decisions

**A separate `emailSheetError` on `LoginViewModel`.** `sendEmailLink` writes it; `error` stays
for the login screen. `SignInWithEmailLinkView` presents `emailSheetError` with the project's
usual bridge (`onChange` → `ErrorWrapper` → `.sheet(item:)` → reset on dismiss), through a
binding. Routing by which sheet is open in `LoginView` was the alternative; it puts a decision in
the view, and two presenters bound to one wrapper rely on SwiftUI refusing one of them.

**Connection check before sending.** `NetworkMonitor` gains `isConnected() async -> Bool`, the
one-off check `LoginViewModel` already had privately, now on `NWPathNetworkMonitor`.
`signInWithEmailLink` and `sendEmailLink` both use it.

**Inject the email dependencies only.** `sendSignInLink(to:)` joins `AuthService` beside the
other email-link methods. `LoginViewModel.init` takes `emailAuthService: any AuthService`,
`networkMonitor: any NetworkMonitor` and `defaults: UserDefaults`, with production defaults.
Apple and Google keep using the concrete service; moving them behind the protocol means
widening it with UIKit-bound calls, which this fix does not need.

## Risks / Trade-offs

- [`LoginViewModel` holds two auth service references] → Named for what each does; folding
  them together is a later change if Apple and Google get tests.
- [`LoginViewModel.swift` compiled into the test target pulls in its imports] → Add it to the
  include list and build the tests before writing them.
