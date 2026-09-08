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
  let personalBests: [MedalPersonalBest]
  let namespace: Namespace.ID

  // MARK: - Computed
  /// Which card is showing, for the dots each card draws.
  ///
  /// `scrollPosition` reports `nil` until the first scroll, so an unscrolled carousel
  /// falls back to the first card rather than lighting no dot at all.
  private var currentIndex: Int {
    guard let scrolledID,
      let index = personalBests.firstIndex(where: { $0.id == scrolledID })
    else { return 0 }

    return index
  }

  // MARK: - Body
  var body: some View {
    if personalBests.isEmpty {
      EmptyView()
    } else {
      ScrollView(.horizontal) {
        HStack(spacing: .Space.gutter) {
          ForEach(personalBests) { personalBest in
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
  ///
  /// The transition source is prefixed because the same medal's row very likely carries
  /// `matchedTransitionSource(id: medal.id)` further down the screen, and two sources
  /// sharing an id in one namespace leave the zoom with no way to choose.
  private func card(for personalBest: MedalPersonalBest) -> some View {
    NavigationLink {
      MedalDetailView(medal: personalBest.medal)
        .navigationTransition(
          .zoom(sourceID: "personalBest-\(personalBest.medal.id)", in: namespace)
        )
    } label: {
      MedalPersonalBestCard(
        distance: personalBest.category.description,
        finishTime: personalBest.medal.finishTime?.formattedHMS ?? "-",
        raceName: personalBest.medal.name,
        pace: MedalDetailViewModel.paceText(
          minutesPerKilometer: personalBest.medal.averagePace,
          in: DistanceUnit.resolved()
        ),
        pageCount: personalBests.count,
        currentPage: currentIndex
      )
      .matchedTransitionSource(id: "personalBest-\(personalBest.medal.id)", in: namespace)
    }
    .buttonStyle(.plain)
  }
}

/// Builds entries for the previews below — `#Preview` bodies are `ViewBuilder` closures,
/// which take declarations and view expressions but not assignments.
private func previewBests(limit: Int = .max) -> [MedalPersonalBest] {
  Array(Medal.sampleData.personalBests.prefix(limit))
}

#Preview("Several records") {
  @Previewable @Namespace var namespace

  NavigationStack {
    MedalPersonalBestCarousel(personalBests: previewBests(), namespace: namespace)
      .background(Color.Background.primary)
  }  // NavigationStack
}

#Preview("One record") {
  @Previewable @Namespace var namespace

  NavigationStack {
    MedalPersonalBestCarousel(personalBests: previewBests(limit: 1), namespace: namespace)
      .background(Color.Background.primary)
  }  // NavigationStack
}

#Preview("No records") {
  @Previewable @Namespace var namespace

  NavigationStack {
    MedalPersonalBestCarousel(personalBests: [], namespace: namespace)
      .background(Color.Background.primary)
  }  // NavigationStack
}
