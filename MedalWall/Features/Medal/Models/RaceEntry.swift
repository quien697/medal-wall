//
//  RaceEntry.swift
//  MedalWall
//
//  Created by Quien on 2026-04-14.
//

import Foundation

struct RaceEntry {
  let race: Race
  let edition: RaceEdition
  let distance: RaceDistance

  var selectionLabel: String {
    .appLocalized("\(race.name) \(String(edition.year)) (\(distance.displayLabel)) selected")
  }
}
