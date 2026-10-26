//
//  SearchRaceRow.swift
//  MedalWall
//
//  Created by Quien on 2026-10-25.
//

import SwiftUI

/// One race as a search result: its photo, its name, where it is run, and how many editions
/// it has.
struct SearchRaceRow: View {
  let photoUrl: String?
  let name: String
  let place: String
  let editionCount: Int

  var body: some View {
    HStack(spacing: .Space.row) {
      PhotoImage(urlString: photoUrl, as: .raceSearchThumbnail)

      VStack(alignment: .leading) {
        Text(name)
          .font(.TypeScale.headline)
          .foregroundStyle(Color.Text.primary)

        Text(place)
          .font(.TypeScale.caption)
          .foregroundStyle(Color.Text.secondary)

        Text("^[\(editionCount) edition](inflect: true)")
          .font(.TypeScale.caption)
          .foregroundStyle(Color.Text.tertiary)
      }  // VStack
    }  // HStack
  }
}

#Preview("Editions") {
  SearchRaceRow(
    photoUrl: nil,
    name: "Taipei Marathon",
    place: "Taipei City, Taiwan",
    editionCount: 2
  )
  .padding()
  .background(Color.Surface.primary)
}

#Preview("One edition") {
  SearchRaceRow(
    photoUrl: nil,
    name: "Taipei 101 Run Up",
    place: "Taipei City, Taiwan",
    editionCount: 1
  )
  .padding()
  .background(Color.Surface.primary)
}
