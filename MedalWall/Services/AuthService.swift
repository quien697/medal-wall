//
//  AuthService.swift
//  MedalWall
//
//  Created by Quien on 2026-04-28.
//

import Foundation
import FirebaseAuth
import AuthenticationServices

final class AuthService {
  
  func signIn(email: String, password: String) async throws -> AuthDataResult {
    try await Auth.auth().signIn(withEmail: email, password: password)
  }
  
  func signUp(email: String, password: String) async throws -> AuthDataResult {
    try await Auth.auth().createUser(withEmail: email, password: password)
  }
  
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
  
  /// Emits the current Firebase user whenever auth state changes (sign in, sign out, token refresh).
  /// Yields `nil` when no user is signed in.
  //  var authStateStream: AsyncStream<FirebaseAuth.User?> {
  //    AsyncStream { continuation in
  //      let handle = Auth.auth().addStateDidChangeListener { _, user in
  //        continuation.yield(user)
  //      }
  //      continuation.onTermination = { _ in
  //        Auth.auth().removeStateDidChangeListener(handle)
  //      }
  //    }
  //  }
}
