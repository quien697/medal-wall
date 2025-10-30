//
//  Medal.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import Foundation
import SwiftData

@Model
final class Medal {
  @Attribute(.unique) var id: UUID
  @Relationship var user: User
  @Relationship var category: RaceCategory
  var result: String?
  var medalPhoto: String?
  var eventPhotos: [String] = []
  var note: String?
  
  init(
    id: UUID,
    user: User,
    category: RaceCategory,
    result: String? = nil,
    medalPhoto: String? = nil,
    eventPhotos: [String],
    note: String? = nil,
  ) {
    self.id = id
    self.user = user
    self.category = category
    self.result = result
    self.medalPhoto = medalPhoto
    self.eventPhotos = eventPhotos
    self.note = note
  }
}
