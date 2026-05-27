//
//  Race.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import Foundation

struct Race: Codable, Identifiable {
  let id: String
  var name: String
  var photoUrl: String?
  var location: GeoLocation
  var websiteUrl: String?
  var editionCount: Int
  var createdBy: String
  var createdAt: Date
  var updatedAt: Date

  init(
    id: String = UUID().uuidString,
    name: String,
    photoUrl: String? = nil,
    location: GeoLocation,
    websiteUrl: String? = nil,
    editionCount: Int = 0,
    createdBy: String,
    createdAt: Date = .now,
    updatedAt: Date = .now
  ) {
    self.id = id
    self.name = name
    self.photoUrl = photoUrl
    self.location = location
    self.websiteUrl = websiteUrl
    self.editionCount = editionCount
    self.createdBy = createdBy
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
}
