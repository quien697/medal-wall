//
//  DurationWheelPicker.swift
//  MedalWall
//
//  Created by Quien on 2026-01-04.
//

import SwiftUI

struct DurationWheelPicker: View {
  let title: String
  @Binding var value: Int
  let range: ClosedRange<Int>
  
  var body: some View {
    VStack(alignment: .center, spacing: 0) {
      Picker(title, selection: $value) {
        ForEach(range, id: \.self) { value in
          Text("\(value)")
            .monospacedDigit()
            .tag(value)
        }
      }
      .pickerStyle(.wheel)
      .frame(height: 120)
      .clipped()
      
      Text(title)
    }
    .frame(minWidth: 60)
  }
}

#Preview {
  let duration: DurationHMS = DurationHMS()
  
  HStack {
    DurationWheelPicker(
      title: "Hour",
      value: .constant(duration.hours),
      range: 0...24
    )
    
    DurationWheelPicker(
      title: "Min",
      value: .constant(duration.minutes),
      range: 0...60
    )
  }
}
