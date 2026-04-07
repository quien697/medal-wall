//
//  MedalDetailView.swift
//  MedalWall
//
//  Created by Quien on 2025-12-24.
//

import SwiftUI
import SwiftData

struct MedalDetailView: View {
  // MARK: - Environment
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  // MARK: - State
  @State private var isShowEditor = false
  @State private var isShowDeleteConfirm = false
  @State private var errorWrapper: ErrorWrapper?
  @State private var viewModel: MedalDetailViewModel
  
  // MARK: - Init
  init(medal: Medal) {
    self._viewModel = State(initialValue: MedalDetailViewModel(medal: medal))
  }

  // MARK: - Body
  var body: some View {
    ScrollView {
      MedalDetailHeroSection(
        photo: viewModel.medal.cropPhoto ?? viewModel.medal.photo,
        name: viewModel.medal.name,
        raceDistance: viewModel.medal.distance.category.description,
        raceDistanceType: viewModel.medal.distance.type.displayName,
        location: viewModel.medal.location.formatted,
        date: viewModel.medal.date.formattedMonthDayYear(),
        bib: viewModel.medal.bibNumber
      )

     MedalDetailStatsSection(
      columns: viewModel.gridColumns,
      spacing: viewModel.gridSpacing,
      finishTime: viewModel.finishTimeText,
      averagePace: viewModel.averagePaceText,
      overallPlacement: viewModel.overallPlacementText,
      totalParticipants: viewModel.totalParticipantsText,
      division: viewModel.divisionText,
      divisionPlacement: viewModel.divisionPlacementText,
      divisionTotal: viewModel.divisionTotalText,
      genderPlacement: viewModel.genderPlacementText,
      genderTotal: viewModel.genderTotalText
     )

      if let note = viewModel.medal.note, !note.isEmpty {
        MedalDetailNoteSection(note: note)
      }
      
//      MedalDetailEventPhotosSection(photots: viewModel.medal.eventPhotos)
      
//      MedalDetailTagsSection()
    }
    .navigationTitle(viewModel.medal.name)
    .navigationBarTitleDisplayMode(.inline)
    .background(Color.Background.primary)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Menu("More Options", systemImage: "ellipsis") {
          Button {
            isShowEditor = true
          } label: {
            Label("Edit Medal", systemImage: "square.and.pencil")
          }

          Divider()

          Button(role: .destructive) {
            isShowDeleteConfirm = true
          } label: {
            Label("Delete Medal", systemImage: "trash")
          }
        }
      }
    }
//    .alert(isPresented: $isShowDeleteConfirm) {
//      .deleteConfirmation(name: viewModel.medal.title, onDelete: {
//        do {
//          try viewModel.configure(context: modelContext)
//          try viewModel.deleteMedal(viewModel.medal)
//          dismiss()
//        } catch {
//          errorWrapper = ErrorWrapper(error: AppError.unknown)
//        }
//      })
//    }
//    .sheet(isPresented: $isShowEditor) {
//      NavigationStack {
//        MedalEditView(medal: viewModel.medal)
//      }
//    }
//    .sheet(item: $errorWrapper, onDismiss: nil) { wrapper in
//      ErrorView(errorWrapper: wrapper)
//    }
  }
}

#Preview {
  NavigationStack {
    MedalDetailView(medal: Medal.sampleData.first!)
  }
}
