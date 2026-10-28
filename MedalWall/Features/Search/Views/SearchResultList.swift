//
//  SearchResultList.swift
//  MedalWall
//
//  Created by Quien on 2026-10-25.
//

import SwiftUI

/// The search results in one list: the user's matching medals, then the matching races.
///
/// A section with no matches is left out. `List` builds its rows lazily, so neither section
/// is capped.
struct SearchResultList: View {
  let medals: [Medal]
  let races: [Race]
  /// Taken from the whole collection, so a query never promotes a medal into a record.
  let personalRecordIDs: Set<String>

  var body: some View {
    List {
      if !medals.isEmpty {
        Section {
          ForEach(medals) { medal in
            NavigationLink {
              MedalDetailView(medal: medal, personalRecordIDs: personalRecordIDs)
            } label: {
              SearchMedalRow(
                photoUrl: medal.photoUrl,
                date: medal.date.formattedMonthDayYear(),
                name: medal.name,
                place: medal.place.formatted,
                distance: medal.raceEvent.displayLabel
              )
            }  // NavigationLink
            .listRowBackground(Color.Surface.primary)
          }  // ForEach
        } header: {
          SearchSectionHeader(title: "Your Collection", count: medals.count)
        }  // Section
      }

      if !races.isEmpty {
        Section {
          ForEach(races) { race in
            NavigationLink {
              RaceDetailView(race: race)
            } label: {
              SearchRaceRow(
                photoUrl: race.photoUrl,
                name: race.name,
                place: race.place.formatted,
                editionCount: race.editionCount
              )
            }  // NavigationLink
            .listRowBackground(Color.Surface.primary)
          }  // ForEach
        } header: {
          SearchSectionHeader(title: "Races", count: races.count)
        }  // Section
      }
    }  // List
    .scrollContentBackground(.hidden)
  }
}

#Preview("Medals and races") {
  NavigationStack {
    SearchResultList(
      medals: Medal.sampleData,
      races: Race.sampleData,
      personalRecordIDs: Medal.sampleData.personalRecordIDs
    )
    .background(Color.Background.primary)
  }  // NavigationStack
  .environment(UserManager())
}

#Preview("Races only") {
  NavigationStack {
    SearchResultList(medals: [], races: Race.sampleData, personalRecordIDs: [])
      .background(Color.Background.primary)
  }  // NavigationStack
  .environment(UserManager())
}
