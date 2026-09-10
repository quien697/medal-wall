//
//  MedalsViewModelTests.swift
//  MedalWall
//
//  Created by Quien on 2026-09-07.
//

import Foundation
import Testing

@testable import MedalWall

struct MedalsViewModelTests {

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

  // MARK: - selectedFilter default
  @Test("selectedFilter defaults to all")
  func testSelectedFilterDefaultsToAll() {
    let viewModel = MedalsViewModel()

    #expect(viewModel.selectedFilter == .all)
  }

  // MARK: - availableFilters
  @Test("availableFilters is empty when no medals are loaded")
  func testAvailableFiltersEmptyCollection() {
    let viewModel = MedalsViewModel()

    #expect(viewModel.availableFilters.isEmpty)
  }

  @Test("availableFilters puts all first, then owned categories longest first")
  func testAvailableFiltersShape() {
    let viewModel = MedalsViewModel()
    viewModel.medals = [
      makeMedal(category: .fiveKM),
      makeMedal(category: .full),
      makeMedal(category: .half)
    ]

    #expect(
      viewModel.availableFilters == [
        .all,
        .category(.full),
        .category(.half),
        .category(.fiveKM)
      ]
    )
  }

  @Test("availableFilters offers no option the collection cannot fill")
  func testAvailableFiltersAllSelectSomething() {
    let viewModel = MedalsViewModel()
    viewModel.medals = [
      makeMedal(category: .full),
      makeMedal(category: .tenKM)
    ]

    for filter in viewModel.availableFilters {
      #expect(viewModel.medals.count(for: filter) >= 1)
    }
  }

  // MARK: - count(for:)
  @Test("count reports the whole collection for all and the category otherwise")
  func testCountPerFilter() {
    let viewModel = MedalsViewModel()
    viewModel.medals = [
      makeMedal(category: .full),
      makeMedal(category: .full),
      makeMedal(category: .half)
    ]

    #expect(viewModel.medals.count(for: .all) == 3)
    #expect(viewModel.medals.count(for: .category(.full)) == 2)
    #expect(viewModel.medals.count(for: .category(.half)) == 1)
  }

  // MARK: - yearGroups
  @Test("yearGroups presents every medal when all is selected")
  func testYearGroupsUnfiltered() {
    let viewModel = MedalsViewModel()
    viewModel.medals = [
      makeMedal(category: .full, date: makeDate(2025, 12, 20)),
      makeMedal(category: .half, date: makeDate(2022, 12, 18))
    ]

    #expect(viewModel.yearGroups.map(\.year) == [2025, 2022])
  }

  @Test("Selecting a category narrows the year groups it presents")
  func testYearGroupsNarrowWithSelection() {
    let viewModel = MedalsViewModel()
    viewModel.medals = [
      makeMedal(id: "full2025", category: .full, date: makeDate(2025, 12, 20)),
      makeMedal(id: "half2022", category: .half, date: makeDate(2022, 12, 18))
    ]
    viewModel.selectedFilter = .category(.half)

    let groups = viewModel.yearGroups

    #expect(groups.map(\.year) == [2022])
    #expect(groups.first?.medals.map(\.id) == ["half2022"])
  }

  @Test("A year with no medals in the selection produces no group")
  func testYearGroupsDropEmptyYears() {
    let viewModel = MedalsViewModel()
    viewModel.medals = [
      makeMedal(category: .full, date: makeDate(2025, 12, 20)),
      makeMedal(category: .full, date: makeDate(2019, 12, 15)),
      makeMedal(category: .half, date: makeDate(2022, 12, 18))
    ]
    viewModel.selectedFilter = .category(.full)

    #expect(viewModel.yearGroups.map(\.year) == [2025, 2019])
  }

  // MARK: - Stale selection
  @Test("A selection whose category is gone falls back to all")
  func testStaleSelectionFallsBackToAll() {
    let viewModel = MedalsViewModel()
    viewModel.medals = [
      makeMedal(id: "tenK", category: .tenKM),
      makeMedal(id: "full", category: .full)
    ]
    viewModel.selectedFilter = .category(.tenKM)
    viewModel.medals = [makeMedal(id: "full", category: .full)]

    #expect(viewModel.selectedFilter == .all)
    #expect(viewModel.yearGroups.first?.medals.count == 1)
  }

  @Test("A selection whose category survives is kept")
  func testSurvivingSelectionIsKept() {
    let viewModel = MedalsViewModel()
    viewModel.medals = [
      makeMedal(id: "half", category: .half),
      makeMedal(id: "full", category: .full)
    ]
    viewModel.selectedFilter = .category(.half)
    viewModel.medals = [makeMedal(id: "half", category: .half)]

    #expect(viewModel.selectedFilter == .category(.half))
  }

  @Test("Emptying the collection falls a category selection back to all")
  func testEmptyCollectionFallsBackToAll() {
    let viewModel = MedalsViewModel()
    viewModel.medals = [makeMedal(category: .full)]
    viewModel.selectedFilter = .category(.full)
    viewModel.medals = []

    #expect(viewModel.selectedFilter == .all)
  }

  // MARK: - personalRecordIDs
  @Test("personalRecordIDs marks the fastest medal in each category")
  func testPersonalRecordIDs() {
    let viewModel = MedalsViewModel()
    viewModel.medals = [
      makeMedal(id: "fastFull", category: .full, finishTime: 12624),
      makeMedal(id: "slowFull", category: .full, finishTime: 14000),
      makeMedal(id: "half", category: .half, finishTime: 6532)
    ]

    #expect(viewModel.personalRecordIDs == ["fastFull", "half"])
  }

  @Test("personalRecordIDs is unchanged by a filter selection")
  func testPersonalRecordIDsIgnoreSelection() {
    let viewModel = MedalsViewModel()
    viewModel.medals = [
      makeMedal(id: "fastFull", category: .full, finishTime: 12624),
      makeMedal(id: "half", category: .half, finishTime: 6532)
    ]
    let unfiltered = viewModel.personalRecordIDs
    viewModel.selectedFilter = .category(.half)

    #expect(viewModel.personalRecordIDs == unfiltered)
  }

  // MARK: - isEmpty
  @Test("isEmpty is true only when no medals are loaded")
  func testIsEmpty() {
    let viewModel = MedalsViewModel()

    #expect(viewModel.isEmpty)

    viewModel.medals = [makeMedal(category: .full)]

    #expect(!viewModel.isEmpty)
  }

  // MARK: - personalBests
  /// The carousel describes the collection, never the current view of it.
  @Test("personalBests is unchanged by a filter selection")
  func testPersonalBestsIgnoreSelection() {
    let viewModel = MedalsViewModel()
    viewModel.medals = [
      makeMedal(id: "fastFull", category: .full, finishTime: 12624),
      makeMedal(id: "slowFull", category: .full, finishTime: 14000),
      makeMedal(id: "fastHalf", category: .half, finishTime: 6532)
    ]
    let unfiltered = viewModel.medals.personalBests.map(\.medal.id)
    viewModel.selectedFilter = .category(.half)

    #expect(viewModel.medals.personalBests.map(\.medal.id) == unfiltered)
    #expect(viewModel.medals.personalBests.map(\.medal.id) == ["fastFull", "fastHalf"])
  }

  /// Narrowing the list must not narrow the carousel to the selected distance.
  @Test("A filter selection keeps every entry, in the same order")
  func testPersonalBestsKeepsEveryEntryWhenFiltered() {
    let viewModel = MedalsViewModel()
    viewModel.medals = [
      makeMedal(id: "full", category: .full, finishTime: 12624),
      makeMedal(id: "half", category: .half, finishTime: 6532),
      makeMedal(id: "tenKM", category: .tenKM, finishTime: 2700)
    ]
    viewModel.selectedFilter = .category(.tenKM)

    #expect(viewModel.medals.personalBests.map(\.category) == [.full, .half, .tenKM])
    #expect(viewModel.yearGroups.flatMap(\.medals).count == 1)
  }

  @Test("personalBests is empty when no medals are loaded")
  func testPersonalBestsEmptyCollection() {
    let viewModel = MedalsViewModel()

    #expect(viewModel.medals.personalBests.isEmpty)
  }

  @Test("personalBests is empty when no medal records an eligible time")
  func testPersonalBestsEmptyWhenNoEligibleTime() {
    let viewModel = MedalsViewModel()
    viewModel.medals = [
      makeMedal(category: .full, finishTime: nil),
      makeMedal(category: .half, finishTime: 0)
    ]

    #expect(viewModel.medals.personalBests.isEmpty)
    #expect(!viewModel.isEmpty)
  }

  // MARK: - Personal best card content
  @Test("A card states its distance, race, time and pace")
  func testPersonalBestCardContent() throws {
    let viewModel = MedalsViewModel()
    viewModel.medals = [
      makeMedal(id: "full", category: .full, finishTime: 12624)
    ]
    let personalBest = try #require(viewModel.medals.personalBests.first)

    #expect(personalBest.medal.name == "Test")
    #expect(personalBest.medal.finishTime?.formattedHMS == "03:30:24")
    #expect(personalBest.category.description == RaceDistanceCategory.full.description)
    #expect(
      DistanceUnit.resolved().paceText(
        minutesPerKilometer: personalBest.medal.averagePace
      ).contains("4'59\"")
    )
  }
}
