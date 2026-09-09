//
//  MedalDetailInfoRow.swift
//  MedalWall
//
//  Created by Quien on 2026-09-08.
//

import SwiftUI

/// One fixed fact about a race: what it is on the left, what it was on the right.
///
/// The second line carries a qualifier that belongs to the value rather than a fact of its
/// own — the race type under the distance — so the list stays four rows rather than five.
struct MedalDetailInfoRow: View {
  // MARK: - Properties
  private let labelTracking: CGFloat = 1.4
  let label: String
  let value: String
  let secondaryValue: String?

  // MARK: - Body
  var body: some View {
    HStack(alignment: .firstTextBaseline, spacing: .Space.gutter) {
      Text(label)
        .font(.TypeScale.microLabel)
        .tracking(labelTracking)
        .textCase(.uppercase)
        .foregroundStyle(Color.Text.secondary)

      Spacer()

      VStack(alignment: .trailing, spacing: .Space.inline) {
        Text(value)
          .font(.TypeScale.caption)
          .fontWeight(.bold)
          .foregroundStyle(Color.Text.primary)

        if let secondaryValue {
          Text(secondaryValue)
            .font(.TypeScale.overline)
            .foregroundStyle(Color.Text.secondary)
        }
      }  // VStack
      .multilineTextAlignment(.trailing)
    }  // HStack
    .padding(.vertical, .Space.stack)
  }
}

#Preview("A plain fact") {
  MedalDetailInfoRow(label: "Location", value: "Taipei City, TW", secondaryValue: nil)
    .padding(.horizontal)
    .background(Color.Background.primary)
}

#Preview("A fact with a qualifier") {
  MedalDetailInfoRow(label: "Distance", value: "Full · 42.2 km", secondaryValue: "In-Person")
    .padding(.horizontal)
    .background(Color.Background.primary)
}
