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
  @Relationship var race: Race
  var date: Date
  var distance: RaceDistance
  var result: String?
  var medalPhoto: String?
  var eventPhotos: [String] = []
  var note: String?
  @Relationship var user: User
  
  init(
    id: UUID = UUID(),
    title: String,
    race: Race,
    date: Date,
    distance: RaceDistance,
    result: String? = nil,
    medalPhoto: String? = nil,
    eventPhotos: [String],
    note: String? = nil,
    user: User
  ) {
    self.id = id
    self.title = title
    self.race = race
    self.date = date
    self.distance = distance
    self.result = result
    self.medalPhoto = medalPhoto
    self.eventPhotos = eventPhotos
    self.note = note
    self.user = user
  }
}
