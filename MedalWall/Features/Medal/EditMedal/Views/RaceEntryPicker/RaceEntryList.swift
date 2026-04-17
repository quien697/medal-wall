//
//  RaceEntryList.swift
//  MedalWall
//
//  Created by Quien on 2026-04-15.
//

import SwiftUI

struct RaceEntryList: View {
  let races: [Race]
  @Binding var selection: RaceEntry?
  
  var body: some View {
    List(races) { race in
      VStack(alignment: .leading) {
        HStack(alignment: .top) {
          RaceImage(
            photo: race.photo,
            imageType: .raceThumbnail
          )
          
          VStack(alignment: .leading) {
            Text(race.name)
              .font(.headline)
              .foregroundStyle(Color.Text.primary)
            
            Text(race.location.formatted)
              .font(.subheadline)
              .foregroundStyle(Color.Text.secondary)
            
            Text("\(race.editions.count) editions")
              .font(.subheadline)
              .foregroundStyle(Color.Text.tertiary)
          } // VStack
        } // HStack
        
        VStack(alignment: .leading, spacing: 16) {
          ForEach(race.editions.sorted { $0.year > $1.year }) { edition in
            RaceEntryEditionRow(
              race: race,
              edition: edition,
              selection: $selection
            )
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .surfaceStyle(vPadding: 12, hPadding: 12)
      } // VStack
      .listRowSeparator(.hidden)
    } // List
    .listStyle(.plain)
  }
}

#Preview {
  RaceEntryList(races: Race.sampleData, selection: .constant(nil))
}
