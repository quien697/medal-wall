//
//  EditMedalInfoSection.swift
//  MedalWall
//
//  Created by Quien on 2026-04-13.
//

import SwiftUI

struct EditMedalInfoSection: View {
  @Binding var name: String
  @Binding var date: Date
  @Binding var bib: String
  let distance: String
  var onEditDistance: () -> Void

  var body: some View {
    Section("Info") {
      LabeledContent {
        TextField("e.g. Taipei Marathon 2025", text: $name)
          .multilineTextAlignment(.trailing)
      } label: {
        Text("Name")
          .fromLabelStyle()
      }

      DatePicker(
        selection: $date,
        displayedComponents: .date
      ) {
        Text("Date")
          .fromLabelStyle()
      }

      LabeledContent {
        TextField("e.g. 4291 (Optional)", text: $bib)
          .multilineTextAlignment(.trailing)
      } label: {
        Text("Bib")
          .fromLabelStyle()
      }

      HStack {
        Text("Distance")
          .fromLabelStyle()

        Spacer()

        Button {
          onEditDistance()
        } label: {
          Text(distance)
            .foregroundStyle(Color.Text.primary)
        }
        .buttonStyle(.bordered)
      }
    }  // Section
  }
}

#Preview {
  let medal = Medal.sampleData.first!

  Form {
    EditMedalInfoSection(
      name: .constant(medal.name),
      date: .constant(medal.date),
      bib: .constant(medal.bibNumber),
      distance: medal.distance.displayLabel,
      onEditDistance: {}
    )
  }
}
