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
  let onRemove: (String) -> Void

  var body: some View {
    Section("Event Photos") {
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 10) {
          ForEach(photos) { photo in
            ZStack(alignment: .topTrailing) {
              if let image = photo.image {
                PhotoImage(photo: image, as: .eventThumbnail)
              } else {
                PhotoImage(urlString: photo.imageUrl, as: .eventThumbnail)
              }

              Button {
                onRemove(photo.id)
              } label: {
                Image(systemName: "xmark.circle.fill")
                  .symbolRenderingMode(.palette)
                  .foregroundStyle(.white, Color.Status.error)
                  .font(.system(size: 18))
              }
              .buttonStyle(.plain)
              .offset(x: 6, y: -6)
            }  // ZStack
          }  // ForEach

          Button {
            onChooseFromLibrary()
          } label: {
            EmptyPhotoSlot(as: .eventThumbnail)
          }
          .buttonStyle(.plain)
        }  // HStack
        .padding()
      }  // ScrollView
      .listRowInsets(EdgeInsets())
    }  // Section
  }
}

#Preview {
  Form {
    EditMedalEventPhotosSection(
      photos: [],
      onChooseFromLibrary: {},
      onRemove: { _ in }
    )
  }
}
