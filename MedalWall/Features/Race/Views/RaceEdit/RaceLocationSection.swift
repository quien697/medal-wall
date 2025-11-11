//
//  RaceLocationSection.swift
//  MedalWall
//
//  Created by Quien on 2025-11-11.
//

import SwiftUI
import SwiftData

struct RaceLocationSection: View {
  @Binding var viewModel: RaceEditViewModel
  
  var body: some View {
    Section("Race Location") {
      TextField("Country", text: $viewModel.country)
      TextField("Province (option)", text: $viewModel.province)
      TextField("City", text: $viewModel.city)
      TextField("District (option)", text: $viewModel.district)
    }
  }
}

#Preview(traits: .sampleData) {
  @Previewable @Query(sort: \Race.date) var races: [Race]
  let context = try! ModelContext(SampleData.makeSharedContext())
  
  Form {
    RaceLocationSection(
      viewModel: .constant(RaceEditViewModel(race: races.first!, context: context))
    )
  }
}
