//
//  RacesView.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import SwiftUI
import SwiftData

struct RacesView: View {
  @Environment(\.modelContext) private var modelContext
  @State private var isShowAddView: Bool = false
  @State private var selectedRace: Race? = nil
  @State private var isShowDeleteConfirm = false
  @State private var viewModel: RacesViewModel = RacesViewModel()
  @State private var errorWrapper: ErrorWrapper?
  
  var body: some View {
    RaceListView(
      searchText: viewModel.searchText,
      predicate: viewModel.predicate,
      sortOrder: viewModel.sortOrder,
      applyFilter: viewModel.filteredRaces
    ) { race in
      selectedRace = race
      isShowDeleteConfirm = true
    }
    .navigationTitle("Races")
    .searchable(text: $viewModel.searchText, prompt: "Search race events...")
    .autocorrectionDisabled()
    .toolbar {
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
        Button("Add Race", systemImage: "plus") {
          isShowAddView = true
        }
      } // ToolbarItem
    }
    .onAppear {
      viewModel.configure(context: modelContext)
    }
    .sheet(isPresented: $isShowAddView) {
      RaceAddView()
    }
    .alert(isPresented: $isShowDeleteConfirm) {
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
  }
}

#Preview(traits: .sampleData) {
  RacesView()
}
