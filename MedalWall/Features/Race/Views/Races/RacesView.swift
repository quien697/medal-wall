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
      sortOrder: viewModel.sortOrder
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
            Text("Sort by Name")
              .tag(RaceSort.name.order)
            
            Text("Sort by Country")
              .tag(RaceSort.country.order)
          }
        } label: {
          Label("Filter", systemImage: "line.3.horizontal.decrease")
        }
      }
      
      ToolbarItem(placement: .topBarTrailing) {
        Button("Add Race", systemImage: "plus") {
          isShowAddView = true
        }
      }
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
