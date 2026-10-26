//
//  SearchViewModelTests.swift
//  MedalWall
//
//  Created by Quien on 2026-10-25.
//

import Foundation
import Testing

@testable import MedalWall

@MainActor
struct SearchViewModelTests {

  private let taipei = Place(countryCode: "TW", city: "Taipei City")

  private func makeMedal(id: String, name: String, finishTime: TimeInterval? = nil) -> Medal {
    Medal(
      id: id,
      name: name,
      date: Date(timeIntervalSince1970: 1_577_836_800),
      bibNumber: "1",
      place: taipei,
      raceEvent: RaceEvent(category: .full, type: .inPerson),
      result: finishTime.map(RaceResult.seconds),
      userID: "uid"
    )
  }

  private func makeRace(name: String, editionCount: Int = 0) -> Race {
    Race(name: name, place: taipei, editionCount: editionCount, createdBy: "uid")
  }

  // MARK: - Query
  @Test("The query is the field's text trimmed of whitespace and newlines")
  func testQueryTrimmed() {
    let viewModel = SearchViewModel()
    viewModel.races = [makeRace(name: "Sun Run"), makeRace(name: "Osaka Marathon")]
    viewModel.searchText = "  Osaka \n"

    #expect(viewModel.query == "Osaka")
    #expect(viewModel.matchingRaces.map(\.name) == ["Osaka Marathon"])
  }

  @Test("A field of only whitespace and newlines is an empty query with no matches")
  func testWhitespaceQueryIsEmpty() {
    let viewModel = SearchViewModel()
    viewModel.medals = [makeMedal(id: "a", name: "Taipei Marathon")]
    viewModel.races = [makeRace(name: "Taipei Marathon")]
    viewModel.searchText = " \n "

    #expect(viewModel.isQueryEmpty)
    #expect(viewModel.matchingMedals.isEmpty)
    #expect(viewModel.matchingRaces.isEmpty)
  }

  @Test("A typed query is not empty")
  func testTypedQueryIsNotEmpty() {
    let viewModel = SearchViewModel()
    viewModel.searchText = "t"

    #expect(!viewModel.isQueryEmpty)
  }

  // MARK: - Matches
  @Test("A query finds both medals and races")
  func testQueryFindsMedalsAndRaces() {
    let viewModel = SearchViewModel()
    viewModel.medals = [
      makeMedal(id: "osaka", name: "Osaka Marathon"),
      makeMedal(id: "sun", name: "Sun Run")
    ]
    viewModel.races = [makeRace(name: "Osaka Marathon"), makeRace(name: "Sun Run")]
    viewModel.searchText = "osaka"

    #expect(viewModel.matchingMedals.map(\.id) == ["osaka"])
    #expect(viewModel.matchingRaces.map(\.name) == ["Osaka Marathon"])
  }

  @Test("A matching race's negative edition count is clamped to zero")
  func testMatchingRacesClampEditionCount() {
    let viewModel = SearchViewModel()
    viewModel.races = [makeRace(name: "Osaka Marathon", editionCount: -3)]
    viewModel.searchText = "Osaka"

    #expect(viewModel.matchingRaces.map(\.editionCount) == [0])
  }

  @Test("A matching race's edition count is kept when it is not negative")
  func testMatchingRacesKeepEditionCount() {
    let viewModel = SearchViewModel()
    viewModel.races = [makeRace(name: "Osaka Marathon", editionCount: 12)]
    viewModel.searchText = "Osaka"

    #expect(viewModel.matchingRaces.map(\.editionCount) == [12])
  }

  // MARK: - Personal records
  @Test("Records come from the whole collection, so a query cannot promote a slower medal")
  func testPersonalRecordIDsFromWholeCollection() {
    let viewModel = SearchViewModel()
    viewModel.medals = [
      makeMedal(id: "fast", name: "Taipei Marathon", finishTime: 3 * 3600),
      makeMedal(id: "slow", name: "Osaka Marathon", finishTime: 4 * 3600)
    ]
    viewModel.searchText = "Osaka"

    #expect(viewModel.matchingMedals.map(\.id) == ["slow"])
    #expect(viewModel.personalRecordIDs == ["fast"])
  }
}
