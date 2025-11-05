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
  var title: String
  var date: Date
  var result: String?
  var medalPhoto: String?
  var note: String?
  
  @Relationship var user: User
  @Relationship var raceCategory: RaceCategory
  
  init(
    id: UUID = UUID(),
    title: String,
    date: Date,
    result: String? = nil,
    medalPhoto: String? = nil,
    note: String? = nil,
    user: User,
    raceCategory: RaceCategory
  ) {
    self.id = id
    self.title = title
    self.date = date
    self.result = result
    self.medalPhoto = medalPhoto
    self.note = note
    self.user = user
    self.raceCategory = raceCategory
  }
}
