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
    Section("Editions") {
      if isLoading && editions.isEmpty {
        ProgressView()
          .frame(maxWidth: .infinity, alignment: .center)
      } else if editions.isEmpty {
        ContentUnavailableView {
          Text("No editions yet.")
            .font(.TypeScale.body)
            .foregroundStyle(Color.Text.secondary)

          Button {
            onTapAddEdition()
          } label: {
            Label("Add Edition", systemImage: "plus")
              .labelStyle(.titleAndIcon)
              .actionStyle(.tertiary)
          }
          .buttonStyle(.plain)
          .padding(.top, 15)
          .matchedTransitionSource(id: transitionID, in: namespace)
        }  // ContentUnavailableView
      } else {
        ForEach(editions) { edition in
          Button {
            onTapEdition(edition)
          } label: {
            HStack(alignment: .top, spacing: 10) {
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
                }

                ScrollView(.horizontal, showsIndicators: false) {
                  HStack {
                    ForEach(edition.distances.sorted()) { distance in
                      Text(distance.displayLabel)
                        .tagStyle(.neutralInCard)
                    }
                  }  // HStack
                }  // ScrollView
              }  // VStack

              Spacer()
            }  // HStack
          }  // Button
          .buttonStyle(.plain)
        }  // ForEach
        .onDelete { offsets in
          for index in offsets {
            onDelete(editions[index].id)
          }
        }

        Button {
          onTapAddEdition()
        } label: {
          Label("Add Another Edition", systemImage: "plus")
            .labelStyle(.titleAndIcon)
            .actionStyle(.tertiary)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .matchedTransitionSource(id: transitionID, in: namespace)
      }
    }  // Section
  }
}

#Preview {
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
