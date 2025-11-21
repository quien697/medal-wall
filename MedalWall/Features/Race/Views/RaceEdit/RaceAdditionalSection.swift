//
//  RaceAdditionalSection.swift
//  MedalWall
//
//  Created by Quien on 2025-11-11.
//

import SwiftUI
import SwiftData

struct RaceAdditionalSection: View {
  @Bindable var viewModel: RaceEditViewModel
  
  var body: some View {
    Section("Additional Details") {
      TextField("Official Website (option)", text: $viewModel.url)
        .keyboardType(.URL)
        .textInputAutocapitalization(.never)
    }
  }
}

#Preview(traits: .sampleData) {
  @Previewable @Query(sort: \Race.date) var races: [Race]
  
  Form {
    RaceAdditionalSection(
      viewModel: RaceEditViewModel(race: races.first!)
    )
  }
}
