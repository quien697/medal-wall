//
//  RaceDetailEditionsSection.swift
//  MedalWall
//
//  Created by Quien on 2026-03-16.
//

import SwiftUI

struct RaceDetailEditionsSection: View {
  /// The editions to show: placeholders while they load.
  let editions: [RaceEdition]
  /// Shows the editions as bones, under the real title, while they load.
  let isShowingSkeleton: Bool

  var body: some View {
    PageSection(title: "Editions") {
      if editions.isEmpty {
        ContentUnavailableView {
          Label("No Editions", systemImage: "tray")
            .font(.TypeScale.headline)
            .foregroundStyle(Color.Text.secondary)

          Text("Add editions to track your race history.")
            .font(.TypeScale.body)
            .foregroundStyle(Color.Text.secondary)
        }  // ContentUnavailableView
        .surfaceStyle()
      } else {
        VStack(spacing: .Space.gutter) {
          ForEach(editions) { edition in
            editionCard(edition)
          }  // ForEach
        }  // VStack
        .skeleton(isShowingSkeleton)
      }
    }  // PageSection
  }

  /// One edition: its year and dates above its logo and distances.
  private func editionCard(_ edition: RaceEdition) -> some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack(spacing: 10) {
        Text(String(edition.year))
          .font(.TypeScale.Numeric.medium)
          .foregroundStyle(Color.Text.primary)
          .skeletonBone(.numericMedium)

        Text(edition.dateDisplayLabel)
          .font(.TypeScale.caption)
          .foregroundStyle(Color.Text.tertiary)
          .skeletonBone(.caption)

        Spacer()
      }  // HStack

      HStack(alignment: .top, spacing: 14) {
        PhotoImage(urlString: edition.photoUrl, as: .raceThumbnail)

        FlowLayout(spacing: 6) {
          ForEach(edition.raceEvents.sorted(), id: \.self) { distance in
            Text(distance.displayLabel)
              .tagStyle(.neutralInCard)
          }  // ForEach
        }  // FlowLayout

        Spacer()
      }  // HStack
    }  // VStack
    .surfaceStyle()
  }
}

#Preview("Sample") {
  ScrollView {
    RaceDetailEditionsSection(editions: RaceEdition.sampleData, isShowingSkeleton: false)
  }
}

#Preview("Empty") {
  ScrollView {
    RaceDetailEditionsSection(editions: [], isShowingSkeleton: false)
  }
}

#Preview("Loading") {
  ScrollView {
    RaceDetailEditionsSection(editions: RaceEdition.placeholders, isShowingSkeleton: true)
  }
  .background(Color.Background.primary)
}
