//
//  MedalList.swift
//  MedalWall
//
//  Created by Quien on 2026-09-07.
//

import SwiftUI

/// The medal collection, grouped by year under a strip of distance filters.
///
/// The screen has exactly one empty state — a collection with no medals — because the
/// filter offers only distances the user owns, so a selection can never empty the list.
struct MedalList: View {
  // MARK: - State
  @Bindable var viewModel: MedalsViewModel

  // MARK: - Namespace
  @Namespace private var namespace

  // MARK: - Body
  var body: some View {
    Group {
      if viewModel.isEmpty && !viewModel.isLoading {
        MedalEmptyView()
      } else {
        ScrollView {
          LazyVStack(alignment: .leading, spacing: .Space.section) {
            ForEach(viewModel.yearGroups) { group in
              MedalYearSection(
                group: group,
                personalRecordIDs: viewModel.personalRecordIDs,
                namespace: namespace
              )
            }  // ForEach
          }  // LazyVStack
          .padding(.horizontal, .Space.gutter)
        }  // ScrollView
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .top) {
          VStack(spacing: .Space.inline) {
            MedalPersonalBestCarousel(
              personalBests: viewModel.medals.personalBests,
              personalRecordIDs: viewModel.personalRecordIDs,
              namespace: namespace
            )

            MedalDistanceFilterBar(
              filters: viewModel.availableFilters,
              count: viewModel.medals.count(for:),
              selection: $viewModel.selectedFilter
            )
          }  // VStack
          .background(Color.Background.primary)
        }
      }
    }  // Group
  }
}

/// Builds a view model for the previews below — `#Preview` bodies are `ViewBuilder`
/// closures, which take declarations and view expressions but not assignments.
private func previewViewModel(
  medals: [Medal] = Medal.sampleData,
  filter: MedalDistanceFilter = .all
) -> MedalsViewModel {
  let viewModel = MedalsViewModel()
  viewModel.medals = medals
  viewModel.selectedFilter = filter
  return viewModel
}

#Preview("Collection") {
  NavigationStack {
    MedalList(viewModel: previewViewModel())
      .background(Color.Background.primary)
  }  // NavigationStack
}

#Preview("Filtered to a distance") {
  NavigationStack {
    MedalList(viewModel: previewViewModel(filter: .category(.half)))
      .background(Color.Background.primary)
  }  // NavigationStack
}

#Preview("Empty") {
  NavigationStack {
    MedalList(viewModel: previewViewModel(medals: []))
      .background(Color.Background.primary)
  }  // NavigationStack
}
