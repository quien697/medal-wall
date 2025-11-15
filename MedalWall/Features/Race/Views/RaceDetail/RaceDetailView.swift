//
//  RaceDetailView.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import SwiftUI
import SwiftData

struct RaceDetailView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  @State private var isShowEditor = false
  @State private var isShowDeleteConfirm = false
  @State private var errorWrapper: ErrorWrapper?
  @State var viewModel: RaceDetailViewModel
  
  var body: some View {
    ScrollView {
      RaceHeroCardSection(race: viewModel.race)
      
      RaceDetailCardSection(viewModel: viewModel)
      
      RaceLastUpdatedCardSection(race: viewModel.race)
    } // ScrollView
    .padding(.horizontal)
    .background(.ultraThinMaterial)
    .navigationTitle(viewModel.race.name)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Menu("More Options", systemImage: "ellipsis") {
          Button {
            isShowEditor = true
          } label: {
            Label("Edit Race", systemImage: "square.and.pencil")
          }
          
          Divider()
          
          Button(role: .destructive) {
            isShowDeleteConfirm = true
          } label: {
            Label("Delete Race", systemImage: "trash")
          }
        } // Menu
      } // ToolbarItem
    } // toolbar
    .sheet(isPresented: $isShowEditor) {
      NavigationStack {
        RaceEditView(viewModel: RaceEditViewModel(
          race: viewModel.race, context: modelContext))
      }
    } // sheet
    .sheet(item: $errorWrapper, onDismiss: nil) { wrapper in
      ErrorView(errorWrapper: wrapper)
    } // sheet
    .alert("Delete \(viewModel.race.name)?", isPresented: $isShowDeleteConfirm) {
      Button("Delete", role: .destructive) {
        do {
          modelContext.delete(viewModel.race)
          try modelContext.save()
          dismiss()
        } catch {
          errorWrapper = ErrorWrapper(error: error, guidance: "Race event couldn't be deleted. Try again later.")
        }
      }
      Button("Cancel", role: .cancel) { }
    } message: {
      Text("This action cannot be undone.")
    }
  }
}

#Preview(traits: .sampleData) {
  @Previewable @Query(sort: \Race.date) var races: [Race]
  
  RaceDetailView(viewModel: RaceDetailViewModel(race: races[0]))
}
