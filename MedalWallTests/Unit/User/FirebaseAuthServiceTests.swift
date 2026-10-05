//
//  FirebaseAuthServiceTests.swift
//  MedalWall
//
//  Created by Quien on 2026-10-03.
//

import Foundation
import Testing

@testable import MedalWall

/// Covers the session decision made in Swift rather than by Firebase Auth: which reload
/// errors end the session on this device.
@MainActor
struct FirebaseAuthServiceTests {

  // Firebase Auth's error codes, written out so a renumbering shows up here.
  private let userNotFound = NSError(domain: "FIRAuthErrorDomain", code: 17011)
  private let userDisabled = NSError(domain: "FIRAuthErrorDomain", code: 17005)
  private let networkError = NSError(domain: "FIRAuthErrorDomain", code: 17020)

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
}
