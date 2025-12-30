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
  @State private var viewModel: RaceDetailViewModel
  
  init(race: Race) {
    self._viewModel = State(initialValue: RaceDetailViewModel(race: race))
  }
  
  var body: some View {
    ScrollView {
      RaceHeroCardSection(race: viewModel.race)
      
      RaceDetailCardSection(race: viewModel.race)
      
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
    .alert(isPresented: $isShowDeleteConfirm) {
      .deleteConfirmation(
        name: viewModel.race.name,
        onDelete: {
          do {
            try viewModel.attachContext(modelContext)
            try viewModel.deleteRace(viewModel.race)
            dismiss()
          } catch {
            errorWrapper = ErrorWrapper(error: AppError.raceDeleteFailed)
          }
        }
      )
    }
    .sheet(isPresented: $isShowEditor) {
      NavigationStack {
        RaceEditView(race: viewModel.race)
      }
    } // sheet
    .sheet(item: $errorWrapper, onDismiss: nil) { wrapper in
      ErrorView(errorWrapper: wrapper)
    } // sheet
  }
}

#Preview(traits: .sampleData) {
  RaceDetailView(race: Race.sampleData.first!)
}
