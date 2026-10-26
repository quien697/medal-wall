//
//  Race+Search.swift
//  MedalWall
//
//  Created by Quien on 2026-10-25.
//

import Foundation

extension Array where Element == Race {
  /// The races whose name or displayed place contains `query` anywhere, ignoring case and
  /// diacritics: races whose name matches first, then races that match only by place, each
  /// group A→Z.
  ///
  /// The place is matched as `place.formatted` renders it, so a race is found by the text
  /// its row shows. Equal names are ordered by `id`, so Firestore's unordered results never
  /// swap them between loads.
  func matching(_ query: String) -> [Race] {
    var nameMatches: [Race] = []
    var placeMatches: [Race] = []

    for race in self {
      if race.name.localizedStandardContains(query) {
        nameMatches.append(race)
      } else if race.place.formatted.localizedStandardContains(query) {
        placeMatches.append(race)
      }
    }

    let byName: (Race, Race) -> Bool = { lhs, rhs in
      let order = lhs.name.localizedCompare(rhs.name)
      return order == .orderedSame ? lhs.id < rhs.id : order == .orderedAscending
    }

    return nameMatches.sorted(by: byName) + placeMatches.sorted(by: byName)
  }
}
