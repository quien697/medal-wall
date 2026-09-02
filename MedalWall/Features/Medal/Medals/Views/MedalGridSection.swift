//
//  MedalGridSection.swift
//  MedalWall
//
//  Created by Quien on 2026-04-02.
//

import SwiftUI

struct MedalGridSection: View {
  let medals: [Medal]
  let columns: [GridItem]
  let spacing: CGFloat
  let namespace: Namespace.ID

  var body: some View {
    PageSection {
      LazyVGrid(columns: columns, spacing: spacing) {
        ForEach(medals, id: \.id) { medal in
          NavigationLink {
            MedalDetailView(medal: medal)
              .navigationTransition(.zoom(sourceID: medal.id, in: namespace))
          } label: {
            MedalCard(
              photoUrl: medal.photoUrl,
              distance: medal.distance.displayLabel,
              name: medal.name,
              finishTime: medal.finishTime?.formattedHMS ?? "-",
              date: medal.date.formattedMonthDayYear()
            )
            .matchedTransitionSource(id: medal.id, in: namespace)
          }
          .buttonStyle(.plain)
        }
      }  // LazyVGrid
    }  // PageSection
  }
}

#Preview {
  @Previewable @Namespace var namespace

  MedalGridSection(
    medals: Medal.sampleData,
    columns: [GridItem](repeating: GridItem(.flexible(minimum: 80), spacing: 16), count: 2),
    spacing: 16,
    namespace: namespace
  )
  .background(Color.Background.primary)
}
