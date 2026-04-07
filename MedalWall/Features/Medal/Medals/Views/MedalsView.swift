//
//  MedalsView.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import SwiftUI
import SwiftData

struct MedalsView: View {
  @Environment(\.modelContext) private var modelContext
  @State private var viewModel = MedalsViewModel()
  @State private var errorWrapper: ErrorWrapper?

  var body: some View {
    MedalGrid(
      columns: viewModel.gridColumns,
      spacing: viewModel.gridSpacing
    )
    .navigationTitle("Your Rewards")
    .background(Color.Background.primary)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button("Add Medal", systemImage: "plus") {
//          isShowingMedalAddView = true
        }
      }
    }
//    .sheet(isPresented: $isShowingMedalAddView) {
//      if let user {
//        NavigationStack {
//          MedalAddView(user: user)
//        }
//      }
//    }
  }
}

#Preview(traits: .sampleData) {
  MedalsView()
}
