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
  let onSelect: (RaceEntry) -> Void
  
  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        RaceEntrySubTitle(selection: selection)
        
        Divider()
        
        if races.isEmpty {
          ContentUnavailableView(
            "No Race Events",
            systemImage: "flag.fill",
            description: Text("Add race events to use auto-fill")
          )
        } else {
          RaceEntryList(races: races, editions: editions, selection: $selection)
        }
      }
      .navigationTitle("Pick Race Entry")
      .navigationBarTitleDisplayMode(.inline)
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
      } // toolbar
    } // NavigationStack
  }
}

#Preview(traits: .sampleData) {
  RaceEntryPicker { _ in }
}
