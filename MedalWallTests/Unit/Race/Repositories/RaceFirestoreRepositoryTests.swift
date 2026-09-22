//
//  RaceFirestoreRepositoryTests.swift
//  MedalWall
//
//  Created by Quien on 2026-09-22.
//

import Foundation
import Testing

@testable import MedalWall

/// Covers the parts of the Firestore race repository that are decided in Swift rather than
/// by the backend: which fields an update writes.
@MainActor
struct RaceFirestoreRepositoryTests {

  private func makeRace(
    photoUrl: String? = "https://example.com/logo.png",
    websiteUrl: String? = "taipeicitymarathon.com",
    editionCount: Int = 7
  ) -> Race {
    Race(
      id: "race-taipei",
      name: "Taipei Marathon",
      photoUrl: photoUrl,
      place: Place(countryCode: "TW", city: "Taipei City"),
      websiteUrl: websiteUrl,
      editionCount: editionCount,
      createdBy: "uid"
    )
  }

  // MARK: - Update fields
  @Test("a race update never writes editionCount")
  func testUpdateOmitsEditionCount() throws {
    let fields = try RaceFirestoreRepository.updateFields(for: makeRace())

    #expect(fields["editionCount"] == nil)
    #expect(fields["name"] as? String == "Taipei Marathon")
  }

  @Test("a cleared photo and website are deleted rather than left behind")
  func testClearedOptionalsAreDeleted() throws {
    let fields = try RaceFirestoreRepository.updateFields(
      for: makeRace(photoUrl: nil, websiteUrl: nil))

    // The encoder omits a nil optional, so the update carries an explicit delete instead —
    // without it the previously stored URL would survive the edit.
    #expect(fields["photoUrl"] != nil)
    #expect(fields["photoUrl"] as? String == nil)
    #expect(fields["websiteUrl"] != nil)
    #expect(fields["websiteUrl"] as? String == nil)
  }

  @Test("every stored race field is covered by the update field list")
  func testUpdateFieldListCoversTheModel() throws {
    let fields = try RaceFirestoreRepository.updateFields(for: makeRace())
    let covered = Set(RaceFirestoreRepository.raceUpdateFields + ["editionCount"])

    // Fails when `Race` gains a field that nobody added to `raceUpdateFields`, which would
    // otherwise quietly stop being saved on update.
    #expect(Set(fields.keys).subtracting(covered).isEmpty)
  }
}
