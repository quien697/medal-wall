//
//  RaceRowView.swift
//  MedalWall
//
//  Created by Quien on 2025-11-11.
//

import SwiftUI

struct RaceRow: View {
  let photoUrl: String?
  let name: String
  let place: String
  let editionCount: Int

  var body: some View {
    HStack {
      RaceImage(
        urlString: photoUrl,
        imageType: .raceThumbnail
      )

      VStack(alignment: .leading) {
        Text(name)
          .font(.headline)
          .foregroundStyle(Color.Text.primary)

        Text(place)
          .font(.subheadline)
          .foregroundStyle(Color.Text.secondary)

        Text("\(editionCount) editions")
          .font(.subheadline)
          .foregroundStyle(Color.Text.tertiary)
      }
    }  // HStack
  }
}

#Preview {
  List {
    RaceRow(
      photoUrl: nil,
      name: "Taipei Marathon",
      place: "Taipei, Taiwan",
      editionCount: 2
    )

    RaceRow(
      photoUrl: nil,
      name: "BMO Vancouver Marathon",
      place: "Vancouver, BC, Canada",
      editionCount: 0
    )
  }
}
