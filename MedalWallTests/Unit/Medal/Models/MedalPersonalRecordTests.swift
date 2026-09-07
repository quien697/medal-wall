//
//  MedalPersonalRecordTests.swift
//  MedalWall
//
//  Created by Quien on 2026-09-07.
//

import Foundation
import Testing

@testable import MedalWall

struct MedalPersonalRecordTests {

  private func makeDate(_ year: Int, _ month: Int, _ day: Int) -> Date {
    var components = DateComponents()
    components.year = year
    components.month = month
    components.day = day
    components.hour = 12
    return Calendar.current.date(from: components) ?? .now
  }

  private func makeMedal(
    id: String = UUID().uuidString,
    category: RaceDistanceCategory = .full,
    finishTime: TimeInterval? = nil,
    date: Date = .now
  ) -> Medal {
    Medal(
      id: id,
      name: "Test",
      date: date,
      bibNumber: "1",
      place: Place(countryCode: "CA", city: "Vancouver"),
      distance: RaceDistance(category: category, type: .inPerson),
      finishTime: finishTime,
      userID: "user1"
    )
  }

  // MARK: - Fastest wins
  @Test("personalRecords is empty for an empty collection")
  func testRecordsEmptyCollection() {
    let medals: [Medal] = []

    #expect(medals.personalRecords.isEmpty)
  }

  @Test("The fastest time in a category holds the record")
  func testFastestTimeHoldsRecord() {
    let medals = [
      makeMedal(id: "slower", category: .half, finishTime: 6760),
      makeMedal(id: "faster", category: .half, finishTime: 6532)
    ]

    #expect(medals.personalRecords[.half]?.id == "faster")
  }

  @Test("A single timed medal holds the record for its category")
  func testSingleMedalHoldsRecord() {
    let medals = [makeMedal(id: "only", category: .full, finishTime: 12624)]

    #expect(medals.personalRecords[.full]?.id == "only")
  }

  @Test("Each category holds its own record independently")
  func testEachCategoryHoldsOwnRecord() {
    let medals = [
      makeMedal(id: "fastFull", category: .full, finishTime: 12624),
      makeMedal(id: "slowFull", category: .full, finishTime: 14000),
      makeMedal(id: "fastHalf", category: .half, finishTime: 6532),
      makeMedal(id: "slowHalf", category: .half, finishTime: 6760)
    ]

    let records = medals.personalRecords

    #expect(records.count == 2)
    #expect(records[.full]?.id == "fastFull")
    #expect(records[.half]?.id == "fastHalf")
  }

  @Test("A record is not shared across race distances")
  func testRecordDoesNotLeakAcrossCategories() {
    let medals = [
      makeMedal(id: "half", category: .half, finishTime: 6532),
      makeMedal(id: "full", category: .full, finishTime: 12624)
    ]

    #expect(medals.personalRecords[.tenKM] == nil)
  }

  @Test("A custom distance collapses onto the preset it measures")
  func testCustomDistanceCollapsesOntoPreset() {
    let medals = [
      makeMedal(id: "preset", category: .full, finishTime: 14000),
      makeMedal(id: "custom", category: .custom(42.195), finishTime: 12624)
    ]

    let records = medals.personalRecords

    #expect(records.count == 1)
    #expect(records[.full]?.id == "custom")
  }

  // MARK: - Eligibility guards
  @Test("A category whose medals are all untimed produces no record")
  func testAllUntimedProducesNoRecord() {
    let medals = [
      makeMedal(id: "a", category: .full, finishTime: nil),
      makeMedal(id: "b", category: .full, finishTime: nil)
    ]

    #expect(medals.personalRecords.isEmpty)
  }

  @Test("An untimed medal never outranks a timed one")
  func testUntimedMedalExcluded() {
    let medals = [
      makeMedal(id: "untimed", category: .full, finishTime: nil),
      makeMedal(id: "timed", category: .full, finishTime: 12624)
    ]

    #expect(medals.personalRecords[.full]?.id == "timed")
  }

