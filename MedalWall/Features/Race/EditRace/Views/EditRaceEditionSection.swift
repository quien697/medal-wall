//
//  EditRaceEditionSection.swift
//  MedalWall
//
//  Created by Quien on 2026-03-24.
//

import SwiftUI

struct EditRaceEditionSection: View {
  // MARK: - Properties
  let raceId: String
  let editions: [DraftRaceEdition]
  let isLoading: Bool
  let namespace: Namespace.ID
  let transitionID: String
  let onTapAddEdition: () -> Void
  let onTapEdition: (DraftRaceEdition) -> Void
  let onAdd: (DraftRaceEdition) -> Void
  let onUpdate: (DraftRaceEdition) -> Void
  let onDelete: (String) -> Void

  // MARK: - Body
  var body: some View {
    Section {
      if isLoading && editions.isEmpty {
        ProgressView()
          .frame(maxWidth: .infinity, alignment: .center)
      } else if editions.isEmpty {
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

                  Text(edition.dateDisplayLabel)
                    .font(.TypeScale.caption)
                    .foregroundStyle(Color.Text.tertiary)
                }  // HStack

                ScrollView(.horizontal, showsIndicators: false) {
                  HStack {
                    ForEach(edition.distances.sorted()) { distance in
                      Text(distance.displayLabel)
                        .tagStyle(.neutralInCard)
                    }
                  }  // HStack
                }  // ScrollView
              }  // VStack

              Image(systemName: "chevron.right")
                .foregroundStyle(Color.Text.tertiary)
            }  // HStack
          }  // Button
          .buttonStyle(.plain)
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
        }
        .actionStyle(
          .plain,
          font: .TypeScale.sectionTitle,
          vPadding: 0,
          hPadding: 0
        )
        .matchedTransitionSource(id: transitionID, in: namespace)
      }  // HStack
    }  // Section
    .listRowBackground(Color.Surface.primary)
  }
}

#Preview("Empty") {
  @Previewable @Namespace var namespace

  Form {
    EditRaceEditionSection(
      raceId: "race-taipei",
      editions: [],
      isLoading: false,
      namespace: namespace,
      transitionID: "transitionID",
      onTapAddEdition: {},
      onTapEdition: { _ in },
      onAdd: { _ in },
      onUpdate: { _ in },
      onDelete: { _ in }
    )
  }
}

#Preview("With Editions") {
  @Previewable @Namespace var namespace

  Form {
    EditRaceEditionSection(
      raceId: "race-taipei",
      editions: [
        DraftRaceEdition(from: .taipei2025),
        DraftRaceEdition(from: .taipei2019)
      ],
      isLoading: false,
      namespace: namespace,
      transitionID: "transitionID",
      onTapAddEdition: {},
      onTapEdition: { _ in },
      onAdd: { _ in },
      onUpdate: { _ in },
      onDelete: { _ in }
    )
  }
}
