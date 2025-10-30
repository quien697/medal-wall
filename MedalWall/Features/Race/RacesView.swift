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
  
  var body: some View {
    NavigationSplitView {
      List {
        ForEach(races) { race in
          NavigationLink {
            Text("Race Detail")
            
            Text(race.name)
              .font(.headline)
          } label: {
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
        .onDelete(perform: deleteRaces)
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          EditButton()
        }
        ToolbarItem {
          Button(action: addRace) {
            Label("Add Item", systemImage: "plus")
          }
        }
      }
    } detail: {
      Text("Select an item")
    }
  }
  
  private func addRace() {
    withAnimation {
      let newRace = Race(
        id: UUID(),
        name: "New Race Number \(Range(1...100).randomElement()!)",
        date: Date(),
        location: RaceLocation(
          country: "Taiwan",
          city: "Taipei"
        ),
        categories: []
      )
      modelContext.insert(newRace)
    }
  }
  
  private func deleteRaces(offsets: IndexSet) {
    withAnimation {
      for index in offsets {
        modelContext.delete(races[index])
      }
    }
  }
}

#Preview {
  RacesView()
    .modelContainer(for: Race.self, inMemory: true)
}
