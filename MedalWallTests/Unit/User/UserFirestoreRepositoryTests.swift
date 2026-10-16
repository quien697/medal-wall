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

    #expect(fetched?.user.firstName == "Mei")
    #expect(fetched?.isFromCache == false)
  }

  @Test("a document read from the phone's copy says so")
  func testCachedIsMarked() throws {
    let fetched = try UserFirestoreRepository.profile(
      exists: true, isFromCache: true, decode: { profile })

    #expect(fetched?.isFromCache == true)
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

  // MARK: - Update fields
  private let fullProfile = User(
    uid: "uid", email: "runner@example.com", firstName: "Mei", lastName: "Lin",
    photoUrl: "https://example.com/avatar.jpg", bio: "Sub-4 or bust", gender: .female,
    birthday: Date(timeIntervalSince1970: 631_152_000), updatedAt: .now)

  @Test("a profile update deletes every optional the profile no longer holds")
  func testClearedOptionalsAreDeleted() throws {
    let storedKeys = try UserFirestoreRepository.updateFields(for: fullProfile).keys
    let fields = try UserFirestoreRepository.updateFields(for: User(uid: "uid", email: nil))

    // The encoder omits a nil optional, so each one needs an explicit delete — without it
    // the previously stored value would survive the edit.
    #expect(Set(fields.keys) == Set(storedKeys))
    #expect(fields["bio"] as? String == nil)
  }

  @Test("every stored profile field is covered by the update field list")
  func testUpdateFieldListCoversTheModel() throws {
    let fields = try UserFirestoreRepository.updateFields(for: fullProfile)

    // Fails when `User` gains a field that nobody added to `userUpdateFields`, which would
    // then never be deleted when cleared.
    #expect(Set(fields.keys).subtracting(UserFirestoreRepository.userUpdateFields).isEmpty)
  }
}
