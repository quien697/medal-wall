//
//  Race+SampleData.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import Foundation

extension Race {
  static let sampleData: [Race] = {
    [taipei, vancouver, tokyo, boston]
  }()

  static let taipei = Race(
    id: "race-taipei",
    name: "Taipei Marathon",
    location: GeoLocation(country: "Taiwan", city: "Taipei"),
    websiteUrl: "taipeicitymarathon.com",
    createdBy: "preview"
  )

  static let vancouver = Race(
    id: "race-vancouver",
    name: "BMO Vancouver Marathon",
    location: GeoLocation(country: "Canada", province: "BC", city: "Vancouver"),
    websiteUrl: "bmovanmarathon.ca",
    createdBy: "preview"
  )

  static let tokyo = Race(
    id: "race-tokyo",
    name: "Tokyo Marathon",
    location: GeoLocation(country: "Japan", city: "Tokyo"),
    websiteUrl: "marathon.tokyo",
    createdBy: "preview"
  )

  static let boston = Race(
    id: "race-boston",
    name: "Boston Marathon",
    location: GeoLocation(country: "United States", province: "MA", city: "Boston"),
    websiteUrl: "baa.org/races/boston-marathon",
    createdBy: "preview"
  )
}

extension RaceEdition {
  static let sampleData: [RaceEdition] = {
    [taipei2019, taipei2025, vancouver2022, vancouver2026, tokyo2023, boston2024]
  }()

  static let taipei2019 = RaceEdition(
    id: "edition-taipei-2019",
    raceId: "race-taipei",
    year: 2019,
    startDate: DateComponents(calendar: .current, year: 2019, month: 12, day: 15).date!,
    endDate: DateComponents(calendar: .current, year: 2019, month: 12, day: 15).date!,
    distances: [
      RaceDistance(category: .full, type: .inPerson),
      RaceDistance(category: .half, type: .inPerson)
    ],
    createdBy: "preview"
  )

  static let taipei2025 = RaceEdition(
    id: "edition-taipei-2025",
    raceId: "race-taipei",
    year: 2025,
    startDate: DateComponents(calendar: .current, year: 2025, month: 12, day: 20).date!,
    endDate: DateComponents(calendar: .current, year: 2025, month: 12, day: 21).date!,
    distances: [
      RaceDistance(category: .full, type: .inPerson),
      RaceDistance(category: .half, type: .inPerson),
      RaceDistance(category: .half, type: .virtual)
    ],
    createdBy: "preview"
  )

  static let vancouver2022 = RaceEdition(
    id: "edition-vancouver-2022",
    raceId: "race-vancouver",
    year: 2022,
    startDate: DateComponents(calendar: .current, year: 2022, month: 5, day: 1).date!,
    endDate: DateComponents(calendar: .current, year: 2022, month: 5, day: 1).date!,
    distances: [
      RaceDistance(category: .full, type: .inPerson),
      RaceDistance(category: .half, type: .inPerson),
      RaceDistance(category: .custom(8.0), type: .inPerson),
      RaceDistance(category: .full, type: .virtual),
      RaceDistance(category: .half, type: .virtual)
    ],
    createdBy: "preview"
  )

  static let vancouver2026 = RaceEdition(
    id: "edition-vancouver-2026",
    raceId: "race-vancouver",
    year: 2026,
    startDate: DateComponents(calendar: .current, year: 2026, month: 5, day: 3).date!,
    endDate: DateComponents(calendar: .current, year: 2026, month: 5, day: 3).date!,
    distances: [
      RaceDistance(category: .full, type: .inPerson),
      RaceDistance(category: .half, type: .inPerson),
      RaceDistance(category: .custom(8.0), type: .inPerson)
    ],
    createdBy: "preview"
  )

  static let tokyo2023 = RaceEdition(
    id: "edition-tokyo-2023",
    raceId: "race-tokyo",
    year: 2023,
    startDate: DateComponents(calendar: .current, year: 2023, month: 3, day: 5).date!,
    endDate: DateComponents(calendar: .current, year: 2023, month: 3, day: 5).date!,
    distances: [
      RaceDistance(category: .full, type: .inPerson)
    ],
    createdBy: "preview"
  )

  static let boston2024 = RaceEdition(
    id: "edition-boston-2024",
    raceId: "race-boston",
    year: 2024,
    startDate: DateComponents(calendar: .current, year: 2024, month: 4, day: 15).date!,
    endDate: DateComponents(calendar: .current, year: 2024, month: 4, day: 15).date!,
    distances: [
      RaceDistance(category: .full, type: .inPerson)
    ],
    createdBy: "preview"
  )
}