  /// A corrupt or malicious stored value must not win by being the minimum.
  @Test("A zero finish time cannot hold the record")
  func testZeroFinishTimeExcluded() {
    let medals = [
      makeMedal(id: "zero", category: .full, finishTime: 0),
      makeMedal(id: "valid", category: .full, finishTime: 12624)
    ]

    #expect(medals.personalRecords[.full]?.id == "valid")
  }

  @Test("A negative finish time cannot hold the record")
  func testNegativeFinishTimeExcluded() {
    let medals = [
      makeMedal(id: "negative", category: .full, finishTime: -500),
      makeMedal(id: "valid", category: .full, finishTime: 12624)
    ]

    #expect(medals.personalRecords[.full]?.id == "valid")
  }

  @Test("A category holding only a non-positive time produces no record")
  func testOnlyNonPositiveTimeProducesNoRecord() {
    let medals = [makeMedal(id: "zero", category: .full, finishTime: 0)]

    #expect(medals.personalRecords.isEmpty)
  }

  // MARK: - Tie-breaking
  @Test("A shared fastest time goes to the earlier-dated medal")
  func testTieGoesToEarlierDate() {
    let medals = [
      makeMedal(id: "later", category: .full, finishTime: 12624, date: makeDate(2025, 12, 20)),
      makeMedal(id: "earlier", category: .full, finishTime: 12624, date: makeDate(2019, 12, 15))
    ]

    #expect(medals.personalRecords[.full]?.id == "earlier")
  }

  @Test("A tie marks exactly one medal")
  func testTieMarksExactlyOne() {
    let medals = [
      makeMedal(id: "a", category: .full, finishTime: 12624, date: makeDate(2025, 12, 20)),
      makeMedal(id: "b", category: .full, finishTime: 12624, date: makeDate(2022, 12, 18)),
      makeMedal(id: "c", category: .full, finishTime: 12624, date: makeDate(2019, 12, 15))
    ]

    #expect(medals.personalRecordIDs.count == 1)
  }

  @Test("A tie on both time and date resolves deterministically")
  func testTieOnTimeAndDateIsDeterministic() {
    let sharedDate = makeDate(2022, 5, 1)
    let first = makeMedal(id: "a", category: .full, finishTime: 12624, date: sharedDate)
    let second = makeMedal(id: "b", category: .full, finishTime: 12624, date: sharedDate)

    #expect(
      [first, second].personalRecords[.full]?.id == [second, first].personalRecords[.full]?.id)
  }

  // MARK: - personalRecordIDs
  @Test("personalRecordIDs is empty for an empty collection")
  func testRecordIDsEmptyCollection() {
    let medals: [Medal] = []

    #expect(medals.personalRecordIDs.isEmpty)
  }

  @Test("personalRecordIDs is empty when no medal is timed")
  func testRecordIDsEmptyWhenUntimed() {
    let medals = [
      makeMedal(category: .full, finishTime: nil),
      makeMedal(category: .half, finishTime: nil)
    ]

    #expect(medals.personalRecordIDs.isEmpty)
  }

  @Test("personalRecordIDs holds exactly the ids of the record-holding medals")
  func testRecordIDsMatchRecords() {
    let medals = [
      makeMedal(id: "fastFull", category: .full, finishTime: 12624),
      makeMedal(id: "slowFull", category: .full, finishTime: 14000),
      makeMedal(id: "fastHalf", category: .half, finishTime: 6532)
    ]

    #expect(medals.personalRecordIDs == ["fastFull", "fastHalf"])
    #expect(medals.personalRecordIDs == Set(medals.personalRecords.values.map(\.id)))
  }

  // MARK: - Scope
  /// Records describe the collection, so narrowing the view must not promote a medal.
  @Test("Filtering to a category marks the same medal as the whole collection does")
  func testFilteringDoesNotMoveARecord() {
    let medals = [
      makeMedal(id: "fastFull", category: .full, finishTime: 12624),
      makeMedal(id: "fastHalf", category: .half, finishTime: 6532),
      makeMedal(id: "slowHalf", category: .half, finishTime: 6760)
    ]

    let wholeCollection = medals.personalRecords[.half]?.id
    let filtered = medals.filtered(by: .category(.half)).personalRecords[.half]?.id

    #expect(wholeCollection == filtered)
    #expect(filtered == "fastHalf")
  }
}
