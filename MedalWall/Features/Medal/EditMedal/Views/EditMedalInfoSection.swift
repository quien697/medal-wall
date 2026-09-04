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
  let place: Place
  let distance: String
  var onEditPlace: () -> Void
  var onEditDistance: () -> Void

  var body: some View {
    Section("Info") {
      LabeledContent {
        TextField("e.g. Taipei Marathon 2025", text: $name)
          .fromStyle(.value)
      } label: {
        Text("Name")
          .fromStyle(.label)
      }

      DatePicker(
        selection: $date,
        displayedComponents: .date
      ) {
        Text("Date")
          .fromStyle(.label)
      }

      LabeledContent {
        TextField("e.g. 4291 (Optional)", text: $bib)
          .fromStyle(.value)
      } label: {
        Text("Bib")
          .fromStyle(.label)
      }

      HStack {
        Text("Distance")
          .fromStyle(.label)

        Spacer()

        Button {
          onEditDistance()
        } label: {
          Text(distance)
            .fromStyle(.value)
        }
        .buttonStyle(.bordered)
      }  // HStack

      LabeledContent {
        Text(place.formatted.isEmpty ? .appLocalized("Choose a place") : place.formatted)
          .fromStyle(.value)
          .foregroundStyle(place.formatted.isEmpty ? .secondary : .primary)
          .onTapGesture {
            onEditPlace()
          }
      } label: {
        Text("Place")
          .fromStyle(.label)
      }  // LabeledContent
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
      place: medal.place,
      distance: medal.distance.displayLabel,
      onEditPlace: {},
      onEditDistance: {}
    )
  }
}
