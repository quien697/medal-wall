//
//  RaceList.swift
//  MedalWall
//
//  Created by Quien on 2026-03-20.
//

import SwiftUI

struct RaceList: View {
  let races: [Race]
  let searchText: String
  let onDelete: (Race) -> Void

  var body: some View {
    Group {
      if races.isEmpty && searchText.isEmpty {
        RaceEmptyView()
      } else if races.isEmpty {
        RaceNoResultView(searchText: searchText)
      } else {
        List(races) { race in
          NavigationLink {
            RaceDetailView(race: race)
          } label: {
            RaceRow(
              photoUrl: race.photoUrl,
              name: race.name,
              location: race.location.formatted,
              editionCount: 0
            )
          } // NavigationLink
          .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
              onDelete(race)
            } label: {
              Label("Delete", systemImage: "trash")
            }
          }
        }
        .scrollContentBackground(.hidden)
      }
    } // Group
  }
}

#Preview("Races") {
  RaceList(races: Race.sampleData, searchText: "", onDelete: { _ in })
}

#Preview("Empty") {
  RaceList(races: [], searchText: "", onDelete: { _ in })
}

#Preview("No Search Results") {
  RaceList(races: [], searchText: "XYZ Marathon", onDelete: { _ in })
}
