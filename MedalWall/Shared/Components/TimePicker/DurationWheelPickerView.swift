//
//  DurationWheelPickerView.swift
//  MedalWall
//
//  Created by Quien on 2026-01-05.
//

import SwiftUI

struct DurationWheelPickerView: View {
  @Binding var duration: DurationHMS
  
  var body: some View {
    HStack {
      DurationWheelPicker(
        title: "Hour",
        value: $duration.hours,
        range: 0...24)
      
      DurationWheelPicker(
        title: "Min",
        value: $duration.minutes,
        range: 0...59)
      
      DurationWheelPicker(
        title: "Sec",
        value: $duration.seconds,
        range: 0...59)
    }
  }
}

#Preview {
  DurationWheelPickerView(duration: .constant(DurationHMS()))
}
