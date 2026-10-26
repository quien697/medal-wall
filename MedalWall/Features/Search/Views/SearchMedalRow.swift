//
//  SearchMedalRow.swift
//  MedalWall
//
//  Created by Quien on 2026-10-25.
//

import SwiftUI

/// One medal as a search result: its photo in the gold ring, its date, its name, where it was
/// run, and its distance.
///
/// A medal can be found by its place, so the row shows it, beneath the name as a race row
/// does. The distance has a line of its own, so a long custom distance never shares one.
struct SearchMedalRow: View {
  // MARK: - Properties
  let photoUrl: String?
  let date: String
  let name: String
  let place: String
  let distance: String

  // MARK: - Body
  var body: some View {
    HStack(spacing: .Space.row) {
      PhotoImage(urlString: photoUrl, as: .medalSearchThumbnail)
        .medalRing()

      VStack(alignment: .leading) {
        Text(date)
          .font(.TypeScale.caption)
          .monospacedDigit()
          .foregroundStyle(Color.Text.tertiary)

        Text(name)
          .font(.TypeScale.headline)
          .foregroundStyle(Color.Text.primary)

        Text(place)
          .font(.TypeScale.caption)
          .foregroundStyle(Color.Text.secondary)

        Text(distance)
          .font(.TypeScale.caption)
          .monospacedDigit()
          .foregroundStyle(Color.Text.tertiary)
      }  // VStack
    }  // HStack
  }
}

#Preview("Standard distance") {
  SearchMedalRow(
    photoUrl: nil,
    date: "Dec 15, 2019",
    name: "Taipei Marathon 2019",
    place: "Taipei City, Taiwan",
    distance: "Full"
  )
  .padding()
  .background(Color.Surface.primary)
}

#Preview("Long custom distance") {
  SearchMedalRow(
    photoUrl: nil,
    date: "Jul 6, 2025",
    name: "Gold Coast Ultra",
    place: "Gold Coast, Australia",
    distance: "Wheel Chair 9,999.9999 mi"
  )
  .padding()
  .background(Color.Surface.primary)
}
