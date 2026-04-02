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

  var body: some View {
    MedalGrid()
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
