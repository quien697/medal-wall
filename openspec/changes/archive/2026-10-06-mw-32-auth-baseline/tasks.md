## 1. Verify the auth spec against code

- [x] 1.1 Confirm email-link failures match `UserManager.handleEmailLink` —
  `testEmailLinkSignInSucceeds`, `testEmailLinkSignInFailureIsReported`,
  `testEmailLinkFromAnotherDeviceIsReported`
- [x] 1.2 Confirm the offline check and send failure match `LoginViewModel.signInWithEmailLink`
  and `sendEmailLink` (code reading)
- [x] 1.3 Confirm Google's cancel check matches `FirebaseAuthService.isGoogleCancellation` —
  `testGoogleCancelIsCancellation`, `testOtherDomainIsNotCancellation`,
  `testOtherGoogleErrorIsNotCancellation`
- [x] 1.4 Confirm Apple's cancel and failure handling matches `LoginViewModel.signInWithApple`
  (code reading)
- [x] 1.5 Confirm session validation matches `FirebaseAuthService.endsSession` —
  `testDeletedAccountEndsSession`, `testDisabledAccountEndsSession`,
  `testNetworkErrorKeepsSession`
- [x] 1.6 Confirm sign-out is still exposed only from `SettingsView` (code reading)

## 2. Verify the launch screen and profile load against code

- [x] 2.1 Confirm `UserManager.sessionState` keeps `.loading` until the profile loads —
  `testLaunchIsLoading`, `testSignInWaitsForProfileCreate`, `testFailedLoadKeepsLoading`
- [x] 2.2 Confirm the retry triggers — `testReconnectLoadsProfile`,
  `testForegroundRetriesProfile`
- [x] 2.3 Confirm the first-sign-in create is awaited — `testFirstSignInWritesProfile`
- [x] 2.4 Confirm only the server can say a profile is missing —
  `testServerMissingIsNoProfile`, `testCacheMissingIsOffline`, `testUnavailableIsOffline`
- [x] 2.5 Confirm a late profile is discarded — `testProfileLoadedAfterSignOutIsDropped`
- [x] 2.6 Confirm `LaunchView` and `ProgressBar` match the iOS mockup's Launch screen and the
  design system's `ProgressBar` (off-screen renders at 375 and 430 pt; bar 69 and 79 pt)
- [x] 2.7 Confirm the launch strings ship in zh-TW — `testLaunchKeysAreTranslated`,
  `testEmailLinkErrorKeysAreTranslated`

## 3. Verify the profile spec against code

- [x] 3.1 Confirm a cached profile is read-only — `testCachedProfileIsNotEditable`,
  `testServerProfileIsEditable`, `testCachedProfileSkipsMilestones`,
  `testServerProfileGetsMilestones`, `testCachedIsMarked`
- [x] 3.2 Confirm the server's profile replaces the cached one —
  `testReconnectReplacesCachedProfile`, `testForegroundReplacesCachedProfile`
- [x] 3.3 Confirm a removed photo is deleted only after the save succeeds —
  `testRemovedPhotoIsDeletedAfterSave`, `testRemovedPhotoIsKeptWhenSaveFails`

## 4. Validate

- [x] 4.1 Run the full test suite on the final state (615 passed, 0 failed)
- [x] 4.2 Run `openspec validate mw-32-auth-baseline --strict`
