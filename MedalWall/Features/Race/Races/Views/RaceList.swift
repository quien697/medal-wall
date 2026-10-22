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
  /// Whether a row can be swiped away; off while the list reloads.
  let canDelete: Bool
  let onDelete: (Race) -> Void

  var body: some View {
    Group {
      if races.isEmpty && searchText.isEmpty {
        EmptyState(
          title: "No Race Events", description: "Tap the + button to add your first race event!")
      } else if races.isEmpty {
        RaceNoResultState(searchText: searchText)
      } else {
        List(races) { race in
          NavigationLink {
            RaceDetailView(race: race)
          } label: {
            RaceRow(
              photoUrl: race.photoUrl,
              name: race.name,
              place: race.place.formatted,
              editionCount: race.editionCount
            )
          }  // NavigationLink
          .listRowBackground(Color.Surface.primary)
          // A list row is a card, though not drawn by `surfaceStyle()`.
          .environment(\.skeletonSurface, .card)
          .swipeActions(edge: .trailing) {
            if canDelete {
              Button(role: .destructive) {
                onDelete(race)
              } label: {
                Label("Delete", systemImage: "trash")
              }  // Button
            }
          }
        }  // List
        .scrollContentBackground(.hidden)
      }
    }  // Group
  }
}

#Preview("Races") {
  RaceList(races: Race.sampleData, searchText: "", canDelete: true, onDelete: { _ in })
}

#Preview("Empty") {
  RaceList(races: [], searchText: "", canDelete: true, onDelete: { _ in })
}

#Preview("Loading") {
  RaceList(races: Race.placeholders, searchText: "", canDelete: true, onDelete: { _ in })
    .skeleton(true)
}

#Preview("No Search Results") {
  RaceList(races: [], searchText: "XYZ Marathon", canDelete: true, onDelete: { _ in })
}
