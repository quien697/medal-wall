//
//  RaceLocationSection.swift
//  MedalWall
//
//  Created by Quien on 2025-11-11.
//

import SwiftUI
import SwiftData

struct RaceLocationSection: View {
  @Binding var country: String
  @Binding var province: String
  @Binding var city: String
  @Binding var district: String
  
  var body: some View {
    Section("Race Location") {
      TextField("Country", text: $country)
      TextField("Province (option)", text: $province)
      TextField("City", text: $city)
      TextField("District (option)", text: $district)
    }
  }
}

#Preview(traits: .sampleData) {
  Form {
    RaceLocationSection(
      country: .constant("Taiwan"),
      province: .constant(""),
      city: .constant("Taipei"),
      district: .constant("")
    )
  }
}
