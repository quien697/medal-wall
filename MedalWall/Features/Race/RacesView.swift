//
//  RacesView.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import SwiftUI
import SwiftData

struct RacesView: View {
  @Environment(\.modelContext) private var modelContext
  @Query private var races: [Race]
  @State private var selectedRace: Race? = nil
  @State private var isShowEditor = false
  
  var body: some View {
    NavigationSplitView {
      List(races, selection: $selectedRace) { race in
        NavigationLink(value: race) {
          VStack(alignment: .leading) {
            Text(race.name)
              .font(.headline)
            Text(race.location.formatted)
              .font(.subheadline)
              .foregroundStyle(.secondary)
            Text(race.date.formatted(date: .abbreviated, time: .omitted))
              .font(.caption)
          }
        }
      }
      .navigationTitle("Races")
    } detail: {
      if let race = selectedRace {
        RaceDetailView(race: race)
      } else {
        Text("Select a race")
      }
    } // NavigationSplitView
  }
}

#Preview {
  RacesView()
    .modelContainer(for: Race.self, inMemory: true)
}
