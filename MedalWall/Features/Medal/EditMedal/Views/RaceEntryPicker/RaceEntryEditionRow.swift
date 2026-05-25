//
//  RaceEntryEditionRow.swift
//  MedalWall
//
//  Created by Quien on 2026-04-16.
//

import SwiftUI

struct RaceEntryEditionRow: View {
  let race: Race
  let edition: RaceEdition
  @Binding var selection: RaceEntry?

  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Text("\(edition.year)")
          .font(.headline)
          .fontWeight(.heavy)
          .foregroundStyle(Color.Gold.primary)

        Text(edition.dateDisplayLabel)
          .font(.subheadline)
          .foregroundStyle(Color.Text.tertiary)
      }  // HStack

      FlowLayout(spacing: 8) {
        ForEach(edition.distances.sorted(), id: \.self) { distance in
          RaceEntryDistanceChip(
            race: race,
            edition: edition,
            distance: distance,
            selection: $selection
          )
        }
      }  // FlowLayout
    }  // VStack
  }
}

#Preview {
  RaceEntryEditionRow(race: Race.taipei, edition: RaceEdition.taipei2019, selection: .constant(nil))
}
