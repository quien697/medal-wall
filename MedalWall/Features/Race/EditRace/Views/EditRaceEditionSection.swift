//
//  EditRaceEditionSection.swift
//  MedalWall
//
//  Created by Quien on 2026-03-24.
//

import SwiftUI

struct EditRaceEditionSection: View {
  // MARK: - Properties
  /// The editions to show: placeholders while they load.
  let editions: [DraftRaceEdition]
  /// Shows the editions as bones, under the real header, while they load.
  let isShowingSkeleton: Bool
  let namespace: Namespace.ID
  let transitionID: String
  let onTapAddEdition: () -> Void
  let onTapEdition: (DraftRaceEdition) -> Void
  let onDelete: (String) -> Void

  // MARK: - Body
  var body: some View {
    Section {
      if editions.isEmpty {
        ContentUnavailableView {
          Text("No editions yet.")
            .font(.TypeScale.body)
            .foregroundStyle(Color.Text.secondary)
        }  // ContentUnavailableView
      } else {
        ForEach(editions) { edition in
          Button {
            onTapEdition(edition)
          } label: {
            editionRow(edition)
          }  // Button
          .buttonStyle(.plain)
          // A form row is a card, though not drawn by `surfaceStyle()`.
          .environment(\.skeletonSurface, .card)
          .skeleton(isShowingSkeleton)
          // VoiceOver reads one "Loading" for the section, not one per placeholder row.
          .accessibilityHidden(isShowingSkeleton && edition.id != editions.first?.id)
          .deleteDisabled(isShowingSkeleton)
        }  // ForEach
        .onDelete { offsets in
          for index in offsets {
            onDelete(editions[index].id)
          }
        }
      }
    } header: {
      HStack {
        Text("Editions")
          .sectionTitleStyle()

        Spacer()

        Button {
          onTapAddEdition()
        } label: {
          Image(systemName: "plus")

          Text("Add")
            .textCase(.uppercase)
        }  // Button
        .actionStyle(
          .plain,
          font: .TypeScale.callout,
          vPadding: 0,
          hPadding: 0
        )
        .matchedTransitionSource(id: transitionID, in: namespace)
      }  // HStack
    }  // Section
    .listRowBackground(Color.Surface.primary)
  }

  // MARK: - Functions
  /// One edition: its logo, year, dates and distances, leading to its editor.
  private func editionRow(_ edition: DraftRaceEdition) -> some View {
    HStack(spacing: 10) {
      if let photo = edition.displayPhoto {
        PhotoImage(photo: photo, as: .raceThumbnail)
      } else {
        PhotoImage(urlString: edition.displayPhotoUrl, as: .raceThumbnail)
      }

      VStack(alignment: .leading, spacing: 5) {
        HStack(spacing: 10) {
          Text(String(edition.year))
            .font(.TypeScale.Numeric.medium)
            .foregroundStyle(Color.Text.primary)
            .skeletonBone(.numericMedium)

          Text(edition.dateDisplayLabel)
            .font(.TypeScale.caption)
            .foregroundStyle(Color.Text.tertiary)
            .skeletonBone(.caption)
        }  // HStack

        ScrollView(.horizontal, showsIndicators: false) {
          HStack {
            ForEach(edition.distances.sorted()) { distance in
              Text(distance.displayLabel)
                .tagStyle(.neutralInCard)
            }  // ForEach
          }  // HStack
        }  // ScrollView
      }  // VStack

      Image(systemName: "chevron.right")
        .foregroundStyle(Color.Text.tertiary)
    }  // HStack
  }
}

#Preview("Empty") {
  @Previewable @Namespace var namespace

  Form {
    EditRaceEditionSection(
      editions: [],
      isShowingSkeleton: false,
      namespace: namespace,
      transitionID: "transitionID",
      onTapAddEdition: {},
      onTapEdition: { _ in },
      onDelete: { _ in }
    )
  }
}

#Preview("With Editions") {
  @Previewable @Namespace var namespace

  Form {
    EditRaceEditionSection(
      editions: [
        DraftRaceEdition(from: .taipei2025),
        DraftRaceEdition(from: .taipei2019)
      ],
      isShowingSkeleton: false,
      namespace: namespace,
      transitionID: "transitionID",
      onTapAddEdition: {},
      onTapEdition: { _ in },
      onDelete: { _ in }
    )
  }
}

#Preview("Loading") {
  @Previewable @Namespace var namespace

  Form {
    EditRaceEditionSection(
      editions: DraftRaceEdition.placeholders,
      isShowingSkeleton: true,
      namespace: namespace,
      transitionID: "transitionID",
      onTapAddEdition: {},
      onTapEdition: { _ in },
      onDelete: { _ in }
    )
  }
}
