//
//  MedalRow.swift
//  MedalWall
//
//  Created by Quien on 2026-09-07.
//

import SwiftUI

/// One medal as the collection list presents it: the thumbnail beside the race it came
/// from, its distance, and the time it was run in.
///
/// The gold ring is unconditional — it marks a medal, not a result — so an untimed race
/// wears it exactly like a timed one. What the ring never does is stand in for the record:
/// that is the champagne tag, and only the fastest medal at a distance carries it.
struct MedalRow: View {
  // MARK: - Properties
  private let metadataTracking: CGFloat = 1.4
  let photoUrl: String?
  let date: String
  let name: String
  let distance: String
  let finishTime: String?
  let isPersonalRecord: Bool

  // MARK: - Body
  var body: some View {
    HStack(spacing: .Space.gutter) {
      PhotoImage(urlString: photoUrl, as: .medalThumbnail)
        .medalRing()

      VStack(alignment: .leading, spacing: .Space.inline) {
        Text(date)
          .font(.TypeScale.microLabel)
          .tracking(metadataTracking)
          .textCase(.uppercase)
          .foregroundStyle(Color.Text.secondary)

        Text(name)
          .font(.TypeScale.headline)
          .foregroundStyle(Color.Text.primary)
          .lineLimit(2)

        Text(distance)
          .font(.TypeScale.microLabel)
          .tracking(metadataTracking)
          .textCase(.uppercase)
          .foregroundStyle(Color.Text.secondary)

        if let finishTime {
          HStack(spacing: .Space.stack) {
            Text(finishTime)
              .font(.TypeScale.Numeric.medium)
              .foregroundStyle(Color.Text.secondary)

            if isPersonalRecord {
              Text("PR")
                .tagStyle(.record)
            }
          }  // HStack
          .padding(.top, .Space.inline)
        } else {
          Text("No time recorded")
            .font(.TypeScale.microLabel)
            .tracking(metadataTracking)
            .textCase(.uppercase)
            .foregroundStyle(Color.Text.secondary)
            .padding(.top, .Space.inline)
        }
      }  // VStack
      .frame(maxWidth: .infinity, alignment: .leading)
    }  // HStack
  }
}

#Preview("Personal record") {
  MedalRow(
    photoUrl: nil,
    date: "Dec 15, 2019",
    name: "Taipei Marathon 2019",
    distance: "Full",
    finishTime: "03:30:24",
    isPersonalRecord: true
  )
  .padding()
  .background(Color.Background.primary)
}

#Preview("Timed") {
  MedalRow(
    photoUrl: nil,
    date: "Dec 20, 2025",
    name: "Taipei Marathon 2025",
    distance: "Half",
    finishTime: "01:48:52",
    isPersonalRecord: false
  )
  .padding()
  .background(Color.Background.primary)
}

#Preview("Untimed") {
  MedalRow(
    photoUrl: nil,
    date: "May 1, 2022",
    name: "BMO Vancouver Marathon 2022",
    distance: "Virtual Full",
    finishTime: nil,
    isPersonalRecord: false
  )
  .padding()
  .background(Color.Background.primary)
}
