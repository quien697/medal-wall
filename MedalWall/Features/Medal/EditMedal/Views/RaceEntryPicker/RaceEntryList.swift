//
//  RaceEntryList.swift
//  MedalWall
//
//  Created by Quien on 2026-04-15.
//

import SwiftUI

struct RaceEntryList: View {
  let races: [Race]
  let editions: [String: [RaceEdition]]
  @Binding var selection: RaceEntry?

  var body: some View {
    List(races) { race in
      let raceEditions = editions[race.id] ?? []
      VStack(alignment: .leading) {
        HStack(alignment: .top) {
          RaceImage(
            urlString: race.photoUrl,
            imageType: .raceThumbnail
          )

          VStack(alignment: .leading) {
            Text(race.name)
              .font(.headline)
              .foregroundStyle(Color.Text.primary)

            Text(race.location.formatted)
              .font(.subheadline)
              .foregroundStyle(Color.Text.secondary)

            Text("\(raceEditions.count) editions")
              .font(.subheadline)
              .foregroundStyle(Color.Text.tertiary)
          }  // VStack
        }  // HStack

        if !raceEditions.isEmpty {
          VStack(alignment: .leading, spacing: 16) {
            ForEach(raceEditions.sorted { $0.year > $1.year }) { edition in
              RaceEntryEditionRow(
                race: race,
                edition: edition,
                selection: $selection
              )
            }
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .surfaceStyle(vPadding: 12, hPadding: 12)
        }
      }  // VStack
      .listRowSeparator(.hidden)
    }  // List
    .listStyle(.plain)
  }
}

#Preview {
  let editions: [String: [RaceEdition]] = [
    Race.taipei.id: [RaceEdition.taipei2019, RaceEdition.taipei2025]
  ]
  RaceEntryList(races: Race.sampleData, editions: editions, selection: .constant(nil))
}
