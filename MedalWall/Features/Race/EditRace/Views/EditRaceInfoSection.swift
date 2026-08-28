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
          .font(.TypeScale.fieldValue)
          .multilineTextAlignment(.trailing)
      } label: {
        Text("Name")
          .font(.TypeScale.callout)
          .foregroundStyle(Color.Text.secondary)
      }

      LabeledContent {
        TextField("optional", text: $url)
          .font(.TypeScale.fieldValue)
          .multilineTextAlignment(.trailing)
      } label: {
        Text("WebSite")
          .font(.TypeScale.callout)
          .foregroundStyle(Color.Text.secondary)
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
