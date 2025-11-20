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
  
  let mode: Mode
  let distance: RaceDistance
  let onSave: (RaceDistance) -> Void
  
  init(mode: Mode, distance: RaceDistance, onSave: @escaping (RaceDistance) -> Void) {
    self.mode = mode
    self.distance = distance
    self.draftDistance = distance
    self.customValue = {
      if case .custom(let value) = distance.category { return value }
      return 0
    }()
    self.onSave = onSave
  }
  
  var body: some View {
    Form {
      Section("Distance") {
        Picker("Distance", selection: $draftDistance.category) {
          Text("Full Marathon").tag(RaceDistanceCategory.full)
          Text("Half Marathon").tag(RaceDistanceCategory.half)
          Text("10K").tag(RaceDistanceCategory.`10K`)
          Text("5K").tag(RaceDistanceCategory.`5K`)
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
          onSave(draftDistance)
          dismiss()
        }
      }
    }
  }
}

#Preview {
  NavigationStack{
    RaceDistanceEditView(
      mode: .add,
      distance: Race.sampleData[0].distances[0],
      onSave: { _ in print("onSave") }
    )
  }
}
