//
//  MedalDetailEventPhotosSection.swift
//  MedalWall
//
//  Created by Quien on 2026-04-07.
//

import SwiftUI

struct MedalDetailEventPhotosSection: View {
  @State private var isPresentingPhotoViewer = false
  @State private var selectedPhotoIndex = 0
  
  let photos: [EventPhoto]

  var body: some View {
    SectionContainer(title: "Event Photos") {
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 12) {
          ForEach(Array(photos.sorted { $0.sortOrder < $1.sortOrder }.enumerated()), id: \.element.id) { index, photo in
            if let image = photo.image {
              Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 140, height: 110)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .onTapGesture {
                  selectedPhotoIndex = index
                  isPresentingPhotoViewer = true
                }
            }
          } // ForEach
        } // HStack
      } // ScrollView
    } // SectionContainer
    .fullScreenCover(isPresented: $isPresentingPhotoViewer) {
      PhotoViewer(
        photos: photos.compactMap { $0.image },
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
