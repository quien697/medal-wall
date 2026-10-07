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
  /// Whether every URL counts as an email sign-in link.
  private let treatsURLsAsSignInLinks: Bool
  /// What signing in with an email link does: succeed, or throw the error.
  private let emailLinkOutcome: Result<Void, AppError>
  /// What sending a sign-in link does: succeed, or throw the error.
  private let sendLinkOutcome: Result<Void, AppError>

  // MARK: - Recorded calls
  private(set) var emailLinkSignInEmails: [String] = []
  private(set) var sentLinkEmails: [String] = []
  private(set) var signOutCount = 0

  // MARK: - Init
  init(
    treatsURLsAsSignInLinks: Bool = false,
    emailLinkOutcome: Result<Void, AppError> = .success(()),
    sendLinkOutcome: Result<Void, AppError> = .success(())
  ) {
    self.treatsURLsAsSignInLinks = treatsURLsAsSignInLinks
    self.emailLinkOutcome = emailLinkOutcome
    self.sendLinkOutcome = sendLinkOutcome
  }

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

  func signOut() throws {
    signOutCount += 1
  }

  func handleGoogleSignInURL(_ url: URL) {}

  func isSignInLink(_ url: URL) -> Bool { treatsURLsAsSignInLinks }

  func signInWithEmailLink(email: String, link: String) async throws {
    await recordEmailLinkSignIn(email)
    try emailLinkOutcome.get()
  }

  func sendSignInLink(to email: String) async throws {
    await recordSentLink(email)
    try sendLinkOutcome.get()
  }

  // MARK: - Recording
  /// Records an email-link sign-in on the main actor: the async requirement's witness runs
  /// nonisolated, so it cannot append to the stub's state directly.
  private func recordEmailLinkSignIn(_ email: String) {
    emailLinkSignInEmails.append(email)
  }

  /// Records a sent link on the main actor, for the same reason as `recordEmailLinkSignIn`.
  private func recordSentLink(_ email: String) {
    sentLinkEmails.append(email)
  }
}
