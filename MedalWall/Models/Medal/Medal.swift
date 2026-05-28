//
//  Medal.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import Foundation

struct Medal: Codable, Identifiable {
  let id: String
  var name: String
  var date: Date
  var bibNumber: String
  var photoUrl: String?
  var location: GeoLocation
  var distance: RaceDistance
  var finishTime: TimeInterval?
  var overallPlacement: Int?
  var totalParticipants: Int?
  var division: String?
  var divisionPlacement: Int?
  var divisionTotal: Int?
  var genderPlacement: Int?
  var genderTotal: Int?
  var note: String?
  var tags: [String]
  var eventPhotos: [EventPhoto]
  var userID: String
  var createdAt: Date
  var updatedAt: Date

  init(
    id: String = UUID().uuidString,
    name: String,
    date: Date,
    bibNumber: String,
    photoUrl: String? = nil,
    location: GeoLocation,
    distance: RaceDistance,
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
    eventPhotos: [EventPhoto] = [],
    userID: String,
    createdAt: Date = .now,
    updatedAt: Date = .now
  ) {
    self.id = id
    self.name = name
    self.date = date
    self.bibNumber = bibNumber
    self.photoUrl = photoUrl
    self.location = location
    self.distance = distance
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
    self.eventPhotos = eventPhotos
    self.userID = userID
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
}
