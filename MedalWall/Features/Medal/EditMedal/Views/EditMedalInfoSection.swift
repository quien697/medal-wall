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
  @Binding var distanceCategory: RaceDistanceCategory
  @Binding var distanceType: RaceDistanceType
  @Binding var customDistanceValue: Double
  
  var body: some View {
    Section("Info") {
      LabeledContent {
        TextField("e.g. Taipei Marathon 2025", text: $name)
          .multilineTextAlignment(.trailing)
      } label: {
        Text("Name")
          .fromLabelStyle()
      }
      
      DatePicker(
        selection: $date,
        displayedComponents: .date) {
          Text("Date")
            .fromLabelStyle()
        }
        .tint(Color.Badge.Gold.primary)
      
      LabeledContent {
        TextField("e.g. 4291 (Optional)", text: $bib)
          .multilineTextAlignment(.trailing)
      } label: {
        Text("Bib")
          .fromLabelStyle()
      }
      
      Picker(selection: $distanceCategory) {
        ForEach(RaceDistanceCategory.standardCases, id: \.self) { category in
          Text(category.description).tag(category)
        }
        Text("Custom").tag(RaceDistanceCategory.custom(customDistanceValue))
      } label: {
        Text("Distance")
          .fromLabelStyle()
      }
      
      if case .custom = distanceCategory {
        TextField(
          "Custom distance (km)",
          value: $customDistanceValue,
          format: .number
        )
        .multilineTextAlignment(.trailing)
        .keyboardType(.decimalPad)
        .onChange(of: customDistanceValue) { _, newValue in
          distanceCategory = .custom(newValue)
        }
      }
      
      Picker(selection: $distanceType) {
        ForEach(RaceDistanceType.allCases) { type in
          Text(type.displayName).tag(type)
        }
      } label: {
        Text("Distance Type")
          .fromLabelStyle()
      }
    } // Section
  }
}

#Preview {
  let medal = Medal.sampleData.first!
  
  Form {
    EditMedalInfoSection(
      name: .constant(medal.name),
      date: .constant(medal.date),
      bib: .constant(medal.bibNumber),
      distanceCategory: .constant(medal.distance.category),
      distanceType: .constant(medal.distance.type),
      customDistanceValue: .constant(0)
    )
  }
}
