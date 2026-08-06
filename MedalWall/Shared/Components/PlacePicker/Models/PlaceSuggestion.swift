//
//  PlaceSuggestion.swift
//  MedalWall
//
//  Created by Quien on 2026-08-05.
//

import Foundation

/// One row in the place search results.
///
/// Deliberately holds no provider type. The search provider keeps whatever object it needs
/// internally and hands back only this, so nothing above `PlaceSearchService` depends on
/// MapKit and the picker can be tested against a stub.
struct PlaceSuggestion: Identifiable, Hashable, Sendable {
  let id: String
  let title: String
  let subtitle: String
}
