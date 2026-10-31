//
//  RacesViewModelTests.swift
//  MedalWall
//
//  Created by Quien on 2026-05-28.
//

import Testing

@testable import MedalWall

@MainActor
struct RacesViewModelTests {
  private let place = Place(countryCode: "CA", city: "Vancouver")

  private func makeRace(name: String) -> Race {
    Race(name: name, place: place, createdBy: "user-1")
  }

  // MARK: - sortedRaces
  @Test("sortedRaces is empty when no races are loaded")
  func testSortedRacesEmpty() {
    let viewModel = RacesViewModel()

    #expect(viewModel.sortedRaces.isEmpty)
  }

  @Test("sortedRaces returns every race sorted alphabetically")
  func testSortedRacesSortedAlphabetically() {
    let viewModel = RacesViewModel()
    viewModel.races = [
      makeRace(name: "Zermatt Marathon"),
      makeRace(name: "Apple Run"),
      makeRace(name: "Boston Marathon")
    ]

    let names = viewModel.sortedRaces.map(\.name)
    #expect(names == ["Apple Run", "Boston Marathon", "Zermatt Marathon"])
  }

  @Test("sortedRaces returns the single race when only one is loaded")
  func testSortedRacesSingleRace() {
    let viewModel = RacesViewModel()
    viewModel.races = [makeRace(name: "Boston Marathon")]

    #expect(viewModel.sortedRaces.count == 1)
    #expect(viewModel.sortedRaces.first?.name == "Boston Marathon")
  }
}
