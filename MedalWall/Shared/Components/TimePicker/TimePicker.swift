//
//  TimePicker.swift
//  MedalWall
//
//  Created by Quien on 2026-01-04.
//

import SwiftUI

struct TimePicker<Label: View>: View {
  // MARK: - State
  @State private var draftDuration: DurationHMS
  @State private var isShowingPickerView: Bool = false
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
    self._draftDuration = State(initialValue: value.wrappedValue.map { DurationHMS(timeInterval: $0) } ?? DurationHMS())
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
    self._draftDuration = State(initialValue: value.wrappedValue.map { DurationHMS(timeInterval: $0) } ?? DurationHMS())
  }

  // MARK: - Body
  var body: some View {
    HStack {
      label

      Spacer()

      Button {
        draftDuration = value.map { DurationHMS(timeInterval: $0) } ?? DurationHMS()
        isShowingPickerView = true
      } label: {
        Text((value.map { DurationHMS(timeInterval: $0) } ?? DurationHMS()).displayString)
          .fontWeight(fontWeight)
          .foregroundStyle(fontColor)
      }
      .buttonStyle(.bordered)
    } // HStack
    .sheet(isPresented: $isShowingPickerView) {
      NavigationStack {
        VStack {
          Text(draftDuration.formattedString)
            .font(.title)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity)
            .padding(.vertical)
            .foregroundStyle(fontColor)
            .background(fontColor.opacity(0.1))
            .clipShape(.rect(cornerRadius: 20))
            .overlay(
              RoundedRectangle(cornerRadius: 20)
                .stroke(fontColor.opacity(0.3), lineWidth: 1)
            )
            .padding()

          DurationWheelPickerView(duration: $draftDuration)

          Spacer()

          Divider()

          Button {
            value = nil
            draftDuration = DurationHMS()
          } label: {
            Text("Clear")
              .tint(.red)
          }
          .padding(.vertical, 8)
        } // VStack
        .navigationTitle(title)
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
            .tint(fontColor)
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
      // String init
      TimePicker("Finish Time", selection: .constant(TimeInterval(3 * 3600 + 20 * 60 + 44)))

      // Custom label init
      TimePicker("Finish Time", selection: .constant(nil)) {
        Text("Finish Time")
          .fromLabelStyle()
      }
    }
    .navigationTitle("TimePicker Preview")
  }
}
