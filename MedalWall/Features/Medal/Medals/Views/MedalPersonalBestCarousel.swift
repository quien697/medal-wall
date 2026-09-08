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

  // MARK: - Body
  var body: some View {
    if personalBests.isEmpty {
      EmptyView()
    } else {
      ScrollView(.horizontal) {
        HStack(spacing: .Space.gutter) {
          ForEach(personalBests) { personalBest in
            NavigationLink {
              MedalDetailView(medal: personalBest.medal, isPersonalRecord: true)
                .navigationTransition(
                  .zoom(sourceID: Self.transitionID(for: personalBest), in: namespace)
                )
            } label: {
              MedalPersonalBestCard(
                distance: personalBest.category.description,
                finishTime: personalBest.medal.finishTime?.formattedHMS ?? "-",
                raceName: personalBest.medal.name,
                pace: DistanceUnit.resolved().paceText(
                  minutesPerKilometer: personalBest.medal.averagePace
                ),
                pageCount: personalBests.count,
                currentPage: currentPage
              )
              .matchedTransitionSource(
                id: Self.transitionID(for: personalBest),
                in: namespace
              )
            }
            .containerRelativeFrame(.horizontal, count: 1, spacing: .Space.gutter)
          }
        }  // HStack
        .scrollTargetLayout()
      }  // ScrollView
      .scrollIndicators(.hidden)
      .scrollTargetBehavior(.viewAligned)
      .scrollPosition(id: $scrolledID)
      .contentMargins(.horizontal, .Space.gutter, for: .scrollContent)
      .padding(.vertical, .Space.row)
    }
  }

  // MARK: - Computed
  /// Which card the scroll position is showing, for the dots the card draws.
  ///
  /// `scrollPosition` reports `nil` until the first scroll, and a stored position can name
  /// a distance the collection no longer holds. Both resolve to the first card rather than
  /// to no card at all, which would leave every dot dimmed.
  private var currentPage: Int {
    guard let scrolledID,
      let page = personalBests.firstIndex(where: { $0.id == scrolledID })
    else { return 0 }

    return page
  }

  // MARK: - Functions
  /// The zoom transition source for a record's card.
  ///
  /// Prefixed because the same medal's row declares `matchedTransitionSource(id: medal.id)`
  /// further down the screen, and two sources sharing an id in one namespace leave the
  /// transition with no way to choose.
  private static func transitionID(for personalBest: MedalPersonalBest) -> String {
    "personalBest-\(personalBest.medal.id)"
  }
}

/// Builds a record set for the previews below — `#Preview` bodies are `ViewBuilder`
/// closures, which take declarations and view expressions but not assignments.
private func previewPersonalBests(medals: [Medal] = Medal.sampleData) -> [MedalPersonalBest] {
  medals.personalBests
}

#Preview("Several records") {
  @Previewable @Namespace var namespace

  NavigationStack {
    MedalPersonalBestCarousel(personalBests: previewPersonalBests(), namespace: namespace)
      .background(Color.Background.primary)
  }  // NavigationStack
}

#Preview("One record") {
  @Previewable @Namespace var namespace

  NavigationStack {
    MedalPersonalBestCarousel(
      personalBests: previewPersonalBests(medals: Array(Medal.sampleData.prefix(1))),
      namespace: namespace
    )
    .background(Color.Background.primary)
  }  // NavigationStack
}

#Preview("No records") {
  @Previewable @Namespace var namespace

  NavigationStack {
    MedalPersonalBestCarousel(personalBests: previewPersonalBests(medals: []), namespace: namespace)
      .background(Color.Background.primary)
  }  // NavigationStack
}
