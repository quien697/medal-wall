//
//  TimePicker.swift
//  MedalWall
//
//  Created by Quien on 2026-01-04.
//

import SwiftUI

struct TimePicker: View {
  @Binding var value: String
  @State private var draftDuration: DurationHMS
  @State private var isShowingPickerView: Bool = false
  
  private var label: String
  private var isShowingClearButton: Bool
  
  init(
    _ label: String = "Time",
    selection value: Binding<String>,
    isShowingClearButton: Bool = true
  ){
    self.label = label
    self.isShowingClearButton = isShowingClearButton
    self._value = value
    self._draftDuration = State(initialValue: DurationHMS.parse(value.wrappedValue) ?? DurationHMS())
  }
  
  var body: some View {
    HStack {
      Text(label)
        .font(.callout)
        .foregroundColor(.primary)
      
      Spacer()

      if isShowingClearButton && !value.isEmpty && !draftDuration.isEmpty {
        Button(action: {
          value = ""
          draftDuration = DurationHMS()
        }) {
          Image(systemName: "xmark.circle.fill")
            .imageScale(.large)
            .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(.isButton)
      }
      
      Button {
        draftDuration = DurationHMS.parse(value) ?? DurationHMS()
        isShowingPickerView = true
      } label: {
        Text(draftDuration.stringValue)
      }
      .buttonStyle(.bordered)
    } // HStack
    .sheet(isPresented: $isShowingPickerView) {
      NavigationStack {
        VStack {
          DurationWheelPickerView(duration: $draftDuration)
            .padding(.top)

          Spacer()

          if isShowingClearButton {
            Button(role: .destructive) {
              value = ""
              draftDuration = DurationHMS()
              isShowingPickerView = false
            } label: {
              Text("Clear")
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            .padding(.bottom)
          }
        } // VStack
        .navigationTitle("Select Time")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") {
              isShowingPickerView = false
            }
          }

          ToolbarItem(placement: .confirmationAction) {
            Button("Done") {
              value = draftDuration.stringValue
              isShowingPickerView = false
            }
          }
        } // toolbar
        .presentationDetents([.medium])
      } // NavigationStack
    } // sheet
  }
}

#Preview {
  NavigationStack {
    Form {
      TimePicker("Result", selection: .constant("03:20:44"))
      TimePicker("Empty", selection: .constant(""))
    }
    .navigationTitle("TimePicker Preview")
  }
}
