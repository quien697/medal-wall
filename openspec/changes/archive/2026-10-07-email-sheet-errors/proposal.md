## Why

When sending an email sign-in link fails — most often because the device went offline after the
email sheet opened — the error is raised on the login screen underneath the sheet. iOS shows it
only once the sheet closes, so the user sees the Send spinner flash and then nothing, and may keep
tapping Send.

## What Changes

- An error from sending the link is shown over the email sheet, while the sheet is still open.
- Sending checks the connection first; offline shows `AppError.noInternetConnection` at once,
  without asking Firebase.
- `LoginViewModel` takes its email-link dependencies (auth service, network monitor, defaults)
  in its init so the email flow can be tested.

## Capabilities

### New Capabilities

### Modified Capabilities
- `auth`: adds Email Sheet Errors — errors from sending a link appear over the email sheet, and
  sending offline is refused at once.

## Impact

- `MedalWall/Features/Login/ViewModels/LoginViewModel.swift`, `Views/LoginView.swift`,
  `Views/SignInWithEmailLinkView.swift`.
- `MedalWall/Services/FirebaseAuthService.swift` — `sendSignInLink(to:)` joins `AuthService`.
- `MedalWall/Services/NWPathNetworkMonitor.swift` — one-off `isConnected()` on `NetworkMonitor`.
- `MedalWallTests/Support/StubAuthService.swift`, `StubNetworkMonitor`, new `LoginViewModelTests`.
- `MedalWall.xcodeproj/project.pbxproj` — `LoginViewModel.swift` added to the test target's list.
