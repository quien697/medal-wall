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
  
  @Query private var races: [Race]
  
  var body: some View {
    NavigationSplitView {
      List(races, selection: $selectedRace) { race in
        NavigationLink(value: race) {
          HStack {
            Image(race.photo ?? "")
              .resizable()
              .scaledToFit()
              .frame(width: 60, height: 60)
              .clipShape(.rect(cornerRadius: 10))
            
            VStack(alignment: .leading) {
              Text(race.name)
                .font(.headline)
              
              Text(race.location.formatted)
                .font(.subheadline)
                .foregroundStyle(.secondary)
              
              Text(race.date.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
            }
          }
        }
      }
      .navigationTitle("Races")
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button("Add Race", systemImage: "plus") {
            isShowAddView.toggle()
          }
        }
      }
      .sheet(isPresented: $isShowAddView) {
        RaceAddView(viewModel: RaceEditViewModel(
          race: selectedRace, context: modelContext)
        )
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
