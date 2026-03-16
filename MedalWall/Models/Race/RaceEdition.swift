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
  var date: Date
  var photoData: Data?
  var cropPhotoData: Data?
  var createBy: UUID
  var createdDate: Date
  var updatedDate: Date
  
  @Relationship var race: Race
  @Relationship(deleteRule: .cascade, inverse: \RaceCategory.raceEdition)
  var categories: [RaceCategory] = []
  
  init(
    id: UUID = UUID(),
    year: Int,
    date: Date,
    photoData: Data? = nil,
    cropPhotoData: Data? = nil,
    createBy: UUID,
    createdDate: Date = .now,
    updatedDate: Date = .now,
    race: Race,
    categories: [RaceCategory]
  ) {
    self.id = id
    self.year = year
    self.date = date
    self.photoData = photoData
    self.cropPhotoData = cropPhotoData
    self.createBy = createBy
    self.createdDate = createdDate
    self.updatedDate = updatedDate
    self.race = race
    self.categories = categories
  }
}
