//
//  RaceEdition.swift
//  MedalWall
//
//  Created by Quien on 2026-03-07.
//

import Foundation

struct RaceEdition: Codable, Identifiable {
  let id: String
  var raceId: String
  var year: Int
  var startDate: Date
  var endDate: Date
  var photoUrl: String?
  /// The events this edition offers, such as Full, Half and 10K. Each one pairs a distance
  /// with a way of taking part. Picking one when adding a medal copies it into the medal's
  /// `event`, so the medal keeps its own copy.
  var events: [RaceEvent]
  var createdBy: String
  var createdAt: Date
  var updatedAt: Date

  init(
    id: String = UUID().uuidString,
    raceId: String,
    year: Int,
    startDate: Date,
    endDate: Date,
    photoUrl: String? = nil,
    events: [RaceEvent] = [],
    createdBy: String,
    createdAt: Date = .now,
    updatedAt: Date = .now
  ) {
    self.id = id
    self.raceId = raceId
    self.year = year
    self.startDate = startDate
    self.endDate = endDate
    self.photoUrl = photoUrl
    self.events = events
    self.createdBy = createdBy
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
}
