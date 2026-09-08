//
//  MedalDetailDaySection.swift
//  MedalWall
//
//  Created by Quien on 2026-09-09.
//

import SwiftUI

/// What the user kept of the day: the photos they took, and what they wrote about it.
///
/// One band rather than two, because a heading naming a data type — `Event Photos`, then
/// `Notes` — says less than one naming the occasion. It also stops a medal with a note and
/// no photos from showing a lone heading over a single paragraph.
struct MedalDetailDaySection: View {
  // MARK: - Properties
  let photos: [EventPhoto]
  let note: String?

  // MARK: - Body
  var body: some View {
    PageSection(title: "The day") {
      VStack(alignment: .leading, spacing: .Space.row) {
        if !photos.isEmpty {
          MedalDetailEventPhotoStrip(photos: photos)
        }

        if let note {
          Text(note)
            .font(.TypeScale.body)
            .foregroundStyle(Color.Text.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(3...)
            .surfaceStyle()
        }
      }  // VStack
    }  // PageSection
  }
}

#Preview("Photos and a note") {
  MedalDetailDaySection(
    photos: Medal.sampleData.first?.eventPhotos ?? [],
    note: "The weather was good, not too much up hill and down hill."
  )
  .background(Color.Background.primary)
}

#Preview("A note on its own") {
  MedalDetailDaySection(
    photos: [],
    note: "Strong negative split."
  )
  .background(Color.Background.primary)
}

#Preview("Photos on their own") {
  MedalDetailDaySection(
    photos: Medal.sampleData.first?.eventPhotos ?? [],
    note: nil
  )
  .background(Color.Background.primary)
}
