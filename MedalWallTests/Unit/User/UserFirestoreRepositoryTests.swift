//
//  UserFirestoreRepositoryTests.swift
//  MedalWall
//
//  Created by Quien on 2026-10-03.
//

import Foundation
import Testing

@testable import MedalWall

/// Covers the parts of the Firestore user repository that are decided in Swift rather than
/// by the backend: what a fetched snapshot means, and which errors mean "offline".
@MainActor
struct UserFirestoreRepositoryTests {

  private let profile = User(uid: "uid", email: "runner@example.com", firstName: "Mei")

  // MARK: - Snapshot
  @Test("a document the server confirms is missing means there is no profile yet")
  func testServerMissingIsNoProfile() throws {
    let fetched = try UserFirestoreRepository.profile(
      exists: false, isFromCache: false, decode: { profile })

    #expect(fetched == nil)
  }

  @Test("a document missing from the phone's copy reads as offline, not as no profile")
  func testCacheMissingIsOffline() {
    #expect(throws: AppError.noInternetConnection) {
      try UserFirestoreRepository.profile(exists: false, isFromCache: true, decode: { profile })
    }
  }

  @Test("an existing document is decoded")
  func testExistingIsDecoded() throws {
    let fetched = try UserFirestoreRepository.profile(
      exists: true, isFromCache: false, decode: { profile })

    #expect(fetched?.firstName == "Mei")
  }

  // MARK: - Errors
  @Test("Firestore's unavailable error means the device is offline")
  func testUnavailableIsOffline() {
    let unavailable = NSError(domain: "FIRFirestoreErrorDomain", code: 14)

    #expect(
      UserFirestoreRepository.fetchError(for: unavailable) as? AppError == .noInternetConnection)
  }

  @Test("other Firestore errors pass through unchanged")
  func testOtherErrorsPassThrough() {
    let permissionDenied = NSError(domain: "FIRFirestoreErrorDomain", code: 7)

    #expect(UserFirestoreRepository.fetchError(for: permissionDenied) as? AppError == nil)
  }
}
