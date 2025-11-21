//
//  RaceFilterView.swift
//  MedalWall
//
//  Created by Quien on 2025-11-21.
//

import SwiftUI

struct RaceFilterView: View {
  @Environment(\.dismiss) private var dismiss
  @Binding var filter: RaceFilter
  @State private var draftFilter: RaceFilter
  
  init(filter: Binding<RaceFilter>) {
    self._filter = filter
    self._draftFilter = State(initialValue: filter.wrappedValue)
  }
  
  var body: some View {
    NavigationStack {
      Form {
        Section("Race Type") {
          ForEach(RaceDistanceType.allCases, id: \.self) { type in
            Toggle(isOn: Binding(
              get: { draftFilter.selectedTypes.contains(type) },
              set: { isOn in
                if isOn {
                  draftFilter.selectedTypes.insert(type)
                } else {
                  draftFilter.selectedTypes.remove(type)
                }
              }
            )) {
              Text(type.displayName)
            }
          }
        }
        
        Section("Race Distance") {
          ForEach(RaceDistanceCategory.standardCases, id: \.self) { category in
            Toggle(isOn: Binding(
              get: { draftFilter.selectedCategories.contains(category) },
              set: { isOn in
                if isOn {
                  draftFilter.selectedCategories.insert(category)
                } else {
                  draftFilter.selectedCategories.remove(category)
                }
              }
            )) {
              Text(category.description)
            }
          }

        }
        
        if !draftFilter.isEmpty {
          Button("Clean Filters", role: .destructive) {
            draftFilter = .default
          }
        }
      }
      .navigationTitle("Filters")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Apply") {
            filter = draftFilter
            dismiss()
          }
        }
      }
    }
  }
}

#Preview {
  RaceFilterView(filter: .constant(RaceFilter.default))
}
