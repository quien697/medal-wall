//
//  MedalDetailResultItem.swift
//  MedalWall
//
//  Created by Quien on 2026-09-08.
//

import SwiftUI

/// One field of a medal's result: what was measured, and what it measured out at.
///
/// Every field is the same shape once the pattern is visible — a large tabular value with
/// a small secondary tail. `1058` and `/ 7373`, `4′59″` and `/KM`, `523` and `/ 1633`.
/// The tail is optional because a total with no placement would state the size of a field
/// the medal never records a position in.
///
/// The value is ink, never gold. Gold on this screen belongs to the record marker alone:
/// a time is a value, not an award.
struct MedalDetailResultItem: View {
  // MARK: - Properties
  private let labelTracking: CGFloat = 1.4
  let label: String
  let value: String
  let suffix: String?

  // MARK: - Body
  var body: some View {
    VStack(alignment: .leading, spacing: .Space.inline) {
      Text(label)
        .font(.TypeScale.microLabel)
        .tracking(labelTracking)
        .textCase(.uppercase)
        .foregroundStyle(Color.Text.secondary)
        .lineLimit(1)
        .minimumScaleFactor(0.7)

      HStack(alignment: .firstTextBaseline, spacing: .Space.inline) {
        Text(value)
          .font(.TypeScale.Numeric.large)
          .foregroundStyle(Color.Text.primary)
          .lineLimit(1)
          .minimumScaleFactor(0.5)

        if let suffix {
          Text(suffix)
            .font(.TypeScale.microLabel)
            .textCase(.uppercase)
            .foregroundStyle(Color.Text.secondary)
        }
      }  // HStack
    }  // VStack
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

#Preview("Placement with its field") {
  MedalDetailResultItem(label: "Overall", value: "1058", suffix: "/ 7373")
    .padding()
    .background(Color.Background.primary)
}

#Preview("Unfilled") {
  MedalDetailResultItem(label: "Division", value: "—", suffix: nil)
    .padding()
    .background(Color.Background.primary)
}
