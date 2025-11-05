//
//  Race+SampleData.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import Foundation

extension Race {
  @MainActor
  static let sampleData: [Race] = {
    let taipei: Race = Race(
      name: "Taipei Marathon",
      photo: "taipei-marathon",
      date: DateComponents(calendar: .current, year: 2025, month: 12, day: 21).date!,
      location: RaceLocation(
        country: "Taiwan",
        city: "Taipei"
      ),
      type: .road,
      url: "https://taipeicitymarathon.com",
      updateTime: Date(),
      categories: [],
    )
    let vancouver: Race = Race(
      name: "BMO Vancouver Marathon",
      photo: "bmo-vancouver-marathon",
      date: DateComponents(calendar: .current, year: 2026, month: 5, day: 9).date!,
      location: RaceLocation(
        country: "Canada",
        province: "BC",
        city: "Vancouver"
      ),
      type: .road,
      url: "https://bmovanmarathon.ca/",
      updateTime: Date(),
      categories: [],
    )
    
    taipei.categories = [
      RaceCategory(
        distance: RaceDistance(category: .full, type: .inPerson),
        race: taipei
      ),
      RaceCategory(
        distance: RaceDistance(category: .half, type: .inPerson),
        race: taipei
      ),
      RaceCategory(
        distance: RaceDistance(category: .half, type: .virtual),
        race: taipei
      )
    ]
    
    vancouver.categories = [
      RaceCategory(
        distance: RaceDistance(category: .full, type: .inPerson),
        race: vancouver
      ),
      RaceCategory(
        distance: RaceDistance(category: .half, type: .inPerson),
        race: vancouver
      ),
      RaceCategory(
        distance: RaceDistance(category: .`10K`, type: .inPerson),
        race: vancouver
      ),
      RaceCategory(
        distance: RaceDistance(category: .`5K`, type: .inPerson),
        race: vancouver
      ),
    ]
    
    return [taipei, vancouver]
  }()
}
