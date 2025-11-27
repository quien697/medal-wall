//
//  RaceInfoSection.swift
//  MedalWall
//
//  Created by Quien on 2025-11-11.
//

import SwiftUI
import SwiftData

struct RaceInfoSection: View {
  @Binding var name: String
  @Binding var date: Date
  
  var body: some View {
    Section("Race Info") {
      TextField("Race Name", text: $name)
      DatePicker("Date", selection: $date, displayedComponents: .date)
    }
  }
}

#Preview(traits: .sampleData) {
  Form {
    RaceInfoSection(
      name: .constant("Taipei Marathon"),
      date: .constant(.now)
    )
  }
}
