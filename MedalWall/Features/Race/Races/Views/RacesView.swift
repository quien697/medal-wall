//
//  RacesView.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import SwiftUI
import SwiftData

struct RacesView: View {
  // MARK: - Environment
  @Environment(\.modelContext) private var modelContext
  // MARK: - State
  @State private var viewModel: RacesViewModel = RacesViewModel()
  @State private var errorWrapper: ErrorWrapper?
  @State private var selectedRace: Race? = nil
  @State private var isPresentingAddRace: Bool = false
  @State private var isPresentingDeleteConfirm = false
  // MARK: - Namespace
  @Namespace private var namespace
  private let addRace: String = "addRace"
  
  var body: some View {
    NavigationStack {
      RaceList(
        searchText: viewModel.searchText,
        predicate: viewModel.predicate,
        sortOrder: viewModel.sortOrder,
        applyFilter: viewModel.filteredRaces
      ) { race in
        selectedRace = race
        isPresentingDeleteConfirm = true
      }
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
        }
        
        ToolbarItem(placement: .topBarTrailing) {
          Menu {
            Picker("Sort", selection: $viewModel.sortOrder) {
              ForEach(RaceSort.allCases, id: \.self) { sort in
                Text("Sort by \(sort.displayName)")
                  .tag(sort.order)
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
                  Label(category.description, systemImage: viewModel.selectedCategories.contains(category) ? "checkmark.square" : "square")
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
                  Label(type.displayName, systemImage: viewModel.selectedTypes.contains(type) ? "checkmark.square" : "square")
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
      }
      .onAppear {
        viewModel.configure(context: modelContext)
      }
      .sheet(isPresented: $isPresentingAddRace) {
        AddRaceView()
          .navigationTransition(.zoom(sourceID: addRace, in: namespace))
      }
      .alert(isPresented: $isPresentingDeleteConfirm) {
        .deleteConfirmation(
          name: selectedRace?.name ?? "Race",
          onDelete: {
            if let race = selectedRace {
              do {
                try viewModel.deleteRace(race)
              } catch {
                errorWrapper = ErrorWrapper(error: AppError.raceDeleteFailed)
              }
            }
          }
        )
      } // alert
      .sheet(item: $errorWrapper, onDismiss: nil) { wrapper in
        ErrorView(errorWrapper: wrapper)
      } // sheet
    } // NavigationStack
  }
}

#Preview(traits: .sampleData) {
  RacesView()
}
