//
//  MedalPersonalBestCarousel.swift
//  MedalWall
//
//  Created by Quien on 2026-09-08.
//

import SwiftUI

/// The records the collection holds, one full-width card per distance.
///
/// A full-width card leaves no part of the next one showing, so the dots below are the
/// only thing saying more records exist. They are absent at one record, where there is
/// nothing to discover.
///
/// The carousel describes the whole collection and never the filtered view of it, so a
/// card can offer a medal whose row the distance filter is currently hiding — which is
/// why it navigates on its own rather than leaning on the row below.
struct MedalPersonalBestCarousel: View {
  // MARK: - State
  @State private var scrolledID: MedalPersonalBest.ID?

  // MARK: - Properties
  private let dotSize: CGFloat = 6
  private let dimmedDot: Double = 0.3
  let personalBests: [MedalPersonalBest]
  let namespace: Namespace.ID

  // MARK: - Computed
  /// The card the dots should mark. `scrollPosition` reports `nil` until the first
  /// scroll, which would otherwise leave every dot dimmed on arrival.
  private var currentID: MedalPersonalBest.ID? {
    scrolledID ?? personalBests.first?.id
  }

  // MARK: - Body
  var body: some View {
    if personalBests.isEmpty {
      EmptyView()
    } else {
      VStack(spacing: .Space.stack) {
        ScrollView(.horizontal) {
          HStack(spacing: .Space.row) {
            ForEach(personalBests) { personalBest in
              card(for: personalBest)
                .containerRelativeFrame(.horizontal, count: 1, spacing: .Space.row)
            }
          }  // HStack
          .scrollTargetLayout()
        }  // ScrollView
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $scrolledID)
        .contentMargins(.horizontal, .Space.gutter, for: .scrollContent)

        if personalBests.count > 1 {
          pageIndicator
        }
      }  // VStack
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
        )
      )
      .matchedTransitionSource(id: "personalBest-\(personalBest.medal.id)", in: namespace)
    }
    .buttonStyle(.plain)
  }

  private var pageIndicator: some View {
    HStack(spacing: .Space.stack) {
      ForEach(personalBests) { personalBest in
        Circle()
          .fill(Color.Text.secondary)
          .opacity(personalBest.id == currentID ? 1 : dimmedDot)
          .frame(width: dotSize, height: dotSize)
      }
    }  // HStack
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
