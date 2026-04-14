//
//  EditMedalLocationSection.swift
//  MedalWall
//
//  Created by Quien on 2026-04-13.
//

import SwiftUI

struct EditMedalLocationSection: View {
  @Binding var country: String
  @Binding var province: String
  @Binding var city: String
  @Binding var district: String
  
  var body: some View {
    Section("Location") {
      LabeledContent {
        TextField("e.g. Taiwan", text: $country)
          .multilineTextAlignment(.trailing)
      } label: {
        Text("Country")
          .fromLabelStyle()
      }
      
      LabeledContent {
        TextField("Optional", text: $province)
          .multilineTextAlignment(.trailing)
      } label: {
        Text("Province")
          .fromLabelStyle()
      }
      
      LabeledContent {
        TextField("e.g. Taipei", text: $city)
          .multilineTextAlignment(.trailing)
      } label: {
        Text("City")
          .fromLabelStyle()
      }
      
      LabeledContent {
        TextField("Optional", text: $district)
          .multilineTextAlignment(.trailing)
      } label: {
        Text("District")
          .fromLabelStyle()
      }
    } // Section
  }
}

#Preview {
  Form {
    EditMedalLocationSection(
      country: .constant("Taiwan"),
      province: .constant(""),
      city: .constant("Taipei"),
      district: .constant("")
    )
    
    EditMedalLocationSection(
      country: .constant("Canada"),
      province: .constant("BC"),
      city: .constant("Vancouver"),
      district: .constant("")
    )
  }
}
