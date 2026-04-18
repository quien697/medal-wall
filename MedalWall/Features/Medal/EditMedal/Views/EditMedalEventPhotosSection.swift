//
//  EditMedalEventPhotosSection.swift
//  MedalWall
//
//  Created by Quien on 2026-04-17.
//

import SwiftUI

struct EditMedalEventPhotosSection: View {
  let photos: [DraftEventPhoto]
  let onChooseFromLibrary: () -> Void
  let onRemove: (UUID) -> Void

  var body: some View {
    Section("Event Photos") {
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 10) {
          ForEach(photos) { photo in
            if let image = photo.image {
              ZStack(alignment: .topTrailing) {
                Image(uiImage: image)
                  .resizable()
                  .aspectRatio(contentMode: .fill)
                  .frame(width: 100, height: 80)
                  .clipShape(RoundedRectangle(cornerRadius: 8))

                Button {
                  onRemove(photo.id)
                } label: {
                  Image(systemName: "xmark.circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, Color.Gold.primary)
                    .font(.system(size: 18))
                }
                .buttonStyle(.plain)
                .offset(x: 6, y: -6)
              } // ZStack
            }
          } // ForEach

          Button {
            onChooseFromLibrary()
          } label: {
            Image(systemName: "photo")
              .placeholderStyled(as: .eventThumbnail)
          }
          .buttonStyle(.plain)
        } // HStack
        .padding()
      } // ScrollView
      .listRowInsets(EdgeInsets())
    } // Section
  }
}

#Preview {
  let medal = Medal.sampleData.first!
  let draftEventPhoto: [DraftEventPhoto] = medal.eventPhotos
    .sorted { $0.sortOrder < $1.sortOrder }
    .map { DraftEventPhoto(data: $0.imageData) }
  
  Form {
    EditMedalEventPhotosSection(
      photos: draftEventPhoto,
      onChooseFromLibrary: { print("onChooseFromLibrary") },
      onRemove: { _ in print("onRemove") }
    )
    
    EditMedalEventPhotosSection(
      photos: [],
      onChooseFromLibrary: { print("onChooseFromLibrary") },
      onRemove: { _ in print("onRemove") }
    )
  }
}
