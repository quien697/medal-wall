//
//  ProfileViewModelRepositoryTests.swift
//  MedalWall
//
//  Created by Quien on 2026-09-29.
//

import Foundation
import Testing

@testable import MedalWall

@MainActor
struct ProfileViewModelRepositoryTests {

  private func makeMedal(id: String) -> Medal {
    Medal(
      id: id,
      name: "Taipei Marathon",
      date: Date(timeIntervalSince1970: 1_577_836_800),
      bibNumber: "00001",
      place: Place(countryCode: "TW", city: "Taipei City"),
      distance: .default,
      userID: "uid"
    )
  }

  @Test("medals load through the injected repository")
  func testLoadMedals() async {
    let repository = StubMedalRepository(medals: [makeMedal(id: "a"), makeMedal(id: "b")])
    let viewModel = ProfileViewModel(repository: repository)

    await viewModel.loadMedals(userId: "uid")

    #expect(viewModel.totalMedals == 2)
    #expect(viewModel.error == nil)
  }

  @Test("a failed fetch surfaces medalFetchFailed")
  func testFailedFetchSurfacesError() async {
    let repository = StubMedalRepository(fetchOutcome: .failure(.medalFetchFailed("network down")))
    let viewModel = ProfileViewModel(repository: repository)

    await viewModel.loadMedals(userId: "uid")

    if case .medalFetchFailed = viewModel.error {
    } else {
      Issue.record("expected medalFetchFailed, got \(String(describing: viewModel.error))")
    }
  }

  @Test("a failed reload keeps the medals already shown")
  func testFailedReloadKeepsMedals() async {
    let repository = StubMedalRepository(fetchOutcome: .failure(.medalFetchFailed("network down")))
    let viewModel = ProfileViewModel(repository: repository)
    viewModel.medals = [makeMedal(id: "a")]

    await viewModel.loadMedals(userId: "uid")

    #expect(viewModel.totalMedals == 1)
  }
}
