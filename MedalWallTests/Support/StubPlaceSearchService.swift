//
//  StubPlaceSearchService.swift
//  MedalWall
//
//  Created by Quien on 2026-08-05.
//

import Foundation

@testable import MedalWall

/// Scriptable `PlaceSearchService` so the picker can be tested without a network or MapKit.
@MainActor
final class StubPlaceSearchService: PlaceSearchService {

  enum SearchOutcome {
    case results([PlaceSuggestion])
    case empty
    case failure(AppError)
  }

  // MARK: - Script
  var searchOutcome: SearchOutcome = .empty
  var resolveOutcome: Result<Place, AppError> = .failure(.placeNotResolved)

  // MARK: - Recorded calls
  private(set) var queryCallCount = 0
  private(set) var lastQuery: String?
  private(set) var resolvedIDs: [PlaceSuggestion.ID] = []

  // MARK: - PlaceSearchService
  func suggestions(for query: String) -> AsyncThrowingStream<[PlaceSuggestion], any Error> {
    queryCallCount += 1
    lastQuery = query

    let (stream, continuation) = AsyncThrowingStream<[PlaceSuggestion], any Error>.makeStream()
    switch searchOutcome {
    case .results(let suggestions):
      continuation.yield(suggestions)
      continuation.finish()
    case .empty:
      continuation.yield([])
      continuation.finish()
    case .failure(let error):
      continuation.finish(throwing: error)
    }
    return stream
  }

  func resolve(suggestionID: PlaceSuggestion.ID) async throws -> Place {
    resolvedIDs.append(suggestionID)
    return try resolveOutcome.get()
  }
}
