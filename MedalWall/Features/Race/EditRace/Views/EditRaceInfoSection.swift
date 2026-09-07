//
//  EditRaceInfoSection.swift
//  MedalWall
//
//  Created by Quien on 2025-11-26.
//

import PhotosUI
import SwiftUI

struct EditRaceInfoSection: View {
  @Binding var name: String
  @Binding var url: String
  let place: Place
  var onEditPlace: () -> Void

  var body: some View {
    Section {
      LabeledContent {
        TextField("e.g. Taipei Marathon", text: $name)
          .fromStyle(.value)
      } label: {
        Text("Name")
          .fromStyle(.label)
      }  // LabeledContent

      LabeledContent {
        TextField("optional", text: $url)
          .fromStyle(.value)
      } label: {
        Text("WebSite")
          .fromStyle(.label)
      }  // LabeledContent

      LabeledContent {
        HStack {
          Text(place.formatted.isEmpty ? .appLocalized("Select") : place.formatted)
            .font(.TypeScale.Field.value)

          Image(systemName: "chevron.right")
            .font(.TypeScale.overline)
            .padding(.leading, -6)
        }

        .foregroundStyle(place.formatted.isEmpty ? Color.Text.tertiary : Color.Text.primary)
        .onTapGesture {
          onEditPlace()
        }
      } label: {
        Text("Place")
          .fromStyle(.label)
      }  // LabeledContent
    } header: {
      Text("Info")
        .sectionTitleStyle()
    }  // Section
    .listRowBackground(Color.Surface.primary)
  }
}

#Preview {
  let race = Race.sampleData.first!

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
