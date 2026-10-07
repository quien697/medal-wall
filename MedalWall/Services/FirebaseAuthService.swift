//
//  FirebaseAuthService.swift
//  MedalWall
//
//  Created by Quien on 2026-04-28.
//

import AuthenticationServices
import FirebaseAuth
import FirebaseCore
import Foundation
import GoogleSignIn
import UIKit

/// The session `UserManager` follows, behind a protocol so it can be tested against a stub.
///
/// `UserManager` takes this as `(any AuthService)? = nil` and resolves it with
/// `?? FirebaseAuthService()` inside `init`, for the same reason the repositories do.
protocol AuthService {
  /// Calls `onChange` with the signed-in account now and on every sign-in or sign-out;
  /// nil means signed out.
  func observeAuthState(
    _ onChange: @escaping @MainActor ((uid: String, email: String?)?) async -> Void)

  /// Signs out if the server no longer accepts the signed-in account.
  func validateSession() async

  /// Ends the session on this device.
  func signOut() throws

  /// Hands a URL the app was opened with to Google Sign-In.
  func handleGoogleSignInURL(_ url: URL)

  /// Whether the URL is a Firebase email sign-in link.
  func isSignInLink(_ url: URL) -> Bool

  /// Signs in with an email sign-in link sent to `email`.
  func signInWithEmailLink(email: String, link: String) async throws

  /// Emails a sign-in link to `email` that opens back into the app.
  func sendSignInLink(to email: String) async throws
}

final class FirebaseAuthService: AuthService {
  static let pendingEmailSignInKey = "pendingEmailSignIn"

  // MARK: - Functions
  /// Registers a Firebase Auth state listener that reports the account to `onChange`.
  func observeAuthState(
    _ onChange: @escaping @MainActor ((uid: String, email: String?)?) async -> Void
  ) {
    _ = Auth.auth().addStateDidChangeListener { _, user in
      let account = user.map { (uid: $0.uid, email: $0.email) }
      Task {
        await onChange(account)
      }
    }
  }

  /// Ends the Firebase Auth session on this device. Needs no connection.
  func signOut() throws {
    try Auth.auth().signOut()
  }

  /// Reloads the current user from Firebase to verify the account can still be used.
  /// Signs out locally if the account was deleted or disabled — e.g. in the Firebase console.
  func validateSession() async {
    guard let user = Auth.auth().currentUser else { return }

    do {
      try await user.reload()
    } catch let error as NSError {
      if Self.endsSession(error) {
        try? signOut()
      }
    }
  }

  /// Whether a failed reload means the account can no longer be used on this device.
  static func endsSession(_ error: NSError) -> Bool {
    let code = AuthErrorCode(rawValue: error.code)
    return code == .userNotFound || code == .userDisabled
  }

  // MARK: - Functions -> Sign in with Email Link
  /// Emails a sign-in link to `email` that opens back into the app.
  func sendSignInLink(to email: String) async throws {
    guard let bundleID = Bundle.main.bundleIdentifier else { throw AppError.unknown }

    let authorizedDomain: String = "https://medal-wall-4697.firebaseapp.com"
    let actionCodeSettings = ActionCodeSettings()
    actionCodeSettings.url = URL(string: authorizedDomain)
    actionCodeSettings.handleCodeInApp = true
    actionCodeSettings.setIOSBundleID(bundleID)
    try await Auth.auth().sendSignInLink(
      toEmail: email,
      actionCodeSettings: actionCodeSettings
    )
  }

  /// Whether the URL is a Firebase email sign-in link.
  func isSignInLink(_ url: URL) -> Bool {
    Auth.auth().isSignIn(withEmailLink: url.absoluteString)
  }

  /// Signs in with an email sign-in link sent to `email`.
  func signInWithEmailLink(email: String, link: String) async throws {
    _ = try await Auth.auth().signIn(withEmail: email, link: link)
  }

  // MARK: - Functions -> Sign in Apple
  /// Signs in to Firebase with the identity token and nonce from Sign in with Apple.
  @discardableResult
  func signInWithApple(
    idTokenString: String,
    rawNonce: String,
    fullName: PersonNameComponents?
  ) async throws -> AuthDataResult {
    let credential = OAuthProvider.appleCredential(
      withIDToken: idTokenString,
      rawNonce: rawNonce,
      fullName: fullName
    )

    return try await Auth.auth().signIn(with: credential)
  }

  // MARK: - Functions -> Sign in with google
  /// Hands a URL the app was opened with to Google Sign-In, which finishes its flow from it.
  func handleGoogleSignInURL(_ url: URL) {
    GIDSignIn.sharedInstance.handle(url)
  }

  /// Presents Google's sign-in sheet and returns the tokens Firebase signs in with.
  ///
  /// Throws `CancellationError` when the user closes the sheet, so callers can tell a
  /// cancel from a failure without importing GoogleSignIn.
  func requestGoogleTokens(
    presenting viewController: UIViewController
  ) async throws -> (idToken: String, accessToken: String) {
    guard let clientID = FirebaseApp.app()?.options.clientID else {
      throw AppError.signInFailed
    }

    GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

    let result: GIDSignInResult
    do {
      result = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)
    } catch  where Self.isGoogleCancellation(error) {
      throw CancellationError()
    }

    guard let idToken = result.user.idToken?.tokenString else {
      throw AppError.missingIdentityToken
    }

    return (idToken, result.user.accessToken.tokenString)
  }

  /// Whether an error is Google Sign-In reporting that the user closed its sheet. Casting to
  /// `GIDSignInError` checks Google's error domain, so another error that happens to share
  /// the code is not mistaken for a cancel.
  static func isGoogleCancellation(_ error: Error) -> Bool {
    (error as? GIDSignInError)?.code == .canceled
  }

  /// Signs in to Firebase with the tokens from Google Sign-In.
  @discardableResult
  func signInWithGoogle(idToken: String, accessToken: String) async throws -> AuthDataResult {
    let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

    return try await Auth.auth().signIn(with: credential)
  }
}
