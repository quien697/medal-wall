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
      .toolbar {
        ToolbarItem(placement: .title) {
          ExpandedNavigationTitle(title: "Races")
        } // ToolbarItem
        
        ToolbarItem(placement: .topBarTrailing) {
          Menu {
            Picker("Sort", selection: $viewModel.selectedSort) {
              ForEach(RaceSort.allCases, id: \.self) { sort in
                Text("Sort by \(sort.displayName)")
                  .tag(sort)
              } // ForEach
            } // Picker
            
            Section("Filter by Race Distance") {
              ForEach(RaceDistanceCategory.standardCases, id: \.self) { category in
                Button {
                  if viewModel.selectedCategories.contains(category) {
                    viewModel.selectedCategories.remove(category)
                  } else {
                    viewModel.selectedCategories.insert(category)
                  }
                } label: {
                  Label(
                    category.description,
                    systemImage: viewModel.selectedCategories.contains(category) ? "checkmark.square" : "square"
                  )
                } // Button
              } // ForEach
            } // Section
            
            Section("Filter by Race Type") {
              ForEach(RaceDistanceType.allCases, id: \.self) { type in
                Button {
                  if viewModel.selectedTypes.contains(type) {
                    viewModel.selectedTypes.remove(type)
                  } else {
                    viewModel.selectedTypes.insert(type)
                  }
                } label: {
                  Label(
                    type.displayName,
                    systemImage: viewModel.selectedTypes.contains(type) ? "checkmark.square" : "square"
                  )
                } // Button
              } // ForEach
            } // Section
          } label: {
            Label("Filter", systemImage: "line.3.horizontal.decrease")
          } // Menu
          .menuActionDismissBehavior(.disabled)
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
      .overlay {
        if viewModel.isLoading {
          ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.1))
        }
      }
      .task {
        if let uid = userManager.currentUserID {
          await viewModel.loadRaces(uid: uid)
        }
      }
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
      .sheet(isPresented: $isPresentingAddRace) {
        Text("Coming soon")
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
