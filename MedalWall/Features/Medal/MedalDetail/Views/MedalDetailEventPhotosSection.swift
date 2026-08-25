//
//  MedalDetailEventPhotosSection.swift
//  MedalWall
//
//  Created by Quien on 2026-04-07.
//

import CachedAsyncImage
import PhotoViewer
import SwiftUI

struct MedalDetailEventPhotosSection: View {
  @State private var isPresentingPhotoViewer = false
  @State private var selectedPhotoIndex = 0

  let photos: [EventPhoto]

  private var sortedPhotoUrls: [String] {
    photos.sorted { $0.sortOrder < $1.sortOrder }.map { $0.imageUrl }
  }

  var body: some View {
    SectionContainer(title: "Event Photos") {
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 12) {
          ForEach(Array(sortedPhotoUrls.enumerated()), id: \.offset) { index, urlString in
            CachedAsyncImage(
              url: URL(string: urlString),
              targetSize: CGSize(width: 140, height: 110)
            ) { phase in
              switch phase {
              case .success(let image):
                image
                  .resizable()
                  .aspectRatio(contentMode: .fill)
              default:
                Color.gray.opacity(0.2)
              }
            }
            .frame(width: 140, height: 110)
            .clipShape(RoundedRectangle(cornerRadius: .Radius.image))
            .onTapGesture {
              selectedPhotoIndex = index
              isPresentingPhotoViewer = true
            }
          }  // ForEach
        }  // HStack
      }  // ScrollView
    }  // SectionContainer
    .fullScreenCover(isPresented: $isPresentingPhotoViewer) {
      PhotoViewer(
        photos: sortedPhotoUrls,
        selectedIndex: $selectedPhotoIndex
      )
    }
  }
}

#Preview {
  ScrollView {
    MedalDetailEventPhotosSection(photos: [])
  }
}
