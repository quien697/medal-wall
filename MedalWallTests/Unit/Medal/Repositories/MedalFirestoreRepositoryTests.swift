//
//  MedalFirestoreRepositoryTests.swift
//  MedalWall
//
//  Created by Quien on 2026-10-08.
//

import Foundation
import Testing

@testable import MedalWall

/// Covers the part of the Firestore medal repository that is decided in Swift rather than by
/// the backend: which fields an update writes.
@MainActor
struct MedalFirestoreRepositoryTests {

  private func makeMedal(isFull: Bool) -> Medal {
    Medal(
      name: "Taipei Marathon",
      date: .now,
      bibNumber: "1024",
      photoUrl: isFull ? "https://example.com/medal.jpg" : nil,
      place: Place(countryCode: "TW", city: "Taipei City"),
      raceEvent: RaceEvent(category: .full, type: .inPerson),
      result: isFull ? .seconds(12_600) : nil,
      overallPlacement: isFull ? 120 : nil,
      totalParticipants: isFull ? 2_000 : nil,
      division: isFull ? Division(gender: .male, ageGroup: .from30to34) : nil,
      divisionPlacement: isFull ? 12 : nil,
      divisionTotal: isFull ? 300 : nil,
      genderPlacement: isFull ? 100 : nil,
      genderTotal: isFull ? 1_200 : nil,
      note: isFull ? "Negative split" : nil,
      tags: ["taipei"],
      eventPhotos: [EventPhoto(imageUrl: "https://example.com/event.jpg")],
      userID: "uid"
    )
  }

  // MARK: - Update fields
  @Test("a medal update deletes every optional the medal no longer holds")
  func testClearedOptionalsAreDeleted() throws {
    let storedKeys = try MedalFirestoreRepository.updateFields(for: makeMedal(isFull: true)).keys
    let fields = try MedalFirestoreRepository.updateFields(for: makeMedal(isFull: false))

    // The encoder omits a nil optional, so each one needs an explicit delete — without it
    // the previously stored value would survive the edit.
    #expect(Set(fields.keys) == Set(storedKeys))
    #expect(fields["result"] as? [String: Any] == nil)
  }

  @Test("a medal stores its race event and result under those names, not the old ones")
  func testRaceEventAndResultFieldNames() throws {
    let fields = try MedalFirestoreRepository.updateFields(for: makeMedal(isFull: true))
    let raceEvent = fields["raceEvent"] as? [String: Any]
    let result = fields["result"] as? [String: Any]

    #expect(raceEvent?["unit"] as? String == "kilometers")
    #expect(result?["value"] as? Double == 12_600)
    #expect(result?["unit"] as? String == "seconds")
    // An old name left in `medalUpdateFields` would show up here as a delete.
    #expect(fields["event"] == nil)
    #expect(fields["distance"] == nil)
    #expect(fields["finishTime"] == nil)
  }

  @Test("every stored medal field is covered by the update field list")
  func testUpdateFieldListCoversTheModel() throws {
    let fields = try MedalFirestoreRepository.updateFields(for: makeMedal(isFull: true))

    // Fails when `Medal` gains a field that nobody added to `medalUpdateFields`, which would
    // then never be deleted when cleared.
    #expect(Set(fields.keys).subtracting(MedalFirestoreRepository.medalUpdateFields).isEmpty)
  }
}
