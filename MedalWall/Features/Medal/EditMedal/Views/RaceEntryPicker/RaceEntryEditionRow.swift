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
          .font(.TypeScale.Numeric.medium)
          .foregroundStyle(Color.Gold.primary)

        Text(edition.dateDisplayLabel)
          .font(.TypeScale.caption)
          .foregroundStyle(Color.Text.tertiary)
      }  // HStack

      if !edition.distances.isEmpty {
        FlowLayout(spacing: 8) {
          ForEach(edition.distances.sorted(), id: \.self) { distance in
            RaceEntryDistanceButton(
              race: race,
              edition: edition,
              distance: distance,
              selection: $selection
            )
          }
        }  // FlowLayout
      } else {
        Text("No Distances")
          .font(.TypeScale.callout)
          .foregroundStyle(Color.Text.secondary)
          .padding(.vertical, 6)
      }
    }  // VStack
  }
}

#Preview {
  RaceEntryEditionRow(race: Race.taipei, edition: RaceEdition.taipei2019, selection: .constant(nil))
}
