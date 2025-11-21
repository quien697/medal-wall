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
  @State private var isShowFilterView = false
  @State private var filter: RaceFilter = .default
  
  @Query(sort: \Race.date, animation: .default) private var races: [Race]
  
  var body: some View {
    let viewModel = RacesViewModel(races: races, filter: filter)
    
    NavigationSplitView {
      List(viewModel.visibleRaces, selection: $selectedRace) { race in
        NavigationLink(value: race) {
          RaceRowView(race: race)
        }
      }
      .navigationTitle("Races")
      .searchable(text: $filter.searchQuery, prompt: "Find a race event")
      .autocorrectionDisabled()
      .animation(.default, value: filter.searchQuery)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button("Filter", systemImage: "slider.horizontal.3") {
            isShowFilterView = true
          }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
          Button("Add Race", systemImage: "plus") {
            isShowAddView = true
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
        RaceAddView(viewModel: RaceEditViewModel(
          race: selectedRace, context: modelContext)
        )
      }
      .sheet(isPresented: $isShowFilterView) {
        RaceFilterView(filter: $filter)
      }
    } detail: {
      if let race = selectedRace {
        RaceDetailView(viewModel: RaceDetailViewModel(race: race))
      } else {
        Text("Select a race")
      }
    } // NavigationSplitView
  }
}

#Preview(traits: .sampleData) {
  RacesView()
}
