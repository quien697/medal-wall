//
//  DistancePickerView.swift
//  MedalWall
//
//  Created by Quien on 2025-11-09.
//

import SwiftUI

struct DistancePickerView: View {
  @Binding var selection: RaceDistanceCategory
  
  var body: some View {
    Picker("Distance Category", selection: $selection) {
      Text("Full Marathon").tag(RaceDistanceCategory.full)
      Text("Half Marathon").tag(RaceDistanceCategory.half)
      Text("10K").tag(RaceDistanceCategory.`10K`)
      Text("5K").tag(RaceDistanceCategory.`5K`)
      Text("Custom").tag(RaceDistanceCategory.custom(selection.value))
    }
    .pickerStyle(.navigationLink)
  }
}

#Preview {
  @Previewable @State var category = RaceDistanceCategory.half
  DistancePickerView(selection: $category)
}
