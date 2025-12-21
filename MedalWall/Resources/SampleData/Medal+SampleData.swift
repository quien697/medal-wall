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
      title: "\(taipeiRace.name) 2020",
      date: taipeiRace.date,
      result: "5:08:08",
      photoData: UIImage(named: "taipei-marathon-2020")?.jpegData(compressionQuality: 0.9),
      note: nil,
      user: User.defaultUser,
      raceCategory: taiepiRaceCategory,
    )
    
    let vancouverRaceCategory = Race.sampleData[1].categories.first(where: { $0.distance == 42.195 })!
    let vancouverRace = vancouverRaceCategory.race
    let vancouverMedal: Medal = Medal(
      title: "\(vancouverRace.name) 2022",
      date: vancouverRace.date,
      result: "4:33:21",
      photoData: UIImage(named: "bmo-vancouver-marathon-2022")?.jpegData(compressionQuality: 0.9),
      note: nil,
      user: User.defaultUser,
      raceCategory: vancouverRaceCategory,
    )
    
    let tokyoRaceCategory = Race.sampleData[1].categories.first(where: { $0.distance == 42.195 })!
    let tokyoRace = vancouverRaceCategory.race
    let tokyoMedal: Medal = Medal(
      title: "\(tokyoRace.name) 2000",
      date: tokyoRace.date,
      result: "3:33:21",
      photoData: UIImage(named: "bmo-vancouver-marathon-2022")?.jpegData(compressionQuality: 0.9),
      note: nil,
      user: User.defaultUser,
      raceCategory: tokyoRaceCategory,
    )
    
    User.defaultUser.medals = [taipeiMedal, vancouverMedal, tokyoMedal]
    
    return [taipeiMedal, vancouverMedal, tokyoMedal]
  }()
}
