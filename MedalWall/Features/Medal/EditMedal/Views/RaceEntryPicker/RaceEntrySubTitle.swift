//
//  RaceEntrySubTitle.swift
//  MedalWall
//
//  Created by Quien on 2026-04-16.
//

import SwiftUI

struct RaceEntrySubTitle: View {
  let selection: RaceEntry?

  var body: some View {
    Group {
      if let selection {
        Text(selection.selectionLabel)
          .font(.subheadline)
          .foregroundStyle(Color.Gold.primary)
          .fontWeight(.semibold)
          .frame(maxWidth: .infinity, alignment: .leading)
      } else {
        Text("Tap a distance to select the race entry.")
          .font(.subheadline)
          .foregroundStyle(Color.Text.tertiary)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
    .animation(.easeInOut(duration: 0.2), value: selection?.selectionLabel)
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
  }
}

#Preview {
  let edition = RaceEdition.taipei2019
  let distance = edition.distances.first!

  RaceEntrySubTitle(selection: nil)

  RaceEntrySubTitle(selection: RaceEntry(race: Race.taipei, edition: edition, distance: distance))
}
