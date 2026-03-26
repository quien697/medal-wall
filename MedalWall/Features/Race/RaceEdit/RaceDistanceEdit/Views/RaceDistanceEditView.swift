//
//  RaceDistanceEditView.swift
//  MedalWall
//
//  Created by Quien on 2025-11-08.
//

import SwiftUI

struct RaceDistanceEditView: View {
  @Environment(\.dismiss) private var dismiss
  
  @State private var draftDistance: RaceDistance
  @State private var customValue: Double
  
  let mode: RaceEditMode
  let distance: RaceDistance
  let onUpdate: (RaceDistance) -> Void
  
  init(mode: RaceEditMode, distance: RaceDistance, onUpdate: @escaping (RaceDistance) -> Void) {
    self.mode = mode
    self.distance = distance
    self.draftDistance = distance
    self.customValue = {
      if case .custom(let value) = distance.category { return value }
      return 0
    }()
    self.onUpdate = onUpdate
  }
  
  var body: some View {
    Form {
      Section("Distance") {
        Picker("Distance", selection: $draftDistance.category) {
          Text("Full Marathon").tag(RaceDistanceCategory.full)
          Text("Half Marathon").tag(RaceDistanceCategory.half)
          Text("10K").tag(RaceDistanceCategory.`10KM`)
          Text("5K").tag(RaceDistanceCategory.`5KM`)
          Text("Custom").tag(RaceDistanceCategory.custom(customValue))
        }
        .pickerStyle(.navigationLink)
        
        if case .custom = draftDistance.category {
          TextField("Custom distance (km)", value: $customValue, format: .number)
            .keyboardType(.decimalPad)
            .onChange(of: customValue) { _, newValue in
              draftDistance.category = .custom(newValue)
            }
        }
      } // Section
      
      Section("Distance Type") {
        Picker("Distance Type", selection: $draftDistance.type) {
          Text(RaceDistanceType.inPerson.displayName)
            .tag(RaceDistanceType.inPerson)
          Text(RaceDistanceType.virtual.displayName)
            .tag(RaceDistanceType.virtual)
        }
        .pickerStyle(.segmented)
      } // Section
    } // Form
    .navigationTitle(mode == .add ? "Add Distance" : "Edit Distance")
    .toolbar {
      if mode == .add {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") {
            dismiss()
          }
        }
      }
      
      ToolbarItem(placement: .confirmationAction) {
        Button(mode == .add ? "Add": "Update") {
          onUpdate(draftDistance)
          dismiss()
        }
      }
    } // toolbar
  }
}

#Preview {
  NavigationStack{
    RaceDistanceEditView(
      mode: .add,
      distance: RaceDistance(category: .half, type: .inPerson),
      onUpdate: { _ in }
    )
  }
}
