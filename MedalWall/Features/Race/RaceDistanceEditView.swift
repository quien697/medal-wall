//
//  RaceDistanceEditView.swift
//  MedalWall
//
//  Created by Quien on 2025-11-08.
//

import SwiftUI
import _SwiftData_SwiftUI

struct RaceDistanceEditView: View {
  @Environment(\.dismiss) private var dismiss
  @Binding var distance: RaceDistance
  
  var body: some View {
    Form {
      Section("Distance") {
        Picker("Distance", selection: $distance.category) {
          Text("Full Marathon").tag(RaceDistanceCategory.full)
          Text("Half Marathon").tag(RaceDistanceCategory.half)
          Text("10K").tag(RaceDistanceCategory.`10K`)
          Text("5K").tag(RaceDistanceCategory.`5K`)
          Text("Custom").tag(RaceDistanceCategory.custom(distance.category.value))
        }
        .pickerStyle(.navigationLink)
        
        if case .custom = distance.category {
          TextField("Custom distance (km)", value: Binding(
            get: { distance.category.value },
            set: { distance.category = .custom($0) }
          ), format: .number)
          .keyboardType(.decimalPad)
        }
      } // Section
      
      Section("Distance Type") {
        Picker("Distance Type", selection: $distance.type) {
          Text(RaceDistanceType.inPerson.displayName)
            .tag(RaceDistanceType.inPerson)
          Text(RaceDistanceType.virtual.displayName)
            .tag(RaceDistanceType.virtual)
        }
        .pickerStyle(.segmented)
      } // Section
    } // Form
  }
}

#Preview(traits: .sampleData) {
  @Previewable @Query(sort: \Race.date) var races: [Race]
  
  NavigationStack{
    RaceDistanceEditView(distance: .constant(races[0].distances[0]))
  }
}
