//
//  RaceAdditionalSection.swift
//  MedalWall
//
//  Created by Quien on 2025-11-11.
//

import SwiftUI
import SwiftData

struct RaceAdditionalSection: View {
  @Binding var viewModel: RaceEditViewModel
  
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
  let context = try! ModelContext(SampleData.makeSharedContext())
  
  Form {
    RaceAdditionalSection(
      viewModel: .constant(RaceEditViewModel(race: races.first!, context: context))
    )
  }
}
