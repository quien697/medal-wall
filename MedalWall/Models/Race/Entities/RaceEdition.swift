//
//  RaceEdition.swift
//  MedalWall
//
//  Created by Quien on 2026-03-07.
//

import Foundation
import SwiftData

@Model
final class RaceEdition {
  @Attribute(.unique) var id: UUID
  var year: Int
  var startDate: Date
  var endDate: Date
  var photoData: Data?
  var createdBy: String
  var createdDate: Date
  var updatedDate: Date
  
  @Relationship var race: Race
  @Relationship(deleteRule: .cascade, inverse: \RaceCategory.raceEdition)
  var categories: [RaceCategory] = []
  
  init(
    id: UUID = UUID(),
    year: Int,
    startDate: Date,
    endDate: Date,
    photoData: Data? = nil,
    createdBy: String,
    createdDate: Date = .now,
    updatedDate: Date = .now,
    race: Race,
    categories: [RaceCategory]
  ) {
    self.id = id
    self.year = year
    self.startDate = startDate
    self.endDate = endDate
    self.photoData = photoData
    self.createdBy = createdBy
    self.createdDate = createdDate
    self.updatedDate = updatedDate
    self.race = race
    self.categories = categories
  }
}
