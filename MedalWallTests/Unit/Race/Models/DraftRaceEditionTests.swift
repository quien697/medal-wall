//
//  DraftRaceEditionTests.swift
//  MedalWall
//
//  Created by Quien on 2026-05-28.
//

import Foundation
import Testing
import UIKit

@testable import MedalWall

struct DraftRaceEditionTests {
  private let raceId = "race-1"
  private let createdBy = "user-1"

  private func makeEdition(
    isOneDay: Bool = true,
    startDate: Date = Date(timeIntervalSinceReferenceDate: 0),
    endDate: Date = Date(timeIntervalSinceReferenceDate: 0),
    photoUrl: String? = nil
  ) -> RaceEdition {
    RaceEdition(
      raceId: raceId,
      year: 2025,
      startDate: startDate,
      endDate: endDate,
      photoUrl: photoUrl,
      createdBy: createdBy
    )
  }

  // MARK: - init(from edition:)
  @Test("init(from:) copies all fields from the source edition")
  func testInitFromEditionCopiesFields() {
    let edition = makeEdition(isOneDay: false)
    let draft = DraftRaceEdition(from: edition)

    #expect(draft.id == edition.id)
    #expect(draft.sourceEditionId == edition.id)
    #expect(draft.year == edition.year)
    #expect(draft.isOneDay == edition.isOneDay)
    #expect(draft.startDate == edition.startDate)
    #expect(draft.endDate == edition.endDate)
    #expect(draft.createdBy == edition.createdBy)
  }

  @Test("init(from:) copies distances from the source edition")
  func testInitFromEditionCopiesDistances() {
    var edition = makeEdition()
    edition.distances = [
      RaceDistance(category: .full, type: .inPerson),
      RaceDistance(category: .half, type: .virtual)
    ]
    let draft = DraftRaceEdition(from: edition)

    #expect(draft.distances == edition.distances)
  }

  @Test("init(from:) sets existingPhotoUrl to nil when source edition has no photo")
  func testInitFromEditionNilPhotoUrl() {
    let draft = DraftRaceEdition(from: makeEdition(photoUrl: nil))

    #expect(draft.existingPhotoUrl == nil)
  }

  @Test("init(from:) starts clean with no pending photo changes")
  func testInitFromEditionStartsClean() {
    let draft = DraftRaceEdition(from: makeEdition())

    #expect(draft.newPhotoData == nil)
    #expect(draft.isPhotoCleared == false)
    #expect(draft.isModified == false)
  }

  @Test("init(from:) carries forward the existing photo URL")
  func testInitFromEditionCarriesPhotoUrl() {
    let draft = DraftRaceEdition(from: makeEdition(photoUrl: "https://example.com/photo.jpg"))

    #expect(draft.existingPhotoUrl == "https://example.com/photo.jpg")
  }

  // MARK: - init(year:isOneDay:startDate:endDate:distances:createdBy:)
  @Test("new draft has no Firestore backing (sourceEditionId is nil)")
  func testNewDraftHasNoSource() {
    let draft = DraftRaceEdition(
      year: 2025, isOneDay: true,
      startDate: Date(), endDate: Date(),
      distances: [], createdBy: createdBy
    )

    #expect(draft.sourceEditionId == nil)
  }

  @Test("new draft starts clean with no pending photo changes")
  func testNewDraftStartsClean() {
    let draft = DraftRaceEdition(
      year: 2025, isOneDay: true,
      startDate: Date(), endDate: Date(),
      distances: [], createdBy: createdBy
    )

    #expect(draft.newPhotoData == nil)
    #expect(draft.isPhotoCleared == false)
    #expect(draft.isModified == false)
  }

  // MARK: - displayPhotoUrl
  @Test("displayPhotoUrl returns existingPhotoUrl when no new photo and not cleared")
  func testDisplayPhotoUrlReturnsExisting() {
    let draft = DraftRaceEdition(from: makeEdition(photoUrl: "https://example.com/photo.jpg"))

    #expect(draft.displayPhotoUrl == "https://example.com/photo.jpg")
  }

