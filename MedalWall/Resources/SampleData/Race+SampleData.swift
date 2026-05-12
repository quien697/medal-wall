//
//  Race+SampleData.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import Foundation
import UIKit

extension Race {
  @MainActor
  static let sampleData: [Race] = {
    let userID = "preview"

    let taipei: Race = Race(
      name: "Taipei Marathon",
      photoData: UIImage(named: "taipei-marathon")?.jpegData(compressionQuality: 0.9),
      location: RaceLocation(
        country: "Taiwan",
        city: "Taipei"
      ),
      url: "taipeicitymarathon.com",
      createdBy: userID
    )
    
    let taipeiDate2019 = DateComponents(calendar: .current, year: 2019, month: 12, day: 15)
    let taipei2019: RaceEdition = RaceEdition(
      year: taipeiDate2019.year!,
      startDate: taipeiDate2019.date!,
      endDate: taipeiDate2019.date!,
      photoData: UIImage(named: "taipei-marathon-2019")?.jpegData(compressionQuality: 0.9),
      createdBy: userID,
      race: taipei,
      categories: []
    )
    
    let taipeiDate2020 = DateComponents(calendar: .current, year: 2020, month: 12, day: 20)
    let taipei2020: RaceEdition = RaceEdition(
      year: taipeiDate2020.year!,
      startDate: taipeiDate2020.date!,
      endDate: taipeiDate2020.date!,
      createdBy: userID,
      race: taipei,
      categories: []
    )
    
    let taipeiStartDate2025 = DateComponents(calendar: .current, year: 2025, month: 12, day: 20)
    let taipeiEndDate2025 = DateComponents(calendar: .current, year: 2025, month: 12, day: 21)
    let taipei2025: RaceEdition = RaceEdition(
      year: taipeiStartDate2025.year!,
      startDate: taipeiStartDate2025.date!,
      endDate: taipeiEndDate2025.date!,
      createdBy: userID,
      race: taipei,
      categories: []
    )
    
    taipei.editions = [taipei2019, taipei2020, taipei2025]
    
    taipei2019.categories = [
      RaceCategory(
        distance: RaceDistance(category: .full, type: .inPerson),
        raceEdition: taipei2019
      ),
      RaceCategory(
        distance: RaceDistance(category: .half, type: .inPerson),
        raceEdition: taipei2019
      ),
    ]
    
    taipei2020.categories = [
      RaceCategory(
        distance: RaceDistance(category: .full, type: .inPerson),
        raceEdition: taipei2020
      ),
      RaceCategory(
        distance: RaceDistance(category: .half, type: .inPerson),
        raceEdition: taipei2020
      ),
    ]
    
    taipei2025.categories = [
      RaceCategory(
        distance: RaceDistance(category: .full, type: .inPerson),
        raceEdition: taipei2019
      ),
      RaceCategory(
        distance: RaceDistance(category: .half, type: .inPerson),
        raceEdition: taipei2019
      ),
      RaceCategory(
        distance: RaceDistance(category: .half, type: .virtual),
        raceEdition: taipei2019
      )
    ]
    
    let vancouver: Race = Race(
      name: "BMO Vancouver Marathon",
      photoData: UIImage(named: "bmo-vancouver-marathon")?.pngData(),
      location: RaceLocation(
        country: "Canada",
        province: "BC",
        city: "Vancouver"
      ),
      url: "bmovanmarathon.ca/",
      createdBy: userID
    )
    
    let vancouverDate2022 = DateComponents(calendar: .current, year: 2022, month: 5, day: 1)
    let vancouver2022: RaceEdition = RaceEdition(
      year: vancouverDate2022.year!,
      startDate: vancouverDate2022.date!,
      endDate: vancouverDate2022.date!,
      createdBy: userID,
      race: vancouver,
      categories: []
    )
    
    let vancouverDate2026 = DateComponents(calendar: .current, year: 2026, month: 5, day: 3)
    let vancouver2026: RaceEdition = RaceEdition(
      year: vancouverDate2026.year!,
      startDate: vancouverDate2026.date!,
      endDate: vancouverDate2026.date!,
      createdBy: userID,
      race: vancouver,
      categories: []
    )
    
    vancouver.editions = [vancouver2022, vancouver2026]
    
    vancouver2022.categories = [
      RaceCategory(
        distance: RaceDistance(category: .full, type: .inPerson),
        raceEdition: vancouver2022
      ),
      RaceCategory(
        distance: RaceDistance(category: .half, type: .inPerson),
        raceEdition: vancouver2022
      ),
      RaceCategory(
        distance: RaceDistance(category: .custom(8.0), type: .inPerson),
        raceEdition: vancouver2022
      ),
      RaceCategory(
        distance: RaceDistance(category: .full, type: .virtual),
        raceEdition: vancouver2022
      ),
      RaceCategory(
        distance: RaceDistance(category: .half, type: .virtual),
        raceEdition: vancouver2022
      ),
      RaceCategory(
        distance: RaceDistance(category: .custom(8.0), type: .virtual),
        raceEdition: vancouver2022
      ),
      RaceCategory(
        distance: RaceDistance(category: .`5KM`, type: .virtual),
        raceEdition: vancouver2022
      )
    ]

    vancouver2026.categories = [
      RaceCategory(
        distance: RaceDistance(category: .full, type: .inPerson),
        raceEdition: vancouver2026
      ),
      RaceCategory(
        distance: RaceDistance(category: .half, type: .inPerson),
        raceEdition: vancouver2026
      ),
      RaceCategory(
        distance: RaceDistance(category: .custom(8.0), type: .inPerson),
        raceEdition: vancouver2026
      )
    ]
    
    return [taipei, vancouver]
  }()
}
