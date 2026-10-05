//
//  StubAuthService.swift
//  MedalWall
//
//  Created by Quien on 2026-10-03.
//

import Foundation

@testable import MedalWall

/// Scriptable `AuthService` so session flows can be tested without Firebase Auth.
///
/// A `@MainActor` class rather than an actor: `observeAuthState` and the URL checks are
/// synchronous, and an actor cannot witness a synchronous requirement.
@MainActor
final class StubAuthService: AuthService {

  // MARK: - Script
  private var onAuthStateChange: (@MainActor ((uid: String, email: String?)?) async -> Void)?

  // MARK: - Script control
  /// Reports a sign-in, or a sign-out when `account` is nil, as Firebase Auth does, and
  /// waits until the observer has handled it.
  func report(_ account: (uid: String, email: String?)?) async {
    await onAuthStateChange?(account)
  }

  // MARK: - AuthService
  func observeAuthState(
    _ onChange: @escaping @MainActor ((uid: String, email: String?)?) async -> Void
  ) {
    onAuthStateChange = onChange
  }

  func validateSession() async {}

  func signOut() throws {}

  func handleGoogleSignInURL(_ url: URL) {}

  func isSignInLink(_ url: URL) -> Bool { false }

  func signInWithEmailLink(email: String, link: String) async throws {}
}