  @Test("displayPhotoUrl is nil when new photo data is pending")
  func testDisplayPhotoUrlNilWhenNewPhotoSet() {
    var draft = DraftRaceEdition(from: makeEdition(photoUrl: "https://example.com/photo.jpg"))
    draft.newPhotoData = Data()

    #expect(draft.displayPhotoUrl == nil)
  }

  @Test("displayPhotoUrl is nil when photo has been cleared")
  func testDisplayPhotoUrlNilWhenCleared() {
    var draft = DraftRaceEdition(from: makeEdition(photoUrl: "https://example.com/photo.jpg"))
    draft.isPhotoCleared = true

    #expect(draft.displayPhotoUrl == nil)
  }

  @Test("displayPhotoUrl is nil when no existing photo and nothing new")
  func testDisplayPhotoUrlNilWhenNoPhoto() {
    let draft = DraftRaceEdition(from: makeEdition(photoUrl: nil))

    #expect(draft.displayPhotoUrl == nil)
  }

  // MARK: - displayPhoto
  @Test("displayPhoto is nil when newPhotoData is nil")
  func testDisplayPhotoNilWhenNoData() {
    let draft = DraftRaceEdition(from: makeEdition())

    #expect(draft.displayPhoto == nil)
  }

  @Test("displayPhoto is nil when newPhotoData is not valid image data")
  func testDisplayPhotoNilForInvalidData() {
    var draft = DraftRaceEdition(from: makeEdition())
    draft.newPhotoData = Data([0x00, 0x01, 0x02])

    #expect(draft.displayPhoto == nil)
  }

  @Test("displayPhoto returns a UIImage when newPhotoData contains valid JPEG data")
  func testDisplayPhotoWithValidData() {
    var draft = DraftRaceEdition(from: makeEdition())
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1))
    draft.newPhotoData = renderer.jpegData(withCompressionQuality: 1.0) { _ in }

    #expect(draft.displayPhoto != nil)
  }

  // MARK: - dateDisplayLabel
  @Test("dateDisplayLabel shows only start date for a one-day draft")
  func testDateDisplayLabelOneDay() {
    let day = Calendar.current.startOfDay(for: Date(timeIntervalSinceReferenceDate: 0))
    let draft = DraftRaceEdition(
      year: 2025, isOneDay: true,
      startDate: day, endDate: day,
      distances: [], createdBy: createdBy
    )

    let expected = day.formattedMonthDay()
    #expect(draft.dateDisplayLabel == expected)
  }

  @Test("dateDisplayLabel shows both dates for a multi-day draft")
  func testDateDisplayLabelMultiDay() {
    let start = Calendar.current.startOfDay(for: Date(timeIntervalSinceReferenceDate: 0))
    let end = Calendar.current.startOfDay(for: start.addingTimeInterval(86400))
    let draft = DraftRaceEdition(
      year: 2025, isOneDay: false,
      startDate: start, endDate: end,
      distances: [], createdBy: createdBy
    )

    let expected = "\(start.formattedMonthDay()), \(end.formattedMonthDay())"
    #expect(draft.dateDisplayLabel == expected)
  }

  @Test("dateDisplayLabel shows only start when isOneDay is true even if dates differ")
  func testDateDisplayLabelOneDayFlagOverridesDates() {
    let start = Calendar.current.startOfDay(for: Date(timeIntervalSinceReferenceDate: 0))
    let end = Calendar.current.startOfDay(for: start.addingTimeInterval(86400))
    let draft = DraftRaceEdition(
      year: 2025, isOneDay: true,
      startDate: start, endDate: end,
      distances: [], createdBy: createdBy
    )

    #expect(draft.dateDisplayLabel == start.formattedMonthDay())
  }

  @Test("dateDisplayLabel shows the same date twice when isOneDay is false but dates are equal")
  func testDateDisplayLabelMultiDayWithSameDates() {
    let day = Calendar.current.startOfDay(for: Date(timeIntervalSinceReferenceDate: 0))
    let draft = DraftRaceEdition(
      year: 2025, isOneDay: false,
      startDate: day, endDate: day,
      distances: [], createdBy: createdBy
    )

    let formatted = day.formattedMonthDay()
    #expect(draft.dateDisplayLabel == "\(formatted), \(formatted)")
  }
}
