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
  let event: RaceEvent

  var selectionLabel: String {
    .appLocalized("\(race.name) \(String(edition.year)) (\(event.displayLabel)) selected")
  }
}
