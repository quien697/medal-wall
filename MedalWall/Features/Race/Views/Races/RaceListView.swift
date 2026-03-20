//
//  RaceListView.swift
//  MedalWall
//
//  Created by Quien on 2026-03-20.
//

import SwiftUI
import SwiftData

struct RaceListView: View {
  let searchText: String
  let onDelete: (Race) -> Void
  
  @Query private var races: [Race]
  
  init(
    searchText: String = "",
    predicate: Predicate<Race>,
    sortOrder: [SortDescriptor<Race>],
    onDelete: @escaping (Race) -> Void = { _ in }
  ) {
    self.searchText = searchText
    self.onDelete = onDelete
    
    _races = Query(
      filter: predicate,
      sort: sortOrder
    )
  }
  
  var body: some View {
    Group {
      if races.isEmpty && !searchText.isEmpty {
        ContentUnavailableView {
          Label("No Results", systemImage: "magnifyingglass")
        } description: {
          Text("No race evnets match '\(searchText)'")
        }
      } else if races.isEmpty && searchText.isEmpty {
        ContentUnavailableView(
          "No Race evnets",
          systemImage: "tray",
          description: Text("Tap the + button to add your first race event!")
        )
      } else {
        List(races) { race in
          NavigationLink {
            RaceDetailView(race: race)
          } label: {
            RaceRowView(race: race)
              .swipeActions(edge: .trailing) {
                Button(role: .destructive) {
                  onDelete(race)
                } label: {
                  Label("Delete", systemImage: "trash")
                }
              }
          }
        }
        .scrollContentBackground(.hidden)
      }
    }
    .background(Color.Background.primary)
  }
}

#Preview(traits: .sampleData) {
  RaceListView(
    searchText: "",
    predicate: #Predicate<Race> { _ in true },
    sortOrder: [SortDescriptor(\Race.name)]
  )
}
