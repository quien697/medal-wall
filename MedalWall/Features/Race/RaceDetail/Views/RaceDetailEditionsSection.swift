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
            .font(.subheadline)
            .foregroundStyle(Color.Text.secondary)
          
          Text("Add editions to track your race history.")
            .font(.subheadline)
            .foregroundStyle(Color.Text.tertiary)
        }
        .surfaceStyle()
      } else {
        ForEach(editions.sorted(by: { $0.startDate > $1.startDate })) { edition in
          VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
              Text(String(edition.year))
                .font(.title)
                .fontWeight(.heavy)
                .foregroundStyle(Color.Gold.primary)
              
              Text(edition.dateDisplayLabel)
                .font(.subheadline)
                .foregroundStyle(Color.Text.tertiary)
              
              Spacer()
            } // HStack
            
            HStack(alignment: .top, spacing: 20) {
              RaceImage(urlString: edition.photoUrl, imageType: .raceThumbnail)
              
              FlowLayout(spacing: 10) {
                ForEach(edition.distances.sorted()) { distance in
                  Text(distance.displayLabel)
                    .secondaryButtonStyle(
                      vPadding: 6,
                      hPadding: 10
                    )
                }
              } // FlowLayout
              
              Spacer()
            } // HStack
          } // VStack
          .surfaceStyle()
        } // ForEach
      }
    } // SectionContainer
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
