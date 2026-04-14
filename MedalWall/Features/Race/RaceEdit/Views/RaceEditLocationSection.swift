//
//  RaceEditLocationSection.swift
//  MedalWall
//
//  Created by Quien on 2025-11-11.
//

import SwiftUI

struct RaceEditLocationSection: View {
  @Binding var country: String
  @Binding var province: String
  @Binding var city: String
  @Binding var district: String
  
  var body: some View {
    Section("Location") {
      LabeledContent {
        TextField("Country", text: $country)
          .multilineTextAlignment(.trailing)
      } label: {
        Text("Country")
          .fontWeight(.bold)
          .foregroundStyle(Color.Text.tertiary)
      }
      
      LabeledContent {
        TextField("Province (optional)", text: $province)
          .multilineTextAlignment(.trailing)
      } label: {
        Text("Province")
          .fontWeight(.bold)
          .foregroundStyle(Color.Text.tertiary)
      }
      
      LabeledContent {
        TextField("City", text: $city)
          .multilineTextAlignment(.trailing)
      } label: {
        Text("City")
          .fontWeight(.bold)
          .foregroundStyle(Color.Text.tertiary)
      }
      
      LabeledContent {
        TextField("District (optional)", text: $district)
          .multilineTextAlignment(.trailing)
      } label: {
        Text("District")
          .fontWeight(.bold)
          .foregroundStyle(Color.Text.tertiary)
      }
    } // Section
  }
}

#Preview {
  Form {
    RaceEditLocationSection(
      country: .constant("Taiwan"),
      province: .constant(""),
      city: .constant("Taipei"),
      district: .constant("")
    )
    
    RaceEditLocationSection(
      country: .constant("Canada"),
      province: .constant("BC"),
      city: .constant("Vancouver"),
      district: .constant("")
    )
  }
}
