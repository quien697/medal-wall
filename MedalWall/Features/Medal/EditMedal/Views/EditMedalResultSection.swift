//
//  EditMedalResultSection.swift
//  MedalWall
//
//  Created by Quien on 2026-04-14.
//

import SwiftUI
import TimePicker

struct EditMedalResultSection: View {
  @Binding var finishTime: TimeInterval?

  var body: some View {
    Section {
      TimePicker(
        "Finish Time",
        selection: $finishTime
      ) {
        Text("Finish Time")
          .fieldStyle(.label)
      }
      .timePickerStyle(accentColor: Color.Accent.primary, fontWeight: .bold)
    } header: {
      Text("Result")
        .sectionTitleStyle()
    }  // Section
  }
}

#Preview {
  @Previewable @State var noTime: TimeInterval?
  @Previewable @State var withTime: TimeInterval? = 5 * 3600 + 10 * 60 + 1

  Form {
    EditMedalResultSection(finishTime: $noTime)
    EditMedalResultSection(finishTime: $withTime)
  }
}
