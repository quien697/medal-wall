//
//  MedalYearHeader.swift
//  MedalWall
//
//  Created by Quien on 2026-09-07.
//

import SwiftUI

/// The rule that opens one year of the collection, naming the year and how many medals
/// came out of it.
///
/// The year is formatted without grouping — a year is a label, not a quantity, so 2025
/// must never render as "2,025".
struct MedalYearHeader: View {
  // MARK: - Properties
  private let countTracking: CGFloat = 1.4
  let year: Int
  let count: Int

  // MARK: - Body
  var body: some View {
    VStack(alignment: .leading, spacing: .Space.inline) {
      HStack(spacing: .Space.row) {
        Text(year, format: .number.grouping(.never))
          .font(.TypeScale.sectionTitle)
          .monospacedDigit()
          .foregroundStyle(Color.Text.primary)

        Spacer()

        Text("^[\(count) medal](inflect: true)")
          .font(.TypeScale.microLabel)
          .tracking(countTracking)
          .textCase(.uppercase)
          .foregroundStyle(Color.Text.secondary)
      }  // HStack

      Rectangle()
        .fill(Color.Border.primary)
        .frame(height: 1)
    }  // VStack
  }
}

#Preview("One medal") {
  MedalYearHeader(year: 2025, count: 1)
    .padding()
    .background(Color.Background.primary)
}

#Preview("Several medals") {
  MedalYearHeader(year: 2022, count: 2)
    .padding()
    .background(Color.Background.primary)
}
