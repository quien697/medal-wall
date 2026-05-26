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
  let location: String
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

        Text(location)
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
      location: "Taipei, Taiwan",
      editionCount: 2
    )

    RaceRow(
      photoUrl: nil,
      name: "BMO Vancouver Marathon",
      location: "Vancouver, BC, Canada",
      editionCount: 0
    )
  }
}
