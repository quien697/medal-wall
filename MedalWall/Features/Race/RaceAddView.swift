//
//  RaceAddView.swift
//  MedalWall
//
//  Created by Quien on 2025-11-05.
//

import SwiftUI
import SwiftData

struct RaceAddView: View {
  let viewModel: RaceEditViewModel
  
  var body: some View {
    RaceEditView(viewModel: viewModel)
  }
}

#Preview(traits: .sampleData) {
  @Previewable @Query(sort: \Race.date) var races: [Race]
  let context = try! ModelContext(SampleData.makeSharedContext())
  RaceAddView(viewModel: RaceEditViewModel(race: races[0], context: context))
}
