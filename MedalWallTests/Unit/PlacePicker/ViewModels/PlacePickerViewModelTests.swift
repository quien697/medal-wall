//
//  PlacePickerViewModelTests.swift
//  MedalWall
//
//  Created by Quien on 2026-08-05.
//

import Foundation
import Testing

@testable import MedalWall

@MainActor
struct PlacePickerViewModelTests {

  // MARK: - Helpers
  private let taipei = PlaceSuggestion(id: "0", title: "Taipei City", subtitle: "Taiwan")
  private let fuxing = PlaceSuggestion(
    id: "1", title: "Fuxing District", subtitle: "Taoyuan, Taiwan")

  private func makeViewModel(_ stub: StubPlaceSearchService) -> PlacePickerViewModel {
    PlacePickerViewModel(service: stub, debounce: .milliseconds(20))
  }

  private func search(
    _ query: String, on viewModel: PlacePickerViewModel
  ) async {
    viewModel.query = query
    viewModel.search()
    await viewModel.searchTask?.value
  }

  // MARK: - Suggestions
  @Test("A query surfaces the provider's suggestions")
  func testQueryProducesSuggestions() async {
    let stub = StubPlaceSearchService()
    stub.searchOutcome = .results([taipei, fuxing])
    let viewModel = makeViewModel(stub)

    await search("taipei", on: viewModel)

    #expect(viewModel.suggestions == [taipei, fuxing])
    #expect(stub.lastQuery == "taipei")
  }

  @Test("Rapid successive queries collapse into a single search")
  func testRapidQueriesAreDebounced() async {
    let stub = StubPlaceSearchService()
    stub.searchOutcome = .results([taipei])
    let viewModel = makeViewModel(stub)

    viewModel.query = "t"
    viewModel.search()
    viewModel.query = "ta"
    viewModel.search()
    viewModel.query = "tai"
    viewModel.search()
    await viewModel.searchTask?.value

    #expect(stub.queryCallCount == 1)
    #expect(stub.lastQuery == "tai")
  }

  @Test("A blank query clears suggestions without searching at all")
  func testBlankQueryDoesNotSearch() async {
    let stub = StubPlaceSearchService()
    stub.searchOutcome = .results([taipei])
    let viewModel = makeViewModel(stub)

    await search("   ", on: viewModel)

    #expect(viewModel.suggestions.isEmpty)
    #expect(viewModel.hasNoResults == false)
    #expect(stub.queryCallCount == 0)
  }

  // MARK: - Empty results
  @Test("A query matching nothing shows the empty state and leaves the place unchanged")
  func testEmptyResults() async {
    let stub = StubPlaceSearchService()
    stub.searchOutcome = .empty
    let viewModel = makeViewModel(stub)

    await search("nowhere at all", on: viewModel)

    #expect(viewModel.suggestions.isEmpty)
    #expect(viewModel.hasNoResults)
    #expect(viewModel.selectedPlace == nil)
    #expect(viewModel.error == nil)
  }

  // MARK: - Failures
  @Test("A failed search sets an AppError and leaves the place unchanged")
  func testSearchFailureSetsError() async {
    let stub = StubPlaceSearchService()
    stub.searchOutcome = .failure(.placeSearchFailed("offline"))
    let viewModel = makeViewModel(stub)

    await search("taipei", on: viewModel)

    #expect(viewModel.error == .placeSearchFailed("offline"))
    #expect(viewModel.selectedPlace == nil)
  }

  @Test("A failed search does not show the empty-results state")
  func testSearchFailureIsNotEmptyState() async {
    let stub = StubPlaceSearchService()
    stub.searchOutcome = .failure(.placeSearchFailed("offline"))
    let viewModel = makeViewModel(stub)

    await search("taipei", on: viewModel)

    #expect(viewModel.hasNoResults == false)
  }

  @Test("A failed resolve sets an AppError and leaves the place unchanged")
  func testResolveFailureSetsError() async {
    let stub = StubPlaceSearchService()
    stub.resolveOutcome = .failure(.placeNotResolved)
    let viewModel = makeViewModel(stub)

    await viewModel.select(taipei)

    #expect(viewModel.error == .placeNotResolved)
    #expect(viewModel.selectedPlace == nil)
    #expect(viewModel.isFinished == false)
  }

  // MARK: - Selection
  @Test("Selecting a suggestion applies the resolved place and signals dismissal")
  func testSelectAppliesResolvedplace() async throws {
    let stub = StubPlaceSearchService()
    let resolved = Place(
      countryCode: "TW", city: "田中鎮", region: "彰化縣")
    stub.resolveOutcome = .success(resolved)
    let viewModel = makeViewModel(stub)

    await viewModel.select(fuxing)

    #expect(try #require(viewModel.selectedPlace) == resolved)
    #expect(viewModel.isFinished)
    #expect(viewModel.error == nil)
    #expect(stub.resolvedIDs == [fuxing.id])
  }
}
