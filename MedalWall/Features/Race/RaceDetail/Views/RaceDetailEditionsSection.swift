//
//  RaceDetailEditionsSection.swift
//  MedalWall
//
//  Created by Quien on 2026-03-16.
//

import SwiftUI

struct RaceDetailEditionsSection: View {
  let editions: [RaceEdition]

  var body: some View {
    SectionContainer(title: "Editions") {
      if editions.isEmpty {
        ContentUnavailableView {
          Label("No Editions", systemImage: "tray")
            .font(.TypeScale.headline)
            .foregroundStyle(Color.Text.secondary)

          Text("Add editions to track your race history.")
            .font(.TypeScale.body)
            .foregroundStyle(Color.Text.secondary)
        }
        .surfaceStyle()
      } else {
        ForEach(editions.sorted(by: { $0.startDate > $1.startDate })) { edition in
          VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
              Text(String(edition.year))
                .font(.TypeScale.Numeric.medium)
                .foregroundStyle(Color.Text.primary)

              Text(edition.dateDisplayLabel)
                .font(.TypeScale.caption)
                .foregroundStyle(Color.Text.tertiary)

              Spacer()
            }  // HStack

            HStack(alignment: .top, spacing: 14) {
              PhotoImage(urlString: edition.photoUrl, as: .raceThumbnail)

              FlowLayout(spacing: 6) {
                ForEach(edition.distances.sorted()) { distance in
                  Text(distance.displayLabel)
                    .tagStyle(.neutralInCard)
                }
              }  // FlowLayout

              Spacer()
            }  // HStack
          }  // VStack
          .surfaceStyle()
        }  // ForEach
      }
    }  // SectionContainer
  }
}

#Preview("Sample") {
  ScrollView {
    RaceDetailEditionsSection(editions: RaceEdition.sampleData)
  }
}

#Preview("Empty") {
  ScrollView {
    RaceDetailEditionsSection(editions: [])
  }
}
