//
//  AppleSignInDelegate.swift
//  MedalWall
//
//  Created by Quien on 2026-05-05.
//

import AuthenticationServices
import UIKit

final class AppleSignInDelegate: NSObject,
  ASAuthorizationControllerDelegate,
  ASAuthorizationControllerPresentationContextProviding
{
  // MARK: - Properties
  private var continuation: CheckedContinuation<ASAuthorization, Error>?

  // MARK: - Functions

  /// Suspends until Apple's authorization sheet completes, then returns the result.
  func waitForAuthorization() async throws -> ASAuthorization {
    try await withCheckedThrowingContinuation { continuation in
      self.continuation = continuation
    }
  }

  /// Returns the window used to present the Apple Sign-In sheet.
  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    let scene = (scenes.first(where: { $0.activationState == .foregroundActive }) ?? scenes.first)!
    return scene.keyWindow ?? UIWindow(windowScene: scene)
  }

  /// Called when the user successfully completes Apple Sign-In; resumes the continuation with the authorization.
  func authorizationController(
    controller: ASAuthorizationController,
    didCompleteWithAuthorization authorization: ASAuthorization
  ) {
    continuation?.resume(returning: authorization)
    continuation = nil
  }

  /// Called when Apple Sign-In fails or is canceled; resumes the continuation by throwing the error.
  func authorizationController(
    controller: ASAuthorizationController,
    didCompleteWithError error: Error
  ) {
    continuation?.resume(throwing: error)
    continuation = nil
  }
}
