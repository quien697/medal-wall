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
  private let titleTracking: CGFloat = 1
  private let metadataTracking: CGFloat = 1.4
  private let dotSize: CGFloat = 6
  private let dimmedDot: Double = 0.3
  let distance: String
  let finishTime: String
  let raceName: String
  let pace: String
  let pageCount: Int
  let currentPage: Int

  // MARK: - Body
  var body: some View {
    VStack(alignment: .leading, spacing: .Space.inline) {
      HStack {
        Text("Personal best")
          .tagStyle(.record)
          .tracking(titleTracking)

        Spacer()

        Text(distance)
          .font(.TypeScale.microLabel)
          .tracking(metadataTracking)
          .textCase(.uppercase)
          .foregroundStyle(Color.Text.secondary)
      }  // HStack
      .padding(.bottom, .Space.inline)

      Text(raceName)
        .font(.TypeScale.callout)
        .fontWeight(.bold)
        .foregroundStyle(Color.Text.primary)
        .lineLimit(1)

      Text(finishTime)
        .font(.TypeScale.Numeric.large)
        .fontWeight(.heavy)
        .foregroundStyle(Color.Text.primary)

      HStack {
        Text(pace)
          .font(.TypeScale.microLabel)
          .tracking(metadataTracking)
          .textCase(.uppercase)
          .foregroundStyle(Color.Text.secondary)

        Spacer()

        if pageCount > 1 {
          pageDots()
        }
      }  // HStack
    }  // VStack
    .frame(maxWidth: .infinity, alignment: .leading)
    .surfaceStyle()
  }

  // MARK: - Functions
  /// Which record of the set this card is, drawn on the card itself because a full-width
  /// card leaves no part of its neighbours showing. Only ever built past one record, so
  /// the range always holds at least two dots.
  @ViewBuilder
  private func pageDots() -> some View {
    HStack(spacing: .Space.stack) {
      ForEach(0..<pageCount, id: \.self) { page in
        Circle()
          .fill(Color.Text.secondary)
          .opacity(page == currentPage ? 1 : dimmedDot)
          .frame(width: dotSize, height: dotSize)
      }  // ForEach
    }  // HStack
  }
}

#Preview("Full marathon") {
  MedalPersonalBestCard(
    distance: "Full",
    finishTime: "03:30:24",
    raceName: "Taipei Marathon 2019",
    pace: "4'59\" /km",
    pageCount: 3,
    currentPage: 0
  )
  .padding()
  .background(Color.Background.primary)
}

#Preview("Long race name") {
  MedalPersonalBestCard(
    distance: "Half",
    finishTime: "01:48:52",
    raceName: "BMO Vancouver Marathon Half Marathon 2022",
    pace: "5'09\" /km",
    pageCount: 3,
    currentPage: 1
  )
  .padding()
  .background(Color.Background.primary)
}

#Preview("Custom distance in miles") {
  MedalPersonalBestCard(
    distance: "31.1 mi",
    finishTime: "05:12:07",
    raceName: "Sun Moon Lake Ultra",
    pace: "10'02\" /mi",
    pageCount: 1,
    currentPage: 0
  )
  .padding()
  .background(Color.Background.primary)
}
