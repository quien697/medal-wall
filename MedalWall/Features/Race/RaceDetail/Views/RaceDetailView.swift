//
//  RaceDetailView.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import SwiftUI
import SwiftData

struct RaceDetailView: View {
  // MARK: - Environment
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  // MARK: - State
  @State private var viewModel: RaceDetailViewModel
  @State private var errorWrapper: ErrorWrapper?
  @State private var isPresentingEditRace = false
  @State private var isPresentingDeleteRaceConfirm = false
  
  // MARK: - Init
  init(race: Race) {
    self._viewModel = State(initialValue: RaceDetailViewModel(race: race))
  }
  
  // MARK: - Body
  var body: some View {
    VStack {
      RaceDetailHeroSection(
        photo: viewModel.race.cropPhoto ?? viewModel.race.photo,
        name: viewModel.race.name,
        location: viewModel.race.location.formatted,
        url: viewModel.race.url
      )
      
      ScrollView {
        RaceDetailEditionsSection(editions: viewModel.race.editions)
      }
    } // VStack
    .background(Color.Background.primary)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Menu("More Options", systemImage: "ellipsis") {
          Button {
            isPresentingEditRace = true
          } label: {
            Label("Edit Race", systemImage: "square.and.pencil")
          }
          
          Divider()
          
          Button(role: .destructive) {
            isPresentingDeleteRaceConfirm = true
          } label: {
            Label("Delete Race", systemImage: "trash")
          }
        } // Menu
      } // ToolbarItem
    } // toolbar
    .onAppear {
      viewModel.configure(context: modelContext)
    }
    .alert(isPresented: $isPresentingDeleteRaceConfirm) {
      .deleteConfirmation(
        name: viewModel.race.name,
        onDelete: {
          do {
            try viewModel.deleteRace(viewModel.race)
            dismiss()
          } catch {
            errorWrapper = ErrorWrapper(error: AppError.raceDeleteFailed)
          }
        }
      )
    }
    .sheet(isPresented: $isPresentingEditRace) {
      NavigationStack {
        EditRaceView(mode: .edit, race: viewModel.race)
      }
    } // sheet
    .sheet(item: $errorWrapper, onDismiss: nil) { wrapper in
      ErrorView(errorWrapper: wrapper)
    } // sheet
  }
}

#Preview {
  NavigationStack {
    RaceDetailView(race: Race.sampleData.first!)
  }
}
