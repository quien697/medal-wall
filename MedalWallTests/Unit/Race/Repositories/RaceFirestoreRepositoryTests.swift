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

  // MARK: - Deletion chunks
  @Test("a race with no editions still commits one batch for the race itself")
  func testNoEditionsStillCommitsOnce() {
    let chunks = RaceFirestoreRepository.deletionChunks(editionIds: [])

    #expect(chunks.count == 1)
    #expect(chunks[0].isEmpty)
  }

  @Test("editions within the batch limit go in a single commit")
  func testSmallDeleteIsOneBatch() {
    let ids = (0..<25).map { "edition-\($0)" }

    let chunks = RaceFirestoreRepository.deletionChunks(editionIds: ids)

    #expect(chunks.count == 1)
    #expect(chunks[0].count == 25)
  }

  @Test("more editions than one batch holds are split, leaving room for the race delete")
  func testLargeDeleteIsChunked() {
    let limit = RaceFirestoreRepository.batchLimit
    let ids = (0..<(limit + 10)).map { "edition-\($0)" }

    let chunks = RaceFirestoreRepository.deletionChunks(editionIds: ids)

    #expect(chunks.count == 2)
    #expect(chunks.allSatisfy { $0.count <= limit - 1 })
    #expect(chunks.flatMap { $0 } == ids)
  }

  @Test("chunking preserves every edition exactly once")
  func testChunkingLosesNothing() {
    let ids = (0..<1200).map { "edition-\($0)" }

    let chunks = RaceFirestoreRepository.deletionChunks(editionIds: ids)

    #expect(Set(chunks.flatMap { $0 }).count == ids.count)
  }
}
