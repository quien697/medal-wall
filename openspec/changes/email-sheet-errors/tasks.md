## 1. Make the email flow testable

- [x] 1.1 Add `sendSignInLink(to:)` to `AuthService` and `StubAuthService` (scriptable outcome,
      recorded emails)
- [x] 1.2 Add `isConnected()` to `NetworkMonitor`, `NWPathNetworkMonitor` and
      `StubNetworkMonitor`
- [x] 1.3 Inject `emailAuthService`, `networkMonitor` and `defaults` into `LoginViewModel`;
      replace its private connection check; add `LoginViewModel.swift` to the test target's
      include list

## 2. Errors over the sheet

- [x] 2.1 Write failing `LoginViewModelTests`: offline send sets `emailSheetError` to
      `.noInternetConnection` without sending or saving; a failed send sets `emailSheetError`
      and leaves `error` nil; a successful send saves the email and marks it sent
- [x] 2.2 Add `emailSheetError`, set it from `sendEmailLink`, and check the connection first
- [x] 2.3 Present `emailSheetError` from `SignInWithEmailLinkView` through a binding; add a
      `#Preview` with an error

## 3. Verify

- [x] 3.1 Run the full test suite and SwiftLint
- [ ] 3.2 In the simulator, offline after opening the sheet: tapping Send shows the error over
      the sheet at once
