//
//  RacesView.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import SwiftUI

struct RacesView: View {
  // MARK: - Environment
  @Environment(UserManager.self) private var userManager
  
  // MARK: - State
  @State private var viewModel: RacesViewModel = RacesViewModel()
  @State private var errorWrapper: ErrorWrapper?
  @State private var selectedRace: Race?
  @State private var isPresentingAddRace = false
  @State private var isPresentingDeleteConfirm = false
  
  // MARK: - Namespace
  @Namespace private var namespace
  private let addRace = "addRace"
  
  // MARK: - Body
  var body: some View {
    NavigationStack {
      RaceList(
        races: viewModel.filteredRaces,
        searchText: viewModel.searchText,
        onDelete: { race in
          selectedRace = race
          isPresentingDeleteConfirm = true
        }
      )
      .scrollIndicators(.hidden)
      .navigationTitle("Races")
      .background(Color.Background.primary)
      .toolbarTitleDisplayMode(.inlineLarge)
      .toolbarRole(.editor)
      .searchable(text: $viewModel.searchText, prompt: "Search race events...")
      .autocorrectionDisabled()
      .overlay {
        if viewModel.isLoading {
          ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.1))
        }
      }
      .task {
        await viewModel.loadRaces()
      }
      .toolbar {
        ToolbarItem(placement: .title) {
          ExpandedNavigationTitle(title: "Races")
        } // ToolbarItem
        
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            isPresentingAddRace = true
          } label: {
            Image(systemName: "plus")
          }
          .matchedTransitionSource(id: addRace, in: namespace)
          .buttonStyle(.glassProminent)
        } // ToolbarItem
      } // toolbar
      .alert(isPresented: $isPresentingDeleteConfirm) {
        .deleteConfirmation(
          name: selectedRace?.name ?? "Race",
          onDelete: {
            if let race = selectedRace {
              Task { await viewModel.deleteRace(race) }
            }
          }
        )
      } // alert
      .onChange(of: viewModel.error) { _, error in
        if let error {
          errorWrapper = ErrorWrapper(error: error)
        }
      }
      .sheet(isPresented: $isPresentingAddRace, onDismiss: {
        Task {
          await viewModel.loadRaces()
        }
      }) {
        EditRaceView(mode: .add)
          .navigationTransition(.zoom(sourceID: addRace, in: namespace))
      }
      .sheet(item: $errorWrapper, onDismiss: { viewModel.error = nil }) { wrapper in
        ErrorView(errorWrapper: wrapper)
      } // sheet
    } // NavigationStack
  }
}

#Preview {
  RacesView()
    .environment(UserManager())
}
