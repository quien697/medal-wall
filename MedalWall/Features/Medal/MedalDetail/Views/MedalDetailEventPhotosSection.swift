//
//  MedalDetailEventPhotosSection.swift
//  MedalWall
//
//  Created by Quien on 2026-04-07.
//

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
    PageSection(title: "Event Photos") {
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 12) {
          ForEach(Array(sortedPhotoUrls.enumerated()), id: \.offset) { index, urlString in
            PhotoImage(urlString: urlString, as: .event)
              .onTapGesture {
                selectedPhotoIndex = index
                isPresentingPhotoViewer = true
              }
          }  // ForEach
        }  // HStack
      }  // ScrollView
    }  // PageSection
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
