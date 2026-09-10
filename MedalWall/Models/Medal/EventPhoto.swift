//
//  EventPhoto.swift
//  MedalWall
//
//  Created by Quien on 2026-04-01.
//

import Foundation

struct EventPhoto: Codable, Identifiable {
  let id: String
  var imageUrl: String
  var caption: String?
  var sortOrder: Int
  var createdAt: Date

  init(
    id: String = UUID().uuidString,
    imageUrl: String,
    caption: String? = nil,
    sortOrder: Int = 0,
    createdAt: Date = .now
  ) {
    self.id = id
    self.imageUrl = imageUrl
    self.caption = caption
    self.sortOrder = sortOrder
    self.createdAt = createdAt
  }
}

extension Array where Element == EventPhoto {
  /// The photos' image URLs in display order — `sortOrder` ascending — so the strip and
  /// the full-screen viewer never disagree about which photo a tap is opening.
  var sortedImageUrls: [String] {
    sorted { $0.sortOrder < $1.sortOrder }.map(\.imageUrl)
  }
}
