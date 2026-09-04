//
//  RaceEntryDistanceButton.swift
//  MedalWall
//
//  Created by Quien on 2026-04-16.
//

import SwiftUI

struct RaceEntryDistanceButton: View {
  let race: Race
  let edition: RaceEdition
  let distance: RaceDistance
  @Binding var selection: RaceEntry?

  private var isSelected: Bool {
    selection?.race.id == race.id
      && selection?.edition.id == edition.id
      && selection?.distance == distance
  }

  var body: some View {
    Button {
      if isSelected {
        selection = nil
      } else {
        selection = RaceEntry(race: race, edition: edition, distance: distance)
      }
    } label: {
      if isSelected {
        Text(distance.displayLabel)
          .chipStyle(.primary)
      } else {
        Text(distance.displayLabel)
          .chipStyle(.secondary)
      }
    }
    .buttonStyle(.plain)
    .animation(.easeInOut(duration: 0.15), value: isSelected)
  }
}

#Preview {
  let race = Race.taipei
  let edition = RaceEdition.taipei2019
  let distance = edition.distances.first!

  RaceEntryDistanceButton(
    race: race,
    edition: edition,
    distance: distance,
    selection: .constant(nil)
  )

  RaceEntryDistanceButton(
    race: race,
    edition: edition,
    distance: distance,
    selection: .constant(RaceEntry(race: race, edition: edition, distance: distance))
  )
}
