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
  var bibNumber: Int
  var photoData: Data?
  var cropPhotoData: Data?

  // MARK: - Location
  var country: String
  var province: String?
  var city: String
  var district: String?

  // MARK: - Race category
  var raceDistance: Double
  var raceType: String

  // MARK: - Result
  var finishTime: TimeInterval?
  
  var overallPlacement: Int?
  var totalParticipants: Int?
  
  var division: String?
  var divisionPlacement: Int?
  var divisionTotal: Int?
  
  var genderPlacement: Int?
  var genderTotal: Int?

  // MARK: - Meta
  var note: String?
  var tags: [String]

  @Relationship var user: User
  @Relationship(deleteRule: .cascade, inverse: \EventPhotos.medal)
  var eventPhotos: [EventPhotos] = []

  init(
    id: UUID = UUID(),
    title: String,
    date: Date,
    bibNumber: Int,
    photoData: Data? = nil,
    cropPhotoData: Data? = nil,
    location: RaceLocation,
    raceCategory: RaceCategory,
    finishTime: TimeInterval? = nil,
    overallPlacement: Int? = nil,
    totalParticipants: Int? = nil,
    division: Division? = nil,
    divisionPlacement: Int? = nil,
    divisionTotal: Int? = nil,
    genderPlacement: Int? = nil,
    genderTotal: Int? = nil,
    note: String? = nil,
    tags: [String] = [],
    user: User,
    eventPhotos: [EventPhotos]
  ) {
    self.id = id
    self.title = title
    self.date = date
    self.bibNumber = bibNumber
    self.photoData = photoData
    self.cropPhotoData = cropPhotoData
    self.country = location.country
    self.province = location.province
    self.city = location.city
    self.district = location.district
    self.raceDistance = raceCategory.distance
    self.raceType = raceCategory.type
    self.finishTime = finishTime
    self.overallPlacement = overallPlacement
    self.totalParticipants = totalParticipants
    self.division = division?.rawValue
    self.divisionPlacement = divisionPlacement
    self.divisionTotal = divisionTotal
    self.genderPlacement = genderPlacement
    self.genderTotal = genderTotal
    self.note = note
    self.tags = tags
    self.user = user
    self.eventPhotos = eventPhotos
  }
}
