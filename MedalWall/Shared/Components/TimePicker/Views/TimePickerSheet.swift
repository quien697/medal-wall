//
//  TimePickerSheet.swift
//  MedalWall
//
//  Created by Quien on 2026-04-15.
//

import SwiftUI

struct TimePickerSheet: View {
  @Binding var draftDuration: HMSDuration
  @Binding var value: TimeInterval?
  @Binding var isPresenting: Bool
  let title: String
  let fontColor: Color

  var body: some View {
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

        DurationWheelPicker(duration: $draftDuration)

        Spacer()

        Divider()

        Button {
          value = nil
          draftDuration = HMSDuration()
        } label: {
          Text("Clear")
            .foregroundStyle(.red)
        }
        .padding(.vertical, 8)
      }  // VStack
      .navigationTitle(title)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button(role: .cancel) { isPresenting = false }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button(role: .confirm) {
            value = draftDuration.isEmpty ? nil : draftDuration.timeInterval
            isPresenting = false
          }
          .foregroundStyle(fontColor)
        }
      }  // toolbar
      .presentationDetents([.medium])
    }  // NavigationStack
  }
}

#Preview {
  TimePickerSheet(
    draftDuration: .constant(HMSDuration(3 * 3600 + 20 * 60 + 44)),
    value: .constant(nil),
    isPresenting: .constant(true),
    title: "Finish Time",
    fontColor: .orange
  )
}
