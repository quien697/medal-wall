//
//  UserManager.swift
//  MedalWall
//
//  Created by Quien on 2026-03-07.
//

import SwiftUI

@Observable
class UserManager {
  // MARK: - Properties
  private let repository: any UserRepository
  private let authService: any AuthService
  private let networkMonitor: any NetworkMonitor
  private let storageService: any PhotoStorage
  private let defaults: UserDefaults
  private var currentUserEmail: String?
  /// Why the profile could not load; nil while it is loading or once it has.
  private var profileLoadError: AppError?
  /// Whether `currentUser` was read from the phone's copy rather than the server. Such a
  /// profile may be older than the server's, so it is shown but never written.
  private var isProfileFromCache = false
  /// An email sign-in link that opened the app before the session was known, kept until it is.
  private var pendingSignInLink: String?
  private(set) var currentUserID: String?
  private(set) var currentUser: User?
  private(set) var isLoadingAuth = true
  /// A sign-in that failed outside the login screen's own buttons — an email sign-in link
  /// opened from Mail. The login screen shows it and resets it to nil.
  var signInError: AppError?

  // MARK: - Computed
  /// Whether the profile may be edited: only once it has come from the server.
  var canEditProfile: Bool { currentUser != nil && !isProfileFromCache }

  /// Which root screen the app shows. A signed-in user reaches the app as soon as the session
  /// is known; their profile loads inside it.
  var sessionState: SessionState {
    if isLoadingAuth { return .loading }
    return currentUserID == nil ? .signedOut : .ready
  }

  // MARK: - Init
  init(
    repository: (any UserRepository)? = nil,
    authService: (any AuthService)? = nil,
    networkMonitor: (any NetworkMonitor)? = nil,
    storageService: (any PhotoStorage)? = nil,
    defaults: UserDefaults = .standard
  ) {
    self.defaults = defaults
    self.repository = repository ?? UserFirestoreRepository()
    self.authService = authService ?? FirebaseAuthService()
    self.networkMonitor = networkMonitor ?? NWPathNetworkMonitor()
    self.storageService = storageService ?? StorageService()
    self.authService.observeAuthState { [weak self] account in
      await self?.authStateDidChange(account)
    }
    self.networkMonitor.observe { [weak self] isConnected in
      await self?.connectivityDidChange(isConnected)
    }
  }

  // MARK: - Functions
  /// Validates the current Firebase session, signing out if the token is invalid, and
  /// loads the profile again if it couldn't load or came from the phone's copy.
  func validateSession() async {
    await authService.validateSession()
    await reloadProfileIfNeeded()
  }

  /// Completes a sign-in from a URL the app was opened with — a Google Sign-In redirect or
  /// a Firebase email sign-in link. An email link opened while someone is signed in is ignored,
  /// so an old link can neither switch accounts nor leave an error for the next login screen.
  /// A link that arrives before the session is known waits until it is.
  func handleOpenURL(_ url: URL) async {
    authService.handleGoogleSignInURL(url)
    guard currentUserID == nil, authService.isSignInLink(url) else { return }
    guard !isLoadingAuth else {
      pendingSignInLink = url.absoluteString
      return
    }

    await handleEmailLink(url.absoluteString)
  }

  /// Signs the current user out of Firebase.
  func signOut() throws {
    try authService.signOut()
  }

  /// Persists an updated profile to Firestore, uploading a new photo to Storage first if provided.
  /// A cleared photo is deleted only once the save succeeds, so a failed save never leaves the
  /// profile pointing at a deleted file.
  func updateUser(_ user: User, photo: UIImage? = nil) async throws {
    var updatedUser = user
    let clearsPhoto = photo == nil && user.photoUrl == nil && currentUser?.photoUrl != nil
    if let photo {
      updatedUser.photoUrl = try await storageService.uploadUserAvatar(uid: user.uid, image: photo)
    }
    try await repository.updateUser(updatedUser)
    self.currentUser = updatedUser
    if clearsPhoto {
      try? await storageService.deleteUserAvatar(uid: user.uid)
    }
  }

  // MARK: - Private Functions
  /// Completes an email link sign-in using the URL opened by the user, reporting a failure
  /// in `signInError`. The saved email is kept after a failure so the link can be tried again.
  private func handleEmailLink(_ link: String) async {
    guard let email = defaults.string(forKey: FirebaseAuthService.pendingEmailSignInKey) else {
      signInError = .emailLinkFromAnotherDevice
      return
    }
    do {
      try await authService.signInWithEmailLink(email: email, link: link)
      defaults.removeObject(forKey: FirebaseAuthService.pendingEmailSignInKey)
    } catch {
      signInError = .emailLinkSignInFailed
    }
  }

  /// Follows a sign-in or sign-out reported by `authService`, then loads the new account's
  /// profile. A sign-in, by any method, drops any link error still waiting for the login
  /// screen and forgets the email a link was sent to, so an unused link can't sign in after a
  /// later sign-out. A link held from launch is used only when nobody is signed in.
  private func authStateDidChange(_ account: (uid: String, email: String?)?) async {
    if account != nil {
      signInError = nil
      defaults.removeObject(forKey: FirebaseAuthService.pendingEmailSignInKey)
    }
    currentUserID = account?.uid
    currentUserEmail = account?.email
    currentUser = nil
    profileLoadError = nil
    isProfileFromCache = false
    isLoadingAuth = false
    let heldLink = pendingSignInLink
    pendingSignInLink = nil
    guard account != nil else {
      if let heldLink { await handleEmailLink(heldLink) }
      return
    }

    await loadProfile()
  }

  /// Loads the signed-in user's profile, creating it on first sign-in. When it can't load,
  /// no profile stands in for it: `currentUser` stays nil and `profileLoadError` says why.
  /// A result that arrives after the account has changed is dropped.
  private func loadProfile() async {
    guard let uid = currentUserID else { return }
    let email = currentUserEmail

    profileLoadError = nil
    do {
      let profile: User
      let isFromCache: Bool
      if let fetched = try await repository.fetchUser(uid: uid) {
        profile = fetched.user
        isFromCache = fetched.isFromCache
      } else {
        profile = User(uid: uid, email: email)
        try await repository.createUser(profile)
        isFromCache = false
      }
      guard currentUserID == uid else { return }
      currentUser = profile
      isProfileFromCache = isFromCache
    } catch {
      guard currentUserID == uid else { return }
      profileLoadError = error as? AppError ?? .unknown
    }
  }

  /// Once the device is back online, loads the profile again if it couldn't load or came
  /// from the phone's copy.
  private func connectivityDidChange(_ isConnected: Bool) async {
    guard isConnected else { return }

    await reloadProfileIfNeeded()
  }

  /// Loads the profile again if the last attempt failed, or replaces the phone's copy with
  /// the server's.
  private func reloadProfileIfNeeded() async {
    let didFail = currentUser == nil && profileLoadError != nil
    guard didFail || isProfileFromCache else { return }

    await loadProfile()
  }
}

// MARK: - SessionState
extension UserManager {
  /// The root screens the app moves between as the session loads.
  enum SessionState {
    /// Working out who is signed in.
    case loading
    case signedOut
    case ready
  }
}
