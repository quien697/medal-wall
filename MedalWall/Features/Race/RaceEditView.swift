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
  @State var viewModel: RaceEditViewModel

  var body: some View {
    NavigationStack {
      Form {
        Section("Race Info") {
          TextField("Race Name", text: $viewModel.name)
          DatePicker("Date", selection: $viewModel.date, displayedComponents: .date)
        }
        
        Section("Race Location") {
          TextField("Country", text: $viewModel.country)
          TextField("Province (option)", text: $viewModel.province)
          TextField("City", text: $viewModel.city)
          TextField("District (option)", text: $viewModel.district)
        }
        
        Section("Additional Details") {
          TextField("Official Website (option)", text: $viewModel.url)
            .keyboardType(.URL)
            .textInputAutocapitalization(.never)
        }
      }
      .navigationTitle("\(viewModel.isNewRace ? "Add" : "Edit") Race")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button("Cancel") {
            dismiss()
          }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
          Button("Save") {
            do {
              try viewModel.save()
              dismiss()
            } catch {
              print("Error saving race: \(error)")
            }
          }
          .disabled(!viewModel.isFormValid)
        }
      }
    }
  }
}

#Preview(traits: .sampleData) {
  @Previewable @Query(sort: \Race.date) var races: [Race]
  let context = try! ModelContext(SampleData.makeSharedContext())
  RaceEditView(viewModel: RaceEditViewModel(race: races[0], context: context))
}
