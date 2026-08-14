//
//  DistanceUnitPicker.swift
//  MedalWall
//
//  Created by Quien on 2026-08-13.
//

import SwiftUI

struct DistanceUnitPicker: View {
  @Binding var distanceUnit: DistanceUnit

  var body: some View {
    Picker("Distance", selection: $distanceUnit) {
      ForEach(DistanceUnit.allCases, id: \.self) { unit in
        Text(unit.label)
          .tag(unit)
      }  // ForEach
    }  // Picker
    .pickerStyle(.navigationLink)
  }
}

#Preview("Kilometers") {
  NavigationStack {
    DistanceUnitPicker(distanceUnit: .constant(.kilometers))
  }
}

#Preview("Miles") {
  NavigationStack {
    DistanceUnitPicker(distanceUnit: .constant(.miles))
  }
}
