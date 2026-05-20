//
//  RaceDetailView.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import SwiftUI

struct RaceDetailView: View {
  // MARK: - Environment
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
        photoUrl: viewModel.race.photoUrl,
        name: viewModel.race.name,
        location: viewModel.race.location.formatted,
        url: viewModel.race.fullWebsiteUrl
      )
      
      ScrollView {
        RaceDetailEditionsSection(editions: viewModel.editions)
      }
    } // VStack
    .background(Color.Background.primary)
    .overlay {
      if viewModel.isLoading {
        ProgressView()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .background(Color.black.opacity(0.1))
      }
    }
    .task {
      await viewModel.loadEditions()
    }
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
    .alert(isPresented: $isPresentingDeleteRaceConfirm) {
      .deleteConfirmation(
        name: viewModel.race.name,
        onDelete: {
          Task {
            await viewModel.deleteRace()
            if viewModel.error == nil {
              dismiss()
            }
          }
        }
      )
    }
    .onChange(of: viewModel.error) { _, error in
      if let error {
        errorWrapper = ErrorWrapper(error: error)
      }
    }
    .sheet(isPresented: $isPresentingEditRace, onDismiss: {
      Task {
        await viewModel.loadRace()
      }
    }) {
      EditRaceView(mode: .edit, race: viewModel.race)
    } // sheet
    .sheet(item: $errorWrapper, onDismiss: { viewModel.error = nil }) { wrapper in
      ErrorView(errorWrapper: wrapper)
    } // sheet
  }
}

#Preview {
  NavigationStack {
    RaceDetailView(race: Race.sampleData.first!)
  }
}
