//
//  Race+Computed.swift
//  MedalWall
//
//  Created by Quien on 2026-05-27.
//

extension Race {
  var fullWebsiteUrl: String? {
    guard let url = websiteUrl, !url.isEmpty else { return nil }
    return url.hasPrefix("http://") || url.hasPrefix("https://") ? url : "https://\(url)"
  }
}

extension Array where Element == Race {
  /// The races with each `editionCount` clamped to zero or more: the count is maintained
  /// server-side, so a corrupt value must not reach a row and render as "-1 editions".
  var withClampedEditionCounts: [Race] {
    map { race in
      var clamped = race
      clamped.editionCount = Swift.max(0, race.editionCount)
      return clamped
    }
  }
}
