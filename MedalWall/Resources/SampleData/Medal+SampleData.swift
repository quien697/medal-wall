//
//  DefaultMedals.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import UIKit

extension Medal {
  static let sampleData: [Medal] = {
    let taipeiMedal2019 = Medal(
      name: "Sample \(Race.taipei.name) \(RaceEdition.taipei2019.year)",
      date: RaceEdition.taipei2019.startDate,
      bibNumber: "00001",
      place: Race.taipei.place,
      distance: RaceEdition.taipei2019.distances[0],
      finishTime: 3 * 3600 + 30 * 60 + 24,
      overallPlacement: 1058,
      totalParticipants: 7373,
      division: Division(gender: .male, ageGroup: .from30to34),
      divisionPlacement: 523,
      divisionTotal: 1633,
      genderPlacement: 233,
      genderTotal: 6081,
      note: "The weather was good, not too much up hill and down hill.",
      tags: ["Taipei", "台北", "Full Marathon", "全馬"],
      userID: "preview"
    )

    let vancouverMedal = Medal(
      name: "Sample \(Race.vancouver.name) \(RaceEdition.vancouver2022.year)",
      date: RaceEdition.vancouver2022.startDate,
      bibNumber: "2814",
      place: Race.vancouver.place,
      distance: RaceEdition.vancouver2022.distances.first ?? .default,
      userID: "preview"
    )

    let taipeiHalfMedal = Medal(
      name: "Sample \(Race.taipei.name) Half \(RaceEdition.taipei2019.year)",
      date: RaceEdition.taipei2019.startDate,
      bibNumber: "00002",
      place: Race.taipei.place,
      distance: RaceEdition.taipei2019.distances[1],
      finishTime: 1 * 3600 + 45 * 60 + 30,
      overallPlacement: 142,
      totalParticipants: 12450,
      division: Division(gender: .male, ageGroup: .from30to34),
      divisionPlacement: 71,
      divisionTotal: 2890,
      genderPlacement: 121,
      genderTotal: 9120,
      note: "Strong negative split.",
      tags: ["Taipei", "台北", "Half Marathon", "半馬"],
      userID: "preview"
    )

    return [taipeiMedal2019, taipeiHalfMedal, vancouverMedal]
  }()
}
