//
//  RaceInfoSection.swift
//  MedalWall
//
//  Created by Quien on 2025-11-11.
//

import SwiftUI
import SwiftData

struct RaceInfoSection: View {
  @Binding var viewModel: RaceEditViewModel
  
  var body: some View {
    Section("Race Info") {
      TextField("Race Name", text: $viewModel.name)
      TextField("Race Photo (option)", text: $viewModel.photo)
      DatePicker("Date", selection: $viewModel.date, displayedComponents: .date)
    }
  }
}

#Preview(traits: .sampleData) {
  @Previewable @Query(sort: \Race.date) var races: [Race]
  let context = try! ModelContext(SampleData.makeSharedContext())
  
  Form {
    RaceInfoSection(
      viewModel: .constant(RaceEditViewModel(race: races.first!, context: context))
    )
  }
}
