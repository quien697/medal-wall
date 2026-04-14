//
//  TimePicker.swift
//  MedalWall
//
//  Created by Quien on 2026-01-04.
//

import SwiftUI

struct TimePicker: View {
  @Binding var value: TimeInterval?
  @State private var draftDuration: DurationHMS
  @State private var isShowingPickerView: Bool = false
  
  private var label: String
  
  init(
    _ label: String = "Time",
    selection value: Binding<TimeInterval?>
  ) {
    self.label = label
    self._value = value
    self._draftDuration = State(initialValue: value.wrappedValue.map { DurationHMS(timeInterval: $0) } ?? DurationHMS())
  }
  
  var body: some View {
    HStack {
      Text(label)
        .font(.callout)
        .foregroundColor(.primary)
      
      Spacer()
      
      Button {
        draftDuration = value.map { DurationHMS(timeInterval: $0) } ?? DurationHMS()
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
          
          Button(role: .destructive) {
            value = nil
            draftDuration = DurationHMS()
            isShowingPickerView = false
          } label: {
            Text("Clear")
          }
          .buttonStyle(.glassProminent)
          .padding(.horizontal)
          .padding(.bottom)
        } // VStack
        .navigationTitle("Select Time")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .cancellationAction) {
            Button(role: .cancel) {
              isShowingPickerView = false
            }
          }
          
          ToolbarItem(placement: .confirmationAction) {
            Button(role: .confirm) {
              value = draftDuration.isEmpty ? nil : draftDuration.timeInterval
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
      TimePicker("Result", selection: .constant(TimeInterval(3 * 3600 + 20 * 60 + 44)))
      TimePicker("Empty", selection: .constant(nil))
    }
    .navigationTitle("TimePicker Preview")
  }
}
