//
//  FirebaseAuthServiceTests.swift
//  MedalWall
//
//  Created by Quien on 2026-10-03.
//

import Foundation
import Testing

@testable import MedalWall

/// Covers the decisions made in Swift rather than by Firebase Auth or Google Sign-In: which
/// reload errors end the session on this device, and which errors mean the user cancelled.
@MainActor
struct FirebaseAuthServiceTests {

  // Firebase Auth's error codes, written out so a renumbering shows up here.
  private let userNotFound = NSError(domain: "FIRAuthErrorDomain", code: 17011)
  private let userDisabled = NSError(domain: "FIRAuthErrorDomain", code: 17005)
  private let networkError = NSError(domain: "FIRAuthErrorDomain", code: 17020)

  // MARK: - Session
  @Test("a deleted account ends the session")
  func testDeletedAccountEndsSession() {
    #expect(FirebaseAuthService.endsSession(userNotFound))
  }

  @Test("a disabled account ends the session")
  func testDisabledAccountEndsSession() {
    #expect(FirebaseAuthService.endsSession(userDisabled))
  }

  @Test("being offline keeps the session")
  func testNetworkErrorKeepsSession() {
    #expect(!FirebaseAuthService.endsSession(networkError))
  }

  // MARK: - Google cancel
  @Test("Google's cancel code in Google's domain is a cancel")
  func testGoogleCancelIsCancellation() {
    let canceled = NSError(domain: "com.google.GIDSignIn", code: -5)

    #expect(FirebaseAuthService.isGoogleCancellation(canceled))
  }

  @Test("the same code from another domain is a failure, not a cancel")
  func testOtherDomainIsNotCancellation() {
    let otherError = NSError(domain: NSURLErrorDomain, code: -5)

    #expect(!FirebaseAuthService.isGoogleCancellation(otherError))
  }

  @Test("another Google error is a failure, not a cancel")
  func testOtherGoogleErrorIsNotCancellation() {
    let unknown = NSError(domain: "com.google.GIDSignIn", code: -1)

    #expect(!FirebaseAuthService.isGoogleCancellation(unknown))
  }
}
