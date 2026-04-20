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
    let user = User.guest
    
    let taipeiRace = Race.sampleData[0]
    let taiepiRaceEdition2019 = taipeiRace.editions[0]
    let taipeiMedal2019: Medal = Medal(
      name: "Sample \(taipeiRace.name) \(taiepiRaceEdition2019.year)",
      date: taiepiRaceEdition2019.startDate,
      bibNumber: "00001",
      location: taipeiRace.location,
      raceDistance: taiepiRaceEdition2019.distances[0],
      finishTime: 3 * 3600 + 30 * 60 + 24, // 3:30:24
      overallPlacement: 1058,
      totalParticipants: 7373,
      division: Division(gender: .male, ageGroup: .from30to34),
      divisionPlacement: 523,
      divisionTotal: 1633,
      genderPlacement: 233,
      genderTotal: 6081,
      note: "The weather was good, not too much up hill and down hill.",
      tags: ["Taipei", "台北", "Full Marathon", "全馬"],
      user: user
    )
    
    let vancouverRace = Race.sampleData[1] // vancouver marathon
    let vancouverRaceEdition = vancouverRace.editions[0]
    let vancouverMedal: Medal = Medal(
      name: "Sample \(vancouverRace.name) \(vancouverRaceEdition.year)",
      date: vancouverRaceEdition.startDate,
      bibNumber: "2814",
      location: vancouverRace.location,
      raceDistance: vancouverRaceEdition.distances.first!,
      user: user
    )
    
    return [taipeiMedal2019, vancouverMedal]
  }()
}
