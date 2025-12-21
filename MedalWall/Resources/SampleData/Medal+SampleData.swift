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
    
    let taiepiRaceCategory = Race.sampleData[0].categories.first(where: { $0.distance == 42.195 })!
    let taipeiRace = taiepiRaceCategory.race
    let taipeiMedal: Medal = Medal(
      title: "\(taipeiRace.name)",
      date: taipeiRace.date,
      result: "5:08:08",
      photoData: UIImage(named: "taipei-marathon-2020")?.jpegData(compressionQuality: 0.9),
      note: nil,
      user: User.defaultUser,
      raceCategory: taiepiRaceCategory,
    )
    
    let vancouverRaceCategory = Race.sampleData[1].categories.first(where: { $0.distance == 10 })!
    let vancouverRace = vancouverRaceCategory.race
    let vancouverMedal: Medal = Medal(
      title: "\(vancouverRace.name)",
      date: vancouverRace.date,
      result: "4:33:21",
      photoData: UIImage(named: "bmo-vancouver-marathon-2022")?.jpegData(compressionQuality: 0.9),
      note: nil,
      user: User.defaultUser,
      raceCategory: vancouverRaceCategory,
    )
    
    User.defaultUser.medals = [taipeiMedal, vancouverMedal]
    
    return [taipeiMedal, vancouverMedal]
  }()
}
