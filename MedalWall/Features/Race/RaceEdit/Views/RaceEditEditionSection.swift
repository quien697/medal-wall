//
//  RaceEditEditionSection.swift
//  MedalWall
//
//  Created by Quien on 2026-03-24.
//

import SwiftUI

struct RaceEditEditionSection: View {
  let editions: [DraftRaceEdition]
  let raceCropPhoto: UIImage?
  let racePhoto: UIImage?
  var onAdd: () -> Void
  var onUpdate: ((DraftRaceEdition, DraftRaceEdition) -> Void)
  var onDelete: (DraftRaceEdition) -> Void
  
  private var sortedEditions: [DraftRaceEdition] {
    editions.sorted(by: { $0.startDate > $1.startDate })
  }
  
  var body: some View {
    Section("Editions") {
      if editions.isEmpty {
        ContentUnavailableView {
          Text("No editions yet.")
            .font(.subheadline)
            .foregroundStyle(Color.Text.tertiary)
          
          Button {
            onAdd()
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
        ForEach(sortedEditions) { edition in
          NavigationLink {
            RaceEditionEditView(
              mode: .edit,
              edition: edition,
              onAction: { updatedEdition in
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
                  if let uiImage = raceCropPhoto ?? racePhoto {
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
        .onDelete { offsets in
          for index in offsets {
            onDelete(sortedEditions[index])
          }
        }
        
        Button {
          onAdd()
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

#Preview(traits: .sampleData) {
  let race = Race.sampleData.first!
  let drafts = race.editions.map { DraftRaceEdition(from: $0) }
  
  Form {
    RaceEditEditionSection(
      editions: drafts,
      raceCropPhoto: race.cropPhoto,
      racePhoto: race.photo,
      onAdd: {},
      onUpdate: { _, _ in },
      onDelete: { _ in  }
    )
    
    RaceEditEditionSection(
      editions: [],
      raceCropPhoto: nil,
      racePhoto: nil,
      onAdd: {},
      onUpdate: { _, _ in },
      onDelete: { _ in  }
    )
  }
}
