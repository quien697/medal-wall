//
//  MedalPersonalBestCard.swift
//  MedalWall
//
//  Created by Quien on 2026-09-08.
//

import SwiftUI

/// One distance's record, as the top of the collection presents it.
///
/// The finish time is the headline because it is the answer the card exists to give. It
/// takes monospaced digits so the number holds still as the user pages between cards
/// rather than shifting under its own varying glyph widths.
///
/// Everything arrives pre-formatted. The card decides nothing about what a record is.
struct MedalPersonalBestCard: View {
  // MARK: - Properties
  private let titleTracking: CGFloat = 2.2
  private let metadataTracking: CGFloat = 1.4
  let distance: String
  let finishTime: String
  let raceName: String
  let pace: String

  // MARK: - Body
  var body: some View {
    VStack(alignment: .leading, spacing: .Space.inline) {
      HStack(alignment: .firstTextBaseline, spacing: .Space.row) {
        Text("Personal best")
          .font(.TypeScale.sectionTitle)
          .tracking(titleTracking)
          .textCase(.uppercase)
          .foregroundStyle(Color.Text.secondary)

        Spacer()

        Text(distance)
          .font(.TypeScale.microLabel)
          .tracking(metadataTracking)
          .textCase(.uppercase)
          .foregroundStyle(Color.Text.secondary)
      }  // HStack

      Text(finishTime)
        .font(.TypeScale.Numeric.large)
        .foregroundStyle(Color.Text.primary)

      HStack(spacing: .Space.row) {
        Text(raceName)
          .font(.TypeScale.microLabel)
          .tracking(metadataTracking)
          .textCase(.uppercase)
          .foregroundStyle(Color.Text.secondary)
          .lineLimit(1)

        Text(pace)
          .font(.TypeScale.microLabel)
          .tracking(metadataTracking)
          .textCase(.uppercase)
          .foregroundStyle(Color.Text.secondary)
          .layoutPriority(1)

        Text("PR")
          .tagStyle(.record)
          .layoutPriority(1)
      }  // HStack
      .padding(.top, .Space.inline)
    }  // VStack
    .frame(maxWidth: .infinity, alignment: .leading)
    .surfaceStyle()
  }
}

#Preview("Full marathon") {
  MedalPersonalBestCard(
    distance: "Full",
    finishTime: "03:30:24",
    raceName: "Taipei Marathon 2019",
    pace: "4'59\" /km"
  )
  .padding()
  .background(Color.Background.primary)
}

#Preview("Long race name") {
  MedalPersonalBestCard(
    distance: "Half",
    finishTime: "01:48:52",
    raceName: "BMO Vancouver Marathon Half Marathon 2022",
    pace: "5'09\" /km"
  )
  .padding()
  .background(Color.Background.primary)
}

#Preview("Custom distance in miles") {
  MedalPersonalBestCard(
    distance: "31.1 mi",
    finishTime: "05:12:07",
    raceName: "Sun Moon Lake Ultra",
    pace: "10'02\" /mi"
  )
  .padding()
  .background(Color.Background.primary)
}
