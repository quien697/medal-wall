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
  // MARK: - Namespace
  @Namespace private var namespace
  private let addMedal: String = "addMedal"
  // MARK: - Query
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
            spacing: viewModel.gridSpacing,
            namespace: namespace
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
            Button {
              isPresentingAddMedal = true
            } label: {
              Image(systemName: "plus")
            }
            .matchedTransitionSource(id: addMedal, in: namespace)
            .tint(Color.Badge.Gold.primary)
            .buttonStyle(.glassProminent)
          }
        } // toolbar
        .sheet(isPresented: $isPresentingAddMedal) {
          AddMedalView()
            .navigationTransition(.zoom(sourceID: addMedal, in: namespace))
        }
      }
    } // NavigationStack
  }
}

#Preview(traits: .sampleData) {
  MedalsView()
}
