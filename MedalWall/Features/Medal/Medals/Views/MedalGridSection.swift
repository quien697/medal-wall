//
//  MedalGridSection.swift
//  MedalWall
//
//  Created by Quien on 2026-04-02.
//

import SwiftUI
import SwiftData

struct MedalGridSection: View {
  let medals: [Medal]
  let columns: [GridItem]
  let spacing: CGFloat
  
  var body: some View {
    SectionContainer {
      LazyVGrid(columns: columns, spacing: spacing) {
        ForEach(medals, id: \.id) { medal in
          NavigationLink {
            MedalDetailView(medal: medal)
          } label: {
            MedalCard(
              photo: medal.cropPhoto ?? medal.photo,
              distance: medal.distance.displayLabel,
              title: medal.name,
              finishTime: medal.finishTime?.formattedHMS ?? "-",
              date: medal.date.formattedMonthDayYear()
            )
          }
          .buttonStyle(.plain)
        }
      } // LazyVGrid
    } // SectionContainer
  }
}

#Preview {
  MedalGridSection(
    medals: Medal.sampleData,
    columns: [GridItem](repeating: GridItem(.flexible(minimum: 80), spacing: 16), count: 2),
    spacing: 16
  )
  .background(Color.Background.primary)
}
