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
/// by the backend: which fields an update writes, and how a cascade delete is batched.
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

  // MARK: - Edition update fields
  private func makeEdition(photoUrl: String?) -> RaceEdition {
    RaceEdition(
      id: "edition-2025", raceId: "race-taipei", year: 2025, startDate: .now, endDate: .now,
      photoUrl: photoUrl, raceEvents: [RaceEvent(category: .full, type: .inPerson)],
      createdBy: "uid")
  }

  @Test("an edition stores its race events under that name, not the old ones")
  func testRaceEventsFieldName() throws {
    let fields = try RaceFirestoreRepository.updateFields(for: makeEdition(photoUrl: nil))
    let raceEvents = fields["raceEvents"] as? [[String: Any]]

    #expect(raceEvents?.first?["kind"] as? String == "distance")
    // An old name left in `editionUpdateFields` would show up here as a delete.
    #expect(fields["events"] == nil)
    #expect(fields["distances"] == nil)
  }

  @Test("an edition update deletes a photo the edition no longer holds")
  func testClearedEditionPhotoIsDeleted() throws {
    let storedKeys = try RaceFirestoreRepository.updateFields(
      for: makeEdition(photoUrl: "https://example.com/edition.png")
    ).keys
    let fields = try RaceFirestoreRepository.updateFields(for: makeEdition(photoUrl: nil))

    #expect(Set(fields.keys) == Set(storedKeys))
    #expect(fields["photoUrl"] as? String == nil)
  }

  @Test("every stored edition field is covered by the update field list")
  func testEditionUpdateFieldListCoversTheModel() throws {
    let fields = try RaceFirestoreRepository.updateFields(
      for: makeEdition(photoUrl: "https://example.com/edition.png"))

    // Fails when `RaceEdition` gains a field that nobody added to `editionUpdateFields`,
    // which would then never be deleted when cleared.
    #expect(Set(fields.keys).subtracting(RaceFirestoreRepository.editionUpdateFields).isEmpty)
  }
}
