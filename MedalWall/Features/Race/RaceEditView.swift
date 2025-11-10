//
//  RaceEditView.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import SwiftUI
import SwiftData

struct RaceEditView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  @State private var newRaceDistance = RaceDistance.default
  @State private var isShowRaceDistanceAddView = false
  @State var viewModel: RaceEditViewModel
  
  var body: some View {
    Form {
      Section("Race Info") {
        TextField("Race Name", text: $viewModel.name)
        TextField("Race Photo (option)", text: $viewModel.photo)
        DatePicker("Date", selection: $viewModel.date, displayedComponents: .date)
      } // Section
      
      Section("Race Location") {
        TextField("Country", text: $viewModel.country)
        TextField("Province (option)", text: $viewModel.province)
        TextField("City", text: $viewModel.city)
        TextField("District (option)", text: $viewModel.district)
      } // Section
      
      Section("Race Distance") {
        ForEach(viewModel.distances.enumerated(), id: \.element.id) { index, distance in
          NavigationLink {
            NavigationStack {
              RaceDistanceEditView(distance: $viewModel.distances[index])
            }
          } label: {
            HStack {
              Image(systemName: "figure.run")
                .padding(8)
                .background(distance.category.color)
                .clipShape(.circle)
              
              Text(distance.category.description)
              
              Spacer()
              
              Text(distance.type.displayName)
            }
          }
        }
        .onDelete { indices in
          print("delete = \(indices)")
        }
        
        Button {
          withAnimation {
            isShowRaceDistanceAddView = true
          }
        } label: {
          HStack {
            Image(systemName: "plus")
              .padding(8)
              .clipShape(.circle)
            
            Text("Add distance")
          }
        }
      } // Section
      
      Section("Additional Details") {
        TextField("Official Website (option)", text: $viewModel.url)
          .keyboardType(.URL)
          .textInputAutocapitalization(.never)
      } // Section
    } // Form
    .navigationTitle("\(viewModel.isNewRace ? "Add" : "Edit") Race")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button("Cancel") {
          dismiss()
        }
      } // ToolbarItem
      
      ToolbarItem(placement: .confirmationAction) {
        Button(viewModel.isNewRace ? "Add" : "Save") {
          do {
            try viewModel.save()
            dismiss()
          } catch {
            print("Error saving race: \(error)")
          }
        }
        .disabled(!viewModel.isFormValid)
      } // ToolbarItem
    } // toolbar
    .sheet(isPresented: $isShowRaceDistanceAddView) {
      NavigationStack {
        RaceDistanceAddView(distance: $newRaceDistance)
          .toolbar {
            ToolbarItem(placement: .cancellationAction) {
              Button("Cancel") {
                isShowRaceDistanceAddView = false
              }
            }
            ToolbarItem(placement: .confirmationAction) {
              Button("Add") {
                viewModel.distances.append(newRaceDistance)
                isShowRaceDistanceAddView = false
              }
            }
          }
      }
    }
  }
}

#Preview(traits: .sampleData) {
  @Previewable @Query(sort: \Race.date) var races: [Race]
  let context = try! ModelContext(SampleData.makeSharedContext())
  NavigationStack {
    RaceEditView(viewModel: RaceEditViewModel(race: races[0], context: context))
  }
}
