//
//  PlaceSearchStatus.swift
//  MedalWall
//
//  Created by Quien on 2026-08-06.
//

/// What the place search currently has to show.
///
/// One value rather than separate flags, so the list cannot be told two things at once —
/// "searching" and "nothing matched" are no longer independently settable.
///
/// A failed search is deliberately **not** a case here. Failures live in the ViewModel's
/// `error`, which the presenting view bridges to `ErrorView`, and the status falls back to
/// `.idle`. That keeps a dropped connection from rendering as "no such place", which is a
/// different and misleading claim.
enum PlaceSearchStatus: Equatable {
  /// Nothing typed yet, the query was cleared, or a search failed.
  case idle
  /// A search is in flight and has not produced results yet.
  case searching
  /// The search matched at least one place.
  case results([PlaceSuggestion])
  /// The search completed and matched nothing.
  case noResults
}
