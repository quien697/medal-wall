//
//  Race+Computed.swift
//  MedalWall
//
//  Created by Quien on 2026-05-27.
//

extension Race {
  var fullWebsiteUrl: String? {
    guard let url = websiteUrl else { return nil }
    return url.hasPrefix("http://") || url.hasPrefix("https://") ? url : "https://\(url)"
  }
}
