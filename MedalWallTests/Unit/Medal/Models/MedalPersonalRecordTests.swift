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

  // MARK: - Sample data
  /// Guards what the previews and the running app actually show: the marker lands on the
  /// medals that recorded a time, and nowhere else.
  @Test("Sample data marks every timed medal and no untimed one")
  func testSampleDataMarksOnlyTimedMedals() {
    let medals = Medal.sampleData
    let timed = medals.filter { ($0.finishTime ?? 0) > 0 }
    let recordIDs = medals.personalRecordIDs

    #expect(!timed.isEmpty, "sample data should carry at least one timed medal")
    #expect(recordIDs.count == timed.count)

    for medal in timed {
      #expect(recordIDs.contains(medal.id), "timed medal \(medal.name) should hold a record")
    }

    for medal in medals where medal.finishTime == nil {
      #expect(!recordIDs.contains(medal.id), "untimed medal \(medal.name) must not be marked")
    }
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

  // MARK: - personalBests
  @Test("personalBests is empty for an empty collection")
  func testPersonalBestsEmptyCollection() {
    let medals: [Medal] = []

    #expect(medals.personalBests.isEmpty)
  }

  @Test("personalBests is empty when no medal records an eligible time")
  func testPersonalBestsEmptyWhenNoEligibleTime() {
    let medals = [
      makeMedal(category: .full, finishTime: nil),
      makeMedal(category: .half, finishTime: 0)
    ]

    #expect(medals.personalBests.isEmpty)
  }

  @Test("personalBests orders entries longest distance first")
  func testPersonalBestsOrderedLongestFirst() {
    let medals = [
      makeMedal(id: "tenKM", category: .tenKM, finishTime: 2700),
      makeMedal(id: "full", category: .full, finishTime: 12624),
      makeMedal(id: "half", category: .half, finishTime: 6532)
    ]

    #expect(medals.personalBests.map(\.category) == [.full, .half, .tenKM])
  }

  /// The carousel and the filter chips must never disagree about distance order.
  @Test("personalBests follows the order the distance filter offers")
  func testPersonalBestsMatchesOwnedCategoryOrder() {
    let medals = [
      makeMedal(id: "half", category: .half, finishTime: 6532),
      makeMedal(id: "fiveKM", category: .fiveKM, finishTime: 1200),
      makeMedal(id: "full", category: .full, finishTime: 12624)
    ]

    let bestOrder = medals.personalBests.map(\.category.value)
    let filterOrder = medals.distanceCategoriesOwned.map(\.value)

    #expect(bestOrder == filterOrder)
  }

  /// The projection reads `personalRecords`; it must not re-derive the rule.
  @Test("Each entry holds the medal personalRecords names for its category")
  func testPersonalBestsAgreeWithPersonalRecords() {
    let medals = [
      makeMedal(id: "fastFull", category: .full, finishTime: 12624),
      makeMedal(id: "slowFull", category: .full, finishTime: 14000),
      makeMedal(id: "fastHalf", category: .half, finishTime: 6532),
      makeMedal(id: "slowHalf", category: .half, finishTime: 6760)
    ]

    let records = medals.personalRecords

    #expect(medals.personalBests.map(\.medal.id) == ["fastFull", "fastHalf"])

    for best in medals.personalBests {
      #expect(best.medal.id == records[best.category]?.id)
    }
  }

  @Test("A distance whose medals are all untimed contributes no entry")
  func testPersonalBestsOmitsUntimedCategory() {
    let medals = [
      makeMedal(id: "full", category: .full, finishTime: 12624),
      makeMedal(id: "untimedHalf", category: .half, finishTime: nil),
      makeMedal(id: "tenKM", category: .tenKM, finishTime: 2700)
    ]

    #expect(medals.personalBests.map(\.category) == [.full, .tenKM])
    #expect(medals.distanceCategoriesOwned.contains(.half))
  }

  @Test("A custom distance equal to a preset yields one entry, not two")
  func testPersonalBestsCollapsesCustomOntoPreset() {
    let medals = [
      makeMedal(id: "preset", category: .full, finishTime: 14000),
      makeMedal(id: "custom", category: .custom(42.195), finishTime: 12624)
    ]

    #expect(medals.personalBests.count == 1)
    #expect(medals.personalBests.first?.medal.id == "custom")
  }
}
