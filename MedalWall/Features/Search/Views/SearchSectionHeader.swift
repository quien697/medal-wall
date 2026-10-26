//
//  SearchSectionHeader.swift
//  MedalWall
//
//  Created by Quien on 2026-10-25.
//

import SwiftUI

/// A section of search results: its title, and how many results it holds.
///
/// The count is a quantity, so it is grouped — 1846 races read "1,846".
struct SearchSectionHeader: View {
  let title: LocalizedStringKey
  let count: Int

  var body: some View {
    HStack(alignment: .firstTextBaseline, spacing: .Space.stack) {
      Text(title)
        .sectionTitleStyle()

      Text(count, format: .number)
        .font(.TypeScale.caption)
        .monospacedDigit()
        .foregroundStyle(Color.Text.tertiary)
    }  // HStack
  }
}

#Preview("Few results") {
  SearchSectionHeader(title: "Your Collection", count: 4)
    .padding()
    .background(Color.Background.primary)
}

#Preview("Many results") {
  SearchSectionHeader(title: "Races", count: 1846)
    .padding()
    .background(Color.Background.primary)
}
