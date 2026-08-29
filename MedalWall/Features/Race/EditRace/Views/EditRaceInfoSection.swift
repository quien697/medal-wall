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

  var body: some View {
    Section("Info") {
      LabeledContent {
        TextField("e.g. Taipei Marathon", text: $name)
          .font(.TypeScale.Field.value)
          .multilineTextAlignment(.trailing)
      } label: {
        Text("Name")
          .font(.TypeScale.Field.label)
          .foregroundStyle(Color.Text.tertiary)
      }

      LabeledContent {
        TextField("optional", text: $url)
          .font(.TypeScale.Field.value)
          .multilineTextAlignment(.trailing)
      } label: {
        Text("WebSite")
          .font(.TypeScale.Field.label)
          .foregroundStyle(Color.Text.tertiary)
      }
    }  // Section
  }
}

#Preview {
  let race = Race.sampleData.first!

  Form {
    EditRaceInfoSection(
      name: .constant(race.name),
      url: .constant(race.websiteUrl ?? "")
    )

    EditRaceInfoSection(
      name: .constant(race.name),
      url: .constant("")
    )
  }
}
