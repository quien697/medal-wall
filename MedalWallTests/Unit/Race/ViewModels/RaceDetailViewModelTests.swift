//
//  RaceDetailViewModelTests.swift
//  MedalWall
//
//  Created by Quien on 2026-05-28.
//

import Testing

@testable import MedalWall

struct RaceDetailViewModelTests {
  private let location = GeoLocation(country: "Canada", city: "Vancouver")

  private func makeRace(name: String = "Test Race") -> Race {
    Race(name: name, location: location, createdBy: "user-1")
  }

  // MARK: - Initial state
  @Test("init stores the provided race")
  func testInitStoresRace() {
    let race = makeRace(name: "Boston Marathon")
    let viewModel = RaceDetailViewModel(race: race)

    #expect(viewModel.race.name == "Boston Marathon")
    #expect(viewModel.race.id == race.id)
  }

  @Test("editions starts empty before any load")
  func testEditionsStartEmpty() {
    let viewModel = RaceDetailViewModel(race: makeRace())

    #expect(viewModel.editions.isEmpty)
  }

  @Test("isLoading starts false")
  func testIsLoadingStartsFalse() {
    let viewModel = RaceDetailViewModel(race: makeRace())

    #expect(viewModel.isLoading == false)
  }

  @Test("error starts nil")
  func testErrorStartsNil() {
    let viewModel = RaceDetailViewModel(race: makeRace())

    #expect(viewModel.error == nil)
  }
}
