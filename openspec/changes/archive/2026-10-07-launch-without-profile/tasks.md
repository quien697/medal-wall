## 1. Tabs without a profile

- [x] 1.1 Write failing tests in `UserManagerTests`: a signed-in user whose profile can't load
      (`.noInternetConnection`, `.unknown`) is `.ready` with no blank profile; a signed-in user
      whose profile is still loading is `.ready`
- [x] 1.2 Replace `testFailedLoadKeepsLoading` and `testSignInWaitsForProfileCreate`, which
      assert the old `.loading` behaviour
- [x] 1.3 Make `sessionState` depend on `isLoadingAuth` and `currentUserID` only; update the
      doc comments on `sessionState` and `SessionState.loading`
- [x] 1.4 In `ProfileView`, show the header, summary and achievements sections only inside
      `if let user = userManager.currentUser`, passing `user.name` to the header; keep the
      title, toolbar and medal loading outside it
- [x] 1.5 Remove `UserManager.currentUserName`, now without a caller; keep the `"Runner"` string,
      which `UserName` still uses
- [x] 1.6 Add a `#Preview` of `ProfileView` with no profile loaded

## 2. Hold an early sign-in link

- [x] 2.1 Write failing tests: a link opened before the session is known, followed by a
      signed-in report, attempts no sign-in and leaves no `signInError`; followed by a
      signed-out report, signs in with the saved email
- [x] 2.2 Add `report(nil)` before `handleOpenURL` in the existing email-link tests that
      expect the link to be used straight away
- [x] 2.3 Add `pendingSignInLink` to `UserManager`: `handleOpenURL` stores the link while
      `isLoadingAuth`; `authStateDidChange` uses it when signed out and drops it when signed in;
      update the `handleOpenURL` doc comment
- [x] 2.4 Write a failing test that a sign-in by any method forgets the saved email, then remove
      the key in `authStateDidChange` whenever an account is reported

## 3. Verify

- [x] 3.1 Run the full test suite
- [x] 3.2 Build, then check in the simulator: launch signed in shows the tabs at once, and the
      You tab is blank, with Settings reachable, while offline with no cached profile
