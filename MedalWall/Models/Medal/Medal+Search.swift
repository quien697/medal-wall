//
//  Medal+Search.swift
//  MedalWall
//
//  Created by Quien on 2026-10-25.
//

import Foundation

extension Array where Element == Medal {
  /// The medals whose name or displayed place contains `query` anywhere, ignoring case and
  /// diacritics, most recent first.
  ///
  /// The place is matched as `place.formatted` renders it, so a medal is found by the text
  /// its row shows.
  func matching(_ query: String) -> [Medal] {
    filter { medal in
      medal.name.localizedStandardContains(query)
        || medal.place.formatted.localizedStandardContains(query)
    }
    .sortedForDisplay
  }
}
