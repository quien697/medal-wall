//
//  MedalPersonalBest.swift
//  MedalWall
//
//  Created by Quien on 2026-09-08.
//

import Foundation

/// The record at one distance: the medal holding it, and the distance it was set at.
///
/// The distance is the identity, not the medal. A faster medal taking the record over must
/// update the card in place rather than replace it — identifying by `medal.id` would tear
/// the card down and re-insert it, which the carousel would show as a jump to another page
/// while the user is reading it.
nonisolated struct MedalPersonalBest: Identifiable {
  var id: Double { category.value }
  let category: RaceDistanceCategory
  let medal: Medal
}

extension Array where Element == MedalPersonalBest {
  /// The page the carousel is currently centred on, for the dots the card draws.
  ///
  /// `scrollPosition` reports `nil` until the first scroll, and a stored position can name
  /// a distance the collection no longer holds. Both resolve to the first page rather than
  /// to no page at all, which would leave every dot dimmed.
  func pageIndex(for scrolledID: MedalPersonalBest.ID?) -> Int {
    guard let scrolledID,
      let page = firstIndex(where: { $0.id == scrolledID })
    else { return 0 }

    return page
  }
}
