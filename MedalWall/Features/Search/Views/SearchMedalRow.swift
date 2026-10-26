//
//  SearchMedalRow.swift
//  MedalWall
//
//  Created by Quien on 2026-10-25.
//

import SwiftUI

/// One medal as a search result: its photo in the gold ring, its name, its date, and its
/// distance with the time it was run in.
///
/// More compact than the collection's `MedalRow`, with no PR tag, so a medal takes the same
/// space as a race in the results.
struct SearchMedalRow: View {
  // MARK: - Properties
  let photoUrl: String?
  let name: String
  let date: String
  let distance: String
  let finishTime: String?

  // MARK: - Body
  var body: some View {
    HStack(spacing: .Space.row) {
      PhotoImage(urlString: photoUrl, as: .medalSearchThumbnail)
        .medalRing()

      VStack(alignment: .leading) {
        Text(name)
          .font(.TypeScale.headline)
          .foregroundStyle(Color.Text.primary)

        Text(date)
          .font(.TypeScale.caption)
          .monospacedDigit()
          .foregroundStyle(Color.Text.secondary)

        Group {
          if let finishTime {
            Text(verbatim: "\(distance) · \(finishTime)")
          } else {
            Text(distance)
          }
        }  // Group
        .font(.TypeScale.caption)
        .monospacedDigit()
        .foregroundStyle(Color.Text.tertiary)
      }  // VStack
    }  // HStack
  }
}

#Preview("Timed") {
  SearchMedalRow(
    photoUrl: nil,
    name: "Taipei Marathon 2019",
    date: "Dec 15, 2019",
    distance: "Full",
    finishTime: "03:30:24"
  )
  .padding()
  .background(Color.Surface.primary)
}

#Preview("Untimed") {
  SearchMedalRow(
    photoUrl: nil,
    name: "BMO Vancouver Marathon 2022",
    date: "May 1, 2022",
    distance: "Virtual Full",
    finishTime: nil
  )
  .padding()
  .background(Color.Surface.primary)
}
