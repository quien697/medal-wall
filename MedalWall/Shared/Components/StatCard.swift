//
//  StatCard.swift
//  MedalWall
//
//  Created by Quien on 2026-04-09.
//

import SwiftUI

struct StatCard: View {
  let title: String
  let titleFont: Font
  let subtitle: LocalizedStringKey
  let titleColor: Color
  let vPadding: CGFloat
  let hPadding: CGFloat

  init(
    title: String,
    titleFont: Font? = nil,
    subtitle: LocalizedStringKey,
    titleColor: Color? = nil,
    vPadding: CGFloat? = nil,
    hPadding: CGFloat? = nil
  ) {
    self.title = title
    self.titleFont = titleFont ?? .TypeScale.Numeric.large
    self.subtitle = subtitle
    self.titleColor = titleColor ?? Color.Text.primary
    self.vPadding = vPadding ?? 16
    self.hPadding = hPadding ?? 16
  }

  var body: some View {
    VStack {
      Text(title)
        .font(titleFont)
        .foregroundStyle(titleColor)
        .lineLimit(1)
        .minimumScaleFactor(0.5)

      Text(subtitle)
        .font(.TypeScale.overline)
        .tracking(.Tracking.label)
        .textCase(.uppercase)
        .foregroundStyle(Color.Text.tertiary)
        .lineLimit(1)
        .minimumScaleFactor(0.5)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .surfaceStyle(
      vPadding: vPadding,
      hPadding: hPadding
    )
  }
}

#Preview {
  let threeColumns = [
    GridItem(.flexible(minimum: 80), spacing: 8),
    GridItem(.flexible(minimum: 80), spacing: 8),
    GridItem(.flexible(minimum: 80), spacing: 8)
  ]

  let twoColumns = [
    GridItem(.flexible(minimum: 160), spacing: 8),
    GridItem(.flexible(minimum: 160), spacing: 8)
  ]

  LazyVGrid(columns: threeColumns, spacing: 8) {
    StatCard(
      title: "32",
      subtitle: "Medals"
    )

    StatCard(
      title: "12",
      subtitle: "Full"
    )

    StatCard(
      title: "4",
      subtitle: "Half"
    )
  }

  LazyVGrid(columns: twoColumns, spacing: 8) {
    StatCard(
      title: "03:30:10",
      titleFont: .TypeScale.Numeric.medium,
      subtitle: "Best Full"
    )

    StatCard(
      title: "--:--:--",
      titleFont: .TypeScale.Numeric.medium,
      subtitle: "Best Half"
    )
  }
}
