//
//  AuthService.swift
//  MedalWall
//
//  Created by Quien on 2026-04-28.
//

import Foundation
import AuthenticationServices
import FirebaseAuth
import GoogleSignIn

final class AuthService {
  static let pendingEmailSignInKey = "pendingEmailSignIn"

  // MARK: - Common
  
  func signOut() throws {
    try Auth.auth().signOut()
  }
  
  /// Updates the current Firebase user's `displayName` from Apple's `PersonNameComponents`.
  /// Only writes if `displayName` is not already set — Apple provides `fullName` on the first sign-in only.
  func updateDisplayName(with fullName: PersonNameComponents?) async {
    guard let user = Auth.auth().currentUser else { return }
    guard user.displayName == nil || user.displayName?.isEmpty == true else { return }
    guard let fullName else { return }
    
    let displayName = PersonNameComponentsFormatter().string(from: fullName)
      .trimmingCharacters(in: .whitespaces)
    guard !displayName.isEmpty else { return }
    
    let changeRequest = user.createProfileChangeRequest()
    changeRequest.displayName = displayName
    changeRequest.commitChanges { _ in }
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
  
  // MARK: - Sign in with Email Link
  
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
  
  @discardableResult
  func signInWithEmailLink(email: String, link: String) async throws -> AuthDataResult {
    try await Auth.auth().signIn(withEmail: email, link: link)
  }
  
  // MARK: - Sign in Apple
  
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
    let result = try await Auth.auth().signIn(with: credential)
    await updateDisplayName(with: fullName)
    return result
  }
  
  // MARK: - Sign in with google
  
  @discardableResult
  func signInWithGoogle(idToken: String, accessToken: String) async throws -> AuthDataResult {
    let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
    return try await Auth.auth().signIn(with: credential)
  }
}
