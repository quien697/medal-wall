//
//  DefaultMedals.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import UIKit

extension Medal {
  @MainActor
  static let sampleData: [Medal] = {
    let user = User.defaultUser
    
    let taipeiRace = Race.sampleData[0] // taipei marathon
    let taiepiRaceEdition2019 = taipeiRace.editions[0]
    let taipeiMedal2019: Medal = Medal(
      title: "\(taipeiRace.name) \(taiepiRaceEdition2019.year)",
      date: taiepiRaceEdition2019.startDate,
      bibNumber: "05180",
      photoData: UIImage(named: "taipei-marathon-medal-2019")?.jpegData(compressionQuality: 0.9),
      location: taipeiRace.location,
      raceDistance: taiepiRaceEdition2019.distances[0], // in-person 42km
      overallPlacement: 6680,
      totalParticipants: 7373,
      division: Division(gender: .male, ageGroup: .from30to34),
      divisionPlacement: 1487,
      divisionTotal: 1633,
      genderPlacement: 5539,
      genderTotal: 6081,
      user: user
    )
    
    let taiepiRaceEdition2020 = taipeiRace.editions[1]
    let taipeiMedal2020: Medal = Medal(
      title: "\(taipeiRace.name) \(taiepiRaceEdition2020.year)",
      date: taiepiRaceEdition2020.startDate,
      bibNumber: "05180",
      photoData: UIImage(named: "taipei-marathon-medal-2020")?.jpegData(compressionQuality: 0.9),
      location: taipeiRace.location,
      raceDistance: taiepiRaceEdition2020.distances[0], // in-person 42km
      overallPlacement: 6680,
      totalParticipants: 7373,
      division: Division(gender: .male, ageGroup: .from30to34),
      divisionPlacement: 1487,
      divisionTotal: 1633,
      genderPlacement: 5539,
      genderTotal: 6081,
      user: user
    )
    
    let taiepiRaceEdition2025 = taipeiRace.editions[2]
    let taipeiMedal2025: Medal = Medal(
      title: "\(taipeiRace.name) \(taiepiRaceEdition2025.year)",
      date: taiepiRaceEdition2025.startDate,
      bibNumber: "00001",
      photoData: UIImage(named: "taipei-marathon-medal-2025")?.jpegData(compressionQuality: 0.9),
      location: taipeiRace.location,
      raceDistance: taiepiRaceEdition2025.distances[1], // in-person 21km
      user: user
    )
    
    let vancouverRace = Race.sampleData[1] // vancouver marathon
    let vancouverRaceEdition = vancouverRace.editions[0] // 2020 edition
    let vancouverMedal: Medal = Medal(
      title: "\(vancouverRace.name) \(vancouverRaceEdition.year)",
      date: vancouverRaceEdition.startDate,
      bibNumber: "2814",
      location: vancouverRace.location,
      raceDistance: vancouverRaceEdition.distances.first!,
      user: user
    )
    
    return [taipeiMedal2019, taipeiMedal2020, taipeiMedal2025, vancouverMedal]
  }()
}
