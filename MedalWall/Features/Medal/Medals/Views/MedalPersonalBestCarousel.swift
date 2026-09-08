//
//  MedalPersonalBestCarousel.swift
//  MedalWall
//
//  Created by Quien on 2026-09-08.
//

import SwiftUI

/// The records the collection holds, one full-width card per distance.
///
/// A full-width card leaves no part of the next one showing, so each card draws the dots
/// that say how many records there are and which one this is.
///
/// The carousel describes the whole collection and never the filtered view of it, so a
/// card can offer a medal whose row the distance filter is currently hiding — which is
/// why it navigates on its own rather than leaning on the row below.
struct MedalPersonalBestCarousel: View {
  // MARK: - State
  @State private var scrolledID: MedalPersonalBest.ID?

  // MARK: - Properties
  let viewModel: MedalsViewModel
  let namespace: Namespace.ID

  // MARK: - Body
  var body: some View {
    if viewModel.personalBests.isEmpty {
      EmptyView()
    } else {
      ScrollView(.horizontal) {
        HStack(spacing: .Space.gutter) {
          ForEach(viewModel.personalBests) { personalBest in
            card(for: personalBest)
              .containerRelativeFrame(.horizontal, count: 1, spacing: .Space.gutter)
          }
        }  // HStack
        .scrollTargetLayout()
      }  // ScrollView
      .scrollIndicators(.hidden)
      .scrollTargetBehavior(.viewAligned)
      .scrollPosition(id: $scrolledID)
      .contentMargins(.horizontal, .Space.gutter, for: .scrollContent)
      .padding(.top, .Space.row)
    }
  }

  // MARK: - Subviews
  /// One record, linked to the medal that set it.
  private func card(for personalBest: MedalPersonalBest) -> some View {
    NavigationLink {
      MedalDetailView(medal: personalBest.medal)
        .navigationTransition(
          .zoom(sourceID: viewModel.transitionID(for: personalBest), in: namespace)
        )
    } label: {
      MedalPersonalBestCard(
        distance: viewModel.distanceText(for: personalBest),
        finishTime: viewModel.finishTimeText(for: personalBest),
        raceName: viewModel.raceNameText(for: personalBest),
        pace: viewModel.paceText(for: personalBest),
        pageCount: viewModel.personalBests.count,
        currentPage: viewModel.personalBestPage(forScrolledID: scrolledID)
      )
      .matchedTransitionSource(
        id: viewModel.transitionID(for: personalBest),
        in: namespace
      )
    }
    .buttonStyle(.plain)
  }
}

/// Builds a view model for the previews below — `#Preview` bodies are `ViewBuilder`
/// closures, which take declarations and view expressions but not assignments.
private func previewViewModel(medals: [Medal] = Medal.sampleData) -> MedalsViewModel {
  let viewModel = MedalsViewModel()
  viewModel.medals = medals
  return viewModel
}

#Preview("Several records") {
  @Previewable @Namespace var namespace

  NavigationStack {
    MedalPersonalBestCarousel(viewModel: previewViewModel(), namespace: namespace)
      .background(Color.Background.primary)
  }  // NavigationStack
}

#Preview("One record") {
  @Previewable @Namespace var namespace

  NavigationStack {
    MedalPersonalBestCarousel(
      viewModel: previewViewModel(medals: Array(Medal.sampleData.prefix(1))),
      namespace: namespace
    )
    .background(Color.Background.primary)
  }  // NavigationStack
}

#Preview("No records") {
  @Previewable @Namespace var namespace

  NavigationStack {
    MedalPersonalBestCarousel(viewModel: previewViewModel(medals: []), namespace: namespace)
      .background(Color.Background.primary)
  }  // NavigationStack
}
