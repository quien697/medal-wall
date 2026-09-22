//
//  MedalsViewModelRepositoryTests.swift
//  MedalWall
//
//  Created by Quien on 2026-09-22.
//

import Foundation
import Testing

@testable import MedalWall

@MainActor
struct MedalsViewModelRepositoryTests {

  private func makeMedal(id: String, userID: String = "uid") -> Medal {
    Medal(
      id: id,
      name: "Taipei Marathon",
      date: Date(timeIntervalSince1970: 1_577_836_800),
      bibNumber: "00001",
      place: Place(countryCode: "TW", city: "Taipei City"),
      distance: .default,
      userID: userID
    )
  }

  @Test("medals load through the injected repository")
  func testLoadMedals() async {
    let repository = StubMedalRepository(medals: [makeMedal(id: "a"), makeMedal(id: "b")])
    let viewModel = MedalsViewModel(repository: repository)

    await viewModel.loadMedals(userId: "uid")

    #expect(viewModel.medals.count == 2)
    #expect(await repository.fetchCallCount == 1)
    #expect(viewModel.error == nil)
    #expect(viewModel.isLoading == false)
  }

  @Test("only the requesting user's medals load")
  func testLoadMedalsScopedToUser() async {
    let repository = StubMedalRepository(medals: [
      makeMedal(id: "mine"),
      makeMedal(id: "theirs", userID: "other")
    ])
    let viewModel = MedalsViewModel(repository: repository)

    await viewModel.loadMedals(userId: "uid")

    #expect(viewModel.medals.map(\.id) == ["mine"])
  }

  @Test("a failed fetch surfaces medalFetchFailed")
  func testFailedFetchSurfacesError() async {
    let repository = StubMedalRepository(fetchOutcome: .failure(.medalFetchFailed("network down")))
    let viewModel = MedalsViewModel(repository: repository)

    await viewModel.loadMedals(userId: "uid")

    #expect(viewModel.medals.isEmpty)
    #expect(viewModel.isLoading == false)
    if case .medalFetchFailed = viewModel.error {
    } else {
      Issue.record("expected medalFetchFailed, got \(String(describing: viewModel.error))")
    }
  }
}
