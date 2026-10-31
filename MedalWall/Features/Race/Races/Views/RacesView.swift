//
//  RacesView.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import SwiftUI

struct RacesView: View {
  // MARK: - State
  @State private var viewModel = RacesViewModel()
  @State private var errorWrapper: ErrorWrapper?
  @State private var isPresentingAddRace = false

  // MARK: - Namespace
  @Namespace private var namespace
  private let addRace = "addRace"

  // MARK: - Body
  var body: some View {
    NavigationStack {
      RaceList(races: viewModel.displayedRaces)
        .skeleton(viewModel.isShowingSkeleton)
        .scrollIndicators(.hidden)
        .navigationTitle("Races")
        .background(Color.Background.primary)
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbarRole(.editor)
        .task {
          await viewModel.loadRaces()
        }
        .toolbar {
          ToolbarItem(placement: .title) {
            ExpandedNavigationTitle(title: "Races")
          }  // ToolbarItem

          ToolbarItem(placement: .topBarTrailing) {
            Button {
              isPresentingAddRace = true
            } label: {
              Image(systemName: "plus")
            }  // Button
            .matchedTransitionSource(id: addRace, in: namespace)
            .buttonStyle(.glassProminent)
          }  // ToolbarItem
        }  // toolbar
        .onChange(of: viewModel.error) { _, error in
          if let error {
            errorWrapper = ErrorWrapper(error: error)
          }
        }
        .sheet(
          isPresented: $isPresentingAddRace,
          onDismiss: {
            Task {
              await viewModel.loadRaces()
            }
          },
          content: {
            AddRaceView()
              .navigationTransition(.zoom(sourceID: addRace, in: namespace))
          }
        )
        .sheet(
          item: $errorWrapper,
          onDismiss: { viewModel.error = nil },
          content: { wrapper in
            ErrorView(errorWrapper: wrapper)
          }
        )  // sheet
    }  // NavigationStack
  }
}

#Preview {
  RacesView()
    .environment(UserManager())
}
