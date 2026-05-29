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
  var distances: [RaceDistance]
  var createdBy: String
  var createdAt: Date
  var updatedAt: Date

  // MARK: - Init
  init(
    id: String = UUID().uuidString,
    raceId: String,
    year: Int,
    startDate: Date,
    endDate: Date,
    photoUrl: String? = nil,
    distances: [RaceDistance] = [],
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
    self.distances = distances
    self.createdBy = createdBy
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }

  // MARK: - Computed
  var isOneDay: Bool {
    Calendar.current.isDate(startDate, inSameDayAs: endDate)
  }

  var dateDisplayLabel: String {
    let start = startDate.formattedMonthDay()
    let end = ", \(endDate.formattedMonthDay())"
    return "\(start)\(isOneDay ? "" : end)"
  }
}
