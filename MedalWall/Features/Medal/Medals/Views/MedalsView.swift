//
//  MedalsView.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import SwiftUI
import SwiftData

struct MedalsView: View {
  // MARK: - Environment
  @Environment(\.modelContext) private var modelContext
  // MARK: - State
  @State private var viewModel: MedalsViewModel = MedalsViewModel()
  @State private var errorWrapper: ErrorWrapper?
  @State private var isPresentingAddMedal = false
  
  @Query private var medals: [Medal]
  
  // MARK: - Body
  var body: some View {
    NavigationStack {
      if medals.isEmpty {
        ContentUnavailableView(
          "No Medals",
          systemImage: "tray",
          description: Text("Tap the + button to add your first medal!")
        )
      } else {
        ScrollView {
          MedalStatsSection(
            totalCount: viewModel.totalCount(medals),
            fullCount: viewModel.fullCount(medals),
            halfCount: viewModel.halfCount(medals)
          )
          
          MedalGridSection(
            medals: medals,
            columns: viewModel.gridColumns,
            spacing: viewModel.gridSpacing
          )
        } // ScrollView
        .scrollIndicators(.hidden)
        .navigationTitle("Your Rewards")
        .background(Color.Background.primary)
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbarRole(.editor)
        .toolbar {
          ToolbarItem(placement: .title) {
            ExpandedNavigationTitle(title: "Your Rewards")
          }
          
          ToolbarItem(placement: .topBarTrailing) {
            Button("Add Medal", systemImage: "plus") {
              isPresentingAddMedal = true
            }
            .buttonStyle(.glassProminent)
          }
        } // toolbar
        .sheet(isPresented: $isPresentingAddMedal) {
          //      MedalAddView(user: user)
        }
      }
    } // NavigationStack
  }
}

#Preview(traits: .sampleData) {
  MedalsView()
}
