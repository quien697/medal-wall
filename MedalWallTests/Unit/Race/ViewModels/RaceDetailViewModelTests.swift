//
//  RaceDetailViewModelTests.swift
//  MedalWall
//
//  Created by Quien on 2026-05-28.
//

import Testing

@testable import MedalWall

@MainActor
struct RaceDetailViewModelTests {
  private let place = Place(countryCode: "CA", city: "Vancouver")

  private func makeRace(name: String = "Test Race") -> Race {
    Race(name: name, place: place, createdBy: "user-1")
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

  @Test("isLoading starts true: the editions load as soon as the screen appears")
  func testIsLoadingStartsTrue() {
    let viewModel = RaceDetailViewModel(race: makeRace())

    #expect(viewModel.isLoading)
  }

  @Test("error starts nil")
  func testErrorStartsNil() {
    let viewModel = RaceDetailViewModel(race: makeRace())

    #expect(viewModel.error == nil)
  }

  // MARK: - Creator
  @Test("the race's creator may edit and delete it")
  func testCreatorCanManageRace() {
    let viewModel = RaceDetailViewModel(race: makeRace())

    #expect(viewModel.canManageRace(userID: "user-1"))
  }

  @Test("another user may not edit or delete the race")
  func testAnotherUserCannotManageRace() {
    let viewModel = RaceDetailViewModel(race: makeRace())

    #expect(!viewModel.canManageRace(userID: "user-2"))
  }

  @Test("with no signed-in user no one may edit or delete the race")
  func testNoUserCannotManageRace() {
    let viewModel = RaceDetailViewModel(race: makeRace())

    #expect(!viewModel.canManageRace(userID: nil))
  }
}
