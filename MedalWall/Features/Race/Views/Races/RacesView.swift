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
  @State private var selectedRace: Race? = nil
  @State private var isShowAddView = false
  @State private var isShowDeleteConfirm = false
  @State private var isShowFilterView = false
  @State private var filter: RaceFilter = .default
  @State private var errorWrapper: ErrorWrapper?
  
  @Query(sort: \Race.date, animation: .default) private var races: [Race]
  
  var body: some View {
    let viewModel = RacesViewModel(races: races, filter: filter)
    
    Group {
      if viewModel.races.isEmpty {
        ContentUnavailableView {
          Label("No Race Events", systemImage: "figure.run")
        } description: {
          Text("There aren't any race events yet.")
        }
      } else {
        if viewModel.visibleRaces.isEmpty {
          ContentUnavailableView {
            Label("No Results", systemImage: "magnifyingglass")
          } description: {
            Text("No rsults found")
          }
        } else {
          List(viewModel.visibleRaces, selection: $selectedRace) { race in
            NavigationLink {
              RaceDetailView(race: race)
            } label: {
              RaceRowView(race: race)
                .swipeActions(edge: .trailing) {
                  Button(role: .destructive) {
                    selectedRace = race
                    isShowDeleteConfirm = true
                  } label: {
                    Label("Delete", systemImage: "trash")
                  }
                }
            }
          }
          .animation(.default, value: viewModel.visibleRaces)
        }
      }
    } // Group
    .navigationTitle("Races")
    .searchable(text: $filter.searchQuery, prompt: "Find a race event")
    .autocorrectionDisabled()
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button("Add Race", systemImage: "plus") {
          isShowAddView = true
        }
      }
      
      ToolbarItem(placement: .topBarTrailing) {
        Button("Filter", systemImage: "ellipsis") {
          isShowFilterView = true
        }
      }
    }
    .onAppear {
      viewModel.races = races
    }
    .onChange(of: races) {
      viewModel.races = races
    }
    .sheet(isPresented: $isShowAddView) {
      RaceAddView()
    }
    .sheet(isPresented: $isShowFilterView) {
      NavigationStack {
        RaceFilterView(filter: $filter)
      }
    }
    .alert(isPresented: $isShowDeleteConfirm) {
      .deleteConfirmation(
        name: selectedRace?.name ?? "Race",
        onDelete: {
          if let race = selectedRace {
            do {
              try viewModel.attachContext(modelContext)
              try viewModel.deleteRace(race)
            } catch {
              errorWrapper = ErrorWrapper(error: AppError.raceDeleteFailed)
            }
          }
        }
      )
    } // alert
  }
}

#Preview(traits: .sampleData) {
  RacesView()
}
