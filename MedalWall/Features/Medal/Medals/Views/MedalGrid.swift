//
//  MedalGrid.swift
//  MedalWall
//
//  Created by Quien on 2026-05-28.
//

import SwiftUI

struct MedalGrid: View {
  // MARK: - Properties
  private let gridSpacing: CGFloat = 16
  let medals: [Medal]
  let isLoading: Bool

  // MARK: - Namespace
  @Namespace private var namespace

  // MARK: - Computed
  private var gridColumns: [GridItem] {
    [GridItem](repeating: GridItem(.flexible(minimum: 80), spacing: gridSpacing), count: 2)
  }

  // MARK: - Body
  var body: some View {
    Group {
      if medals.isEmpty && !isLoading {
        MedalEmptyView()
      } else {
        ScrollView {
          MedalStatsSection(
            totalCount: medals.count,
            fullCount: medals.fullCount,
            halfCount: medals.halfCount
          )

          MedalGridSection(
            medals: medals,
            columns: gridColumns,
            spacing: gridSpacing,
            namespace: namespace
          )
        }  // ScrollView
        .scrollIndicators(.hidden)
      }
    }  // Group
  }
}

#Preview {
  NavigationStack {
    MedalGrid(medals: Medal.sampleData, isLoading: false)
  }
  .background(Color.Background.primary)
}
