//
//  RaceList.swift
//  MedalWall
//
//  Created by Quien on 2026-03-20.
//

import SwiftUI

struct RaceList: View {
  let races: [Race]

  var body: some View {
    Group {
      if races.isEmpty {
        EmptyState(
          title: "No Race Events", description: "Tap the + button to add your first race event!")
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
        }  // List
        .scrollContentBackground(.hidden)
      }
    }  // Group
  }
}

#Preview("Races") {
  RaceList(races: Race.sampleData)
}

#Preview("Empty") {
  RaceList(races: [])
}

#Preview("Loading") {
  RaceList(races: Race.placeholders)
    .skeleton(true)
}
