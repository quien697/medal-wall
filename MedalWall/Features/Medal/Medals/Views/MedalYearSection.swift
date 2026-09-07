//
//  MedalYearSection.swift
//  MedalWall
//
//  Created by Quien on 2026-09-07.
//

import SwiftUI

/// One year of the collection: its header, then every medal earned that year.
struct MedalYearSection: View {
  // MARK: - Properties
  let group: MedalYearGroup
  let personalRecordIDs: Set<String>
  let namespace: Namespace.ID

  // MARK: - Body
  var body: some View {
    VStack(alignment: .leading, spacing: .Space.row) {
      MedalYearHeader(year: group.year, count: group.medals.count)

      ForEach(group.medals) { medal in
        NavigationLink {
          MedalDetailView(medal: medal)
            .navigationTransition(.zoom(sourceID: medal.id, in: namespace))
        } label: {
          MedalRow(
            photoUrl: medal.photoUrl,
            date: medal.date.formattedMonthDayYear(),
            name: medal.name,
            distance: medal.distance.displayLabel,
            finishTime: medal.finishTime?.formattedHMS,
            isPersonalRecord: personalRecordIDs.contains(medal.id)
          )
          .matchedTransitionSource(id: medal.id, in: namespace)
        }
        .buttonStyle(.plain)
      }
    }  // VStack
  }
}

#Preview {
  @Previewable @Namespace var namespace

  let medals = Medal.sampleData

  NavigationStack {
    ScrollView {
      MedalYearSection(
        group: MedalYearGroup(year: 2022, medals: medals),
        personalRecordIDs: medals.personalRecordIDs,
        namespace: namespace
      )
      .padding()
    }  // ScrollView
    .background(Color.Background.primary)
  }  // NavigationStack
}
