//
//  EditMedalEventPhotosSection.swift
//  MedalWall
//
//  Created by Quien on 2026-04-17.
//

import CachedAsyncImage
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
              photoThumbnail(for: photo)
                .frame(width: 100, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: .Radius.image))

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
            }  // ZStack
          }  // ForEach

          Button {
            onChooseFromLibrary()
          } label: {
            Image(systemName: "photo")
              .placeholderStyled(as: .eventThumbnail)
          }
          .buttonStyle(.plain)
        }  // HStack
        .padding()
      }  // ScrollView
      .listRowInsets(EdgeInsets())
    }  // Section
  }

  @ViewBuilder
  private func photoThumbnail(for photo: DraftEventPhoto) -> some View {
    if let image = photo.image {
      Image(uiImage: image)
        .resizable()
        .aspectRatio(contentMode: .fill)
    } else if let urlString = photo.imageUrl, let url = URL(string: urlString) {
      CachedAsyncImage(url: url, targetSize: CGSize(width: 100, height: 80)) { phase in
        switch phase {
        case .success(let image):
          image.resizable().aspectRatio(contentMode: .fill)
        default:
          Color.gray.opacity(0.2)
        }
      }
    } else {
      Color.gray.opacity(0.2)
    }
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
