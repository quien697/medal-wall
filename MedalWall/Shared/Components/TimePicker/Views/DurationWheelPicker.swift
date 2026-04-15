//
//  DurationWheelPicker.swift
//  MedalWall
//
//  Created by Quien on 2026-01-05.
//

import SwiftUI

struct DurationWheelPicker: View {
  @Binding var duration: HMSDuration
  
  var body: some View {
    HStack {
      WheelUnitPicker(
        title: "Hour",
        value: $duration.hours,
        range: 0...24)
      
      WheelUnitPicker(
        title: "Min",
        value: $duration.minutes,
        range: 0...59)
      
      WheelUnitPicker(
        title: "Sec",
        value: $duration.seconds,
        range: 0...59)
    }
  }
}

#Preview {
  DurationWheelPicker(duration: .constant(HMSDuration()))
}
