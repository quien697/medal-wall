//
//  AuthService.swift
//  MedalWall
//
//  Created by Quien on 2026-04-28.
//

import AuthenticationServices
import FirebaseAuth
import Foundation
import GoogleSignIn

final class AuthService {
  static let pendingEmailSignInKey = "pendingEmailSignIn"

  // MARK: - Functions
  func signOut() throws {
    try Auth.auth().signOut()
  }

  /// Reloads the current user from Firebase to verify the account still exists.
  /// Signs out locally if the account was deleted — e.g. removed from the Firebase console.
  func validateSession() async {
    guard let user = Auth.auth().currentUser else { return }

    do {
      try await user.reload()
    } catch let error as NSError {
      if AuthErrorCode(rawValue: error.code) == .userNotFound {
        try? signOut()
      }
    }
  }

  // MARK: - Functions -> Sign in with Email Link
  func sendSignInLink(to email: String) async throws {
    let authorizedDomain: String = "https://medal-wall-4697.firebaseapp.com"
    let actionCodeSettings = ActionCodeSettings()
    actionCodeSettings.url = URL(string: authorizedDomain)
    actionCodeSettings.handleCodeInApp = true
    actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
    try await Auth.auth().sendSignInLink(
      toEmail: email,
      actionCodeSettings: actionCodeSettings
    )
  }

  /// Whether the URL is a Firebase email sign-in link.
  func isSignInLink(_ url: URL) -> Bool {
    Auth.auth().isSignIn(withEmailLink: url.absoluteString)
  }

  @discardableResult
  func signInWithEmailLink(email: String, link: String) async throws -> AuthDataResult {
    try await Auth.auth().signIn(withEmail: email, link: link)
  }

  // MARK: - Functions -> Sign in Apple
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

  @discardableResult
  func signInWithGoogle(idToken: String, accessToken: String) async throws -> AuthDataResult {
    let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

    return try await Auth.auth().signIn(with: credential)
  }
}
