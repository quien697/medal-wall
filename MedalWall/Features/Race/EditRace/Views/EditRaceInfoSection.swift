//
//  EditRaceInfoSection.swift
//  MedalWall
//
//  Created by Quien on 2025-11-26.
//

import SwiftUI
import PhotosUI

struct EditRaceInfoSection: View {
  @Binding var name: String
  @Binding var url: String
  
  var body: some View {
    Section("Info") {
      LabeledContent {
        TextField("e.g. Taipei Marathon", text: $name)
          .multilineTextAlignment(.trailing)
      } label: {
        Text("Name")
          .fontWeight(.bold)
          .foregroundStyle(Color.Text.tertiary)
      }
      
      LabeledContent {
        TextField("optional", text: $url)
          .multilineTextAlignment(.trailing)
      } label: {
        Text("WebSite")
          .fontWeight(.bold)
          .foregroundStyle(Color.Text.tertiary)
      }
    } // Section
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
