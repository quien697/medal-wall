//
//  RaceEntryPicker.swift
//  MedalWall
//
//  Created by Quien on 2026-04-14.
//

import SwiftUI

struct RaceEntryPicker: View {
  @Environment(\.dismiss) private var dismiss
  @State private var selection: RaceEntry?
  @State private var races: [Race] = []
  @State private var editions: [String: [RaceEdition]] = [:]
  private let repository = RaceFirestoreRepository()
  let onSelect: (RaceEntry) -> Void

  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        RaceEntrySubTitle(selection: selection)

        Divider()

        if races.isEmpty {
          ContentUnavailableView {
            Label("No Race Events", systemImage: "flag.fill")
              .font(.TypeScale.title2)
              .foregroundStyle(Color.Text.primary)
          } description: {
            Text("Add race events to use auto-fill")
              .font(.TypeScale.body)
              .foregroundStyle(Color.Text.secondary)
          }  // ContentUnavailableView
        } else {
          RaceEntryList(races: races, editions: editions, selection: $selection)
        }
      }
      .navigationTitle("Pick Race Entry")
      .navigationBarTitleDisplayMode(.inline)
      .task {
        guard let fetched = try? await repository.fetchRaces() else { return }
        races = fetched
        for race in fetched {
          editions[race.id] = try? await repository.fetchEditions(raceId: race.id)
        }
      }
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button(role: .cancel) {
            dismiss()
          }
        }

        if let selection {
          ToolbarItem(placement: .confirmationAction) {
            Button(role: .confirm) {
              onSelect(selection)
              dismiss()
            }
          }
        }
      }  // toolbar
    }  // NavigationStack
  }
}

#Preview {
  RaceEntryPicker { _ in }
}
