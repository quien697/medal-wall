//
//  PlaceSearchService.swift
//  MedalWall
//
//  Created by Quien on 2026-08-05.
//

import Foundation

/// Supplies place suggestions for a search query and resolves a chosen one into a
/// `Place`.
///
/// The protocol exists so the picker can be tested without a network or a map framework:
/// `MapKitPlaceSearchService` is the only implementation that talks to MapKit.
@MainActor
protocol PlaceSearchService {
  /// Streams suggestions for `query`, emitting a new array each time results arrive.
  /// Starting a new search finishes the previous stream.
  ///
  /// A query that simply matches nothing yields an empty array; the stream only fails when
  /// the search itself does, so "no results" and "search broke" stay distinguishable.
  /// - Throws: `AppError.placeSearchFailed` when the search fails.
  func suggestions(for query: String) -> AsyncThrowingStream<[PlaceSuggestion], any Error>

  /// Resolves a suggestion into a complete place.
  /// - Throws: `AppError.placeNotResolved` when the suggestion is unknown or has no result,
  ///   or `AppError.placeSearchFailed` when the lookup itself fails.
  func resolve(suggestionID: PlaceSuggestion.ID) async throws -> Place
}
