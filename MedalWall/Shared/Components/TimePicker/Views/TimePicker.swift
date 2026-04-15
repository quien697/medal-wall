//
//  TimePicker.swift
//  MedalWall
//
//  Created by Quien on 2026-01-04.
//

import SwiftUI

struct TimePicker<Label: View>: View {
  // MARK: - State
  @State private var draftDuration: HMSDuration
  @State private var isPresentingPickerView: Bool = false
  // MARK: - Properties
  private var label: Label
  private var title: String
  private var fontColor: Color
  private var fontWeight: Font.Weight
  @Binding var value: TimeInterval?
  
  // MARK: - Init
  init(
    _ title: String = "Select Time",
    fontColor: Color? = nil,
    fontWeight: Font.Weight? = nil,
    selection value: Binding<TimeInterval?>
  ) where Label == Text {
    self.title = title
    self.fontColor = fontColor ?? .primary
    self.fontWeight = fontWeight ?? .regular
    self.label = Text(title)
    self._value = value
    self._draftDuration = State(initialValue: HMSDuration(value.wrappedValue))
  }
  
  // MARK: - Custom label init
  init(
    _ title: String = "Select Time",
    fontColor: Color? = nil,
    fontWeight: Font.Weight? = nil,
    selection value: Binding<TimeInterval?>,
    @ViewBuilder label: () -> Label
  ) {
    self.title = title
    self.fontColor = fontColor ?? .primary
    self.fontWeight = fontWeight ?? .regular
    self.label = label()
    self._value = value
    self._draftDuration = State(initialValue: HMSDuration(value.wrappedValue))
  }
  
  // MARK: - Computed
  private var currentDuration: HMSDuration { HMSDuration(value) }
  
  // MARK: - Body
  var body: some View {
    HStack {
      label
      
      Spacer()
      
      Button {
        draftDuration = currentDuration
        isPresentingPickerView = true
      } label: {
        Text(currentDuration.displayString)
          .fontWeight(fontWeight)
          .foregroundStyle(fontColor)
      }
      .buttonStyle(.bordered)
    } // HStack
    .sheet(isPresented: $isPresentingPickerView) {
      TimePickerSheet(
        draftDuration: $draftDuration,
        value: $value,
        isPresenting: $isPresentingPickerView,
        title: title,
        fontColor: fontColor
      )
    }
  }
}

#Preview {
  NavigationStack {
    Form {
      TimePicker("Finish Time", selection: .constant(TimeInterval(3 * 3600 + 20 * 60 + 44)))
      TimePicker("Finish Time", selection: .constant(nil)) {
        Text("Finish Time")
      }
    }
    .navigationTitle("TimePicker Preview")
  }
}
