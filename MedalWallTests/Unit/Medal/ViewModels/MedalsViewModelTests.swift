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
      #expect(viewModel.count(for: filter) >= 1)
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

    #expect(viewModel.count(for: .all) == 3)
    #expect(viewModel.count(for: .category(.full)) == 2)
    #expect(viewModel.count(for: .category(.half)) == 1)
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
    let unfiltered = viewModel.personalBests.map(\.medal.id)
    viewModel.selectedFilter = .category(.half)

    #expect(viewModel.personalBests.map(\.medal.id) == unfiltered)
    #expect(viewModel.personalBests.map(\.medal.id) == ["fastFull", "fastHalf"])
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

    #expect(viewModel.personalBests.map(\.category) == [.full, .half, .tenKM])
    #expect(viewModel.yearGroups.flatMap(\.medals).count == 1)
  }

  @Test("personalBests is empty when no medals are loaded")
  func testPersonalBestsEmptyCollection() {
    let viewModel = MedalsViewModel()

    #expect(viewModel.personalBests.isEmpty)
  }

  @Test("personalBests is empty when no medal records an eligible time")
  func testPersonalBestsEmptyWhenNoEligibleTime() {
    let viewModel = MedalsViewModel()
    viewModel.medals = [
      makeMedal(category: .full, finishTime: nil),
      makeMedal(category: .half, finishTime: 0)
    ]

    #expect(viewModel.personalBests.isEmpty)
    #expect(!viewModel.isEmpty)
  }

  // MARK: - Personal best card content
  @Test("A card states its distance, race, time and pace")
  func testPersonalBestCardContent() throws {
    let viewModel = MedalsViewModel()
    viewModel.medals = [
      makeMedal(id: "full", category: .full, finishTime: 12624)
    ]
    let personalBest = try #require(viewModel.personalBests.first)

    #expect(viewModel.raceNameText(for: personalBest) == "Test")
    #expect(viewModel.finishTimeText(for: personalBest) == "03:30:24")
    #expect(viewModel.distanceText(for: personalBest) == RaceDistanceCategory.full.description)
    #expect(viewModel.paceText(for: personalBest).contains("4'59\""))
  }

  /// The row below declares `medal.id`; two sources sharing one id in a namespace leave
  /// the zoom transition with no way to choose.
  @Test("A card's transition id is prefixed so it cannot collide with its row")
  func testPersonalBestTransitionID() throws {
    let viewModel = MedalsViewModel()
    viewModel.medals = [makeMedal(id: "full", category: .full, finishTime: 12624)]
    let personalBest = try #require(viewModel.personalBests.first)

    #expect(viewModel.transitionID(for: personalBest) == "personalBest-full")
    #expect(viewModel.transitionID(for: personalBest) != personalBest.medal.id)
  }

  // MARK: - Personal best paging
  @Test("An unscrolled carousel reports the first page")
  func testPersonalBestPageWithoutScrollPosition() {
    let viewModel = MedalsViewModel()
    viewModel.medals = [
      makeMedal(id: "full", category: .full, finishTime: 12624),
      makeMedal(id: "half", category: .half, finishTime: 6532)
    ]

    #expect(viewModel.personalBestPage(forScrolledID: nil) == 0)
  }

  @Test("Each scroll position reports its own page")
  func testPersonalBestPagePerPosition() {
    let viewModel = MedalsViewModel()
    viewModel.medals = [
      makeMedal(id: "full", category: .full, finishTime: 12624),
      makeMedal(id: "half", category: .half, finishTime: 6532),
      makeMedal(id: "tenKM", category: .tenKM, finishTime: 2700)
    ]

    #expect(viewModel.personalBestPage(forScrolledID: RaceDistanceCategory.full.value) == 0)
    #expect(viewModel.personalBestPage(forScrolledID: RaceDistanceCategory.half.value) == 1)
    #expect(viewModel.personalBestPage(forScrolledID: RaceDistanceCategory.tenKM.value) == 2)
  }

  /// A distance can leave the collection while its id is still the scroll position.
  @Test("A scroll position naming no card falls back to the first page")
  func testPersonalBestPageForUnknownPosition() {
    let viewModel = MedalsViewModel()
    viewModel.medals = [makeMedal(id: "full", category: .full, finishTime: 12624)]

    #expect(viewModel.personalBestPage(forScrolledID: RaceDistanceCategory.half.value) == 0)
  }

  @Test("An empty collection reports the first page rather than a negative one")
  func testPersonalBestPageWithoutCards() {
    let viewModel = MedalsViewModel()

    #expect(viewModel.personalBestPage(forScrolledID: nil) == 0)
    #expect(viewModel.personalBestPage(forScrolledID: RaceDistanceCategory.full.value) == 0)
  }
}
