//
//  RaceEditionSection.swift
//  MedalWall
//
//  Created by Quien on 2026-03-24.
//

import SwiftUI

struct RaceEditionSection: View {
  let editions: [RaceEdition]
  var onUpdate: ((RaceEdition, RaceEdition) -> Void)
  
  var body: some View {
    Section("Editions") {
      if editions.isEmpty {
        ContentUnavailableView {
          Text("No editions yet.")
            .font(.subheadline)
            .foregroundStyle(Color.Text.tertiary)
          
          Button {
            
          } label: {
            Label("Add Edition", systemImage: "plus")
              .labelStyle(.titleAndIcon)
          }
          .goldOutLineButtonStyle(
            fontWeight: .heavy,
            vPadding: 12,
            hPadding: 20
          )
          .padding(.top, 15)
        } // ContentUnavailableView
      } else {
        ForEach(editions, id: \.self) { edition in
          NavigationLink {
            RaceEditionEditView(
              mode: .edit,
              race: edition.race,
              edition: edition,
              onUpdate: { updatedEdition in
                onUpdate(edition, updatedEdition)
              }
            )
          } label: {
            HStack(alignment: .top, spacing: 10) {
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
              
              VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 10) {
                  Text(String(edition.year))
                    .font(.title2)
                    .fontWeight(.heavy)
                    .foregroundStyle(Color.Badge.Gold.primary)
                  
                  Text(edition.dateDisplayLabel)
                    .font(.subheadline)
                    .foregroundStyle(Color.Text.tertiary)
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                  HStack {
                    ForEach(edition.distances.sorted()) { distance in
                      Text(distance.displayLabel)
                        .secondaryButtonStyle(
                          font: .caption,
                          fgColor: Color.Text.tertiary,
                          vPadding: 6,
                          hPadding: 10,
                        )
                    }
                  } // HStack
                } // ScrollView
              } // VStack
              
              Spacer()
            } // HStack
          } // NavigationLink
        } // ForEach
        
        Button {
          
        } label: {
          Label("Add Another Edition", systemImage: "plus")
            .labelStyle(.titleAndIcon)
        }
        .goldOutLineButtonStyle(
          fontWeight: .heavy,
          vPadding: 12,
          hPadding: 20
        )
        .frame(maxWidth: .infinity)
      }
    } // Section
  }
}

#Preview {
  RaceEditionSection(editions: Race.sampleData.first!.editions, onUpdate: { _, _ in })
  
  RaceEditionSection(editions: [], onUpdate: { _, _ in })
}
