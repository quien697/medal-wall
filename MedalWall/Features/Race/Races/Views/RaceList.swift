//
//  RaceList.swift
//  MedalWall
//
//  Created by Quien on 2026-03-20.
//

import SwiftUI
import SwiftData

struct RaceList: View {
  let searchText: String
  let applyFilter: ([Race]) -> [Race]
  let onDelete: (Race) -> Void
  
  @Query private var races: [Race]
  
  init(
    searchText: String = "",
    predicate: Predicate<Race>,
    sortOrder: [SortDescriptor<Race>],
    applyFilter: @escaping ([Race]) -> [Race] = { $0 },
    onDelete: @escaping (Race) -> Void = { _ in }
  ) {
    self.searchText = searchText
    self.applyFilter = applyFilter
    self.onDelete = onDelete
    
    _races = Query(
      filter: predicate,
      sort: sortOrder
    )
  }
  
  var body: some View {
    Group {
      if races.isEmpty && searchText.isEmpty {
        ContentUnavailableView(
          "No Race evnets",
          systemImage: "tray",
          description: Text("Tap the + button to add your first race event!")
        )
      } else if (races.isEmpty && !searchText.isEmpty) || (applyFilter(races).isEmpty) {
        ContentUnavailableView {
          Label("No Results", systemImage: "magnifyingglass")
        } description: {
          Text("No race evnets match '\(searchText)'")
        }
      } else {
        List(applyFilter(races)) { race in
          NavigationLink {
            RaceDetailView(race: race)
          } label: {
            RaceRow(
              photo: race.cropPhoto ?? race.photo,
              name: race.name,
              location: race.location.formatted,
              editionCount: race.editions.count
            )
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

#Preview("Sample", traits: .sampleData) {
  RaceList(
    searchText: "",
    predicate: #Predicate<Race> { _ in true },
    sortOrder: [SortDescriptor(\Race.name)]
  )
}

#Preview("Empty") {
  RaceList(
    searchText: "",
    predicate: #Predicate<Race> { _ in true },
    sortOrder: [SortDescriptor(\Race.name)]
  )
}

#Preview("No Search Results") {
  RaceList(
    searchText: "XYZ Marathon",
    predicate: #Predicate<Race> { _ in true },
    sortOrder: [SortDescriptor(\Race.name)]
  )
}

