//
//  RacesViewModelTests.swift
//  MedalWall
//
//  Created by Quien on 2026-05-28.
//

import Testing

@testable import MedalWall

struct RacesViewModelTests {
  private let location = GeoLocation(country: "Canada", city: "Vancouver")

  private func makeRace(name: String) -> Race {
    Race(name: name, location: location, createdBy: "user-1")
  }

  // MARK: - filteredRaces
  @Test("filteredRaces is empty when no races are loaded")
  func testFilteredRacesEmpty() {
    let viewModel = RacesViewModel()

    #expect(viewModel.filteredRaces.isEmpty)
  }

  @Test("filteredRaces returns all races sorted alphabetically when searchText is empty")
  func testFilteredRacesNoSearchSortedAlphabetically() {
    let viewModel = RacesViewModel()
    viewModel.races = [
      makeRace(name: "Zermatt Marathon"),
      makeRace(name: "Apple Run"),
      makeRace(name: "Boston Marathon")
    ]

    let names = viewModel.filteredRaces.map(\.name)
    #expect(names == ["Apple Run", "Boston Marathon", "Zermatt Marathon"])
  }

  @Test("filteredRaces returns only matching races when searchText is set")
  func testFilteredRacesWithSearch() {
    let viewModel = RacesViewModel()
    viewModel.races = [
      makeRace(name: "Boston Marathon"),
      makeRace(name: "Berlin Marathon"),
      makeRace(name: "Apple Run")
    ]
    viewModel.searchText = "Marathon"

    let names = viewModel.filteredRaces.map(\.name)
    #expect(names == ["Berlin Marathon", "Boston Marathon"])
  }

  @Test("filteredRaces search is case-insensitive")
  func testFilteredRacesCaseInsensitive() {
    let viewModel = RacesViewModel()
    viewModel.races = [makeRace(name: "Boston Marathon"), makeRace(name: "Apple Run")]
    viewModel.searchText = "marathon"

    #expect(viewModel.filteredRaces.count == 1)
    #expect(viewModel.filteredRaces.first?.name == "Boston Marathon")
  }

  @Test("filteredRaces returns empty when no races match the search")
  func testFilteredRacesNoMatch() {
    let viewModel = RacesViewModel()
    viewModel.races = [makeRace(name: "Boston Marathon"), makeRace(name: "Apple Run")]
    viewModel.searchText = "XYZ"

    #expect(viewModel.filteredRaces.isEmpty)
  }

  @Test("filteredRaces results remain sorted alphabetically after filtering")
  func testFilteredRacesSortedAfterFilter() {
    let viewModel = RacesViewModel()
    viewModel.races = [
      makeRace(name: "Vancouver Marathon"),
      makeRace(name: "Boston Marathon"),
      makeRace(name: "Berlin Marathon")
    ]
    viewModel.searchText = "Marathon"

    let names = viewModel.filteredRaces.map(\.name)
    #expect(names == ["Berlin Marathon", "Boston Marathon", "Vancouver Marathon"])
  }

  @Test("filteredRaces returns the single race when only one is loaded")
  func testFilteredRacesSingleRace() {
    let viewModel = RacesViewModel()
    viewModel.races = [makeRace(name: "Boston Marathon")]

    #expect(viewModel.filteredRaces.count == 1)
    #expect(viewModel.filteredRaces.first?.name == "Boston Marathon")
  }

  @Test("filteredRaces returns all races sorted when search matches all of them")
  func testFilteredRacesSearchMatchesAll() {
    let viewModel = RacesViewModel()
    viewModel.races = [makeRace(name: "Berlin Run"), makeRace(name: "Apple Run")]
    viewModel.searchText = "Run"

    let names = viewModel.filteredRaces.map(\.name)
    #expect(names == ["Apple Run", "Berlin Run"])
  }

  @Test("filteredRaces matches a partial name substring")
  func testFilteredRacesPartialMatch() {
    let viewModel = RacesViewModel()
    viewModel.races = [makeRace(name: "Boston Marathon"), makeRace(name: "Apple Run")]
    viewModel.searchText = "Bos"

    #expect(viewModel.filteredRaces.count == 1)
    #expect(viewModel.filteredRaces.first?.name == "Boston Marathon")
  }
}
