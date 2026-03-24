//
//  RaceEditionsCardSection.swift
//  MedalWall
//
//  Created by Quien on 2026-03-16.
//

import SwiftUI

struct RaceEditionsCardSection: View {
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
        ForEach(editions) { edition in
          VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 15) {
              ZStack(alignment: .leading) {
                if let uiImage = edition.cropPhoto ?? edition.photo {
                  Image(uiImage: uiImage)
                    .styled(as: ImageType.raceThumbnail)
                } else {
                  if let uiImage = edition.race.cropPhoto ?? edition.race.photo {
                    Image(uiImage: uiImage)
                      .styled(as: ImageType.raceThumbnail)
                  } else {
                    Image(systemName: "photo.fill")
                      .placeholderStyled(as: ImageType.raceThumbnail)
                  }
                }
              } // ZStack
              
              VStack(alignment: .leading) {
                Text(String(edition.year))
                  .font(.title2)
                  .fontWeight(.heavy)
                  .foregroundStyle(Color.Badge.Gold.primary)
                
                let startDate = edition.startDate.formattedMonthDay()
                let endDate = ", \(edition.endDate.formattedMonthDay())"
                
                Text("\(startDate)\(edition.isOneDay ? "" : endDate)")
                  .font(.subheadline)
                  .foregroundStyle(Color.Text.tertiary)
                
                Spacer()
              } // VStack
              
              Spacer()
            } // HStack
            
            Divider()
            
            ForEach(edition.distancesByTypeOrdered, id: \.type) { typeGroup in
              VStack(alignment: .leading, spacing: 10) {
                Text(typeGroup.type.displayName)
                  .font(.headline)
                  .foregroundStyle(Color.Text.secondary)
                
                FlowLayout(spacing: 10) {
                  ForEach(typeGroup.distances) { distance in
                    Text(distance.category.description)
                      .secondaryButtonStyle()
                  }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
              } // VStack
              
              if typeGroup.type != edition.distancesByTypeOrdered.last?.type {
                Divider()
                  .padding(.vertical, 5)
              }
            } // ForEach
          } // VStack
          .surfaceStyle()
        } // ForEach
      }
    } // SectionContainer
  }
}

#Preview {
  RaceEditionsCardSection(editions: Race.sampleData.first!.editions)
  
  RaceEditionsCardSection(editions: [])
}
