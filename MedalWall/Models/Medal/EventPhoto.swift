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
