//
//  EditRaceInfoSection.swift
//  MedalWall
//
//  Created by Quien on 2025-11-26.
//

import SwiftUI

struct EditRaceInfoSection: View {
  @Binding var name: String
  @Binding var url: String
  let place: Place
  let onEditPlace: () -> Void

  var body: some View {
    Section {
      LabeledContent {
        TextField("e.g. Taipei Marathon", text: $name)
          .fieldStyle(.value)
      } label: {
        Text("Name")
          .fieldStyle(.label)
      }  // LabeledContent

      LabeledContent {
        TextField("optional", text: $url)
          .fieldStyle(.value)
      } label: {
        Text("Website")
          .fieldStyle(.label)
      }  // LabeledContent

      LabeledContent {
        HStack {
          Text(place.formatted.isEmpty ? .appLocalized("Select") : place.formatted)
            .font(.TypeScale.Field.value)

          Image(systemName: "chevron.right")
            .font(.TypeScale.overline)
            .padding(.leading, -6)
        }  // HStack
        .foregroundStyle(place.formatted.isEmpty ? Color.Text.tertiary : Color.Text.primary)
        .onTapGesture {
          onEditPlace()
        }
      } label: {
        Text("Place")
          .fieldStyle(.label)
      }  // LabeledContent
    } header: {
      Text("Info")
        .sectionTitleStyle()
    }  // Section
    .listRowBackground(Color.Surface.primary)
  }
}

#Preview {
  let race = Race.taipei

  Form {
    EditRaceInfoSection(
      name: .constant(race.name),
      url: .constant(race.websiteUrl ?? ""),
      place: race.place,
      onEditPlace: {}
    )

    EditRaceInfoSection(
      name: .constant(race.name),
      url: .constant(""),
      place: Place(countryCode: "", city: ""),
      onEditPlace: {}
    )
  }
}
