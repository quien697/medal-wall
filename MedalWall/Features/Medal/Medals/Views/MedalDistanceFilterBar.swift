//
//  MedalDistanceFilterBar.swift
//  MedalWall
//
//  Created by Quien on 2026-09-07.
//

import SwiftUI

/// The strip of distance chips above the collection.
///
/// Options are handed in already derived from the collection, so every chip selects at
/// least one medal and tapping one can never empty the list. Chips are authored at the
/// design system's 34pt height and sit in a 44pt row: the row carries the tap target so a
/// strip of filters stays visually light.
struct MedalDistanceFilterBar: View {
  // MARK: - State
  @Binding var selection: MedalDistanceFilter

  // MARK: - Properties
  let filters: [MedalDistanceFilter]
  let count: (MedalDistanceFilter) -> Int

  // MARK: - Init
  init(
    filters: [MedalDistanceFilter],
    count: @escaping (MedalDistanceFilter) -> Int,
    selection: Binding<MedalDistanceFilter>
  ) {
    self.filters = filters
    self.count = count
    self._selection = selection
  }

  // MARK: - Body
  var body: some View {
    ScrollView(.horizontal) {
      HStack(spacing: .Space.stack) {
        ForEach(filters) { filter in
          Button {
            selection = filter
          } label: {
            HStack(spacing: .Space.inline) {
              Text(filter.label)

              Text(count(filter), format: .number)
                .monospacedDigit()
            }  // HStack
            .textCase(.uppercase)
          }  // Button
          .chipStyle(
            selection == filter ? .primary : .secondary,
            font: .TypeScale.microLabel)
        }
      }  // HStack
      .padding(.horizontal, .Space.gutter)
      .padding(.vertical, .Space.stack)
    }  // ScrollView
    .scrollIndicators(.hidden)
  }
}

#Preview("All selected") {
  @Previewable @State var selection: MedalDistanceFilter = .all

  MedalDistanceFilterBar(
    filters: [.all, .category(.full), .category(.half)],
    count: { filter in
      switch filter {
      case .all: 9
      case .category(let category): category == .full ? 5 : 4
      }
    },
    selection: $selection
  )
  .background(Color.Background.primary)
}

#Preview("A distance selected") {
  @Previewable @State var selection: MedalDistanceFilter = .category(.half)

  MedalDistanceFilterBar(
    filters: [.all, .category(.full), .category(.half), .category(.tenKM)],
    count: { _ in 4 },
    selection: $selection
  )
  .background(Color.Background.primary)
}
