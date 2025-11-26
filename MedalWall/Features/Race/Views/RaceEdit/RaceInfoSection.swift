//
//  RaceInfoSection.swift
//  MedalWall
//
//  Created by Quien on 2025-11-11.
//

import SwiftUI
import SwiftData

struct RaceInfoSection: View {
  @Bindable var viewModel: RaceEditViewModel
  
  var body: some View {
    Section("Race Info") {
      TextField("Race Name", text: $viewModel.name)
      DatePicker("Date", selection: $viewModel.date, displayedComponents: .date)
    }
  }
}

#Preview(traits: .sampleData) {
  @Previewable @Query(sort: \Race.date) var races: [Race]
  
  Form {
    RaceInfoSection(
      viewModel: RaceEditViewModel(race: races.first!)
    )
  }
}
