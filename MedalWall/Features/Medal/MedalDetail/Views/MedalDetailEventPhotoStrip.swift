//
//  MedalDetailEventPhotoStrip.swift
//  MedalWall
//
//  Created by Quien on 2026-04-07.
//

import PhotoViewer
import SwiftUI

/// The photos a user took on the day, side by side.
///
/// No heading of its own: it sits inside `MedalDetailDaySection` beside the note, and the
/// two together are what the heading names.
struct MedalDetailEventPhotoStrip: View {
  @State private var isPresentingPhotoViewer = false
  @State private var selectedPhotoIndex = 0

  let photos: [EventPhoto]

  private var sortedPhotoUrls: [String] {
    photos.sorted { $0.sortOrder < $1.sortOrder }.map { $0.imageUrl }
  }

  var body: some View {
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
    MedalDetailEventPhotoStrip(photos: [])
  }
}
